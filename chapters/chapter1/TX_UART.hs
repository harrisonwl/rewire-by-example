{-# LANGUAGE DataKinds #-}

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

    -- localparam IDLE = 2'b00;
    -- localparam START_BIT = 2'b01;
    -- localparam DATA_BITS = 2'b10;
    -- localparam STOP_BIT = 2'b11;

_IDLE , _START_BIT , _DATA_BITS , _STOP_BIT :: W 2
_IDLE      = lit 0
_START_BIT = lit 1
_DATA_BITS = lit 2
_STOP_BIT  = lit 3

    -- output reg tx_pin,
    -- output reg tx_done

    -- reg [1:0] state;
    -- reg [15:0] clk_count;
    -- reg [2:0] bit_index;
    -- reg [7:0] data_reg;

-- data O = O { tx_pin   :: Bit
--            , tx_done  :: Bit }

data RF = RF { state     :: W 2
             , clk_count :: W 16
             , bit_index :: W 3
             , data_reg  :: W 8
             , tx_pin    :: Bit
             , tx_done   :: Bit }           

            -- state <= IDLE;
            -- tx_pin <= 1'b1;
            -- tx_done <= 1'b0;
            -- clk_count <= 0;
            -- bit_index <= 0;

reset :: StateT RF Identity ()
reset = put $ RF { state     = _IDLE
                 , tx_pin    = True
                 , tx_done   = False
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

loop i = if rst i then
            do
              lift reset
              click
         else
            click
            
    
