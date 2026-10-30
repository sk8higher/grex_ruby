# frozen_string_literal: true

require_relative 'grex_ruby/version'
require 'grex_ruby/grex_ruby'

module Grex
  class Error < StandardError; end

  def self.generate(samples,
                    convert_digits: false,
                    convert_repetitions: false,
                    minimum_substring_length: 1,
                    minimum_repetitions: 1,
                    anchors: true,
                    ignore_case: false,
                    capturing_groups: false,
                    verbose: false,
                    convert_non_digits: false,
                    convert_whitespace: false,
                    convert_non_whitespace: false,
                    convert_words: false,
                    convert_non_words: false,
                    start_anchor: true)
    pattern = generate_native(samples,
                              { convert_digits:, convert_repetitions:, minimum_substring_length:, minimum_repetitions:,
                                anchors:, ignore_case:, capturing_groups:, verbose:, convert_non_digits:, convert_whitespace:, convert_non_whitespace:, convert_words:, convert_non_words:, start_anchor: })
    adapt_pattern(pattern)
  end

  def self.adapt_pattern(pattern)
    chars = pattern.chars
    result = +''
    index = 0

    while index < chars.length
      if chars[index] == '\\'
        result << case chars[index + 1]
                  when 'd'
                    '\p{Nd}'
                  when 'D'
                    '\P{Nd}'
                  when 's'
                    '\p{Space}'
                  when 'S'
                    '\P{Space}'
                  when 'w'
                    '[\p{Alpha}\p{M}\p{Nd}\p{Pc}\p{Join_Control}]'
                  when 'W'
                    '[^\p{Alpha}\p{M}\p{Nd}\p{Pc}\p{Join_Control}]'
                  else
                    chars[index, 2].join
                  end
        index += 2
      else
        result << chars[index]
        index += 1
      end
    end

    result
  end

  private_class_method :generate_native, :adapt_pattern
end
