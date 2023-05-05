# frozen_string_literal: true

module Koch
  # Deletes a file if it exists
  class DeleteFile < Resource
    def apply!
      unless File.exist? name
        debug "Not deleting file #{name}, it does not exist"
        return
      end

      @changed = true
      maybe("Delete file #{name}") do
        File.delete name
      end
    end
  end
end
