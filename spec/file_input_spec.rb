# frozen_string_literal: true

require 'tempfile'
require 'tmpdir'

RSpec.describe Grex, '.generate_from_file' do
  def with_sample_file(contents)
    Tempfile.create('grex-file-input') do |file|
      file.binmode
      file.write(contents)
      file.close
      yield file.path
    end
  end

  it 'reads LF and CRLF lines including a final line without a newline' do
    with_sample_file("cat\r\ndog\nbird") do |path|
      expect(Grex.generate_from_file(path)).to eq(Grex.generate(%w[cat dog bird]))
    end
  end

  it 'passes keyword options to the generator' do
    with_sample_file("111\n") do |path|
      expect(Grex.generate_from_file(path, convert_digits: true, convert_repetitions: true))
        .to eq('^\p{Nd}{3}$')
    end
  end

  it 'preserves leading and trailing spaces in examples' do
    with_sample_file(" cat \n") do |path|
      regexp = Regexp.new(Grex.generate_from_file(path))
      expect(regexp.match?(' cat ')).to eq(true)
      expect(regexp.match?('cat')).to eq(false)
    end
  end

  it 'reads Unicode examples as UTF-8' do
    with_sample_file("кот\n🐈\n") do |path|
      regexp = Regexp.new(Grex.generate_from_file(path))
      expect(regexp.match?('кот')).to eq(true)
      expect(regexp.match?('🐈')).to eq(true)
    end
  end

  it 'rejects an empty file with ArgumentError' do
    with_sample_file('') do |path|
      expect { Grex.generate_from_file(path) }.to raise_error(ArgumentError, 'samples must not be empty')
    end
  end

  it 'preserves the filesystem error for a missing file' do
    Dir.mktmpdir('grex-missing-file') do |directory|
      expect { Grex.generate_from_file(File.join(directory, 'missing.txt')) }.to raise_error(Errno::ENOENT)
    end
  end
end
