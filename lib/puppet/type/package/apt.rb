module Puppet
    module PackagingType
        # A derivative of DPKG; this is how most people actually manage
        # Debian boxes, and the only thing that differs is that it can
        # install packages from remote sites.
        module APT
            include DPKG

            # Install a package using 'apt-get'.  This function needs to support
            # installing a specific version.
            def install
                should = self.should(:install)

                str = self.name
                case should
                when true, false, Symbol
                    # pass
                else
                    # Add the package version
                    str += "=%s" % should
                end
                cmd = "apt-get install %s" % str

                Puppet.info "Executing %s" % cmd.inspect
                output = %x{#{cmd} 2>&1}

                unless $? == 0
                    raise Puppet::PackageError.new(output)
                end
            end

            # What's the latest package version available?
            def latest
                cmd = "apt-cache show %s" % self.name 
                output = %x{#{cmd} 2>&1}

                unless $? == 0
                    raise Puppet::PackageError.new(output)
                end

                if output =~ /Version: (.+)\n/
                    return $1
                else
                    Puppet.debug "No version"
                    if Puppet[:debug]
                        print output
                    end

                    return nil
                end
            end

            def update
                self.install
            end
        end
    end
end
