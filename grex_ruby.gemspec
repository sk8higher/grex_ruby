# frozen_string_literal: true

require_relative 'lib/grex_ruby/version'

Gem::Specification.new do |spec|
  spec.name = 'grex_ruby'
  spec.version = GrexRuby::VERSION
  spec.authors = ['Nelly Simkova']
  spec.email = ['sk8high3r@ya.ru']
  spec.license = 'MIT'

  spec.summary = 'Ruby gem with bindings for Grex Rust library.'
  spec.homepage = 'https://github.com/sk8higher/grex_ruby'
  spec.required_ruby_version = '>= 3.2.0'

  # Uncomment the line below to require MFA for gem pushes.
  # This helps protect your gem from supply chain attacks by ensuring
  # no one can publish a new version without multi-factor authentication.
  # See: https://guides.rubygems.org/mfa-requirement-opt-in/
  # spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/])
    end
  end
  spec.files = (spec.files + ['LICENSE.txt']).uniq
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.extensions = ['ext/grex_ruby/extconf.rb']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency 'rb_sys', '~> 0.9.128'

  # For more information and examples about making a new gem, check out our
  # guide at: https://guides.rubygems.org/make-your-own-gem/
end
