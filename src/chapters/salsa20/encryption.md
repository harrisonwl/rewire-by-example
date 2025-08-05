## Salsa20 Encryption function

The definitions below can be found in [Encrypt.hs](https://github.com/harrisonwl/rwcrypto/blob/main/src/salsa20/Encrypt.hs) and the testing code can be found in [Test_Encrypt.hs](https://github.com/harrisonwl/rwcrypto/blob/main/src/salsa20/Test_Encrypt.hs).

### Remarks on Section 10 & A Quick Demo

This section defines the Salsa20 encrypt function from Section 10 of Bernstein. In the FIPS document, the function is (very confusingly IMHO) called \\(Salsa20_{k}(v){\oplus}m\\). The snippet of the FIPS document that is most relevant here is:
<p align="center"><img src="./salsa20encryption.jpg"  style="height:70%; width:70%" ></p>


### Inputs and Outputs

### Definition

```haskell
encrypt :: Hex (W 8) -> Hex (W 8) -> Oct (W 8) -> W 64 -> W 8 ->  W 8
encrypt k0 k1 v i mi = mi ^ ((salsa20_k0k1 (k0 , k1) (splice v (factor64 i))) `pi64` (mod64 i))
```

```haskell
-- |
-- | This is factor function tweeked so that it takes (W 64) as input instead of Integer. 
-- |
factor64 :: W 64 -> (W 8 , W 8 , W 8 , W 8 , W 8 , W 8 , W 8 , W 8 )
mod64    :: W 64 -> W 6
```
