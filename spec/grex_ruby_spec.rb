# frozen_string_literal: true

RSpec.describe Grex do
  it 'preserves the GrexRuby alias for compatibility' do
    expect(GrexRuby).to equal(Grex)
    expect(GrexRuby.generate(['cat'])).to eq('^cat$')
  end

  it 'has a version number' do
    expect(Grex::VERSION).not_to be nil
  end

  it 'can call generate with doc example' do
    result = Grex.generate(%w[a aa aaa])

    expect(result).to eq('^a(?:aa?)?$')
  end

  it 'can call grex on a word' do
    result = Grex.generate(%w[cat])

    expect(result).to eq('^cat$')
  end

  it 'raises ArgumentError if array is empty' do
    expect { Grex.generate([]) }.to raise_error(ArgumentError, 'samples must not be empty')
  end

  it 'works with digits off' do
    result = Grex.generate(%w[123])

    expect(result).to eq('^123$')
  end

  it 'works with digits' do
    result = Grex.generate(%w[123], convert_digits: true)

    expect(result).to eq('^\\p{Nd}\\p{Nd}\\p{Nd}$')
  end

  it 'raises TypeError if a string is passed as an argument' do
    expect { Grex.generate('cat') }.to raise_error(TypeError)
  end

  it 'raises TypeError if an array contains non string values' do
    expect { Grex.generate(['cat', 123]) }.to raise_error(TypeError)
  end

  it 'escapes literal dot' do
    pattern = Grex.generate(['a.b'])
    regexp = Regexp.new(pattern)

    expect(regexp.match?('a.b')).to eq(true)
    expect(regexp.match?('axb')).to eq(false)
  end

  it 'works with unicode: cyrillic' do
    pattern = Grex.generate(%w[кот кит])
    regexp = Regexp.new(pattern)

    expect(regexp.match?('кот')).to eq(true)
    expect(regexp.match?('кит')).to eq(true)
    expect(regexp.match?('кат')).to eq(false)
  end

  it 'works with unicode: emojis' do
    pattern = Grex.generate(['🐈'])
    regexp = Regexp.new(pattern)

    expect(regexp.match?('🐈')).to eq(true)
    expect(regexp.match?('🐕')).to eq(false)
  end

  it 'works with unicode: arabic digits' do
    pattern = Grex.generate(['١٢٣'], convert_digits: true)
    regexp = Regexp.new(pattern)

    expect(regexp.match?('١٢٣')).to eq(true)
  end

  it 'preserves literal backslashes when converting digit' do
    pattern = Grex.generate(['\\d', '123'], convert_digits: true)
    regexp = Regexp.new(pattern)

    expect(regexp.match?('\\d')).to eq(true)
    expect(regexp.match?('ddd')).to eq(false)
    expect(regexp.match?('123')).to eq(true)
  end

  it 'works with char repetitions' do
    result = Grex.generate(['aaa'], convert_repetitions: true)

    expect(result).to eq('^a{3}$')
  end

  it 'works with char repetitions false' do
    result = Grex.generate(['aaa'])

    expect(result).to eq('^aaa$')
  end

  it 'works with char repetitions and convert digits' do
    pattern = Grex.generate(['111'], convert_digits: true, convert_repetitions: true)
    regexp = Regexp.new(pattern)

    expect(regexp.match?('111')).to eq(true)
    expect(pattern).to eq('^\p{Nd}{3}$')

    expect(regexp.match?('١٢٣')).to eq(true)
    expect(regexp.match?('11')).to eq(false)
    expect(regexp.match?('1111')).to eq(false)
  end

  it 'leaves repetitions shorter than minimum_substring_length unconverted' do
    result = Grex.generate(%w[aaaa], convert_repetitions: true, minimum_substring_length: 2)

    expect(result).to eq('^aaaa$')
  end

  it 'converts repetitions whose substring length meets minimum_substring_length' do
    result = Grex.generate(%w[ababab], convert_repetitions: true, minimum_substring_length: 2)

    expect(result).to eq('^(?:ab){3}$')
  end

  it 'rejects a zero minimum_substring_length with ArgumentError' do
    expect do
      Grex.generate(%w[aaaa],
                    minimum_substring_length: 0)
    end.to raise_error(ArgumentError, 'minimum_substring_length must be greater than zero')
  end

  it 'leaves substrings with fewer repetitions than minimum_repetitions unconverted' do
    result = Grex.generate(%w[aa], convert_repetitions: true, minimum_repetitions: 2)

    expect(result).to eq('^aa$')
  end

  it 'converts substrings with enough repetitions to meet minimum_repetitions' do
    result = Grex.generate(%w[aaa], convert_repetitions: true, minimum_repetitions: 2)

    expect(result).to eq('^a{3}$')
  end

  it 'rejects a zero minimum_repetitions with ArgumentError' do
    expect do
      Grex.generate(%w[aaaa],
                    minimum_repetitions: 0)
    end.to raise_error(ArgumentError, 'minimum_repetitions must be greater than zero')
  end

  it 'matches within a larger string when anchors are disabled' do
    pattern = Grex.generate(['cat'], anchors: false)
    regexp = Regexp.new(pattern)

    expect(regexp.match?('a cat sleeps')).to eq(true)
    expect(pattern).to eq('cat')
  end

  it 'works with ignore_case' do
    pattern = Grex.generate(['cat'], ignore_case: true)
    regexp = Regexp.new(pattern)

    expect(regexp.match?('cat')).to eq(true)
    expect(regexp.match?('Cat')).to eq(true)
    expect(regexp.match?('CAT')).to eq(true)
  end

  it 'works with ignore_case: unicode' do
    pattern = Grex.generate(['кот'], ignore_case: true)
    regexp = Regexp.new(pattern)

    expect(regexp.match?('КОТ')).to eq(true)
  end

  it 'does not capture grouped alternatives by default' do
    pattern = Grex.generate(%w[cat dog])
    regexp = Regexp.new(pattern)

    %w[cat dog].each do |sample|
      match = regexp.match(sample)
      expect(match).not_to be_nil
      expect(match.captures).to eq([])
    end
  end

  it 'captures grouped alternatives when capturing_groups is enabled' do
    pattern = Grex.generate(%w[cat dog], capturing_groups: true)
    regexp = Regexp.new(pattern)

    %w[cat dog].each do |sample|
      match = regexp.match(sample)
      expect(match).not_to be_nil
      expect(match.captures).to eq([sample])
    end
  end

  it 'matches case-sensitivity by default' do
    pattern = Grex.generate(['cat'])
    regexp = Regexp.new(pattern)

    expect(regexp.match?('cat')).to eq(true)
    expect(regexp.match?('CAT')).to eq(false)
  end

  it 'formats a working pattern across multiple lines in verbose mode' do
    pattern = Grex.generate(%w[cat dog], verbose: true)
    regexp = Regexp.new(pattern)

    expect(pattern).to include("\n")
    expect(regexp.match?('cat')).to eq(true)
    expect(regexp.match?('dog')).to eq(true)
  end

  it 'generalizes non-digit characters when convert_non_digits is enabled' do
    pattern = Grex.generate(['abc'], convert_non_digits: true)
    regexp = Regexp.new(pattern)

    expect(regexp.match?('abc')).to eq(true)
    expect(regexp.match?('xyz')).to eq(true)
  end

  it 'excludes ASCII and Unicode digits when converting non-digits' do
    pattern = Grex.generate(['abc'], convert_non_digits: true)
    regexp = Regexp.new(pattern)

    expect(regexp.match?('123')).to eq(false)
    expect(regexp.match?('١٢٣')).to eq(false)
  end

  it 'preserves a literal backslash followed by D when converting non-digits' do
    pattern = Grex.generate(['\\D', 'abc'], convert_non_digits: true)
    regexp = Regexp.new(pattern)

    expect(regexp.match?('\\D')).to eq(true)
    expect(regexp.match?('abc')).to eq(true)
    expect(regexp.match?('١٢٣')).to eq(false)
  end

  it 'keeps literal whitespace by default' do
    regexp = Regexp.new(Grex.generate(['a b']))

    expect(regexp.match?('a b')).to eq(true)
    expect(regexp.match?("a\tb")).to eq(false)
  end

  it 'generalizes spaces to other whitespace when convert_whitespace is enabled' do
    regexp = Regexp.new(Grex.generate(['a b'], convert_whitespace: true))

    expect(regexp.match?('a b')).to eq(true)
    expect(regexp.match?("a\tb")).to eq(true)
    expect(regexp.match?('ab')).to eq(false)
    expect(regexp.match?('a-b')).to eq(false)
  end

  it 'matches Unicode whitespace when convert_whitespace is enabled' do
    sample = "a\u00A0b" # NO-BREAK SPACE
    regexp = Regexp.new(Grex.generate([sample], convert_whitespace: true))

    expect(regexp.match?(sample)).to eq(true)
    expect(regexp.match?("a\u2003b")).to eq(true) # EM SPACE
    expect(regexp.match?('a b')).to eq(true)
  end

  it 'preserves a literal backslash followed by s when converting whitespace' do
    regexp = Regexp.new(Grex.generate(['\\s', 'a b'], convert_whitespace: true))

    expect(regexp.match?('\\s')).to eq(true)
    expect(regexp.match?("a\tb")).to eq(true)
    expect(regexp.match?('s')).to eq(false)
  end

  it 'keeps non-whitespace characters literal by default' do
    regexp = Regexp.new(Grex.generate(['abc']))

    expect(regexp.match?('abc')).to eq(true)
    expect(regexp.match?('xyz')).to eq(false)
  end

  it 'generalizes non-whitespace characters including digits when enabled' do
    regexp = Regexp.new(Grex.generate(['abc'], convert_non_whitespace: true))

    expect(regexp.match?('abc')).to eq(true)
    expect(regexp.match?('xyz')).to eq(true)
    expect(regexp.match?('123')).to eq(true)
  end

  it 'excludes ASCII and Unicode whitespace when converting non-whitespace' do
    regexp = Regexp.new(Grex.generate(['abc'], convert_non_whitespace: true))

    expect(regexp.match?('a b')).to eq(false)
    expect(regexp.match?("a\tb")).to eq(false)
    expect(regexp.match?("a\u00A0b")).to eq(false)
    expect(regexp.match?("a\u2003b")).to eq(false)
  end

  it 'preserves a literal backslash followed by S when converting non-whitespace' do
    regexp = Regexp.new(Grex.generate(['\\S', 'abc'], convert_non_whitespace: true))

    expect(regexp.match?('\\S')).to eq(true)
    expect(regexp.match?('abc')).to eq(true)
    expect(regexp.match?("\u00A0S")).to eq(false)
  end

  it 'preserves literal spaces and hashes in verbose mode' do
    pattern = Grex.generate(['a b#c'], verbose: true)
    regexp = Regexp.new(pattern)

    expect(regexp.match?('a b#c')).to eq(true)
    expect(regexp.match?('ab#c')).to eq(false)
    expect(regexp.match?('a b')).to eq(false)
  end
end
