# Reference Semantics

This section introduces the reference semantics for Salsa20 written in Haskell/ReWire. The development follows Bernstein's specification closely, including a section here corresponding to each one in his specification. The result is an executable, type-checked version of Salsa20 in Haskell/ReWire.

## Why do you keep saying *Haskell/ReWire*?

Recall that ReWire is a domain-specific language embedded in Haskell---i.e., every ReWire design is a legal Haskell program but the converse does not hold. When I say *Haskell/ReWire*, I mean a Haskell program that makes use of ReWire constructs (e.g., bit vectors) but that, for one reason or another, is not legal ReWire. For example, ReWire does not support Haskell's class system and requires that data structures be finite in nature. 




