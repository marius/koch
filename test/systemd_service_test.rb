# frozen_string_literal: true

require "minitest/autorun"
require "minitest/mock"
require_relative "../lib/koch"

class SystemdServiceTest < Minitest::Test
  CONTENTS = "[Service]\nExecStart=/bin/true\n"

  def setup
    @service = Koch::SystemdService.new("myservice")
    @service.contents CONTENTS
  end

  def test_fatal_when_no_contents
    svc = Koch::SystemdService.new("myservice")
    assert_raises(SystemExit) do
      capture_subprocess_io { svc.apply! }
    end
  end

  def test_not_changed_when_contents_unchanged
    File.stub(:read, CONTENTS) do
      capture_subprocess_io { @service.apply! }
    end

    refute @service.changed
  end

  def test_changed_when_contents_differ
    File.stub(:read, "old\n") do
      @service.stub(:system, false) do
        capture_subprocess_io { @service.apply! }
      end
    end

    assert @service.changed
  end

  def test_changed_when_service_file_missing
    File.stub(:read, ->(_) { raise Errno::ENOENT }) do
      @service.stub(:system, false) do
        capture_subprocess_io { @service.apply! }
      end
    end

    assert @service.changed
  end

  def test_daemon_reload_when_already_enabled
    File.stub(:read, "old\n") do
      File.stub(:write, nil) do
        @service.stub(:system, true) do
          out, = capture_subprocess_io { @service.apply! }

          assert_match "systemctl daemon-reload", out
        end
      end
    end
  end

  def test_enable_now_when_not_enabled
    File.stub(:read, "old\n") do
      File.stub(:write, nil) do
        @service.stub(:system, false) do
          out, = capture_subprocess_io { @service.apply! }

          assert_match "systemctl enable --now myservice", out
        end
      end
    end
  end
end
