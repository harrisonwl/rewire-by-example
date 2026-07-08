{-# LANGUAGE DataKinds #-}

import ReWire
import ReWire.Bits
import ReWire.Finite
import ReWire.Vectors

    -- uart_tx inputs
    -- input clk,
    -- input rst,
    -- input tx_start,
    -- input [7:0] tx_data,

-- | Implicitly, receiving a data word signals "start"
-- | [9] in Cryptol
data I = TX_DATA (W 8)
       | Nop
-- TX_START

    -- output reg tx_pin,
    -- output reg tx_done
      
type O = ( Bit   -- tx_pin
         , Bit ) -- tx_done

-- data S = S { tx_pin   :: Bit
--            , tx_done  :: Bit
--            , data_reg :: W 8 }

-- rw__Pure_dispatch : [14] -> [9] -> [22]

type S = (Bit , Bit , W 8)

tx_pin , tx_done :: S -> Bit
tx_pin (tp , _ , _) = tp
tx_done (_ , td , _) = td

data_reg :: S -> W 8
data_reg (_ , _ , dr) = dr

clrTX_PIN , clrTX_Done , setTX_PIN :: StateT S Identity ()
setTX_PIN  = modify (\ (_ , td , dr) -> (True , td , dr))
clrTX_PIN  = modify (\ (_ , td , dr) -> (False , td , dr)) 
clrTX_Done = modify (\ (tp , _ , dr) -> (tp , False , dr))

setDR :: W 8 -> StateT S Identity ()
setDR w    = modify (\ (tp , td , _) -> (tp , td , w))

getDR :: StateT S Identity (W 8)
getDR = get >>= return . data_reg 

genout :: ReacT I O (StateT S Identity) I
genout = do
           s <- lift get
           signal (tx_pin s , tx_done s)

out_pin :: Finite 8 -> StateT S Identity ()
out_pin i = do
              (_ , td , dr) <- get
              put (dr `index` i , td , dr)

idle , data_bits :: I -> ReacT I O (StateT S Identity) ()
idle Nop          = do
                      lift setTX_PIN
                      lift clrTX_Done
                      i <- genout
                      idle i
-- | eliminated the explicit start state.
-- idle TX_START     = do
--                       lift clrTX_PIN
--                       i <- genout
--                       data_bits i
idle (TX_DATA w8) = do
                      lift clrTX_PIN
                      lift (setDR w8)
                      i <- genout
                      data_bits i                      

data_bits _   = do
                  lift (out_pin (finite 0))
                  genout
                  lift (out_pin (finite 1))
                  genout
                  lift (out_pin (finite 2))
                  genout
                  lift (out_pin (finite 3))
                  genout
                  lift (out_pin (finite 4))
                  genout
                  lift (out_pin (finite 5))
                  genout
                  lift (out_pin (finite 6))
                  genout
                  lift (out_pin (finite 7))
                  i <- genout
                  idle i

s0 :: S
s0 = (True , False , lit 0)

start :: ReacT I O Identity ()
start = extrude (idle Nop) s0
                  
