# frozen_string_literal: true

require "etc"

module Koch
  # This module applies changes to of file's or directory's owner, group, mode.
  module Ogm
    def apply_owner
      return if @owner.nil?

      @owner = Etc.getpwnam(@owner).uid if @owner.is_a? String
      return if stat.uid == @owner

      @changed = true
      maybe("Owner changed: #{name} #{stat.uid} to #{@owner}") do
        File.chown @owner, nil, name
      end
    end

    def apply_group
      return if @group.nil?

      @group = Etc.getgrnam(@group).gid if @group.is_a? String
      return if stat.gid == @group

      @changed = true
      maybe("Group changed: #{name} #{stat.gid} to #{@group}") do
        File.chown nil, @group, name
      end
    end

    def apply_mode
      return if @mode.nil?

      @mode = Integer(@mode, 8) if @mode.is_a? String
      curr_mode = stat.mode & 0o7777
      return if curr_mode == @mode

      @changed = true
      maybe(format("Mode changed: #{name} old: %o new: %o", (curr_mode || 0), @mode)) do
        File.chmod @mode, name
      end
    end

    private

    def stat
      @stat ||= begin
        File.stat name
      rescue Errno::ENOENT
        Struct.new(:uid, :gid, :mode).new
      end
    end
  end
end
