Puppet::Type.newtype(:enc_file) do

  desc <<-EOT
    Ensures that a given contents are the file  I suggest
    that you use the puppet file type to set the permission
    on the file.

    Example:

        enc_file { 'supersecretfile':
          path => '/etc/secrets',
          contents => template('modulename/secerts.data'),
        }
        file { 'supersecretfile':
          path => '/etc/secrets',
          ensure => file,
          owner => root,
          group => root,
          mode => 0400,
        }

    In this example, Puppet will ensure a file contains the correct
    decrypted data with the correct permissions.

  EOT

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, :namevar => true) do
    desc 'An arbitrary name used as the identity of the resource.'
  end

  newparam(:contents) do
    desc 'The data to be written to the file, once it has been decrypted;\n' +
        'using the hosts public key'
  end

  newparam(:path) do
    desc 'The file Puppet will ensure contains the line specified by the line parameter.'
    validate do |value|
      unless (Puppet.features.posix? and value =~ /^\//) or (Puppet.features.microsoft_windows? and (value =~ /^.:\// or value =~ /^\/\/[^\/]+\/[^\/]+/))
        raise(Puppet::Error, "File paths must be fully qualified, not '#{value}'")
      end
    end
  end


  newparam(:key) do
    desc 'The private key to decrypt the contents with defaults to hosts private key.'
    defaultto Puppet.settings[:hostprivkey]
  end

  # Autorequire the file resource if it's being managed
  autorequire(:file) do
    self[:path]
  end

  validate do
    unless self[:contents] and self[:path]
      raise(Puppet::Error, "Both content and path are required attributes")
    end

  end
end