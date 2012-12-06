require 'spec_helper'

describe Puppet::Face[:rsaenc, :current] do
  let(:publickey) {IO.read(File.expand_path("../../fixtures/public.key",__FILE__))}
  let(:privatekey) {IO.read(File.expand_path("../../fixtures/private.key",__FILE__))}
  let(:encdata) {IO.read(File.expand_path("../../fixtures/date.enc",__FILE__))}

  let :options do
    { :input => '1234', :output => Tempfile.new('output').path, :key => 'localhost', :filter => '*' }
  end

  describe 'when creating an encrypted file' do
    it 'requires a file' do
      lambda {
        options.delete(:input)
        subject.encrypt(options)
      }.should raise_error(ArgumentError)
    end
    it 'requires a output' do
      lambda {
        options.delete(:output)
        subject.encrypt(options)
      }.should raise_error(ArgumentError)
    end
    it 'should encrypted a file' do
      RsaUtils::Utils.stubs(:loadkey).with(options[:key]).returns(publickey)
      subject.encrypt(options)
    end
    it 'should be able to decrypt a file' do
       options[:input] = encdata
       RsaUtils::Utils.stubs(:loadkey).with(options[:key]).returns(privatekey)
       subject.decrypt(options)
    end
     it 'should be able to encryt and decrypt a file' do
      RsaUtils::Utils.stubs(:loadkey).with(options[:key]).returns(publickey)
      subject.encrypt(options)
      input = options[:input]
      options[:input] = options[:output]
      options[:output] = Tempfile.new('crap').path
      RsaUtils::Utils.stubs(:loadkey).with(options[:key]).returns(privatekey)
      subject.decrypt(options)
      (File.read options[:output]).should eq(input)
    end
  end
end
