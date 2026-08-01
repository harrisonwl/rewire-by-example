# Operations

```haskell
addRoundKey :: RoundKey -> State -> State
addRoundKey rk s = generate $ \ i ->
                   generate $ \ j ->
                      lkup s (i , j) ^ lkup rk (i , j)             
```

```haskell
subbytes :: State -> State
subbytes s = generate $ \ i ->
             generate $ \ j -> let xij = (s `index` i) `index` j in
                                 sbox xij
```
