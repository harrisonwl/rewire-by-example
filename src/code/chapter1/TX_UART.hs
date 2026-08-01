{-# LANGUAGE DataKinds #-}

import Prelude hiding ((-) , (<) , (+))
import ReWire
import ReWire.Bits
import ReWire.Finite
import ReWire.Vectors

-- This version of the uart_tx from rtl_uart.sv is meant to
-- reflect that version very closely. I.e., everything but the
-- clock clk signal.

    -- input clk,
    -- input rst,
    -- input tx_start,
    -- input [7:0] tx_data,

data I = I { rst      :: Bit
           , tx_start :: Bit
           , tx_data  :: W 8 }

i0 :: I
i0 = I { rst = True
       , tx_start = False
       , tx_data  = lit 0
       }

data State = IDLE | START_BIT | DATA_BITS | STOP_BIT 

    -- output reg tx_pin,
    -- output reg tx_done

    -- reg [1:0] state;
    -- reg [15:0] clk_count;
    -- reg [2:0] bit_index;
    -- reg [7:0] data_reg;

--    parameter CLKS_PER_BIT = 868 // e.g., 100MHz clock / 115200 baud

_CLKS_PER_BIT :: W 16
_CLKS_PER_BIT = lit 868

data RF = RF { state     :: State
             , clk_count :: W 16
             , bit_index :: W 3
             , data_reg  :: W 8
             , tx_pin    :: Bit
             , tx_done   :: Bit }           

rf0 :: RF
rf0 = RF { state     = IDLE
         , clk_count = lit 0
         , bit_index = lit 0
         , data_reg  = lit 0
         , tx_pin    = True
         , tx_done   = False
         }

            -- state <= IDLE;
            -- tx_pin <= 1'b1;
            -- tx_done <= 1'b0;
            -- clk_count <= 0;
            -- bit_index <= 0;

reset :: StateT RF Identity ()
reset = put $ RF { state     = IDLE
                 , tx_pin    = True
                 , tx_done   = False
                 , data_reg  = lit 0
                 , clk_count = lit 0
                 , bit_index = lit 0 }

-- |
-- | click defines the end of a clock cycle
-- |
click :: ReacT I (Bit , Bit) (StateT RF Identity) I
click = do
          rf <- lift get
          let o = (tx_pin rf , tx_done rf)
          signal o

idle :: I -> StateT RF Identity ()
idle i = do
           rf <- get
           let tx_s = tx_start i
           put $ rf { state     = if tx_s then START_BIT else IDLE
                    , tx_pin    = True
                    , tx_done   = False
                    , clk_count = lit 0
                    , bit_index = lit 0
                    , data_reg  = if tx_s then tx_data i else data_reg rf
                    }

                -- IDLE: begin
                --     tx_pin <= 1'b1;
                --     tx_done <= 1'b0;
                --     clk_count <= 0;
                --     bit_index <= 0;
                --                    
                --     if (tx_start) begin
                --         data_reg <= tx_data;
                --         state <= START_BIT;
                --     end
                -- end

start_bit :: StateT RF Identity ()
start_bit   = do
                rf <- get
                let cc = clk_count rf < _CLKS_PER_BIT - lit 1
                put $ rf { state     = if cc then START_BIT else DATA_BITS
                         , tx_pin    = False
                         , clk_count = if cc then clk_count rf + lit 1 else lit 0
                         }
                  
                -- START_BIT: begin
                --     tx_pin <= 1'b0; // Start bit
                --     if (clk_count < CLKS_PER_BIT - 1) begin
                --         clk_count <= clk_count + 1;
                --     end else begin
                --         clk_count <= 0;
                --         state <= DATA_BITS;
                --     end
                -- end

data_bits :: StateT RF Identity ()
data_bits   = do
                rf <- get
                let tx_pin' = (data_reg rf) `index` (toFinite $ bit_index rf)
                let ccc     = clk_count rf < _CLKS_PER_BIT - lit 1
                let bic     = bit_index rf < lit 7
                put $ rf { state     = if not (ccc || bic) then STOP_BIT else DATA_BITS
                         , tx_pin    = tx_pin'
                         , bit_index = if ccc then bit_index rf
                                         else if not ccc && bic 
                                                then bit_index rf + lit 1
                                                else lit 0
                         , clk_count = if ccc then clk_count rf + lit 1 else lit 0
                         }

                -- DATA_BITS: begin
                --     tx_pin <= data_reg[bit_index];
                --     if (clk_count < CLKS_PER_BIT - 1) begin
                --         clk_count <= clk_count + 1;
                --     end else begin
                --         clk_count <= 0;
                --         if (bit_index < 7) begin
                --             bit_index <= bit_index + 1;
                --         end else begin
                --             bit_index <= 0;
                --             state <= STOP_BIT;
                --         end
                --     end
                -- end

stop_bit :: StateT RF Identity ()
stop_bit   = do
                rf <- get
                let ccc = clk_count rf < _CLKS_PER_BIT - lit 1
                put $ rf { state     = if ccc then STOP_BIT else IDLE
                         , tx_pin    = True
                         , tx_done   = if ccc then tx_done rf else True
                         , clk_count = if ccc then clk_count rf + lit 1 else lit 0
                         }
                -- STOP_BIT: begin
                --     tx_pin <= 1'b1; // Stop bit
                --     if (clk_count < CLKS_PER_BIT - 1) begin
                --         clk_count <= clk_count + 1;
                --     end else begin
                --         clk_count <= 0;
                --         tx_done <= 1'b1;
                --         state <= IDLE;
                --     end
                -- end

loop :: I -> ReacT I (Bit, Bit) (StateT RF Identity) I
loop i = if rst i then
            do
              lift reset
              i' <- click
              loop i'
         else
            do
              rf <- lift get
              let st = state rf
              case st of
                IDLE      -> do
                                lift $ idle i
                                i' <- click
                                loop i'
                START_BIT -> do
                                lift $ start_bit
                                i' <- click
                                loop i'
                DATA_BITS -> do
                                lift $ data_bits
                                i' <- click
                                loop i'
                STOP_BIT  -> do
                                lift $ stop_bit
                                i' <- click
                                loop i'

body :: I -> ReacT I (Bit, Bit) (StateT RF Identity) I
body i = if rst i then
            do
              lift reset
              click
         else
            do
              rf <- lift get
              let st = state rf
              case st of
                IDLE      -> do
                                lift $ idle i
                                click
                START_BIT -> do
                                lift $ start_bit
                                click
                DATA_BITS -> do
                                lift $ data_bits
                                click
                STOP_BIT  -> do
                                lift $ stop_bit
                                click


              
start :: ReacT I (Bit , Bit) Identity I
start = extrude (loop i0) rf0
