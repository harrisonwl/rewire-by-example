## Salsa20 Expansion function

The definitions below can be found in [Expansion.hs](https://github.com/harrisonwl/rwcrypto/blob/main/src/salsa20/Expansion.hs) and the testing code can be found in [Test_Expansion.hs](https://github.com/harrisonwl/rwcrypto/blob/main/src/salsa20/Test_Expansion.hs).

### Inputs and Outputs

To quote Bernstein, *If k is a 32-byte or 16-byte sequence and n is a 16-byte sequence then `Salsa20k(n)` is a 64-byte sequence.* Really, this means that there are two expansion functions, to which we will give the following types:
```haskell
salsa20_k0k1 :: (Hex (W 8), Hex (W 8)) -> Hex (W 8) -> X64 (W 8)
salsa20_k :: Hex (W 8) -> Hex (W 8) -> X64 (W 8)
```
Just to unpack this, if *k* is a 32-byte sequence, then *k* can be split into two 16-byte sequences, *k0* and *k1*. So, the first argument's type in `salsa20_k0k1` is `(Hex (W 8), Hex (W 8))`. If *k* is a 16-byte sequence, then that explains the type of the first argument to `salsa20_k`. I didn't invent this naming scheme, so don't blame me.

Quoting Bernstein again, ** \\(\\)

### Defining `salsa20_k0k1`

Bernstein first defines several 4-tuples of constants, each of which is implicitly assumed to be a single byte:
\\[
\begin{array}{lcl}
\sigma_0 &=& (101,120,112,97)
\newline
\sigma_1 &=& (110,100,32,51)
\newline
\sigma_2 &=& (50,45,98,121)
\newline
\sigma_3 &=& (116,101,32,107)
\end{array}
\\]
Note that each \\(\sigma_i\\) would have type `(W 8 , W 8 , W8 , W 8)` if defined in Haskell/ReWire and, consequently, there are sixteen bytes total contained in them.

The 32-byte expansion function is then defined as:
\\[
Salsa20_{k0k1}(n) = Salsa20(\sigma_0,k_0,\sigma_1,n,\sigma_2,k_1,\sigma_3)
\\]
where \\(Salsa20\\) is the Salsa20 hash function from the previous subsection. The argument to \\(Salsa20\\) (i.e., the 7-tuple \\((\sigma_0,k_0,\sigma_1,n,\sigma_2,k_1,\sigma_3)\\)) contains 64 bytes in total. However, the argument is intended to be a 64-byte sequence or, in terms of Haskell/ReWire, it has type `X64 (W 8)`. Below, I define a function called `expandk0k1` to construct this argument.

### Rendering in Haskell/ReWire

It is probably easier to understand this definition by looking directly at its expression in Haskell/ReWire:
```haskell
salsa20_k0k1 :: (Hex (W 8), Hex (W 8)) -> Hex (W 8) -> X64 (W 8)
salsa20_k0k1 (k0,k1) n = hash_salsa20 (expandk0k1 (k0 , k1 , n))

expandk0k1 :: (Hex (W 8), Hex (W 8), Hex (W 8)) -> X64 (W 8)
expandk0k1 
       ( (X16 y1 y2 y3 y4 y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16) -- k0
       , (X16 z1 z2 z3 z4 z5 z6 z7 z8 z9 z10 z11 z12 z13 z14 z15 z16) -- k1
       , (X16 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16) -- n
       ) = let
              sigma0 , sigma1 , sigma2 , sigma3 :: Quad (W 8)
              sigma0@(x1,x2,x3,x4) = (lit 101, lit 120, lit 112,  lit 97)
              sigma1@(w1,w2,w3,w4) = (lit 110, lit 100,  lit 32,  lit 51)
              sigma2@(v1,v2,v3,v4) = ( lit 50,  lit 45,  lit 98, lit 121)
              sigma3@(t1,t2,t3,t4) = (lit 116, lit 101,  lit 32, lit 107)
           in
             X64
                 x1 x2 x3 x4
                 --
                 y1 y2 y3 y4 y5 y6 y7 y8 y9 y10 y11 y12 y13 y14 y15 y16
                 --
                 w1 w2 w3 w4
                 --
                 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16
                 --
                 v1 v2 v3 v4
                 --
                 z1 z2 z3 z4 z5 z6 z7 z8 z9 z10 z11 z12 z13 z14 z15 z16
                 --
                 t1 t2 t3 t4
                 --
```

### Defining the 16-byte Expansion Function

The 16-byte expansion function is  defined as:
\\[
Salsa20_{k}(n) = Salsa20(\tau_0,k,\tau_1,n,\tau_2,k,\tau_3)
\\]
where the \\(\tau_i\\) are defined as:
\\[
\begin{array}{lcl}
\tau_0 &=& (101,120,112,97)
\newline
\tau_1 &=& (110,100,32,49)
\newline
\tau_2 &=& (54,45,98,121)
\newline
\tau_3 &=& (116,101,32,107)
\end{array}
\\]
Note that the argument to \\(Salsa20\\) has 64 bytes in total and we defined a function `expandk` to construct this argument.

### Rendering in Haskell/ReWire

The definition of the 16-byte expansion function `salsa20_k` is very similar to the 32-byte function defined above:
```haskell
salsa20_k :: Hex (W 8) -> Hex (W 8) -> X64 (W 8)
salsa20_k k n = hash_salsa20 (expandk k n)

expandk :: Hex (W 8) -> Hex (W 8) -> X64 (W 8)
expandk k@(X16 k1 k2 k3 k4 k5 k6 k7 k8 k9 k10 k11 k12 k13 k14 k15 k16)
        n@(X16 n1 n2 n3 n4 n5 n6 n7 n8 n9 n10 n11 n12 n13 n14 n15 n16)
       = let
             tau0 , tau1 , tau2 , tau3 :: Quad (W 8)
             tau0@(x1 , x2 , x3 , x4) = (lit 101,lit 120,lit 112,lit 97)
             tau1@(y1 , y2 , y3 , y4) = (lit 110,lit 100,lit 32,lit 49)
             tau2@(u1 , u2 , u3 , u4) = (lit 54,lit 45,lit 98,lit 121)
             tau3@(v1 , v2 , v3 , v4) = (lit 116,lit 101,lit 32,lit 107)
         in
           X64
               --- tau0
               x1 x2 x3 x4 
               --- k
               k1 k2 k3 k4 k5 k6 k7 k8 k9 k10 k11 k12 k13 k14 k15 k16
               --- tau1
               y1 y2 y3 y4
               --- n
               n1 n2 n3 n4 n5 n6 n7 n8 n9 n10 n11 n12 n13 n14 n15 n16
               --- tau2
               u1 u2 u3 u4
               --- k
               k1 k2 k3 k4 k5 k6 k7 k8 k9 k10 k11 k12 k13 k14 k15 k16
               --- tau3
               v1 v2 v3 v4
```
