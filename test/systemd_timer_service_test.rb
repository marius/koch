# frozen_string_literal: true

require "minitest/autorun"
require "minitest/mock"
require_relative "../lib/koch"

class SystemdTimerServiceTest < Minitest::Test
  CONTENTS = "[Service]\nExecStart=/bin/true\n"

  def setup
    @service = Koch::SystemdTimerService.new("myservice")
    @service.contents CONTENTS
  end

  def expected_timer_contents(name)
    hash = name.each_byte.reduce(0) { |acc, byte| (acc * 31) + byte } % 360
    hour = hash / 60
    minute = hash % 60
    <<~TIMER
      [Unit]
      Description=Run #{name} regularly

      [Timer]
      #{format("OnCalendar=%02d:%02d", hour, minute)}

      [Install]
      WantedBy=timers.target
    TIMER
  end

  def test_default_timer_is_in_range
    timer_line = @service.timer

    assert_match(/\AOnCalendar=0[0-5]:\d{2}\z/, timer_line)
  end

  def test_timer_is_deterministic
    svc1 = Koch::SystemdTimerService.new("myservice")
    svc2 = Koch::SystemdTimerService.new("myservice")

    assert_equal svc1.timer, svc2.timer
  end

  def test_different_names_may_produce_different_timers
    svc1 = Koch::SystemdTimerService.new("service-a")
    svc2 = Koch::SystemdTimerService.new("service-b")

    refute_equal svc1.timer, svc2.timer
  end

  def test_fatal_when_no_contents
    svc = Koch::SystemdTimerService.new("myservice")
    assert_raises(SystemExit) do
      capture_subprocess_io { svc.apply! }
    end
  end

  def test_not_changed_when_both_unchanged
    tc = expected_timer_contents("myservice")
    File.stub(:read, ->(path) { path.end_with?(".timer") ? tc : CONTENTS }) do
      capture_subprocess_io { @service.apply! }
    end

    refute @service.changed
  end

  def test_changed_when_service_contents_differ
    tc = expected_timer_contents("myservice")
    File.stub(:read, ->(path) { path.end_with?(".timer") ? tc : "old\n" }) do
      File.stub(:write, nil) do
        @service.stub(:system, false) do
          capture_subprocess_io { @service.apply! }
        end
      end
    end

    assert @service.changed
  end

  def test_changed_when_timer_contents_differ
    File.stub(:read, ->(path) { path.end_with?(".timer") ? "old timer\n" : CONTENTS }) do
      File.stub(:write, nil) do
        @service.stub(:system, false) do
          capture_subprocess_io { @service.apply! }
        end
      end
    end

    assert @service.changed
  end

  def test_enable_now_when_not_enabled
    File.stub(:read, ->(_) { raise Errno::ENOENT }) do
      File.stub(:write, nil) do
        @service.stub(:system, false) do
          out, = capture_subprocess_io { @service.apply! }

          assert_match "systemctl enable --now myservice.timer", out
        end
      end
    end
  end

  def test_daemon_reload_when_already_enabled
    File.stub(:read, ->(_) { raise Errno::ENOENT }) do
      File.stub(:write, nil) do
        @service.stub(:system, true) do
          out, = capture_subprocess_io { @service.apply! }

          assert_match "systemctl daemon-reload", out
        end
      end
    end
  end
end
