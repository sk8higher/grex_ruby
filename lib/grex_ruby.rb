# frozen_string_literal: true

require_relative 'grex_ruby/version'
require 'grex_ruby/grex_ruby'

module Grex
  class Error < StandardError; end

  def self.generate(samples, convert_digits: false, convert_repetitions: false, minimum_substring_length: 1, minimum_repetitions: 1)
    pattern = generate_native(samples, { convert_digits:, convert_repetitions:, minimum_substring_length:, minimum_repetitions: })
    adapt_pattern(pattern)
  end

  def self.adapt_pattern(pattern)
    chars = pattern.chars
    result = +''
    index = 0

    while index < chars.length
      if chars[index] == '\\'
        result << if chars[index + 1] == 'd'
                    '\p{Nd}'
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
