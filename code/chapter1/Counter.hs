{-# LANGUAGE DataKinds #-}
module Counter where

import Prelude hiding ((^), (+))
import ReWire
import ReWire.Bits

type W8 = W 8

f :: W8 -> W8 -> W8 -> (W8, W8)
f a b c = ( ((a .&. b) .|. (a .&. c) .|. (b .&. c) ) <<. lit 1 , (a ^ b) ^ c )

-- |
-- | Example 2. Storing CSA
-- |

count :: W8 -> ReacT W8 W8 (StateT  W8 Identity) ()
count i = save i >>= \ cs -> signal cs >>= count
  where
    save :: W8 -> ReacT W8 W8 (StateT W8 Identity) W8
    save a = lift (put (a + lit 1) >> get)

-- start :: ReacT (W8 , W8 , W8) (W8 , W8) Identity ()
-- start = extrude (scsa (lit 0, lit 0, lit 0)) (lit 0, lit 0)
  
