require 'puppet/parser/files'
require File.expand_path('../../../util/rsautils', __FILE__)



module Puppet::Parser::Functions
  newfunction(:encrypt_rsa, :type => :rvalue, :doc => <<-EOS
                encrypt a string using the puppetmaster public key if a key file not given.
                arguments
                  data,filter,keyfile
              EOS
             ) do |arguments|

               if (arguments.size < 1) then
                 raise(Puppet::ParseError, "encypt_rsa(): Wrong number of arguments "+
                       "given #{arguments.size} for atleast 1")
               end

               data = arguments[0]
               filter = arguments[1]

              if filter.nil?
                filter = ['*']
              end

               if (arguments[2].nil?) then
                 key = Puppet.settings[:hostpubkey]
               else
                 key = arguments[2]
               end

               begin
                RsaUtils::Utils.encrypt(data,key,filter)
              rescue RsaUtils::KeyFileError => e
                raise(Puppet::ParseError, e.message)
              end
             end
end
