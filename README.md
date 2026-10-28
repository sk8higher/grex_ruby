# GrexRuby

GrexRuby provides Ruby bindings for the Rust library [grex](https://github.com/pemistahl/grex).
It generates a regular expression pattern from an array of example strings.

## Installation

The gem is not published yet. To build it locally, follow the development instructions below.

## Usage

`GrexRuby.generate` accepts a non-empty array of strings and returns a Ruby `String`.

```ruby
require 'grex_ruby'

GrexRuby.generate(%w[a aa aaa])
# => "^a(?:aa?)?$"

GrexRuby.generate(%w[cat])
# => "^cat$"
```

Both keyword options default to `false`:

| Option | Behavior when enabled |
| --- | --- |
| `convert_digits` | Generalizes decimal digits to the Unicode digit class `\p{Nd}`. |
| `convert_repetitions` | Converts repeated substrings to quantifiers such as `{3}`. |

```ruby
GrexRuby.generate(%w[123])
# => "^123$"

GrexRuby.generate(%w[123], convert_digits: true)
# => "^\\p{Nd}\\p{Nd}\\p{Nd}$"

GrexRuby.generate(['aaa'], convert_repetitions: true)
# => "^a{3}$"

GrexRuby.generate(['111'], convert_digits: true, convert_repetitions: true)
# => "^\\p{Nd}{3}$"
```

Digit conversion allows other decimal digits to match too, including non-ASCII
digits. GrexRuby adapts grex's `\d` tokens to `\p{Nd}` because Ruby's `\d` matches
only ASCII digits.

Pass the returned pattern to `Regexp.new` to match strings. Special characters
in the examples, such as the dot below, are escaped:

```ruby
pattern = GrexRuby.generate(['a.b'])
# => "^a\\.b$"

regexp = Regexp.new(pattern)

regexp.match?('a.b')
# => true

regexp.match?('axb')
# => false
```

An empty array raises `ArgumentError` with the message `samples must not be empty`.
Passing a string instead of an array, or an array containing an integer, raises
`TypeError`.

## Development

### Linux

Use Ruby 3.2 or newer, Bundler, and a current stable Rust toolchain installed
via [rustup](https://rustup.rs/). Run the build commands from the project directory.

Install a C/C++ compiler, Make, pkg-config, and libclang.

On Ubuntu/Debian:

```bash
sudo apt update
sudo apt install build-essential pkg-config libclang-dev
```

On Fedora:

```bash
sudo dnf install gcc gcc-c++ make pkgconf-pkg-config clang-devel
```

Ruby's development headers must match the Ruby used to build the extension.
If using the distribution's Ruby, also install `ruby-dev` on Ubuntu/Debian
or `ruby-devel` on Fedora. Check `ruby -v`: some distribution releases provide
a Ruby version older than this gem supports. Ruby installed through a version
manager usually already includes matching headers.

Install Bundler if needed, then install the gem dependencies, compile, and run RSpec:

```bash
gem install bundler
bundle install
bundle exec rake
```

Use the default native Linux Rust target. The Windows `RUST_TARGET` setting
and `ridk.cmd` are not needed. With the packages above, libclang should be
discovered automatically; if it is installed in a custom location, set
`LIBCLANG_PATH` to the directory containing `libclang.so`.

See the [bindgen requirements](https://rust-lang.github.io/rust-bindgen/requirements.html)
for libclang installation details.

### Windows (64-bit RubyInstaller with UCRT)

Install RubyInstaller with Devkit and Rust via rustup before running these commands.
Run the commands from the project directory in PowerShell.

Update the MSYS2 environment used by RubyInstaller:

```powershell
ridk.cmd exec pacman -Syu
```

If the update asks you to close the terminal, open a new PowerShell and run the
same command again to finish updating the remaining packages.

Install Clang (including libclang, used to read Ruby's C headers), the Rust GNU
target matching RubyInstaller, and the Ruby dependencies:

```powershell
ridk.cmd exec pacman -S mingw-w64-ucrt-x86_64-clang
rustup target add x86_64-pc-windows-gnu
bundle install
```

Set the build environment, then compile the extension and run RSpec:

```powershell
# Adjust this path if RubyInstaller is installed elsewhere.
$env:LIBCLANG_PATH = "C:\Ruby40-x64\msys64\ucrt64\bin"
$env:RUST_TARGET = "x86_64-pc-windows-gnu"
ridk.cmd exec bundle exec rake
```

Set these environment variables again when opening a new PowerShell session.
Use `ridk.cmd exec` to select RubyInstaller's build tools when other MSYS2
installations, such as devkitPro, are also present.

`bundle exec rake` compiles the extension before running the tests;
`bundle exec rake spec` only runs the tests and requires an existing build.

### Build a local gem

```bash
bundle exec rake build
```

The package is written to `pkg/grex_ruby-<version>.gem`. On Windows, run the
command through `ridk.cmd exec` with the environment variables shown above.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sk8higher/grex_ruby.

## License

GrexRuby is available under the [MIT License](LICENSE.txt).
