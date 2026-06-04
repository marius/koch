# frozen_string_literal: true

module Koch
  # Expands relative names to absolute paths at resource creation time, so
  # Dir.chdir blocks work correctly.
  module CurrentDir
    def initialize(name)
      super(File.expand_path(name))
    end
  end
end
