{-# LANGUAGE DataKinds #-}

import ReWire hiding (lift, signal , put , get , modify)
import ReWire.Bits
import ReWire.Finite
import ReWire.Vectors

import ReWire.Interactive (xshow,pp,bshow)
import ExtensionalSemantics

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

-- clrTX_PIN , clrTX_Done , setTX_PIN :: StateT S Identity ()
clrTX_PIN , clrTX_Done , setTX_PIN :: ST S ()
setTX_PIN  = modify (\ (_ , td , dr) -> (True , td , dr))
clrTX_PIN  = modify (\ (_ , td , dr) -> (False , td , dr)) 
clrTX_Done = modify (\ (tp , _ , dr) -> (tp , False , dr))

-- setDR :: W 8 -> StateT S Identity ()
setDR :: W 8 -> ST S ()
setDR w    = modify (\ (tp , td , _) -> (tp , td , w))

-- getDR :: StateT S Identity (W 8)
getDR :: ST S (W 8)
getDR = get >>= return . data_reg 

-- genout :: ReacT I O (StateT S Identity) I
genout :: Re I S O I
genout = do
           s <- lift get
           signal (tx_pin s , tx_done s)

-- out_pin :: Finite 8 -> StateT S Identity ()
out_pin :: Finite 8 -> ST S ()
out_pin i = do
              (_ , td , dr) <- get
              put (dr `index` i , td , dr)

-- idle , data_bits :: I -> ReacT I O (StateT S Identity) ()
idle , data_bits :: I -> Re I S O ()
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
                  lift (setDR (lit 0) >> clrTX_PIN >> clrTX_Done)
                  idle i

s0 :: S
s0 = (True , False , lit 0)

-- start :: ReacT I O Identity ()
-- start :: Re I O Identity ()
-- start = extrude (idle Nop) s0
                  
start = re_inf (idle Nop) (Nop , s0 , (False , False))

is0 :: Stream I
is0 = TX_DATA (lit 0xFF) :< rep Nop

instance Show I where
  show (TX_DATA w8) = "TX_DATA " Prelude.++ xshow w8
  show Nop          = "Nop"

urp (b,b',w) = "(" Prelude.++ ppbit b Prelude.++ "," Prelude.++
                              ppbit b' Prelude.++ "," Prelude.++
                              bshow w Prelude.++ ")"
   where
     ppbit True  = "1"
     ppbit False = "0"

grunt []                  = "\n"
grunt ((i , s , o) : sns) = "(" Prelude.++ show i Prelude.++ "," Prelude.++ urp s
                                Prelude.++ "," Prelude.++ pp o Prelude.++ ")"
                                Prelude.++ "\n" Prelude.++ grunt sns
