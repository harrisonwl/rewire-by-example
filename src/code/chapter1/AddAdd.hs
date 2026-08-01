{-# LANGUAGE DataKinds #-}
-- module AddAdd where

import Prelude hiding ((+))
import ReWire
import ReWire.Bits

-- |
-- | Example. 
-- |
-- | The only thing this does is take one inputs i, adds them, and
-- | outputs the result every clock cycle.
-- |
-- | Why? To illustrate the timing distinction.
-- |

addadd :: W 8 -> ReacT (W 8) (Maybe (W 8)) Identity ()
addadd a = do
              b  <- signal Nothing
              a' <- signal (Just (a + b))
              addadd a'

_0 :: W 8
_0  = lit 0

start :: ReacT (W 8) (Maybe (W 8)) Identity ()
start = addadd _0
