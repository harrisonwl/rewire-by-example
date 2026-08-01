{-# LANGUAGE DataKinds #-}

import Prelude hiding ((^))
import ReWire
import ReWire.Finite
import ReWire.Vectors
import Data.Vector.Sized as DVS hiding (index) 

least :: KnownNat n => Vec n Bit -> Maybe (Finite n)
least v = snd $ DVS.foldl delta (finite 0 , Nothing) v
  where
    delta :: KnownNat n => (Finite n , Maybe (Finite n)) -> Bit -> (Finite n , Maybe (Finite n))
    delta (i , Just j) _  = (i + finite 1 , Just j)
    delta (i , Nothing) b = if b then (i + finite 1 , Just i)
                                   else (i + finite 1 , Nothing)

type Cfg = Vec 4 (Vec 4 Bit)

column :: KnownNat n1 => Vec n1 (Vec n2 a) -> Finite n2 -> Vec n1 a
column cfg j = ReWire.Vectors.generate $ \ i -> cfg @@ (i , j)

(@@) :: Vec n1 (Vec n2 a) -> (Finite n1, Finite n2) -> a
s @@ (i , j) = s `index` i `index` j

cbar :: Vec 4 (Maybe (W 8)) -> Cfg -> Vec 4 (Maybe (W 8))
cbar ins cfg = undefined

switch :: t -> t -> Bit -> (t, t)
switch x _ True  = (x,x)
switch x y False = (x,y)

data Maybe4 = Maybe4 (Maybe (W 8)) (Maybe (W 8)) (Maybe (W 8)) (Maybe (W 8))

-- | helper function
explode :: W 16 -> ( Bit , Bit , Bit , Bit , Bit , Bit , Bit , Bit
                   , Bit , Bit , Bit , Bit , Bit , Bit , Bit , Bit )
explode w16 = (c11,c12,c13,c14,c21,c22,c23,c24
              ,c31,c32,c33,c34,c41,c42,c43,c44)
  where
          c11,c12,c13,c14,c21,c22,c23,c24,
              c31,c32,c33,c34,c41,c42,c43,c44 :: Bit
          c11 = index w16 (finite 0)
          c12 = index w16 (finite 1)
          c13 = index w16 (finite 2)
          c14 = index w16 (finite 3)
          c21 = index w16 (finite 4)
          c22 = index w16 (finite 5)
          c23 = index w16 (finite 6)
          c24 = index w16 (finite 7)
          c31 = index w16 (finite 8)
          c32 = index w16 (finite 9)
          c33 = index w16 (finite 10)
          c34 = index w16 (finite 11)
          c41 = index w16 (finite 12)
          c42 = index w16 (finite 13)
          c43 = index w16 (finite 14)
          c44 = index w16 (finite 15)

-- crossbar :: Maybe4 -> W 16 -> Maybe4 
crossbar (x10 , x20 , x30 , x40) (c11,c12,c13,c14,c21,c22,c23,c24,c31,c32,c33,c34,c41,c42,c43,c44)
   = {- Maybe4 -} (y10 , y20 , y30 , y40)
         where
          -- c11,c12,c13,c14,c21,c22,c23,c24,
          --     c31,c32,c33,c34,c41,c42,c43,c44 :: Bit
          -- (c11,c12,c13,c14,c21,c22,c23,c24
          --     ,c31,c32,c33,c34,c41,c42,c43,c44) = explode w16                          
          
          (x41,y31) = switch x40 Nothing c41
          (x42,y32) = switch x41 Nothing c42
          (x43,y33) = switch x42 Nothing c43
          (_,y34)   = switch x43 Nothing c44

          (x31,y21) = switch x30 y31 c31
          (x32,y22) = switch x31 y32 c32
          (x33,y23) = switch x32 y33 c33
          (_,y24)   = switch x33 y34 c34

          (x21,y11) = switch x20 y21 c21
          (x22,y12) = switch x21 y22 c22
          (x23,y13) = switch x22 y23 c23
          (_,y14)   = switch x23 y24 c24

          (x11,y10) = switch x10 y11 c11
          (x12,y20) = switch x11 y12 c12
          (x13,y30) = switch x12 y13 c13
          (_,y40)   = switch x13 y14 c14
           
data Inp = Inp Maybe4 (W 16) | NoInput
data Out = Out Maybe4 | Nix

{-
dev :: Inp -> ReacT Inp Out Identity ()
dev (Inp m4 b16) = signal (Out (crossbar m4 b16)) >>= dev
dev NoInput      = signal Nix >>= dev

start :: ReacT Inp Out Identity ()
start = signal Nix >>= dev
-}

{-
type Bool16 = (Bool,Bool,Bool,Bool,Bool,Bool,Bool,Bool,Bool,Bool,Bool,Bool,Bool,Bool,Bool,Bool)

crossbar :: Maybe4 -> Bool16 -> Maybe4 
crossbar (Maybe4 x10 x20 x30 x40) (c11,c12,c13,c14,c21,c22,c23,c24,c31,c32,c33,c34,c41,c42,c43,c44)
   = let
          (x41,y31) = switch x40 Nothing c41
          (x42,y32) = switch x41 Nothing c42
          (x43,y33) = switch x42 Nothing c43
          (_,y34) = switch x43 Nothing c44

          (x31,y21) = switch x30 y31 c31
          (x32,y22) = switch x31 y32 c32
          (x33,y23) = switch x32 y33 c33
          (_,y24) = switch x33 y34 c34

          (x21,y11) = switch x20 y21 c21
          (x22,y12) = switch x21 y22 c22
          (x23,y13) = switch x22 y23 c23
          (_,y14) = switch x23 y24 c24

          (x11,y10) = switch x10 y11 c11
          (x12,y20) = switch x11 y12 c12
          (x13,y30) = switch x12 y13 c13
          (_,y40) = switch x13 y14 c14
     in
       Maybe4 y10 y20 y30 y40
-}
