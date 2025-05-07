# Salsa20 Case Study

This document presents a case study in constructing verified cryptographic hardware in ReWire. In it, I follow the Daniel Bernstein's Salsa20 specification: [https://cr.yp.to/snuffle/spec.pdf](https://cr.yp.to/snuffle/spec.pdf). Throughout this tutorial, I'll refer to this document (i.e., the PDF I just linked to) as either the *Salsa20 specification* or simply the "_spec_". Page and section numbers will refer to that document. 

The source code for this example can be found here [https://github.com/harrisonwl/rwcrypto](https://github.com/harrisonwl/rwcrypto) under `src/salsa20`. The original version of the ReWire design here was presented at FPT 2015 (linked to below). ReWire's syntax has evolved since then, but the case study here follows that paper.

Generally speaking, when you're going to prove the correctness of a hardware design (or anything else fo that matter really), you need to have:
  1. a rigorous standard that constitutes a definition of what *to be correct* means;
  2. a precise definition of what the implementation and/or design does; and
  3. some mathematical relationship between (1.) and (2.) that you will demonstrate or prove.
  
The standard in (1.) we will call the *reference semantics* and, for the Salsa20 case study, the 
reference semantics is discussed in the first subsection. The reference semantics is effectively 
a Haskell/ReWire rendering of the pseudocode functions given in the text of Bernstein's 
specification. Our reference semantics is also executable -- e.g., you can load it into GHCi, 
type-check it, and run test cases.

The second subsection describes (2.); that is, the actual ReWire code that can be both compiled to Verilog and reasoned about with formal tools. The first implementation we present is designed for simplicity rather than performance. The third subsection describes (3.) at a very high, somewhat informal level. The purpose of this entire tutorial is to focus on ReWire programming.


#### Recent Relevant Publications 

A more technical presentation can be found in these recent publications:
  - *Temporal Staging for Correct-by-Construction Cryptographic Hardware.*, Yakir Forman and Bill Harrison. Proceedings of the 2024 Rapid Systems Prototyping (RSP24). [pdf](https://harrisonwl.github.io/assets/papers/rsp24.pdf)
  - *Formalized High Level Synthesis with Applications to Cryptographic Hardware.*, Bill Harrison, Ian Blumenfeld, Eric Bond, Chris Hathhorn, Paul Li, May Torrence, and Jared Ziegler. Proceedings of the 2023 NASA Formal Methods Symposium (NFM23). [pdf](https://harrisonwl.github.io/assets/papers/nfm23.pdf)
  - *Provably Correct Development of Reconfigurable Designs via Equational Reasoning.*, Ian Graves, Adam Procter, Bill Harrison, and Gerry Allwein. Proceedings of the 2015 International Conference on Field-Programmable Technology (FPT), [pdf](https://harrisonwl.github.io/assets/papers/fpt15.pdf)
