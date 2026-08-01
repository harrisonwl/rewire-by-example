# AddRoundKey


<img src="images/addroundkey.png"  style="height:75%; width:75%" >

```haskell
addRoundKey :: RoundKey -> State -> State
addRoundKey rk s = generate $ \ i ->
                   generate $ \ j ->
                      lkup s (i , j) ^ lkup rk (i , j)
```
