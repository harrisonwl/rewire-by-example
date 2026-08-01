{-# LANGUAGE DataKinds #-}
import Prelude hiding ((+))
import ReWire
import ReWire.Bits

-- |
-- | Example. 
-- |
-- | The only thing this does is take its inputs i, adds them, and
-- | outputs the result every clock cycle.
-- |
-- | Why? To illustrate the timing distinction.
-- |

add2 :: (W 8 , W 8) -> ReacT (W 8, W 8) (W 8) Identity ()
add2 (a, b) = do
                 ab <- signal (a + b)
                 add2 ab

_0 :: W 8
_0  = lit 0

start :: ReacT (W 8, W 8) (W 8) Identity ()
start = add2 (_0 , _0)
