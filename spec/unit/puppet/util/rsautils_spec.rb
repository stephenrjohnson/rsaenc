require 'spec_helper'
require 'puppet/util/rsautils'

describe RsaUtils::Utils do

  let(:privatekey) {IO.read(File.expand_path("../../fixtures/private.key",__FILE__))}
  let(:publickey) {IO.read(File.expand_path("../../fixtures/public.key",__FILE__))}
  let(:encdata) {IO.read(File.expand_path("../../fixtures/date.enc",__FILE__))}
  let(:largefile) {IO.read(File.expand_path("../../fixtures/largefile",__FILE__))}

  context "when encrypting a file" do
    it "should raise an exception if file cannot be found" do
      expect { RsaUtils::Utils.encrypt("dadad","/asdasd/asdasd/asdasd") }.to raise_error RsaUtils::KeyFileError
    end

    it "should return a string when encrypting a large file" do
      RsaUtils::Utils.stubs(:loadkey).with(Puppet.settings[:hostpubkey]).returns(privatekey)
      RsaUtils::Utils.encrypt(File.expand_path("../../fixtures/largefile",__FILE__),
                              Puppet.settings[:hostpubkey]).should be_an_instance_of(String)
    end
  end

  context "when decrypting a file" do

    it "should raise an exception if key is invalid" do
      expect { RsaUtils::Utils.decrypt(encdata,"asdasd") }.to raise_error RsaUtils::KeyFileError
    end

    it "should raise an exception if encdata is invalid" do
      RsaUtils::Utils.stubs(:loadkey).with(Puppet.settings[:hostprivkey]).returns(privatekey)
      expect { RsaUtils::Utils.decrypt("no asdasd",Puppet.settings[:hostprivkey]) }.to raise_error RsaUtils::DecryptDataError
    end

    it "should return a string when decrypting a small string" do
      RsaUtils::Utils.stubs(:loadkey).with(Puppet.settings[:hostprivkey]).returns(privatekey)
      RsaUtils::Utils.decrypt(encdata,Puppet.settings[:hostprivkey]).should == "1234"
    end

    it "should decrypting a small file correctly" do
      RsaUtils::Utils.stubs(:loadkey).with(Puppet.settings[:hostprivkey]).returns(privatekey)
      RsaUtils::Utils.decrypt(File.expand_path("../../fixtures/date.enc",__FILE__),Puppet.settings[:hostprivkey]).should == "1234"
    end

    it "should be able encrypt and decrypt hashes" do
      testhash = {:test => 1 , :test2 => 2}
      RsaUtils::Utils.stubs(:loadkey).with(Puppet.settings[:hostpubkey]).returns(privatekey)
      RsaUtils::Utils.stubs(:loadkey).with(Puppet.settings[:hostprivkey]).returns(privatekey)
      RsaUtils::Utils.decrypt(RsaUtils::Utils.encrypt(testhash,Puppet.settings[:hostpubkey]),Puppet.settings[:hostprivkey]).should == testhash
    end

    it "should be able encrypt and decrypt arrays" do
      testarray = ['1','2']
      RsaUtils::Utils.stubs(:loadkey).with(Puppet.settings[:hostpubkey]).returns(privatekey)
      RsaUtils::Utils.stubs(:loadkey).with(Puppet.settings[:hostprivkey]).returns(privatekey)
      RsaUtils::Utils.decrypt(RsaUtils::Utils.encrypt(testarray,Puppet.settings[:hostpubkey]),Puppet.settings[:hostprivkey]).should == testarray
    end

    it "should be able decrypt large files correctly" do
      testarray = ['1','2']
      RsaUtils::Utils.stubs(:loadkey).with(Puppet.settings[:hostpubkey]).returns(privatekey)
      RsaUtils::Utils.stubs(:loadkey).with(Puppet.settings[:hostprivkey]).returns(privatekey)
      RsaUtils::Utils.decrypt(RsaUtils::Utils.encrypt(largefile,Puppet.settings[:hostpubkey]),Puppet.settings[:hostprivkey]).should == largefile
    end
  end

  context "when encrypting using hosts" do
    it "should raise an exception if array no pasted into filter hosts" do
      RsaUtils::Utils.stubs(:loadkey).with(Puppet.settings[:hostpubkey]).returns(privatekey)
      expect { RsaUtils::Utils.encrypt("dadad",Puppet.settings[:hostpubkey],"test.com") }.to raise_error RsaUtils::FilterHostsError
    end

    it "should return a string when encrypting a large file" do
      RsaUtils::Utils.stubs(:loadkey).with(Puppet.settings[:hostpubkey]).returns(privatekey)
      RsaUtils::Utils.encrypt(File.expand_path("../../fixtures/largefile",__FILE__),
                              Puppet.settings[:hostpubkey],['test.com']).should be_an_instance_of(String)
    end
  end
end
