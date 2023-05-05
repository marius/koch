# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/koch"

class CreateFileTest < Minitest::Test
  def setup
    @file = Koch::CreateFile.new "stubbed_file"
    @file.contents "contents"
    @file.reload "reload_service"
  end

  def test_files_apply!
    file = Minitest::Mock.new
    file.expect :apply!, nil
    file.expect :changed, true
    file.expect :reload, "reload_service"
    file.expect :restart, "restart_service"
    file.expect :on_change, "echo hello"

    files = Koch::Resources.new
    files << file
    files.apply!

    assert_equal files.reloads, ["reload_service"]
    assert_equal files.restarts, ["restart_service"]
    assert_equal files.on_changes, ["echo hello"]

    file.verify
  end

  def test_files_all_apply!
    mock_files = (0..4).map do
      f = Minitest::Mock.new
      f.expect :apply!, nil
      f.expect :changed, false
    end
    files = Koch::Resources.new
    mock_files.each do |mock_file|
      files << mock_file
    end

    files.apply!

    mock_files.each(&:verify)
  end

  def test_changed_apply!
    capture_subprocess_io do
      File.stub :read, "read file contents" do
        File.stub :write, nil do
          @file.apply!
        end
      end
    end
  end

  def test_unchanged_apply!
    capture_subprocess_io do
      File.stub :read, "contents" do
        File.stub :open, proc { raise "should not be called" } do
          @file.apply!
        end
      end
    end
  end

  def test_reload_changed_file
    capture_subprocess_io do
      File.stub :read, "read file contents" do
        File.stub :write, nil do
          @file.apply!
        end
      end
    end
    assert_equal "reload_service", @file.reload
  end

  def test_reload_unchanged_file
    capture_subprocess_io do
      File.stub :read, "contents" do
        File.stub :open, proc { raise "should not be called" } do
          @file.apply!
        end
      end
    end

    assert !@file.changed
    assert_equal "reload_service", @file.reload
  end

  def test_file_group_change
    @file.owner "www-data"
    File.stub :read, "contents" do
      File.stub :chown, nil do
        capture_subprocess_io do
          @file.apply!
        end
      end
    end
  end
end
