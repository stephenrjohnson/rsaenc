require 'spec_helper'

describe Puppet::Type.type(:enc_file) do
  let(:privatekey) {IO.read(File.expand_path("../../fixtures/private.key",__FILE__))}
  let(:encdata) {IO.read(File.expand_path("../../fixtures/date.enc",__FILE__))}
  let :enc_file do
    Puppet::Type.type(:enc_file).new(:name => 'foo', :contents => encdata, :path => '/tmp/path', :key => privatekey)
  end
  it 'should accept a contents and path' do
    enc_file[:contents] = 'my_line'
    enc_file[:contents].should == 'my_line'
    enc_file[:path] = '/my/path'
    enc_file[:path].should == '/my/path'
  end
  it 'should accept a key' do
    enc_file[:key] = '/my/path'
    enc_file[:key].should == '/my/path'
    enc_file[:key] = '1233123'
    enc_file[:key].should == '1233123'
  end
  it 'should not accept a path that isnt absolute' do
    expect {
      Puppet::Type.type(:enc_file).new(
          :name   => 'foo',
          :path   => 'path',
          :contents => encdata,
          :key => privatekey
    )}.to raise_error(Puppet::Error, /File paths must be fully qualified, not/)
  end
  it 'should accept a path that is absolute' do
    expect {
      Puppet::Type.type(:enc_file).new(
          :name   => 'foo',
          :path   => '/my/path',
          :contents => encdata,
          :key => privatekey
      )}.not_to raise_error
  end
  it 'should require that a line is specified' do
    expect { Puppet::Type.type(:enc_file).new(:name => 'foo', :path => '/tmp/file') }.to raise_error(Puppet::Error, /Both content and path are required attributes/)
  end
  it 'should require that a file is specified' do
    expect { Puppet::Type.type(:enc_file).new(:name => 'foo', :contents => encdata) }.to raise_error(Puppet::Error, /Both content and path are required attributes/)
  end
  it 'should default to ensure => present' do
    enc_file[:ensure].should eq :present
  end

  it "should autorequire the file it manages" do
    catalog = Puppet::Resource::Catalog.new
    file = Puppet::Type.type(:file).new(:name => "/tmp/path")
    catalog.add_resource file
    catalog.add_resource enc_file

    relationship = enc_file.autorequire.find do |rel|
      (rel.source.to_s == "File[/tmp/path]") and (rel.target.to_s == enc_file.to_s)
    end
    relationship.should be_a Puppet::Relationship
  end

  it "should not autorequire the file it manages if it is not managed" do
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource enc_file
    enc_file.autorequire.should be_empty
  end
end