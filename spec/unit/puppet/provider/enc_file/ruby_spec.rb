require 'spec_helper'

provider_class = Puppet::Type.type(:enc_file).provider(:ruby)
describe provider_class do
  let(:privatekey) {IO.read(File.expand_path("../../../fixtures/private.key",__FILE__))}
  let(:encdata) {IO.read(File.expand_path("../../../fixtures/date.enc",__FILE__))}

  context "when creating" do
    before :each do
      tmp = Tempfile.new('tmp')
      @tmpfile = tmp.path
      tmp.close!
      @resource = Puppet::Type::Enc_file.new(
        {:name => 'foo', :path => @tmpfile, :contents => encdata, :key => privatekey}
      )
      @provider = provider_class.new(@resource)
    end

    it 'should detect if file is the same as the contents' do
      File.open(@tmpfile, 'w') do |fh|
        fh.write('1234')
      end
      @provider.exists?.should be_true
    end
    it 'should detect if file is not same as the contents' do
      File.open(@tmpfile, 'w') do |fh|
        fh.write('foo1')
      end
      @provider.exists?.should be_false
    end
    it 'should write the file twice' do
      @provider.create
      @provider.exists?.should be_false
    end
    it 'overwrites a file' do
      File.open(@tmpfile, 'w') do |fh|
        fh.write('foo1')
      end
      @provider.create
      File.read(@tmpfile).chomp.should == '1234'
    end
  end

  context "when removing" do
    before :each do
      tmp = Tempfile.new('tmp')
      @tmpfile = tmp.path
      tmp.close!
      @resource = Puppet::Type::Enc_file.new(
        {:name => 'foo', :path => @tmpfile, :contents => encdata, :key => privatekey}
      )
      @provider = provider_class.new(@resource)
    end
    it 'should remove the line if it exists' do
      File.open(@tmpfile, 'w') do |fh|
        fh.write("foo1\nfoo\nfoo2")
      end
      @provider.destroy
      File.read(@tmpfile).should eql("")
    end
  end
end