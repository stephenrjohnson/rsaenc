
require File.expand_path('../../../util/rsautils', __FILE__)
Puppet::Type.type(:enc_file).provide(:ruby) do

  def exists?
    contents = RsaUtils::Utils.decrypt(resource[:contents],resource[:key])
    file = File.read(resource[:path])
    if file == contents
      return true
    else
      return false
    end
  end

  def create
    contents = RsaUtils::Utils.decrypt(resource[:contents],resource[:key])
    File.open(resource[:path], 'w') do |fh|
      fh.puts contents
    end
  end

  def destroy
    File.open(resource[:path],'w') do |fh|
      fh.write("")
    end
  end
end