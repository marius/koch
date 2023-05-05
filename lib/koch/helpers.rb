# frozen_string_literal: true

require "diffy"

module Koch
  # A random collection of helpers
  module Helpers
    @@dry_run = true

    def maybe(msg_or_cmd)
      if @@dry_run
        info "DRY RUN: #{msg_or_cmd}"
      else
        info msg_or_cmd
        if block_given?
          yield
        else
          system msg_or_cmd, exception: true, err: :out
        end
      end
    end

    def diff(old, new)
      Diffy::Diff.new(old, new, include_diff_info: true, context: 3).to_s(:color).lines[2..].join
    end

    def debian?
      !File.read("/etc/issue").match(/Debian/).nil?
    end

    def ubuntu?
      !File.read("/etc/issue").match(/Ubuntu/).nil?
    end
  end
end
