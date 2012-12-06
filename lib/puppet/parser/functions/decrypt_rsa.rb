require 'puppet/parser/files'
require File.expand_path('../../../util/rsautils', __FILE__)

module Puppet::Parser::Functions
  newfunction(:decrypt_rsa, :type => :rvalue, :doc => <<-EOS
                Decrypt a string using the puppetmaster private key is key file not given.
                arguments
                  data, filtermatch, privatekey
              EOS
             ) do |arguments|

               if (arguments.size < 1) then
                 raise(Puppet::ParseError, "dercyptrsa(): Wrong number of arguments "+
                       "given #{arguments.size} for atleast 1")
               end

               data = arguments[0]
               filter = arguments[1]

               if (arguments[2].nil?) then
                 key = Puppet.settings[:hostprivkey]
               else
                 key = arguments[2]
               end


               begin
                RsaUtils::Utils.decrypt(data,key,filter)
               rescue RsaUtils::KeyFileError => e
                raise(Puppet::ParseError, e.message)
              end

             end

end
