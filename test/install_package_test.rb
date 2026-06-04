# frozen_string_literal: true

require "minitest/autorun"
require "minitest/mock"
require_relative "../lib/koch"

class InstallPackageTest < Minitest::Test
  def setup
    @pkgs = Koch::Packages.new
  end

  def with_installed(*packages, &block)
    @pkgs.stub(:installed_packages, packages, &block)
  end

  def test_installs_missing_package
    @pkgs << Koch::InstallPackage.new("vim")
    with_installed do
      out, = capture_subprocess_io { @pkgs.apply! }

      assert_match "apt -y install vim", out
    end
  end

  def test_skips_already_installed_package
    @pkgs << Koch::InstallPackage.new("vim")
    with_installed("vim") do
      out, = capture_subprocess_io { @pkgs.apply! }

      refute_match "apt", out
    end
  end

  def test_purges_installed_package
    @pkgs << Koch::DeletePackage.new("vim")
    with_installed("vim") do
      out, = capture_subprocess_io { @pkgs.apply! }

      assert_match "apt -y purge vim", out
    end
  end

  def test_skips_purge_when_not_installed
    @pkgs << Koch::DeletePackage.new("vim")
    with_installed do
      out, = capture_subprocess_io { @pkgs.apply! }

      refute_match "apt", out
    end
  end

  def test_installs_multiple_packages_in_one_command
    @pkgs << Koch::InstallPackage.new("vim")
    @pkgs << Koch::InstallPackage.new("git")
    with_installed do
      out, = capture_subprocess_io { @pkgs.apply! }

      assert_match "apt -y install vim git", out
    end
  end

  def test_install_package_to_s
    assert_equal "vim", Koch::InstallPackage.new("vim").to_s
  end

  def test_delete_package_to_s
    assert_equal "vim", Koch::DeletePackage.new("vim").to_s
  end
end
