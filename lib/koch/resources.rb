# frozen_string_literal: true

module Koch
  # Represents a list of resources
  class Resources < Array
    def initialize
      super
      @reloads = []
      @restarts = []
      @on_changes = []
    end

    def apply!
      each do |r|
        r.apply!
        next unless r.changed

        @reloads << r.reload
        @restarts << r.restart
        @on_changes << r.on_change
      end
    end

    def reloads
      @reloads.compact.flatten.uniq
    end

    def restarts
      @restarts.compact.flatten.uniq
    end

    def on_changes
      @on_changes.compact.flatten.uniq
    end
  end
end
