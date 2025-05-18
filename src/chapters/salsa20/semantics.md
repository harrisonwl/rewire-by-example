# Reference Semantics

This section introduces the reference semantics for Salsa20 written in Haskell/ReWire. The development follows Bernstein's specification closely, including a section here corresponding to each one in his specification. The result is an executable, type-checked version of Salsa20 in Haskell/ReWire.

With this Salsa20 reference semantics, we can define a test function (`encryptS20 :: String -> String` below) that encrypts a message with the same key. Running `encryptS20` twice on the same plaintext message should, and does, return the original plaintext. For example, consider the following GHCi output where we first print the message and then run the test function on it twice:
```
λ> putStrLn godzilla_haiku
With artillery
You greet your nuclear child
Am I the monster?
λ> putStrLn (encryptS20 . encryptS20 $ godzilla_haiku)
With artillery
You greet your nuclear child
Am I the monster?
```

## Why do you keep saying *Haskell/ReWire*?

ReWire is a domain-specific language embedded in Haskell---i.e., every ReWire design is a legal Haskell program but the converse does not hold. When I say *Haskell/ReWire*, I mean a Haskell program that makes use of ReWire constructs (e.g., bit vectors) but that, for one reason or another, is not legal ReWire. A frequently used Haskell feature that is *not* inherited by ReWire currently is the type class system. More fundamental is the restrictions on recursion. However, it is often helpful while developing and testing ReWire designs to have access to Haskell's full power.

#### Aside on ReWire's Limits on Recursion 

Functional recursion is limited to functions with codomains typed in `ReacT`. E.g., recall the carry-save adder example from the previous chapter:
```haskell
csa :: (W 8, W 8, W 8) -> ReacT (W 8, W 8, W 8) (W 8, W 8) Identity ()
```
Similarly, data recursion (e.g., lists) is not allowed in ReWire because hardware data structures are necessarily finite. 

Arbitrary recursion for functions and data requires unbounded storage like heaps and stacks to implement and that is incompatible with hardware's fixed, finite storage footprint.




