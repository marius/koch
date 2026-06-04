# frozen_string_literal: true

require "minitest/autorun"
require "minitest/mock"
require_relative "../lib/koch"

class UserTest < Minitest::Test
  def setup
    @user = Koch::User.new "testuser"
  end

  def stub_absent(&block)
    Etc.stub(:getpwnam, ->(_) { raise ArgumentError }, &block)
  end

  def stub_present(&block)
    Etc.stub(:getpwnam, Struct.new(:name).new("testuser"), &block)
  end

  def test_not_changed_when_user_exists
    stub_present { capture_subprocess_io { @user.apply! } }

    refute @user.changed
  end

  def test_changed_when_user_absent
    stub_absent { capture_subprocess_io { @user.apply! } }

    assert @user.changed
  end

  def test_useradd_command
    stub_absent do
      out, = capture_subprocess_io { @user.apply! }

      assert_match "useradd testuser", out
    end
  end

  def test_useradd_with_uid
    @user.uid 1001
    stub_absent do
      out, = capture_subprocess_io { @user.apply! }

      assert_match "useradd --uid 1001 testuser", out
    end
  end

  def test_useradd_with_gid
    @user.gid 1001
    stub_absent do
      out, = capture_subprocess_io { @user.apply! }

      assert_match "useradd --gid 1001 testuser", out
    end
  end

  def test_useradd_with_home
    @user.home "/home/testuser"
    stub_absent do
      out, = capture_subprocess_io { @user.apply! }

      assert_match "useradd --home-dir /home/testuser testuser", out
    end
  end

  def test_useradd_with_shell
    @user.shell "/bin/bash"
    stub_absent do
      out, = capture_subprocess_io { @user.apply! }

      assert_match "useradd --shell /bin/bash testuser", out
    end
  end

  def test_useradd_system_user
    @user.system_user true
    stub_absent do
      out, = capture_subprocess_io { @user.apply! }

      assert_match "useradd --system testuser", out
    end
  end

  def test_useradd_all_options
    @user.uid 1001
    @user.gid 1001
    @user.home "/home/testuser"
    @user.shell "/bin/bash"
    @user.system_user true
    stub_absent do
      out, = capture_subprocess_io { @user.apply! }

      assert_match "useradd --uid 1001 --gid 1001 --home-dir /home/testuser --shell /bin/bash --system testuser", out
    end
  end
end
