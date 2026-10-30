# frozen_string_literal: true

require 'open3'
require 'tempfile'

RSpec.describe 'grex-ruby CLI' do
  def run_cli(*arguments)
    Open3.capture3(Gem.ruby, '-I', File.expand_path('../lib', __dir__),
                   File.expand_path('../exe/grex-ruby', __dir__), *arguments)
  end

  def with_samples(contents)
    Tempfile.create('grex-cli') do |file|
      file.write(contents)
      file.close
      yield file.path
    end
  end

  it 'shows help without requiring an input file' do
    output, error, status = run_cli('--help')

    expect(status.success?).to eq(true)
    expect(output).to include('--convert-words', '--minimum-repetitions', '--[no-]end-anchor')
    expect(error).to eq('')
  end

  it 'shows the gem version without requiring an input file' do
    output, error, status = run_cli('--version')

    expect(status.success?).to eq(true)
    expect(output.strip).to eq(Grex::VERSION)
    expect(error).to eq('')
  end

  it 'passes conversion, numeric and anchor options to the generator' do
    with_samples("111\n") do |path|
      output, error, status = run_cli(path, '--convert-digits', '--convert-repetitions',
                                      '--minimum-repetitions', '2', '--minimum-substring-length', '1', '--no-anchors')

      expect(status.success?).to eq(true)
      expect(output.strip).to eq('\p{Nd}{3}')
      expect(error).to eq('')
    end
  end

  it 'passes formatting, case and group options to the generator' do
    with_samples("cat\ndog\n") do |path|
      output, error, status = run_cli('--verbose', '--ignore-case', '--capturing-groups', path)

      expect(status.success?).to eq(true)
      expect(Regexp.new(output).match('CAT').captures).to eq(['CAT'])
      expect(error).to eq('')
    end
  end

  it 'reports a missing input argument on stderr with a failure status' do
    output, error, status = run_cli

    expect(status.success?).to eq(false)
    expect(output).to eq('')
    expect(error).to include('FILE', '--help')
  end

  it 'rejects an invalid numeric option before reading the file' do
    output, error, status = run_cli('--minimum-repetitions', 'abc', 'unused.txt')

    expect(status.success?).to eq(false)
    expect(output).to eq('')
    expect(error).to include('invalid argument', '--minimum-repetitions')
  end

  it 'reports an empty sample file without a Ruby backtrace' do
    with_samples('') do |path|
      output, error, status = run_cli(path)

      expect(status.success?).to eq(false)
      expect(output).to eq('')
      expect(error).to include('samples must not be empty')
      expect(error).not_to include('from ')
    end
  end
end
