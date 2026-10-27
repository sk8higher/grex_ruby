# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rb_sys/extensiontask"

task build: :compile

GEMSPEC = Gem::Specification.load("grex_ruby.gemspec")

RbSys::ExtensionTask.new("grex_ruby", GEMSPEC) do |ext|
  ext.lib_dir = "lib/grex_ruby"
end

task default: %i[compile spec]
