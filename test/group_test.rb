# frozen_string_literal: true

require "minitest/autorun"
require "minitest/mock"
require_relative "../lib/koch"

class GroupTest < Minitest::Test
  def setup
    @group = Koch::Group.new "testgroup"
  end

  def stub_absent(&block)
    Etc.stub :getgrnam, ->(_) { raise ArgumentError }, &block
  end

  def stub_present(&block)
    Etc.stub :getgrnam, Struct.new(:name).new("testgroup"), &block
  end

  def test_not_changed_when_group_exists
    stub_present do
      capture_subprocess_io { @group.apply! }
    end

    refute @group.changed
  end

  def test_changed_when_group_absent
    stub_absent do
      capture_subprocess_io { @group.apply! }
    end

    assert @group.changed
  end

  def test_groupadd_command
    stub_absent do
      out, = capture_subprocess_io { @group.apply! }

      assert_match "groupadd testgroup", out
    end
  end

  def test_groupadd_with_gid
    @group.gid 1234
    stub_absent do
      out, = capture_subprocess_io { @group.apply! }

      assert_match "groupadd --gid 1234 testgroup", out
    end
  end

  def test_groupadd_system_group
    @group.system_group true
    stub_absent do
      out, = capture_subprocess_io { @group.apply! }

      assert_match "groupadd --system testgroup", out
    end
  end

  def test_groupadd_gid_and_system
    @group.gid 1234
    @group.system_group true
    stub_absent do
      out, = capture_subprocess_io { @group.apply! }

      assert_match "groupadd --gid 1234 --system testgroup", out
    end
  end
end
