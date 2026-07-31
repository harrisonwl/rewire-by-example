# Summary

[ReWire by Example](./rewire-by-example.md)

# Prerequisites

- [Prerequisites](./chapters/chapter0/prequisites.md)

- [Haskell Resources](./chapters/chapter0/haskell.md)
  
- [Monads in Haskell](./chapters/chapter0/monadwrangling/monadwrangling.md)

     - [Simple Arithmetic Expressions](./chapters/chapter0/monadwrangling/FirstInterpreter.md)

     - [Identity Monad](./chapters/chapter0/monadwrangling/IdentityBigNothing.md)

     - [Second Interpreter: Errors and Maybe](./chapters/chapter0/monadwrangling/Errors.md)

     - [Register](./chapters/chapter0/monadwrangling/Register.md)

     - [Errors and Register](./chapters/chapter0/monadwrangling/RegisterErrors.md)
  
# Introduction

- [Hello Worlds in ReWire](./chapters/chapter1/helloworlds.md)

   - [Simple Mealy](./chapters/chapter1/simplemealy.md)

   - [Fibonacci, of course](./chapters/chapter1/fibonacci.md)

   - [Carry Save Adders](./chapters/chapter1/carrysaveadders.md)

- [Basic Designs](./chapters/basicdesigns/basics.md)
    - [UART](./chapters/basicdesigns/UART.md)
    - [Simple Processors](./chapters/basicdesigns/simpleprocs.md)
         - [Tiny ISA](./chapters/basicdesigns/tinyisa.md)
    - [Cross Bar Switch](./chapters/basicdesigns/crossbarswitch.md)


# Cryptographic Hardware in ReWire
   
- [Blake2b Case Study](./chapters/blake2b/front.md)

   - [Reference Semantics](./chapters/blake2b/semantics.md)
 
   - [Conversion into ReWire](./chapters/blake2b/correctbyconstruction.md)
 
- [Salsa20 Case Study](./chapters/salsa20/front.md)

   - [Reference Semantics](./chapters/salsa20/semantics.md)
   
      - [Introduction](./chapters/salsa20/introduction.md)

      - [Words](./chapters/salsa20/words.md)
   
      - [The quarterround function](./chapters/salsa20/quarterround.md)

      - [The rowround function](./chapters/salsa20/rowround.md)

      - [The columnround function](./chapters/salsa20/columnround.md)

      - [The doubleround function](./chapters/salsa20/doubleround.md)

      - [The littleendian function](./chapters/salsa20/littleendian.md)

      - [Salsa20 Hash function](./chapters/salsa20/hashfunction.md)

      - [Salsa20 Expansion function](./chapters/salsa20/expansionfunction.md)

      - [Salsa20 Encryption function](./chapters/salsa20/encryption.md)

- [Pipelining in ReWire](./chapters/pipelining/pipelining.md)

   - [Hello World Example](./chapters/pipelining/onetwothree.md)
   - [One, Two, Three,... Stall](./chapters/pipelining/stalling123.md)
   - [Pipelined Doubleround](./chapters/pipelining/doubleround.md)

- [AES Case Study](./chapters/aes/aescasestudy.md)

   - [Reference Semantics](./chapters/aes/semantics.md)
 
     - [Key Expansion](./chapters/aes/keyexpansion.md)
	     - [Rot- and SubWord](./chapters/aes/rotword.md)

     - [Cipher Operations](./chapters/aes/operations.md)
	     - [ShiftRows](./chapters/aes/shiftrows.md)
	     - [AddRoundKey](./chapters/aes/addroundkey.md)
	     - [MixColumns](./chapters/aes/mixcolumns.md)
	     - [SubBytes](./chapters/aes/subbytes.md)

   - [Conversion into ReWire](./chapters/aes/correctbyconstruction.md)


   <!--  - [Simple Arithmetic](./chapters/chapter0/monadwrangling/FirstInterpreter.md) -->
   <!-- - [Identity is a Big Nothingburger](./chapters/chapter0/monadwrangling/IdentityBigNothing.md) -->
   <!-- - [Errors and Maybe](./chapters/chapter0/monadwrangling/Errors.md) -->
   <!-- - [Adding a Register](./chapters/chapter0/monadwrangling/Register.md) -->
   <!-- - [Errors + Register](./chapters/chapter0/monadwrangling/RegisterErrors.md) -->

