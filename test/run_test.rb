# frozen_string_literal: true

require "minitest/autorun"
require "minitest/mock"
require_relative "../lib/koch"

class RunTest < Minitest::Test
  def test_always_changed
    r = Koch::Run.new "echo hello"
    capture_subprocess_io { r.apply! }

    assert r.changed
  end

  def test_uses_name_as_command
    r = Koch::Run.new "echo hello"
    out, = capture_subprocess_io { r.apply! }

    assert_match "echo hello", out
  end

  def test_uses_command_over_name
    r = Koch::Run.new "my-task"
    r.command "echo world"
    out, = capture_subprocess_io { r.apply! }

    assert_match "echo world", out
    refute_match "my-task", out
  end
end
