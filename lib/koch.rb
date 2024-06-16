# frozen_string_literal: true

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

module Koch
  # This class evaluates the Rezeptfile and applies the resources
  class Runner
    def initialize(rezeptfile)
      @rezeptfile = rezeptfile

      @packages = Packages.new
      @snap_packages = SnapPackages.new

      @resources = Resources.new

      @delete = false
    end

    def go
      info("Starting Koch runner (version #{VERSION}).")
      info("DRY RUN MODE! Add --no-dry-run to apply changes.") if @@dry_run

      eval_rezeptfile
      apply!

      @resources.reloads.each do |r|
        maybe "systemctl reload #{r}"
      end
      @resources.restarts.each do |r|
        maybe "systemctl restart #{r}"
      end
      @resources.on_changes.each do |r|
        maybe r
      end

      info("Run complete.")
    end

    def self.make_method_body(add, delete = nil, collection = nil)
      proc do |name, &block|
        r = if @delete
              fatal "Delete not supported for resource #{name}" if delete.nil?

              delete.new(name)
            else
              add.new(name)
            end

        # block_given? does not work.
        r.instance_eval(&block) if block

        if collection.nil?
          @resources << r
        else
          c = instance_variable_get(collection)
          c << r
        end
      end
    end

    define_method :run, &make_method_body(Run)
    define_method :file, &make_method_body(CreateFile, DeleteFile)
    define_method :package, &make_method_body(InstallPackage, DeletePackage, :@packages)
    define_method :snap_package, &make_method_body(InstallSnapPackage, DeleteSnapPackage, :@snap_packages)
    define_method :directory, &make_method_body(CreateDirectory, DeleteDirectory)
    define_method :systemd_service, &make_method_body(SystemdService)
    define_method :systemd_timer_service, &make_method_body(SystemdTimerService)
    define_method :swapfile, &make_method_body(Swapfile)
    define_method :group, &make_method_body(Group)
    define_method :user, &make_method_body(User)

    private

    def eval_rezeptfile
      begin
        rezepte = File.read(@rezeptfile)
      rescue Errno::ENOENT, Errno::EISDIR
        fatal "Did not find a file called #{@rezeptfile} in the current directory: #{Dir.pwd}"
      end
      instance_eval(rezepte, @rezeptfile)
    end

    def apply!
      @packages.apply!
      @snap_packages.apply!
      @resources.apply!
    end

    def delete
      old = @delete
      @delete = true
      yield
    ensure
      @delete = old
    end
  end
end

include Koch::LogHelper # rubocop:disable Style/MixinUsage
include Koch::Helpers # rubocop:disable Style/MixinUsage
