# Words

A *word* in the context of Bernstein's Salsa20 specification is a bit vector of size 32. Representing bit vectors in ReWire is done via the built-in type constructor for words, `W`. It is size-indexed so that, for example, 32-bit words are represented by `W 32`. There are a host of operators defined for words parameterized by size. For example, the type of addition on words has type (checking its type in the GHCi interpreter):
```haskell
λ> :type (+)
(+) :: KnownNat n => W n -> W n -> W n
```
This means that, for any natural number `n`, `(+)` takes two `(W n)` and returns a `(W n)`.

Most bit-vector operations in Verilog or VHDL have a corresponding operation in ReWire.

#### The Basic Usage TL;DR

The first lines of code for the Salsa20 `quarterround` function are below and illustrate how to load the built-in bit-vector types and operations in ReWire.

```haskell
{-# LANGUAGE DataKinds #-}                    -- 1
module QuarterRound(quarterround) where

import Prelude hiding ((+) , (^))             -- 2
import ReWire                                 -- 3
import ReWire.Bits (lit , rotL , (^) , (+))   -- 4
```

To use the built-in bit vector type, one must simply include `import ReWire` (line `3`) and also the language directive (`1`). To use specific operations, one can include them from `ReWire.Bits` (line `4`) and some of these operations have the same name as Haskell Prelude operations, so one can exclude these as in line `2`. 

#### Some additional type constructors for Salsa20

Some additional type constructors used in this specification are included below. We could use Haskell built-in tuple types for these, but it is useful for various technical reasons to define our own larger vector types instead (e.g., it makes pretty-printing values as we wish easier). It's not important to understand the precise details, however.

```haskell
data X16 a  = X16 a a a a a a a a a a a a a a a a 

type Quad a = (a , a , a , a)
type Oct a  = (a , a , a , a , a , a , a , a)
type Hex a  = X16 a
    
data X64 a  = X64 a a a a a a a a a a a a a a a a
                  a a a a a a a a a a a a a a a a
                  a a a a a a a a a a a a a a a a
                  a a a a a a a a a a a a a a a a 
```
