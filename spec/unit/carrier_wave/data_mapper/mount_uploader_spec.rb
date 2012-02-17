require 'spec_helper'

describe CarrierWave::DataMapper, '.mount_uploader' do
  let(:described_class) do
    Class.new do
      include DataMapper::Resource
      property :id, DataMapper::Property::Serial

      def self.name; :spec_model; end
    end
  end

  let(:uploader_name) { :image }
  let(:uploader)      { Class.new(CarrierWave::Uploader::Base) }

  before do
    DataMapper.finalize
  end

  describe 'Model' do
    specify { described_class.should respond_to(:mount_uploader) }
  end

  context 'after mounting an uploader' do
    let!(:uploader_property) do
      described_class.mount_uploader(uploader_name, uploader)
    end

    describe 'Uploader Property' do
      subject { uploader_property }

      it { should be_instance_of(CarrierWave::DataMapper::Property::Uploader) }

      its(:name)    { should == uploader_name }
      its(:custom?) { should be(true) }

      specify 'has auto-validation turned off' do
        subject.options[:auto_validation].should be(false)
      end
    end

    describe 'Resource' do
      subject { described_class.new }

      it { should respond_to("remove_#{uploader_name}=") }
      it { should respond_to("#{uploader_name}=") }
    end
  end

  context "when using the :mount_on option" do
    let(:uploader_column) { :image_file_name }

    let(:described_class) do
      Class.new do
        include DataMapper::Resource

        property :id, DataMapper::Property::Serial

        property :image_file_name, String

        def self.name; :spec_model; end
      end
    end

    let!(:uploader_property) do
      described_class.mount_uploader uploader_name, uploader,
                                     :mount_on => :image_file_name
    end

    it "should not define a new uploader property" do
      described_class.properties.should_not be_named(:image)
    end

    describe 'Uploader Property' do
      subject { uploader_property }

      its(:name)    { should == uploader_column }
    end
  end
end
