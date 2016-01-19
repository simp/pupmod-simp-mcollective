module Puppet::Parser::Functions
  newfunction(:mco_autokey, :type => :rvalue, :doc => <<-EOM) do |args|
    This function generates a random RSA private and public key pair for the mco server.

    Keys are stored in "Puppet[:environmentpath]/::environment/simp_autofiles/mco_autokeys"

    Arguments: [key_strength hash|integer], [return_private]
      * If an integer is the first argument, it will be used as the key strength.

      * If a second option is passed AND the first option is not a Hash, the function will return the private key.

      * option hash
        * If option hash is passed (as a Hash) then the following options are supported:
          - 'key strength' => Integer
          - 'return_private' => Boolean (Anything but false|nil will be treated as 'true')

      NOTE: A minimum key strength of 1024 will be enforced!
  EOM

    require "timeout"

    key_strength = 2048
    return_private = false
    retval = "error"

    if args[0]
      if args[0].is_a?(Hash)
        key_strength = args[0]['key_strength'].to_i if args[0]['key_strength']
        return_private = args[0]['return_private'] if args[0]['return_private']
      elsif args[0].to_i != 0
        key_strength = args[0].to_i
        return_private = args[1] if args[1]
      else
        raise Puppet::ParseError, "The second argument must be an Integer or a Hash!"
      end
    end

    key_strength = 1024 unless (key_strength > 1024)

    keydir = "#{Puppet[:environmentpath]}/#{lookupvar('::environment')}/simp_autofiles/mco_autokeys"

    if ( !File.directory?(keydir) )
      begin
        FileUtils.mkdir_p(keydir,{:mode => 0770})
      rescue
        Puppet.warning "Could not make directory #{keydir}.  Ensure that #{keydir} is writable by 'puppet'"
        return retval
      end
    end

    if ( !File.exists?("#{keydir}/mco_server.pem") )
      begin
        Timeout::timeout(30) do
          system "/usr/bin/openssl genrsa -out #{keydir}/mco_server.pem #{key_strength}"
          FileUtils.chmod 0640, "#{keydir}/mco_server.pem"
          system "/usr/bin/openssl rsa -in #{keydir}/mco_server.pem -pubout > #{keydir}/mco_server.pub"
          FileUtils.chmod 0640, "#{keydir}/mco_server.pub"
        end
      rescue
        Puppet.warning "openssl timed out when generating mco keys"
      end
    elsif ( !File.exists?("#{keydir}/mco_server.pub") )
      begin
        system "/usr/bin/openssl rsa -in #{keydir}/mco_server.pem -pubout > #{keydir}/mco_server.pub"
        FileUtils.chmod 0640, "#{keydir}/mco_server.pub"
      rescue
        Puppet.warning "openssl failed to create mco public key"
      end
    end


    if ( File.exists?("#{keydir}/mco_server.pub") ) then
      if return_private
        retval = File.read("#{keydir}/mco_server.pem")
      else
        retval = File.read("#{keydir}/mco_server.pub")
      end
    end
    return retval

  end
end
