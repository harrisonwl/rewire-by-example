{-# LANGUAGE DataKinds #-}
import Prelude hiding ((+))
import ReWire
import ReWire.Bits

acc :: W 8 -> ReacT (W 8) (W 8) (StateT (W 8) Identity) ()
acc a = save a >>= \ x -> signal x >>= acc
  where
    save :: W 8 -> ReacT (W 8) (W 8) (StateT (W 8) Identity) (W 8)
    save a = lift (get >>= \ reg -> put (a + reg) >> get)

start :: ReacT (W 8) (W 8) Identity ()
start = extrude (acc (lit 0)) (lit 0xf)
