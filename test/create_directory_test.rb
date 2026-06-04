# frozen_string_literal: true

require "minitest/autorun"
require "minitest/mock"
require_relative "../lib/koch"

class CreateDirectoryTest < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir
    @dir = Koch::CreateDirectory.new "#{@tmpdir}/newdir"
  end

  def teardown
    FileUtils.remove_entry @tmpdir
    Koch::Helpers.class_variable_set(:@@dry_run, true)
  end

  def without_dry_run(&block)
    Koch::Helpers.class_variable_set(:@@dry_run, false)
    capture_subprocess_io(&block)
  ensure
    Koch::Helpers.class_variable_set(:@@dry_run, true)
  end

  def test_expands_relative_name
    Dir.chdir "/tmp" do
      d = Koch::CreateDirectory.new "testdir"

      assert_equal "/tmp/testdir", d.name
    end
  end

  def test_creates_directory_when_missing
    without_dry_run { @dir.apply! }

    assert Dir.exist?("#{@tmpdir}/newdir")
  end

  def test_changed_when_created
    capture_subprocess_io { @dir.apply! }

    assert @dir.changed
  end

  def test_not_changed_when_already_exists
    FileUtils.mkdir_p "#{@tmpdir}/newdir"
    capture_subprocess_io { @dir.apply! }

    refute @dir.changed
  end

  def test_creates_nested_directories
    dir = Koch::CreateDirectory.new "#{@tmpdir}/a/b/c"
    without_dry_run { dir.apply! }

    assert Dir.exist?("#{@tmpdir}/a/b/c")
  end

  def test_apply_mode
    @dir.mode "0700"
    without_dry_run { @dir.apply! }

    assert_equal 0o700, File.stat("#{@tmpdir}/newdir").mode & 0o7777
  end

  def test_apply_owner
    FileUtils.mkdir_p "#{@tmpdir}/newdir"
    @dir.owner Process.uid
    capture_subprocess_io { @dir.apply! }
  end
end
