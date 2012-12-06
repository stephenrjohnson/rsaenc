require 'spec_helper'

describe "the encrypt_cert_rsa function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }
  let(:privatekey) {IO.read(File.expand_path("../../fixtures/private.key",__FILE__))}
  let(:publickey) {IO.read(File.expand_path("../../fixtures/public.key",__FILE__))}
  let(:encdata) {IO.read(File.expand_path("../../fixtures/date.enc",__FILE__))}

  it "should exist" do
    Puppet::Parser::Functions.function("encrypt_rsa").should == "function_encrypt_rsa"
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    lambda { scope.function_encrypt_rsa([]) }.should( raise_error(Puppet::ParseError))
  end

  it "should raise a ParserError if no private rsa is present" do
    lambda { scope.function_encrypt_rsa(["testdata"]) }.should(raise_error(Puppet::ParseError))
  end

  it "should should encrypt and string using a public key" do
    RsaUtils::Utils.stubs(:loadkey).with(Puppet.settings[:hostpubkey]).returns(publickey)
    scope.function_encrypt_rsa(["1234"])
  end

  it "should be able to encrypt and decrypt a string" do
    RsaUtils::Utils.stubs(:loadkey).with(Puppet.settings[:hostprivkey]).returns(privatekey)
    RsaUtils::Utils.stubs(:loadkey).with(Puppet.settings[:hostpubkey]).returns(publickey)
    scope.function_decrypt_rsa([scope.function_encrypt_rsa(["1234"])]).should == scope.function_decrypt_rsa([encdata])
  end

  it "should not be able to encrypt and then decrypt a string with a filter on it" do
    RsaUtils::Utils.stubs(:loadkey).with(Puppet.settings[:hostprivkey]).returns(privatekey)
    RsaUtils::Utils.stubs(:loadkey).with(Puppet.settings[:hostpubkey]).returns(publickey)
    lambda { scope.function_decrypt_rsa([scope.function_encrypt_rsa(["1234",["wibble"]])]).should == scope.function_decrypt_rsa([encdata])}.should(raise_error(RsaUtils::FilterHostsError))
  end
end
