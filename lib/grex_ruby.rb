# frozen_string_literal: true

require_relative 'grex_ruby/version'
require 'grex_ruby/grex_ruby'

module GrexRuby
  private_class_method :generate_native

  class Error < StandardError; end

  def self.generate(samples, convert_digits: false)
    generate_native(samples, convert_digits)
  end
end
