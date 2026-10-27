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
end
