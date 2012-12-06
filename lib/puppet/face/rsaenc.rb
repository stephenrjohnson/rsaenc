require 'puppet'
require 'puppet/face'
require File.expand_path('../../util/rsautils', __FILE__)
require File.expand_path('../../util/rsaerrors', __FILE__)
Puppet::Face.define(:rsaenc, '0.0.1') do
  summary "Create rsa encrypted files for puppet"
  copyright "Stephen Johnson", 2013
  license   "Apache 2 license; see LICENSE"

  option "--input=" do
    summary "Your file to encrypt"
    required
  end

  option "--output=" do
    summary "Your file to encrypt"
    required
  end

  option "--key=" do
    summary "The host to encrypt the file"
  end

  option "--filter=" do
    summary "Comma separated list of items for the filter"
  end

  action :encrypt do
    summary "Encrypt a file using the rsa public key of the host"
    description <<-EOT
      Create a encrypted file for use with the rsa function on the puppet master. Please pass in 
      the public rsa key file if not the machine you are running on. Please note
      that you can also pass in a filter if you wish to restrict the decryption process. 
    EOT

    when_invoked do |options|
      if options[:filter].nil?
         options[:filter] = "*"
      end

      if options[:key].nil?
        options[:key] = Puppet.settings[:hostpubkey]
      end

      options[:filter]=options[:filter].split(',')
      encfile = RsaUtils::Utils.encrypt(options[:input],options[:key],options[:filter])
      RsaUtils::Utils.writedata(options[:output],encfile)
    end
  end

  action :decrypt do
    summary "Decrypt a encrypted file"
    description <<-EOT
      Create a deencrypted file from a encrypted file. Please pass in the private rsa key file. 
      Normally this will be the private key of the puppet master. 
    EOT

    when_invoked do |options|
      if options[:key].nil?
        options[:key] = Puppet.settings[:hostprivkey]
      end

      decfile = RsaUtils::Utils.decrypt(options[:input],options[:key])
      RsaUtils::Utils.writedata(options[:output],decfile)
    end
  end
end
