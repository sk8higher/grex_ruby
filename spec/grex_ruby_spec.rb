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
end
