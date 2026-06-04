# frozen_string_literal: true

require "minitest/autorun"
require "minitest/mock"
require_relative "../lib/koch"

class DeleteFileTest < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir
    @target = "#{@tmpdir}/target.txt"
    @file = Koch::DeleteFile.new @target
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
      f = Koch::DeleteFile.new "target.txt"

      assert_equal "/tmp/target.txt", f.name
    end
  end

  def test_deletes_file_when_present
    File.write @target, "data"
    without_dry_run { @file.apply! }

    refute_path_exists @target
  end

  def test_changed_when_deleted
    File.write @target, "data"
    without_dry_run { @file.apply! }

    assert @file.changed
  end

  def test_not_changed_when_already_absent
    capture_subprocess_io { @file.apply! }

    refute @file.changed
  end

  def test_dry_run_does_not_delete
    File.write @target, "data"
    capture_subprocess_io { @file.apply! }

    assert_path_exists @target
  end
end
