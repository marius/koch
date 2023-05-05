# frozen_string_literal: true

require "fileutils"

module Koch
  # Deletes a directory if it exists
  class DeleteDirectory < Resource
    def apply!
      unless Dir.exist? name
        debug "Not deleting directory #{name}, it does not exist"
        return
      end

      @changed = true
      maybe("Delete directory #{name}") do
        FileUtils.remove_entry_secure name
      end
    end
  end
end
