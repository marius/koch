# frozen_string_literal: true

require_relative "lib/koch/version"

Gem::Specification.new do |spec|
  spec.name = "koch"
  spec.version = Koch::VERSION
  spec.authors = ["Marius Nuennerich"]
  spec.email = ["marius@nuenneri.ch"]
  spec.summary = "Koch automates machine setup."
  spec.description = "Koch automates machine setup by providing a library of helper functions."
  spec.homepage = "https://github.com/marius/koch"
  spec.license = "Apache-2.0"

  spec.required_ruby_version = ">= 2.7.0"
  spec.files = ["README.md", "koch.gemspec", "LICENSE"]
  spec.files += Dir.glob("lib/**/*.rb")
  spec.executables = ["koch"]

  spec.add_dependency "diffy", "~> 3.4"
  spec.add_dependency "logger", "~> 1.5"
  spec.add_dependency "thor", "~> 1.2"
  spec.add_dependency "zeitwerk", "~> 2.6"
  spec.add_dependency "zlib", "~> 3.0.1"
  spec.add_development_dependency "guard", "~> 2.18"
  spec.add_development_dependency "guard-minitest", "~> 2.4"
  # ostruct stopped being a default gem in Ruby 3.5/4.0; rake still requires it.
  spec.add_development_dependency "ostruct", "~> 0.6"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rubocop", "~> 1.87"
  spec.add_development_dependency "rubocop-rake", "~> 0.7"
end
