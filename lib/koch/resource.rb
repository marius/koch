# frozen_string_literal: true

module Koch
  # Resource represents a thing in the system that can be changed by Koch
  class Resource
    attr_reader :changed, :name

    def initialize(name)
      @name = name
    end

    def self.dsl_writer(*syms)
      syms.each do |sym|
        define_method sym do |*args|
          if args.empty?
            instance_variable_get "@#{sym}"
          elsif args.size == 1
            instance_variable_set "@#{sym}", args[0]
          else
            instance_variable_set "@#{sym}", args
          end
        end
      end
    end

    dsl_writer :reload, :restart, :on_change
  end
end
