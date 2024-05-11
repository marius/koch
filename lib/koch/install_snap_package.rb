# frozen_string_literal: true

require_relative "resource"

module Koch
  # A list of snap packages
  class SnapPackages < Array
    def apply!
      # We cannot install from multiple stores in one go, let's split the installs up.
      installs.each do |pkg|
        maybe("snap install --classic #{pkg}")
      end
      maybe("snap remove #{deletes.join(" ")}") unless deletes.empty?
    end

    private

    def installs
      select { |pkg| pkg.is_a?(InstallSnapPackage) && !installed_packages.include?(pkg.to_s) }
    end

    def deletes
      select { |pkg| pkg.is_a?(DeleteSnapPackage) && installed_packages.include?(pkg.to_s) }
    end

    def installed_packages
      return @installed_packages if @installed_packages

      @installed_packages = `snap list`.lines.drop(1).map { |pkg| pkg.split[0] }
      debug "Installed snap packages: "
      debug @installed_packages.join(" ")
      @installed_packages
    end
  end

  # Represents an abstract package resource, can not be used on its own
  class AbstractSnapPackage < Resource
    def to_s
      name
    end
  end

  # Installs a snap package
  class InstallSnapPackage < AbstractPackage
  end

  # Deletes a snap package
  class DeleteSnapPackage < AbstractPackage
  end
end
