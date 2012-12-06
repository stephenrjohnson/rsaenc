require File.expand_path('.././rsaerrors', __FILE__)

module RsaUtils
  class Utils

    def self.decrypt (data, keyfile, item = nil)
      if Pathname.new(data).absolute?
        data = File.read YAML::load(data)
      end
      data = YAML::load(data)
      if data.class == String
        raise DecryptDataError, "Doesn't look file contains correct data"
      end
      key = self.dencryptcert(keyfile,Base64.decode64(data[:keydata]))
      filter = YAML::load(self.decryptkey(key,Base64.decode64(data[:filter])))
      self.checkfilter(item,filter)
      return YAML::load(self.decryptkey(key,Base64.decode64(data[:encdata])))
    end

    def self.encrypt (data, keyfile,filter = ['*'])
      if data.kind_of?(String) && Pathname.new(data).absolute?
        data = File.read data
      end
      key = Digest::SHA256.digest(rand.to_s)
      encrypted_data = self.encryptkey( key ,data.to_yaml)
      keydata = self.encryptcert(keyfile,key)
      if filter.class != Array
        raise FilterHostsError, "Please pass array to encrypt for allowed hosts"
      end
      filter = self.encryptkey( key ,filter.to_yaml)
      output = {:keydata => keydata, :encdata => Base64.encode64(encrypted_data),
        :filter => Base64.encode64(filter)}.to_yaml
      return output
    end

    def self.loadkey(keyfile)
      if Pathname.new(keyfile).absolute?
        if File.exists?(keyfile)
          return File.read keyfile
        else
          raise KeyFileError, "KeyFile #{keyfile} does not exists"
        end
      else
        return keyfile
      end
    end

    def self.writedata(dst, data)
      if Pathname.new(dst).absolute?
        File.open(dst, 'w') {|f| f.write(data)}
      else
        raise WriteFileError "Path isn't absolute"
      end
    end

    def self.encryptcert(cert,data)
      encrypter = OpenSSL::PKey::RSA.new(self.loadkey(cert))
      return Base64.encode64(encrypter.public_encrypt(data))
    end

    def self.dencryptcert(cert,data)
      begin
        decrypter = OpenSSL::PKey::RSA.new(self.loadkey(cert))
        return decrypter.private_decrypt(data)
      rescue OpenSSL::PKey::RSAError => e
        raise KeyFileError, e
      end
    end

    def self.encryptkey(key,data)
      aes = OpenSSL::Cipher.new("AES-256-CBC")
      aes.encrypt
      aes.key = key
      return aes.update(data) + aes.final
    end

    def self.decryptkey(key,data)
      aes = OpenSSL::Cipher.new('AES-256-CBC')
      aes.decrypt
      aes.key = key
      return  aes.update(data) + aes.final
    end

    def self.checkfilter(needle,haystack)
      haystack.each do |item|
        if item == "*"
          return true
        elsif item == needle
          return true
        elsif needle =~ item
          return true
        end
      end
      raise FilterHostsError, "Item not found in filter"
    end
  end
end
