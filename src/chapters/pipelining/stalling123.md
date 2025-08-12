
## A Hello World Example with Stalling

*Stalling* is the delaying the execution of a pipelined architecture to wait for some condition. In a pipelined processor, this may be due to a data hazard or resource conflict. In our simple example, let's suppose that valid inputs may not always be available.

So, if an input isn't available, call is `Stall`. If a valid output isn't produced, then call it
`DC` for *don't care*. 
```haskell
data Inp a = Stall | Arg a deriving Show
data Out a = DC    | Val a deriving Show 
```

Then, we'll lift `one`, `two`, and `three` to `io_one`, `io_two`, and `io_three`, respectively, and define `times3` as before.
```haskell
io_one , io_two , io_three :: Inp (W 8) -> Out (W 8)
io_one Stall     = DC
io_one (Arg a)   = Val (one a)
io_two Stall     = DC
io_two (Arg a)   = Val (two a)
io_three Stall   = DC
io_three (Arg a) = Val (three a)

times3 :: (Inp (W 8), Inp (W 8), Inp (W 8)) -> (Out (W 8), Out (W 8), Out (W 8))
times3 (i1 , i2 , i3) = (io_one i1 , io_two i2 , io_three i3)
```

It is in the connection function that delaying of execution is manifest.
```haskell
conn3 :: (Out a, Out a, Out a) -> Inp a -> (Inp a, Inp a, Inp a)
conn3 (DC , DC , _) ix         = (ix , Stall , Stall)
conn3 (Val x1 , Val x2 , _) ix = (ix , Arg x1 , Arg x2)
conn3 (Val x1 , DC , _) ix     = (ix , Arg x1 , Stall)
conn3 (DC , Val x2 , _) ix     = (ix , Stall , Arg x2)
```

The `pipeline` function from the previous section is identical and the remainder of the definition is equivalent.
```haskell
withstall :: Inp (W 8) -> ReacT (Inp (W 8)) (Out (W 8)) Identity ()
withstall = pipeline times3 out3 conn3 (DC , DC , DC)

start :: ReacT (Inp (W 8)) (Out (W 8)) Identity ()
start = withstall Stall
```

As examples, consider the following two input lists:
```haskell
λ> pretty ins
Arg 0x01 : Arg 0x02 : Arg 0x03 : Arg 0x04 : Arg 0x05 : Arg 0x06 : Arg 0x07 : Arg 0x08 : Arg 0x09 : Arg 0x0A : Arg 0x0B : Arg 0x0C : Arg 0x0D : Arg 0x0E : Arg 0x0F : []
λ> pretty ins'
Arg 0x01 : Stall : Arg 0x02 : Stall : Stall : Arg 0x03 : Stall : Stall : Stall : []
```

The first list `ins` is identical to that of the previous section and produces the same output (modulo the `Arg`s and `Val`s):
```haskell
λ> pretty exS
   (Stall,DC) :> (Arg 0x01,DC) :> (Arg 0x02,DC) :> (Arg 0x03,DC) :> (Arg 0x04,Val 0x07) :> 
      (Arg 0x05,Val 0x08) :> (Arg 0x06,Val 0x09) :> (Arg 0x07,Val 0x0A) :> (Arg 0x08,Val 0x0B) :> 
	      (Arg 0x09,Val 0x0C) :> (Arg 0x0A,Val 0x0D) :> (Arg 0x0B,Val 0x0E) :> (Arg 0x0C,Val 0x0F) :> 
		      (Arg 0x0D,Val 0x10) :> (Arg 0x0E,Val 0x11) :> (Arg 0x0F,Val 0x12) :+> Nothing
```

The second input stream, `ins'`, has `Stall`s inserted to demonstrate the stalling of the `withstall` device. 
```haskell
λ> pretty exS'
   (Stall,DC) :> (Arg 0x01,DC)       :> 
                 (Stall,DC)          :> 
				 (Arg 0x02,DC)       :> 
				 (Stall,Val 0x07)    :> 
				 (Stall,DC)          :> 
				 (Arg 0x03,Val 0x08) :> 
				 (Stall,DC)          :> 
				 (Stall,DC)          :> 
				 (Stall,Val 0x09)    :+> Nothing
λ> 
```
Notice that, as before, a valid input (e.g., `Arg 0x01`) produces its output three cycles later (e.g., `Val 0x07`, resp.). But a `Stall` input begets a `DC` output three cycles later.

There are two versions of the code for this example:
  - [Haskell/ReWire version](https://github.com/harrisonwl/rwcrypto/blob/main/src/pipelining/WithStallPipe123.hs). This is executable in GHCi.
  - [ReWire version](https://github.com/harrisonwl/rwcrypto/blob/main/src/pipelining/RW_WithStallPipe123.hs). This is compilable by the ReWire compiler.

