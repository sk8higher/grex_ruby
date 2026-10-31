# Generation benchmarks

Run from the repository root after compiling the extension in release mode.
All inputs are built before timing. Data contains unique strings of nine Unicode
code points; Unicode strings contain more UTF-8 bytes than ASCII strings.

## Ruby pipeline

```powershell
$env:ITERATIONS = "2"
bundle exec ruby -Ilib benchmark/generate.rb
```

This measures the private native call (including Magnus conversions), the Ruby
adapter on a precomputed pattern, and the public API independently. `bmbm` runs
both a rehearsal and a measured pass. Reported times should not be added or
subtracted to estimate exact overhead; use more repeats and multiple process
runs before drawing conclusions from small differences.

## Direct Rust

Export the exact same Ruby-generated datasets, plus raw patterns for validation:

```powershell
bundle exec ruby -Ilib benchmark/export.rb
```

On Windows with RubyInstaller, select the same GNU target as the extension:

```powershell
$env:CARGO_BUILD_TARGET = "x86_64-pc-windows-gnu"
ridk.cmd exec cargo run --release --manifest-path=benchmark/rust/Cargo.toml -- tmp/benchmark-inputs 2
```

On Linux:

```bash
cargo run --release --manifest-path=benchmark/rust/Cargo.toml -- tmp/benchmark-inputs 2
```

The standalone Cargo project uses its own lockfile and does not build Magnus or
rb-sys. File loading, validation and one-time compiler startup are outside the
measured loops. Rust validates its output against the exported native patterns,
then warms up and measures the same number of generations as the Ruby run.

Use the same toolchain, target, input files and repeat count when comparing.
The Rust caller starts with owned strings, so argument conversion from Ruby is
absent. Results include building and dropping the generated Rust string.
Compilation and cold dependency installation are not benchmarked.

Random datasets with 1000 samples can take seconds per generation. Start with
two repeats. The default is ten in both scripts.

## Example results (2026-10-31)

Environment: Intel Core i5-12450H, Windows x64 (build 26200), Ruby 4.0.7,
grex_ruby 0.3.0, grex 1.4.6, rustc 1.99.1. Both native builds used the
`x86_64-pc-windows-gnu` target and release optimization.

These are preliminary observations from one run per implementation with two
warmup/rehearsal calls and two measured calls per case. All times below are
elapsed milliseconds per generation of a dataset containing 1000 examples:

| Dataset | Ruby native call | Ruby adapter | Full Ruby API | Direct Rust |
| --- | ---: | ---: | ---: | ---: |
| Common prefix | 6.981 | 0.011 | 6.635 | 8.720 |
| Random ASCII | 2638.293 | 0.662 | 2587.141 | 2679.296 |
| Random Unicode | 2582.570 | 0.860 | 2566.244 | 2680.237 |
| Common prefix + digit conversion | 5.192 | 0.010 | 4.714 | 4.595 |

Random ASCII patterns contained 9740 characters/bytes; random Unicode patterns
contained 9728 characters and 17555 UTF-8 bytes. Plain common-prefix patterns
contained only 24 characters. Converted digit patterns contained 16 raw
characters and 32 after Ruby adaptation.

For these inputs, the slow random-string cases remain slow when calling grex
directly without Ruby or Magnus. The adapter took less than one millisecond.
This points to generation inside grex as the dominant cost for these cases;
it is not a general statement about all inputs or a precise estimate of FFI
overhead. The independently timed phases will not add up exactly, and the short
run is particularly noisy for fast cases. Repeat the experiment before quoting
performance numbers. These benchmarks measure generation, not regex matching.
