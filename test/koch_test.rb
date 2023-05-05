# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/koch"

class KochTest < Minitest::Test
  def test_go
    r = Koch::Runner.new "nocare"

    File.stub :read, 'package "foo"' do
      Kernel.stub :system, nil do
        capture_subprocess_io do
          r.go
        end
      end
    end
  end
end
