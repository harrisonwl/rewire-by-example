
## Tiny ISA

We now describe a simple processor with a tiny instruction set (hence the name [TinyISA.hs](TinyISA.hs)). TinyISA has four 8-bit registers, 6-bit addresses, and five instructions. 
```haskell
type W6    = W 6
type W8    = W 8
data Reg   = R0 | R1 | R2 | R3 
type Addr  = W6
data Instr = NOP
           | LD Addr
           | ST Addr
           | NAND Reg Reg Reg
           | BNZ Addr
```

### Inputs, outputs, and register file.

TinyISA has two inputs, represented by the record type `Ins`, with two fields for the instruction to execute (`instrIn`) and a `dataIn` for data read from memory. 
The register file `RegFile` is a record type as well
```haskell
data Ins     = Ins { instrIn :: Instr,
                     dataIn  :: W 8 }
data Out     = Out { weOut   :: Bit,
                     addrOut :: Addr,
                     dataOut :: W 8 }
data RegFile = RegFile { r0 :: W 8, r1 :: W 8, r2 :: W 8, r3 :: W 8,
                         pc :: Addr, inputs :: Ins, outputs :: Out }
```

```haskell
type S   = StateT RegFile Identity
type Dev = ReacT Ins Out S
```

```haskell
-- read, write, and increment the PC
getPC :: S Addr
getPC = do s <- get
           return (pc s)
           
putPC :: Addr -> S ()
putPC a = do s <- get
             put (s { pc = a })

incrPC :: S ()
incrPC = do pc <- getPC
            putPC (pc + lit 1)
```

```haskell
-- read and write each register
getReg :: Reg -> S (W 8)
getReg R0 = get >>= return . r0
getReg R1 = get >>= return . r1 
getReg R2 = get >>= return . r2 
getReg R3 = get >>= return . r3
            
putReg :: Reg -> W 8 -> S ()
putReg R0 b = get >>= \ s -> put (s { r0 = b })
putReg R1 b = get >>= \ s -> put (s { r1 = b })
putReg R2 b = get >>= \ s -> put (s { r2 = b })
putReg R3 b = get >>= \ s -> put (s { r3 = b })
```

```haskell
getOut :: S Out
getOut   = do
             s <- get
             return (outputs s) 

putOut :: Out -> S ()
putOut o = do
             s <- get
             put (s { outputs = o })

getIns :: S Ins
getIns   = do
             s <- get
             return (inputs s)

getDataIn :: S (W 8)
getDataIn = do
              i <- getIns
              return (dataIn i) 

getInstr :: S Instr
getInstr = do
             i <- getIns
             return (instrIn i) 

putIns :: Ins -> S ()
putIns i = do
             s <- get
             put (s { inputs = i })

tick :: Dev ()
tick     = do o <- lift getOut
              i <- signal o
              lift (putIns i)

putWeOut :: Bit -> S ()
putWeOut b = do o <- getOut
                putOut (o { weOut = b })

putAddrOut :: Addr -> S ()                       
putAddrOut a = do o <- getOut
                  putOut (o { addrOut = a })

putDataOut :: W 8 -> S ()                  
putDataOut d = do o <- getOut
                  putOut (o { dataOut = d })
```
