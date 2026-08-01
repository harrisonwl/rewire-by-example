# ShiftRows

<img src="images/ShiftRows.png"  style="height:75%; width:75%" >

```haskell
shiftrows :: State -> State
shiftrows v = generate $ \ i ->
              generate $ \ j ->
                            (v `index` i) `index` (j FC.+ i)
```
