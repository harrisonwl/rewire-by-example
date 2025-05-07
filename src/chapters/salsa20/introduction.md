# Introduction

The reference semantics culminates in the definition of a Salsa20 encryption function of the following type:
```haskell
encrypt :: Hex (W 8) -> Hex (W 8) -> Oct (W 8) -> W 64 -> W 8 -> W 8
```

What exactly this means will be apparent as you read the reference semantics subsection, but it is simply a Haskell transliteration of the function defined in Section 10 of Bernstein's specification; along the way, I recommend that you keep a copy of his spec handy throughout. At first, you will find that our definitions correspond very closely to his. Towards the end of his spec, I think you will find our reference semantics much easier to understand.



