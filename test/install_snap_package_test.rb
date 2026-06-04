# frozen_string_literal: true

require "minitest/autorun"
require "minitest/mock"
require_relative "../lib/koch"

class InstallSnapPackageTest < Minitest::Test
  def setup
    @pkgs = Koch::SnapPackages.new
  end

  def with_installed(*packages, &block)
    @pkgs.stub(:installed_packages, packages, &block)
  end

  def test_installs_missing_package
    @pkgs << Koch::InstallSnapPackage.new("code")
    with_installed do
      out, = capture_subprocess_io { @pkgs.apply! }

      assert_match "snap install --classic code", out
    end
  end

  def test_skips_already_installed_package
    @pkgs << Koch::InstallSnapPackage.new("code")
    with_installed("code") do
      out, = capture_subprocess_io { @pkgs.apply! }

      refute_match "snap install", out
    end
  end

  def test_removes_installed_package
    @pkgs << Koch::DeleteSnapPackage.new("code")
    with_installed("code") do
      out, = capture_subprocess_io { @pkgs.apply! }

      assert_match "snap remove code", out
    end
  end

  def test_skips_remove_when_not_installed
    @pkgs << Koch::DeleteSnapPackage.new("code")
    with_installed do
      out, = capture_subprocess_io { @pkgs.apply! }

      refute_match "snap remove", out
    end
  end

  def test_installs_each_package_separately
    @pkgs << Koch::InstallSnapPackage.new("code")
    @pkgs << Koch::InstallSnapPackage.new("slack")
    with_installed do
      out, = capture_subprocess_io { @pkgs.apply! }

      assert_match "snap install --classic code", out
      assert_match "snap install --classic slack", out
    end
  end

  def test_install_snap_package_to_s
    assert_equal "code", Koch::InstallSnapPackage.new("code").to_s
  end

  def test_delete_snap_package_to_s
    assert_equal "code", Koch::DeleteSnapPackage.new("code").to_s
  end
end
