# Changelog

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
