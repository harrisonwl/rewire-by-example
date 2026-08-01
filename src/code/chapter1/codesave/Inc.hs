{-# LANGUAGE DataKinds #-}
import Prelude hiding ((^))
import ReWire
import ReWire.Bits

inc :: W 8 -> ReacT (W 8) (W 8) Identity ()
inc w8 = do
            w8' <- signal (w8 + lit 1)
            inc w8'

start :: ReacT (W 8) (W 8) Identity ()
start = inc (lit 0)
