require 'spec_helper'

describe "the decryptras rsa using cert function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }
  let(:privatekey) {IO.read(File.expand_path("../../fixtures/private.key",__FILE__))}
  let(:publickey) {IO.read(File.expand_path("../../fixtures/public.key",__FILE__))}
  let(:encdata) {IO.read(File.expand_path("../../fixtures/date.enc",__FILE__))}

  it "should exist" do
    Puppet::Parser::Functions.function("decrypt_rsa").should == "function_decrypt_rsa"
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    lambda { scope.function_decrypt_rsa([]) }.should( raise_error(Puppet::ParseError))
  end

  it "should raise a ParserError is no encrypted file is present" do
     lambda { scope.function_decrypt_rsa([encdata]) }.should( raise_error(Puppet::ParseError))
  end

  it "should raise a ParserError is no private rsa is present" do
    lambda { scope.function_decrypt_rsa([encdata]) }.should( raise_error(Puppet::ParseError))
  end

  it "should raise a ParserError is no private rsa is present and passed" do
    lambda { scope.function_decrypt_rsa([encdata,"key2"]) }.should( raise_error(Puppet::ParseError))
  end

  it "should decrypt a file using a private rsa" do
    RsaUtils::Utils.stubs(:loadkey).with(Puppet.settings[:hostprivkey]).returns(privatekey)
    scope.function_decrypt_rsa([encdata]).should == "1234"
  end

  it "should decrypt a file and alllow if filter is *" do
    RsaUtils::Utils.stubs(:loadkey).with(Puppet.settings[:hostprivkey]).returns(privatekey)
    scope.function_decrypt_rsa([encdata,"test"]).should == "1234"
  end
end
