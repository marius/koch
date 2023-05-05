# frozen_string_literal: true

module Koch
  # Creates and/or changes a files' contents, mode, owner and/or group
  class CreateFile < Resource
    dsl_writer :mode, :contents, :owner, :group

    include Ogm

    def apply!
      apply_contents
      apply_owner
      apply_group
      apply_mode
    end

    private

    def apply_contents
      if contents.nil?
        debug "No contents specified for file #{name}"
        return
      end

      old_contents = begin
        File.read name
      rescue Errno::ENOENT
        nil
      end
      if old_contents == contents
        debug "Contents of file #{name} unchanged"
        return
      end

      info "Diff for #{name}:"
      info diff(old_contents, contents)
      @changed = true
      maybe("Updating file contents of #{name}") do
        File.write(name, contents)
      end
    end
  end
end
