# Third-party notices

The Ruby bindings in this repository are licensed under MIT; see `LICENSE.txt`.
Dependencies retain their own licenses. The MIT license for the bindings does
not replace the licenses of those dependencies.

## grex

- Version: 1.4.6 (see `Cargo.lock` for the resolved version).
- Project: https://github.com/pemistahl/grex
- License: Apache License, Version 2.0.
- Upstream copyright notice: Copyright © 2019-today Peter M. Stahl pemistahl@gmail.com
- License text: `licenses/grex-APACHE-2.0.txt`, copied unchanged from the grex 1.4.6 crate.

The bindings call grex through its public API. The source gem declares grex as
a Cargo dependency; Cargo downloads it when building the native extension.
The resulting native extension contains compiled dependency code.

No separate NOTICE file was present in the grex 1.4.6 crate inspected for this
release. This document records grex attribution and is not an upstream NOTICE file.

Other dependencies listed in `Cargo.lock` and the gemspec have their own license
terms. Before distributing precompiled gems, include the applicable license
texts and notices for all dependencies incorporated into those binaries.
