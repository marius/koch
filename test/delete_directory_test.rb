# frozen_string_literal: true

require "minitest/autorun"
require "minitest/mock"
require_relative "../lib/koch"

class DeleteDirectoryTest < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir
    @target = "#{@tmpdir}/target"
    @dir = Koch::DeleteDirectory.new @target
  end

  def teardown
    FileUtils.rm_rf @tmpdir
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
      d = Koch::DeleteDirectory.new "target"

      assert_equal "/tmp/target", d.name
    end
  end

  def test_deletes_directory_when_present
    FileUtils.mkdir_p @target
    without_dry_run { @dir.apply! }

    refute Dir.exist?(@target)
  end

  def test_changed_when_deleted
    FileUtils.mkdir_p @target
    without_dry_run { @dir.apply! }

    assert @dir.changed
  end

  def test_not_changed_when_already_absent
    capture_subprocess_io { @dir.apply! }

    refute @dir.changed
  end

  def test_deletes_directory_with_contents
    FileUtils.mkdir_p "#{@target}/sub"
    File.write "#{@target}/sub/file.txt", "data"
    without_dry_run { @dir.apply! }

    refute Dir.exist?(@target)
  end

  def test_dry_run_does_not_delete
    FileUtils.mkdir_p @target
    capture_subprocess_io { @dir.apply! }

    assert Dir.exist?(@target)
  end
end
