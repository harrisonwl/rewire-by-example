# Pipelining

As an example, I'll build several pipelined versions of a part of the Salsa20 crypto spec. In the Salsa20 hash function ([Section 3.1.8](../salsa20/hashfunction.md)), there is a place where the `doubleround` function is composed ten times:
```haskell
dr10 :: Hex (W 32) -> Hex (W 32)
dr10 = doubleround . doubleround . doubleround . doubleround . doubleround .
          doubleround . doubleround . doubleround . doubleround . doubleround 
```

We will use this as an opportunity for pipelining.

## Naive Approach

We can write perfectly valid ReWire code for in the same style as the first carry-save adder from ([Section 2.3](../chapter1/carrysaveadders.md)). That is, as a simple loop that takes an input, applies `dr10`, and `signal`s the output:
```haskell
type HxW32 = Hex (W 32)

dr10 :: HxW32 -> HxW32
dr10 = doubleround . doubleround . doubleround . doubleround . doubleround .
       doubleround . doubleround . doubleround . doubleround . doubleround 

loop :: Maybe HxW32 -> ReacT (Maybe HxW32) (Maybe HxW32) Identity ()
loop (Just hxw32) = signal (Just (dr10 hxw32)) >>= loop
loop Nothing      = signal Nothing >>= loop

start :: ReacT (Maybe HxW32) (Maybe HxW32) Identity ()
start = loop Nothing
```
The full code is available here: [Naive_DR10.hs](https://github.com/harrisonwl/rwcrypto/blob/main/src/pipeline/Naive_DR10.hs). If the `loop` function is passed a valid input (i.e., `(Just hxw32)`), then `dr10` is applied to it. In each cycle, `dr10 hxw32` is calculated.

*Why is this naive?* If you look at the code for `doubleround`, there are a lot of operations going on in `dr10`. Pure functions like these are compiled to combinational logic, and, the combinational logic for ten `doubleround`s is substantial. It would be better to pipeline calls to `doubleround` to avoid this.

There's another way that this is naive in that inputs and outputs include `Hex (W 32)` which is \\(16 \times 32 = 512\\) bits. This means that, on an FGPA, one would need 1024 input and output ports and that is (I believe) beyond what's currently available. We'll come back to this issue later on.

## The Plan
- Using the `doubleround` function, I'll demonstrate 2- and 5-stage pipelines of `dr10`.
- I.e., ReWire versions of:
```haskell
	pipe2 = [doubleround . doubleround . doubleround . doubleround . doubleround] .
               [doubleround . doubleround . doubleround . doubleround . doubleround]
	pipe5 = [doubleround . doubleround] . [doubleround . doubleround] . [doubleround .
               doubleround] . [doubleround . doubleround] . [doubleround . doubleround]
```
	


```haskell
λ> :t ins
ins :: [W 8]
λ> pretty ins
0x01 : 0x02 : 0x03 : 0x04 : 0x05 : 0x06 : 0x07 : 0x08 : 0x09 : 0x0A : 0x0B : 0x0C : 0x0D : 0x0E : 0x0F : []
λ> 
λ> pretty $ map (three . two . one) ins
0x07 : 0x08 : 0x09 : 0x0A : 0x0B : 0x0C : 0x0D : 0x0E : 0x0F : 0x10 : 0x11 : 0x12 : 0x13 : 0x14 : 0x15 : []
λ> pretty $ runP start (Stall , DC) (map Arg ins)
(Stall,DC) :> (Arg 0x01,DC) :> (Arg 0x02,DC) :> (Arg 0x03,DC) :> (Arg 0x04,Val 0x07) :> (Arg 0x05,Val 0x08) :> (Arg 0x06,Val 0x09) :> (Arg 0x07,Val 0x0A) :> (Arg 0x08,Val 0x0B) :> (Arg 0x09,Val 0x0C) :> (Arg 0x0A,Val 0x0D) :> (Arg 0x0B,Val 0x0E) :> (Arg 0x0C,Val 0x0F) :> (Arg 0x0D,Val 0x10) :> (Arg 0x0E,Val 0x11) :> (Arg 0x0F,Val 0x12) :+> Nothing
λ> 
```
