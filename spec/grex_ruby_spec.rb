# frozen_string_literal: true

RSpec.describe GrexRuby do
  it 'has a version number' do
    expect(GrexRuby::VERSION).not_to be nil
  end

  it 'can call generate with doc example' do
    result = GrexRuby.generate(%w[a aa aaa])

    expect(result).to eq('^a(?:aa?)?$')
  end

  it 'can call grex on a word' do
    result = GrexRuby.generate(%w[cat])

    expect(result).to eq('^cat$')
  end

  it 'raises ArgumentError if array is empty' do
    expect { GrexRuby.generate([]) }.to raise_error(ArgumentError, 'samples must not be empty')
  end

  it 'works with digits off' do
    result = GrexRuby.generate(%w[123])

    expect(result).to eq('^123$')
  end

  it 'works with digits' do
    result = GrexRuby.generate(%w[123], convert_digits: true)

    expect(result).to eq('^\\d\\d\\d$')
  end

  it 'raises TypeError if a string is passed as an argument' do
    expect { GrexRuby.generate('cat') }.to raise_error(TypeError)
  end

  it 'raises TypeError if an array contains non string values' do
    expect { GrexRuby.generate(['cat', 123]) }.to raise_error(TypeError)
  end

  it 'treats dot as a dot withing screening' do
    pattern = GrexRuby.generate(['a.b'])
    regexp = Regexp.new(pattern)

    expect(regexp.match?('a.b')).to eq(true)
    expect(regexp.match?('axb')).to eq(false)
  end
end
