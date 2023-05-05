# frozen_string_literal: true

require "zlib"
require_relative "resource"

module Koch
  # A systemd service that is triggered by a timer
  class SystemdTimerService < Resource
    dsl_writer :contents, :timer

    def initialize(name)
      super
      # Pick a pseudo-random time between 00:00 and 06:00 (360 minutes)
      hash = Zlib.crc32(name) % 360
      hour = hash / 60
      minute = hash % 60
      @timer = format("OnCalendar=%02d:%02d", hour, minute)
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def apply!
      fatal "Systemd services require contents." if contents.nil?

      name_prefix = "/etc/systemd/system/#{name}"
      old_contents = begin
        File.read("#{name_prefix}.service")
      rescue Errno::ENOENT
        nil
      end

      old_timer_contents = begin
        File.read("#{name_prefix}.timer")
      rescue Errno::ENOENT
        nil
      end

      new_timer_contents = <<~TIMER
        [Unit]
        Description=Run #{name} regularly

        [Timer]
        #{@timer}

        [Install]
        WantedBy=timers.target
      TIMER
      if old_contents == contents && old_timer_contents == new_timer_contents
        debug "Systemd #{name} service and timer unchanged"
        return
      end

      @changed = true

      if old_contents != contents
        info "Diff for Systemd service #{name}:"
        info diff(old_contents, contents)
        maybe("Changed Systemd service #{name}") do
          File.write("#{name_prefix}.service", contents)
        end
      end

      if old_timer_contents != new_timer_contents
        info "Diff for Systemd timer #{name}:"
        info diff(old_timer_contents, new_timer_contents)

        maybe("Changed Systemd timer #{name}") do
          File.write("#{name_prefix}.timer", new_timer_contents)
        end
      end

      if system("systemctl is-enabled --quiet #{name}.timer")
        maybe "systemctl daemon-reload"
      else
        maybe "systemctl enable --now #{name}.timer"
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity
  end
end
