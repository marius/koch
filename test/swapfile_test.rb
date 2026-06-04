# frozen_string_literal: true

require "minitest/autorun"
require "minitest/mock"
require_relative "../lib/koch"

class SwapfileTest < Minitest::Test
  def setup
    @swapfile = Koch::Swapfile.new "/swapfile"
  end

  def test_expands_relative_name
    Dir.chdir "/tmp" do
      s = Koch::Swapfile.new "swapfile"

      assert_equal "/tmp/swapfile", s.name
    end
  end

  def test_default_size
    assert_equal "1G", @swapfile.size
  end

  def test_not_changed_when_file_exists
    File.stub(:exist?, true) do
      capture_subprocess_io { @swapfile.apply! }
    end

    refute @swapfile.changed
  end

  def test_changed_when_file_absent
    File.stub(:exist?, false) do
      capture_subprocess_io { @swapfile.apply! }
    end

    assert @swapfile.changed
  end

  def test_fallocate_command
    File.stub(:exist?, false) do
      out, = capture_subprocess_io { @swapfile.apply! }

      assert_match "fallocate -l 1G /swapfile", out
    end
  end

  def test_custom_size
    @swapfile.size "2G"
    File.stub(:exist?, false) do
      out, = capture_subprocess_io { @swapfile.apply! }

      assert_match "fallocate -l 2G /swapfile", out
    end
  end

  def test_mkswap_and_swapon_commands
    File.stub(:exist?, false) do
      out, = capture_subprocess_io { @swapfile.apply! }

      assert_match "mkswap /swapfile", out
      assert_match "swapon /swapfile", out
    end
  end
end
