# Monad Wrangling 101

ReWire is a monadic language, meaning that it is organized in terms of various monads (which ones, we'll get to shortly). There are about a zillion tutorials on monads out there, and most of them are just *terrible*. This is a shame since the idea of a monad itself is really beautiful and, if you know how to use them correctly, they're a really important part of functional programming practice. And, furthermore, they are a really important part of programming language semantics, too, and consequently an important part of formal methods properly understood. 

What this section does is introduce the monad idea through a sequence of simple language interpreters. As we add features to the language, we have to change the monad we use to define the new interpreter. We will see four interpreters whose core is a language of simple arithmetic expressions. 

To see all of the monads discussed in this tutorial defined in one convenient Haskell file, download this: 
[MonadWrangling.hs](MonadWrangling.hs). These monad and monad transformer definitions are in the style of earlier versions of GHC, which were immensely easier to understand than the current mess.

---

## Simple Arithmetic Expressions

The first interpreter, found in [Arith.hs](Arith.hs), defines a language `Exp` that has integer constants, negation, and addition. These correspond to the constructors `Const`, `Neg`, and `Add` of the `Exp` data type. The interpreter `eval0` does not use a monad and should be fairly self-explanatory.

```haskell
module Arith where

data Exp = Const Int | Neg Exp | Add Exp Exp

instance Show Exp where
  show (Const i) = show i
  show (Neg e)   = "-" ++ show e
  show (Add e1 e2) = show e1 ++ " + " ++ show e2

eval0 :: Exp -> Int
eval0 (Const i)   = i
eval0 (Neg e)     = - (eval0 e)
eval0 (Add e1 e2) = eval0 e1 + eval0 e2

c = Const 99
n = Neg c
a = Add c n
```

Loading this into GHCi gives you what you'd expect:
```
λ> a
99 + -99
λ> eval0 a
0
```

---

## The `Identity` Monad is a Big Nothingburger

We introduce now the `Identity` monad, which doesn't really give you anything at all. I introduce it first because it uses Haskell's built-in monad syntax, and it's useful to meet that syntax first when the monad is just a big nothing. The code for this section is found in [IdentityMonad.hs](IdentityMonad.hs) and [IdentityMonadDo.hs](IdentityMonadDo.hs).

First, here's the new interpreter `eval1`. The salient point is that `eval0` and `eval1` are doing the same thing, but what's all this `return` and `>>=` business? (They're explained below if you want to skip ahead.)
```haskell
module IdentityMonad where

import Control.Monad.Identity -- this is new.

data Exp = Const Int | Neg Exp | Add Exp Exp

instance Show Exp where
  show (Const i) = show i
  show (Neg e)   = "-" ++ show e
  show (Add e1 e2) = show e1 ++ " + " ++ show e2

eval1 :: Exp -> Identity Int
eval1 (Const i)   = return i
eval1 (Neg e)     = eval1 e >>= \ v -> return (- v)
eval1 (Add e1 e2) = eval1 e1 >>= \ v1 -> eval1 e2 >>= \ v2 -> return (v1 + v2)

c = Const 99
n = Neg c
a = Add c n
```

The `Identity` monad has the following definition (it's actually a simplification). 
```haskell
data Identity a = Identity a -- apologies for overloading the constructors.
return :: a -> Identity a
return v = Identity v
(>>=) :: Identity a -> (a -> Identity b) -> Identity b
(Identity v) >>= f = f v
```
So, `return` just injects its argument into `Identity`. The operation `>>=` (a.k.a., "bind") boils down to a backwards apply. It's just a whole lot of applying and pattern-matching on the `Identity` constructor, signifying nothing. When you load all this into GHCi, you get just what you'd expect:
```
λ> a
99 + -99
λ> eval1 a
Identity 0
λ> 
```

## Lessons Learned

As people say, `eval1` and `eval0` are morally equivalent, in the sense that, if you were so inclined, you could *prove* the equality `eval1 a = Identity (eval0 a)` holds for any `a`.

### Monadic Syntactic Sugar or Saccharine? 

Haskell overloads its monad syntax, so when we see the `>>=` and `return` again, they will be typed in different monads than `Identity`. Overloading is great for some uses, because it removes clutter. I find for formal methods it can be kind of confusing. So, reader beware!

There is also another shorthand for `>>=` that is frequently used called `do` notation; it's defined as:
```haskell
   x >>= f = do
               v <- x
		       f v
```
So, the clause of `eval1` for `Neg` is as follows when written in `do` notation:
```haskell
eval1 (Neg e)     = do
                      v <- eval1 e
                      return (- v)
```

The code `IdentityMonadDo.hs` just reformulates the code in `IdentityMonad.hs` using `do` notation.

---

## 2nd Interpreter: Errors and Maybe

The code for this section is found in [Errors.hs](Errors.hs). This new interpreter adds a new arithmetic operation `Div`. I pasted in the `eval0` with a new case for `Div`.
```haskell
module Errors where

data Exp = Const Int | Neg Exp | Add Exp Exp
         | Div Exp Exp                      -- new

instance Show Exp where
  show (Const i) = show i
  show (Neg e)   = "-" ++ show e
  show (Add e1 e2) = show e1 ++ " + " ++ show e2
  show (Div e1 e2) = show e1 ++ " / " ++ show e2

-- | Same as before, but with a new case
eval0 :: Exp -> Int
eval0 (Const i)   = i
eval0 (Neg e)     = - (eval0 e)
eval0 (Add e1 e2) = eval0 e1 + eval0 e2
eval0 (Div e1 e2) = eval0 e1 `div` eval0 e2 -- new

a    = Add c (Neg c)
        where
          c = Const 99
uhoh = Div (Const 1) (Const 0)              -- new
```

Note that, when you run the `Div`-extended version of `eval0`, things don't always end well:
```haskell
λ> uhoh
1 / 0
λ> eval0 uhoh
*** Exception: divide by zero
λ> 
```

### Why can't we just check for 0? 

Think about it this way, what should I replace `????` with below? There's no way of handling that exceptional case and it crashes the program. 
```haskell
eval0 (Div e1 e2) = if v2 == 0 then ???? else eval0 e1 `div` v2 
   where
      v2 = eval0 e2
```

But with the `Maybe` monad, we can use its `Nothing` constructor for this erroneous case; recall the definition of the `Maybe` data type:
```haskell
data Maybe a = Nothing | Just a
```

Here's the definition of `eval2` whhich is typed in the `Maybe` monad:
```haskell
eval2 :: Exp -> Maybe Int     -- N.b., the new type
eval2 (Const i)   = return i
eval2 (Neg e)     = do
                      v <- eval2 e
                      return (- v)
eval2 (Add e1 e2) = do
                      v1 <- eval2 e1
                      v2 <- eval2 e2
                      return (v1 + v2)
eval2 (Div e1 e2) = do
                      v1 <- eval2 e1
                      v2 <- eval2 e2
                      if v2==0 then Nothing else return (v1 `div` v2) -- fill in ???? with Nothing
```

```haskell
λ> uhoh
1 / 0
λ> eval2 uhoh
Nothing
```

### Maybe Under the Hood

Below is the definition of the `Maybe` monad. The way to think of a computation `x >>= f` is that, if `x` is returns some value (i.e., it's `Just v`), then just proceed normally. If an exception is thrown by computing `x` (i.e., it's `Nothing`), then the whole computation `x >>= f` 
```haskell
data Maybe a = Nothing | Just a

return :: a -> Maybe a
return v = Just v

(>>=) :: Maybe a -> (a -> Maybe b) -> Maybe b 
(Just v) >>= f = f v
Nothing >>= f  = Nothing
```

---

# 3rd Interpreter: Adding a Register

The code for this section is [Register.hs](Register.hs).

```haskell
module Register where

import Control.Monad.State

data Exp = Const Int | Neg Exp | Add Exp Exp
         | X  -- new register X

instance Show Exp where
  show (Const i) = show i
  show (Neg e)   = "-" ++ show e
  show (Add e1 e2) = show e1 ++ " + " ++ show e2
  show X           = "X"

-- | Just a copy 
eval2 :: Exp -> Maybe Int
eval2 (Const i)   = return i
eval2 (Neg e)     = do
                      v <- eval2 e
                      return (- v)
eval2 (Add e1 e2) = do
                      v1 <- eval2 e1
                      v2 <- eval2 e2
                      return (v1 + v2)

eval2 X           = undefined -- How do we do handle this?
```

Here's how we handle this:
- Create a new monad from `Identity` with an `Int` register: `StateT Int Identity`
- This new monad has two operations
  - `get` that reads the current value of the register
  - `put` that updates the value of the register
- `StateT Int` is known as a *monad transformer*
  
The code below does just that  
```haskell
readX :: StateT Int Identity Int
readX = get

eval3 :: Exp -> StateT Int Identity Int
eval3 (Const i)   = return i
eval3 (Neg e)     = do
                      v <- eval3 e
                      return (- v)
eval3 (Add e1 e2) = do
                      v1 <- eval3 e1
                      v2 <- eval3 e2
                      return (v1 + v2)

eval3 X           = readX
```

---

# 4th: Errors + Register

The code for this is [RegisterError.hs](RegisterError.hs). In this example, we want to add both a possibly error-producing computation along with the register. This is done mostly through monadic means.


```haskell
module Register where

import Control.Monad.State

data Exp = Const Int | Neg Exp | Add Exp Exp
         | Div Exp Exp  -- Both errors
         | X            -- and a register X

instance Show Exp where
  show (Const i) = show i
  show (Neg e)   = "-" ++ show e
  show (Add e1 e2) = show e1 ++ " + " ++ show e2
  show (Div e1 e2) = show e1 ++ " / " ++ show e2
  show X           = "X"
```

Here's how we handle this:
- Create a new monad from `Maybe` with an `Int` register: `StateT Int Maybe`
- This new monad has two operations
  - `get` that reads the current value of the register
  - `put` that updates the value of the register
- `StateT Int` is known as a *monad transformer*
  
The code below does just that  
```haskell
readX :: StateT Int Maybe Int
readX = get

eval3 :: Exp -> StateT Int Maybe Int
eval3 (Const i)   = return i
eval3 (Neg e)     = do
                      v <- eval3 e
                      return (- v)
eval3 (Add e1 e2) = do
                      v1 <- eval3 e1
                      v2 <- eval3 e2
                      return (v1 + v2)
eval3 (Div e1 e2) = do
                      v1 <- eval3 e1
                      v2 <- eval3 e2
                      if v2==0 then lift Nothing else return (v1 `div` v2)
                                 -- N.b., this is new.

eval3 X           = readX
```

