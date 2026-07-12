# ReWire-by-Example Tutorial

This is an online tutorial written using [mdbook](https://github.com/rust-lang/mdBook).

## Reading the tutorial

* Install `mdbook`: either from the above github or via homebrew.
* From the repository root, run `mdbook serve`; this will let you view the
  tutorial at `http://localhost:3000` in your browser.

I will be adding chapters to this tutorial periodically. If there's a
particular thing you're looking for, just send me an email.

## Running the code

Each chapter's example code lives under `src/code/<chapter>/` (for example,
the chapter in `src/chapters/chapter1` discusses code in `src/code/chapter1`).
The code within a chapter may import other modules from the *same* chapter,
but not from other chapters.

All of this code depends on the
[ReWire](https://github.com/rewire-hardware/ReWire) `rewire-user` library,
which provides the `ReWire`, `ReWire.Bits`, `ReWire.Finite`, `ReWire.Vectors`,
and `ReWire.Interactive` modules. Everything is wired up with
[stack](https://docs.haskellstack.org), so you don't need to install ReWire
separately.

### One-time setup

Check out this repository and build the dependencies. The first build fetches
`rewire-user` (pinned in `stack.yaml`) and compiles it along with the required
GHC plugins, so it takes a few minutes:

```sh
stack build
```

### Loading and evaluating a chapter's code

The example files are meant to be loaded and explored one at a time in GHCi.
Point `stack ghci` at any chapter file:

```sh
stack ghci src/code/chapter1/Fib.hs
```

Then evaluate things at the prompt, e.g.:

```
ghci> :type start
ghci> :browse
```

Because most example files are standalone modules (and some reuse names like
`f` or `W8`, or import `ReWire.Interactive`), load them individually rather
than all at once.

You can also load a file from inside an already-running session, which
guarantees the project's GHC options (DataKinds and the `ghc-typelits-*`
plugins) are applied:

```sh
stack ghci
ghci> :load src/code/chapter1/Fib.hs
```

## Structure of the repo

```
rewire-by-example/
├── book.toml                  # mdBook configuration
├── stack.yaml                 # stack resolver + ReWire (rewire-user) dependency
├── rewire-by-example.cabal    # root package; `stack build` compiles the deps
├── app/
│   └── Main.hs                # trivial exe that anchors the build
└── src/
    ├── SUMMARY.md             # mdBook table of contents
    ├── chapters/              # Markdown for each chapter
    │   ├── chapter1/
    │   └── ...
    └── code/                  # Runnable Haskell/ReWire code per chapter
        ├── chapter1/
        ├── chapter2/
        └── ...
```
