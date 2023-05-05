# frozen_string_literal: true

module Koch
  # A single command to run
  class Run < Resource
    dsl_writer :command

    def apply!
      @changed = true
      maybe(command || name)
    end
  end
end
