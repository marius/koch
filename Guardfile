# frozen_string_literal: true

guard :minitest do
  watch(%r{^test/(.*)?_test\.rb$})
  watch(%r{^lib/(.*/)?([^/]+)\.rb$})     { |m| "test/#{m[2]}_test.rb" }
  watch(%r{^test/test_helper\.rb$})      { "test" }
  watch(%r{^bin/koch$})                  { "test" }
end
