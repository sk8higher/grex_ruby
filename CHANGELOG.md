# Changelog

## 0.3.1

- Add a documentation link to the GitHub README in RubyGems metadata.
- Keep reproducible benchmarks in the repository and exclude them from the gem package.

## 0.3.0

- Add `Grex.generate_from_file` with UTF-8 input, LF/CRLF line handling and keyword options.
- Add the `grex-ruby` command with flags for every generation option.
- Add command-line help, version output and readable errors with nonzero exit status.
- Document file input and command-line usage, including local development commands.
- Add integration tests for the CLI and file-based generation.

## 0.2.0

- Expose the public API as `Grex`, keeping `GrexRuby` as a compatibility alias.
- Add conversion of non-digits, whitespace, non-whitespace, words and non-words.
- Adapt character classes for Unicode matching in Ruby, preserving escaped literals.
- Add minimum repetition count and minimum repeated substring length settings.
- Support case-insensitive matching, capturing groups and verbose patterns.
- Allow disabling both anchors or the start and end anchors individually.
- Support non-ASCII escaping with Unicode code points understood by Ruby Regexp.
- Document Ruby's line anchor semantics and local build prerequisites.
- Include grex's Apache-2.0 license and third-party attribution in the gem.
- Add regression coverage for combinations of conversion options.

## 0.1.0

- Generate regular expression patterns from arrays of strings.
- Support digit and repetition conversion.
- Adapt digit classes for Unicode matching in Ruby.
