## Salsa20 Encryption function

### Remarks on Section 10 & A Quick Demo

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
