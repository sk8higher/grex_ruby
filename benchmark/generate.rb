# frozen_string_literal: true

require 'benchmark'
require 'grex_ruby'
require_relative 'datasets'

iterations = Integer(ENV.fetch('ITERATIONS', '10'), 10)
abort 'ITERATIONS must be greater than zero' unless iterations.positive?

# Keep these in sync with Grex.generate: the private native entry point expects
# every option, whereas the public Ruby method supplies defaults itself.
default_options = GrexBenchmark::DEFAULT_OPTIONS

keyword_names = Grex.method(:generate).parameters.filter_map { |kind, name| name if kind == :key }
abort 'Update benchmark defaults to match Grex.generate' unless keyword_names.sort == default_options.keys.sort

cases = GrexBenchmark.cases

puts RUBY_DESCRIPTION
puts "Grex #{Grex::VERSION}; #{iterations} calls per phase per case; random seed: 42"
puts 'Benchmark.bmbm runs every case twice; large random inputs can take a few minutes.'
puts 'Inputs contain 9 characters each; Unicode inputs contain more UTF-8 bytes.'
puts 'Input generation and correctness checks are outside the timed blocks.'
puts 'Native includes Magnus argument/result conversion, not just Rust execution.'
puts 'Adapter uses a precomputed native pattern. Full uses the public Ruby API.'
puts

cases.each do |benchmark_case|
  benchmark_case[:native_options] = default_options.merge(benchmark_case[:options])
  benchmark_case[:native_pattern] =
    Grex.send(:generate_native, benchmark_case[:samples], benchmark_case[:native_options])
  pattern = Grex.send(:adapt_pattern, benchmark_case[:native_pattern])
  benchmark_case[:ruby_pattern] = pattern
  regexp = Regexp.new(pattern)
  all_samples_match = benchmark_case[:samples].all? { |sample| regexp.match?(sample) }
  abort "Pattern does not match input: #{benchmark_case[:label]}" unless all_samples_match
end

measurements = Benchmark.bmbm do |report|
  cases.each do |benchmark_case|
    report.report("#{benchmark_case[:label]} / native") do
      iterations.times do
        Grex.send(:generate_native, benchmark_case[:samples], benchmark_case[:native_options])
      end
    end

    report.report("#{benchmark_case[:label]} / adapter") do
      iterations.times { Grex.send(:adapt_pattern, benchmark_case[:native_pattern]) }
    end

    report.report("#{benchmark_case[:label]} / full") do
      iterations.times { Grex.generate(benchmark_case[:samples], **benchmark_case[:options]) }
    end
  end
end

puts "\nAverage elapsed time in ms/call (main run):"
puts format('%-36s %12s %12s %12s %16s %16s',
            'case', 'native', 'adapter', 'full', 'raw chars/bytes', 'Ruby chars/bytes')
cases.zip(measurements.each_slice(3)).each do |benchmark_case, phase_measurements|
  native_ms, adapter_ms, full_ms = phase_measurements.map { |measurement| measurement.real / iterations * 1_000 }
  raw = benchmark_case[:native_pattern]
  adapted = benchmark_case[:ruby_pattern]
  puts format('%-36s %12.4f %12.4f %12.4f %16s %16s', benchmark_case[:label],
              native_ms, adapter_ms, full_ms, "#{raw.length}/#{raw.bytesize}", "#{adapted.length}/#{adapted.bytesize}")
end
puts 'Phases are measured independently; their times are not expected to add up exactly.'
