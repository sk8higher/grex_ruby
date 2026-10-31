# frozen_string_literal: true

module GrexBenchmark
  # The native entry point requires all options, unlike the public Ruby API.
  DEFAULT_OPTIONS = {
    convert_digits: false, convert_repetitions: false,
    minimum_substring_length: 1, minimum_repetitions: 1,
    anchors: true, ignore_case: false, capturing_groups: false, verbose: false,
    convert_non_digits: false, convert_whitespace: false, convert_non_whitespace: false,
    convert_words: false, convert_non_words: false,
    start_anchor: true, end_anchor: true, escape_non_ascii: false
  }.freeze

  def self.random_samples(size, alphabet)
    random = Random.new(42)
    samples = {}

    until samples.size == size
      sample = Array.new(9) { alphabet.fetch(random.rand(alphabet.size)) }.join
      samples[sample] = true
    end

    samples.keys
  end

  def self.cases
    ascii = ('a'..'z').to_a + ('0'..'9').to_a
    unicode = ('а'..'я').to_a.first(26) + '٠١٢٣٤٥٦٧٨٩'.chars

    [10, 100, 1_000].flat_map do |size|
      prefix = Array.new(size) { |index| format('item-%04d', index) }
      [
        { label: "prefix / #{size}", samples: prefix, options: {} },
        { label: "random ASCII / #{size}", samples: random_samples(size, ascii), options: {} },
        { label: "random Unicode / #{size}", samples: random_samples(size, unicode), options: {} },
        { label: "prefix + digit conversion / #{size}", samples: prefix, options: { convert_digits: true } }
      ]
    end
  end
end
