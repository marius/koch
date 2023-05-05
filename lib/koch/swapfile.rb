# frozen_string_literal: true

module Koch
  # Creates a single swap file
  class Swapfile < Resource
    dsl_writer :size

    def initialize(name)
      super
      @size = "1G"
    end

    def apply!
      if File.exist? name
        debug "Swap file #{name} already exists"
        return
      end

      @changed = true

      maybe "fallocate -l #{size} #{name}"
      maybe "Chmod 600 swap file #{name}" do
        File.chmod 0o600, name
      end
      maybe "mkswap #{name}"
      maybe "swapon #{name}"
      maybe "Add swap file #{name} to /etc/fstab" do
        File.write("/etc/fstab", "#{name} none swap sw 0 0\n", mode: "a")
      end
    end
  end
end
