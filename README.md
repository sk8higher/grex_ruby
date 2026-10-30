# Grex

Grex provides Ruby bindings for the Rust library [grex](https://github.com/pemistahl/grex).
It generates a regular expression pattern from an array of example strings.

## Installation

Install from RubyGems:

```bash
gem install grex_ruby
```

Or add it to your application's bundle:

```bash
bundle add grex_ruby
```

Grex requires Ruby 3.2 or newer. The gem builds its native extension during
installation, so Rust (including Cargo), a C/C++ compiler, Make, libclang, and
matching Ruby development headers must be available.

Follow the dependency setup instructions for [Linux](#linux) or
[Windows](#windows-64-bit-rubyinstaller-with-ucrt) below before installing.
On Windows, set `LIBCLANG_PATH` and `RUST_TARGET` as shown there, then install with:

```powershell
ridk.cmd exec gem install grex_ruby
```

## Usage

`Grex.generate` accepts a non-empty array of strings and returns a Ruby `String`.

The gem name and require path remain `grex_ruby`. `GrexRuby` is kept as an alias
of `Grex` for compatibility with version 0.1.0. The `Grex` module name will be
available in the next release; version 0.1.0 uses `GrexRuby`.

```ruby
require 'grex_ruby'

Grex.generate(%w[a aa aaa])
# => "^a(?:aa?)?$"

Grex.generate(%w[cat])
# => "^cat$"
```

Keyword options:

| Option | Default | Behavior |
| --- | --- | --- |
| `convert_digits` | `false` | Generalizes decimal digits to the Unicode digit class `\p{Nd}`. |
| `convert_repetitions` | `false` | Converts repeated substrings to quantifiers such as `{3}`. |
| `minimum_substring_length` | `1` | Minimum length of a repeated fragment eligible for conversion. |
| `minimum_repetitions` | `1` | Minimum number of repetitions after the fragment's first occurrence. |
| `anchors` | `true` | Keeps grex's `^` and `$` line anchors; set to `false` to omit both. |
| `ignore_case` | `false` | Generates a pattern that matches without regard to letter case. |
| `capturing_groups` | `false` | Uses capturing groups instead of non-capturing groups. |
| `verbose` | `false` | Formats the pattern across multiple lines with indentation and enables extended mode. |

The two minimum settings affect generation when `convert_repetitions: true`.
Both accept integers from `1` to `4_294_967_295`; zero raises `ArgumentError`.
These settings will be available in the next release and are not part of 0.1.0.

```ruby
Grex.generate(%w[123])
# => "^123$"

Grex.generate(%w[123], convert_digits: true)
# => "^\\p{Nd}\\p{Nd}\\p{Nd}$"

Grex.generate(['aaa'], convert_repetitions: true)
# => "^a{3}$"

Grex.generate(['111'], convert_digits: true, convert_repetitions: true)
# => "^\\p{Nd}{3}$"
```

Control which repetitions are converted:

```ruby
Grex.generate(['aaaa'], convert_repetitions: true, minimum_substring_length: 2)
# => "^aaaa$"

Grex.generate(['ababab'], convert_repetitions: true, minimum_substring_length: 2)
# => "^(?:ab){3}$"

Grex.generate(['aa'], convert_repetitions: true, minimum_repetitions: 2)
# => "^aa$"

Grex.generate(['aaa'], convert_repetitions: true, minimum_repetitions: 2)
# => "^a{3}$"
```

For `minimum_repetitions`, the first occurrence is not counted as a repetition:
`'aa'` has one repetition of `'a'`, while `'aaa'` has two.

Digit conversion allows other decimal digits to match too, including non-ASCII
digits. Grex adapts grex's `\d` tokens to `\p{Nd}` because Ruby's `\d` matches
only ASCII digits.

Pass the returned pattern to `Regexp.new` to match strings. Special characters
in the examples, such as the dot below, are escaped:

```ruby
pattern = Grex.generate(['a.b'])
# => "^a\\.b$"

regexp = Regexp.new(pattern)

regexp.match?('a.b')
# => true

regexp.match?('axb')
# => false
```

### Capturing groups

By default, groups introduced by grex are non-capturing. Set
`capturing_groups: true` to make their matches available through `MatchData#captures`:

```ruby
pattern = Grex.generate(%w[cat dog], capturing_groups: true)
regexp = Regexp.new(pattern)

regexp.match('cat').captures
# => ["cat"]

regexp.match('dog').captures
# => ["dog"]
```

This option changes groups created by grex; it does not force a group around
every pattern. The `capturing_groups` and `ignore_case` options will be available
in the next release and are not part of 0.1.0.

### Verbose patterns

Set `verbose: true` to generate a multiline pattern. Use `puts` to display
the actual line breaks:

```ruby
pattern = Grex.generate(%w[cat dog], verbose: true)
puts pattern
```

Output:

```text
(?x)
^
  (?:
    cat
    |
    dog
  )
$
```

The inline `(?x)` flag enables extended mode: formatting whitespace is ignored
and unescaped `#` starts a comment. grex escapes literal spaces and hashes from
the input examples so that they still match:

```ruby
pattern = Grex.generate(['a b#c'], verbose: true)
regexp = Regexp.new(pattern)

regexp.match?('a b#c')
# => true

regexp.match?('ab#c')
# => false
```

The `verbose` option will be available in the next release and is not part of 0.1.0.

### Anchors in Ruby

By default, grex generates `^` and `$` anchors. In Ruby these match the beginning
and end of a line, so the pattern can match a complete line inside multiline text:

```ruby
regexp = Regexp.new(Grex.generate(['cat']))

regexp.match?("dog\ncat\nbird")
# => true
```

Use `anchors: false` to allow matches within a line as well:

```ruby
pattern = Grex.generate(['cat'], anchors: false)
# => "cat"

Regexp.new(pattern).match?('a cat sleeps')
# => true
```

Ruby's `\A` and `\z` anchor the entire string rather than individual lines.
Grex preserves grex's line anchors and does not automatically replace them with
`\A` and `\z`. The `anchors` option will be available in the next release;
it is not part of 0.1.0.

### Invalid input

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

The Ruby bindings in this project are available under the [MIT License](LICENSE.txt).
The underlying Rust library grex is licensed under
[Apache License 2.0](licenses/grex-APACHE-2.0.txt).
Dependencies retain their own licenses; see [third-party notices](THIRD_PARTY_NOTICES.md).
