# Pipelining

Let's say you have three functions, `f`, `g`, and `h`. Obviously, you can compose them (`h . g . f` in Haskell).  It's a fairly common situation that one wants to compose them *temporally*---i.e., to pipeline them.
The idea is that, for each clock tick, there's one input `i`, and `h (g (f i))` is calculated over the next three ticks:

| Input | `f` | `g` | `h` | Output | 
| :-----------: | :------------: | :------------: | :------------: | :------------: |
| `i0` | `f i0` |  | | |
| `i1` | `f i1` | `g (f i0)` | | |
| `i2` | `f i2` | `g (f i1)` | `h (g (f i0))` | |
| `i3` | `f i3` | `g (f i2)` | `h (g (f i1))` | `h (g (f i0))` |
| \\(\vdots\\) | \\(\vdots\\)  | \\(\vdots\\)  | \\(\vdots\\) | \\(\vdots\\) |

Pipelining is a common hardware design technique for splitting large computations into smaller computations over time. ReWire makes such pipelining both easy to express and formally verify.

In the Salsa20 hash function ([Section 3.1.8](../salsa20/hashfunction.md)), there is a place where the `doubleround` function is composed ten times:
```haskell
dr10 :: Hex (W 32) -> Hex (W 32)
dr10 = doubleround . doubleround . doubleround . doubleround . doubleround .
          doubleround . doubleround . doubleround . doubleround . doubleround 
```
The `doubleround` function has a lot of arithmetic operations contained in it and its tenfold composition `dr10`, when unrolled into combinational logic, has many, many such operations. So, it's a good opportunity for pipelining.
This is a great opportunity for pipelining.

First, we will illustrate how pipelines are defined in ReWire, and then apply that same structuring technique to `doubleround`. 
