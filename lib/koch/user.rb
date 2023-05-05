# frozen_string_literal: true

require "etc"

module Koch
  # Represents a Linux user
  class User < Resource
    dsl_writer :uid, :gid, :home, :shell, :system_user

    def apply!
      if exist? name
        debug "User #{name} already exists"
        return
      end

      @changed = true

      params = +""
      params << " --uid #{uid}" if uid
      params << " --gid #{gid}" if gid
      params << " --home-dir #{home}" if home
      params << " --shell #{shell}" if shell
      params << " --system" if system_user

      maybe "useradd#{params} #{name}"
    end

    private

    def exist?(user)
      Etc.getpwnam user
      true
    rescue ArgumentError
      false
    end
  end
end
