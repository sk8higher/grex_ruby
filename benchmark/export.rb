# frozen_string_literal: true

require 'fileutils'
require 'grex_ruby'
require_relative 'datasets'

destination = File.expand_path(ARGV.fetch(0, File.join(__dir__, '../tmp/benchmark-inputs')))
FileUtils.mkdir_p(destination)

manifest = GrexBenchmark.cases.each_with_index.map do |benchmark_case, index|
  input_file = format('%02d.txt', index)
  pattern_file = format('%02d.pattern', index)
  options = GrexBenchmark::DEFAULT_OPTIONS.merge(benchmark_case[:options])
  pattern = Grex.send(:generate_native, benchmark_case[:samples], options)
  File.binwrite(File.join(destination, input_file), benchmark_case[:samples].join("\n") + "\n")
  File.binwrite(File.join(destination, pattern_file), pattern)
  [benchmark_case[:label], options[:convert_digits], input_file, pattern_file].join("\t")
end

File.binwrite(File.join(destination, 'manifest.tsv'), manifest.join("\n") + "\n")
puts "Exported #{manifest.length} datasets and expected raw patterns to #{destination}"
