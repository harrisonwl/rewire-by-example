{-# LANGUAGE DataKinds #-}

import ReWire hiding (lift, signal , put , get , modify)
import ReWire.Bits
import ReWire.Finite
import ReWire.Vectors

import ReWire.Interactive (xshow,pp,bshow)
import ExtensionalSemantics

type I = Maybe (W 8)      
type O = Maybe Bit

uarttx :: Maybe (W 8) -> Re (Maybe (W 8)) () (Maybe Bit) ()
uarttx Nothing   = signal Nothing >>= uarttx
uarttx (Just w8) = do
                    signal (Just (w8 `index` finite 0))
                    signal (Just (w8 `index` finite 1))
                    signal (Just (w8 `index` finite 2))
                    signal (Just (w8 `index` finite 3))
                    signal (Just (w8 `index` finite 4))
                    signal (Just (w8 `index` finite 5))
                    signal (Just (w8 `index` finite 6))
                    i <- signal (Just (w8 `index` finite 7))
                    uarttx i
                    
start = re_inf (uarttx Nothing) (Nothing , () , Nothing)

is0 :: Stream I
is0 = Nothing :< Just (lit 0xAF) :< Just (lit 0x11) :< Nothing :< Just (lit 0x22) :< Nothing :< rep Nothing

urp (b,b',w) = "(" Prelude.++ ppbit b Prelude.++ "," Prelude.++
                              ppbit b' Prelude.++ "," Prelude.++
                              bshow w Prelude.++ ")"

ppbit True  = "1"
ppbit False = "0"
ppm (Just x) = "Just " Prelude.++ ppbit x
ppm Nothing  = "Nothing"

grunt []                  = "\n"
grunt ((i , s , o) : sns) = "(" Prelude.++ pp i Prelude.++ "," Prelude.++ show s
                                Prelude.++ "," Prelude.++ ppm o Prelude.++ ")"
                                Prelude.++ "\n" Prelude.++ grunt sns

