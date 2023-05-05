# frozen_string_literal: true

module Koch
  # A list of packages
  class Packages < Array
    def apply!
      ENV["DEBIAN_FRONTEND"] = "noninteractive"
      maybe("apt -y install #{installs.join(" ")}") unless installs.empty?
      maybe("apt -y purge #{deletes.join(" ")}") unless deletes.empty?
    end

    private

    def installs
      select { |pkg| pkg.is_a?(InstallPackage) && !installed_packages.include?(pkg.to_s) }
    end

    def deletes
      select { |pkg| pkg.is_a?(DeletePackage) && installed_packages.include?(pkg.to_s) }
    end

    def installed_packages
      return @installed_packages if @installed_packages

      @installed_packages = `dpkg -l`.lines.grep(/^ii/).map { |pkg| pkg.split[1] }
      debug "Installed deb packages: "
      debug @installed_packages.join(" ")
      @installed_packages
    end
  end

  # Represents an abstract package resource, can not be used on its own
  class AbstractPackage < Resource
    def to_s
      name
    end
  end

  # Installs a package
  class InstallPackage < AbstractPackage
  end

  # Deletes a package
  class DeletePackage < AbstractPackage
  end
end
