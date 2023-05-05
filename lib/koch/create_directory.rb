# frozen_string_literal: true

require "fileutils"

module Koch
  # Creates a directory if it doesn't exist and/or changes its mode/owner/group
  class CreateDirectory < Resource
    dsl_writer :mode, :owner, :group

    include Ogm

    def apply!
      if Dir.exist? name
        debug "Not creating directory #{name}, it already exists"
      else
        @changed = true
        maybe("Creating directory #{name}") do
          FileUtils.mkdir_p name
        end
      end

      apply_owner
      apply_group
      apply_mode
    end
  end
end
