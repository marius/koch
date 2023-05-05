# frozen_string_literal: true

require_relative "resource"

module Koch
  # A Systemd service
  class SystemdService < Resource
    dsl_writer :contents

    def apply!
      fatal "Systemd services require contents." if contents.nil?

      full_name = "/etc/systemd/system/#{name}.service"
      old_contents = begin
        File.read(full_name)
      rescue Errno::ENOENT
        nil
      end
      if old_contents == contents
        debug "Systemd service #{name} unchanged"
        return
      end

      @changed = true

      info "Diff for Systemd service #{name}:"
      info diff(old_contents, contents)
      maybe("Changed Systemd service #{name}") do
        File.write(full_name, contents)
      end
      if system("systemctl is-enabled --quiet #{name}.service")
        maybe "systemctl daemon-reload"
      else
        maybe "systemctl enable --now #{name}"
      end
    end
  end
end
