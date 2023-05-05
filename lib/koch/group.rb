# frozen_string_literal: true

module Koch
  # Represents a Linux group
  class Group < Resource
    dsl_writer :gid, :system_group

    def apply!
      if exist? name
        debug "Group #{name} already exists"
        return
      end

      @changed = true

      params = +""
      params << " --gid #{gid}" if gid
      params << " --system" if system_group

      maybe "groupadd#{params} #{name}"
    end

    private

    def exist?(group)
      Etc.getgrnam group
      true
    rescue ArgumentError
      false
    end
  end
end
