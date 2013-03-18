# encoding: utf-8

require 'spec_helper'

describe CarrierWave::DataMapper do
  let(:uploader)      { Class.new(CarrierWave::Uploader::Base) }
  let(:uploader_name) { :image }
  let(:file)          { stub_file('test.jpeg') }

  let(:described_class) do
    klass = Class.new do
      include DataMapper::Resource

      storage_names[:default] = 'events'

      property :id, DataMapper::Property::Serial

      def self.name; :event; end
    end

    klass.mount_uploader uploader_name, uploader
    klass
  end

  before do
    DataMapper.finalize.auto_migrate!
  end

  let(:object) { described_class.new }

  describe '#image' do
    subject { object.image }

    context 'with a new resource' do
      context 'when nothing has been assigned' do
        let(:object) { described_class.new }

        it { should be_blank }
      end

      context 'when file name is set' do
        before do
          object.attribute_set(:image, 'test.jpeg')
          object.save
          object.reload
        end

        its(:current_path) { should == public_path('uploads/test.jpeg') }
      end
    end

    context 'with a persisted resource' do
      let(:object) { described_class.first }

      context 'when an empty string has been assigned' do
        before do
          repository(:default).adapter.execute("INSERT INTO events (image) VALUES ('')")
        end

        it { should be_blank }
      end

      context 'when a value is stored in the database' do
        before do
          repository(:default).adapter.execute("INSERT INTO events (image) VALUES ('test.jpg')")
        end

        it { should be_an_instance_of(uploader) }
      end
    end
  end

  describe '#image=' do
    context 'when a file is assigned' do
      before do
        object.image = file
      end

      it "caches a file" do
        object.image.should be_an_instance_of(uploader)
      end

      it "copies a file into into the cache directory" do
        object.image.current_path.should =~ %r[^#{public_path('uploads/tmp')}]
      end

      context "with a saved resource" do
        before do
          object.save
          object.image = stub_file('test.jpeg')
        end

        it "marks the resource as dirty" do
          object.dirty?.should be(true)
        end
      end
    end

    context 'when nil is assigned' do
      before do
        object.image = nil
      end

      it "does nothing" do
        object.image.should be_blank
      end
    end

    context 'when nil is assigned' do
      before do
        object.image = 'nil'
      end

      it "does nothing" do
        object.image.should be_blank
      end
    end

    it "should write nothing to the database, to prevent overriden filenames to fail because of unassigned attributes" do
      object.attribute_get(:image).should be_nil
    end
  end

  describe '#save' do
    context 'when no file has been assigned' do
      before do
        object.save
      end

      it "does nothing" do
        object.image.should be_blank
      end
    end

    context 'when a file has been assigned' do
      before do
        object.image = file
        object.save
      end

      context 'without validations' do
        it "copies the file to the upload directory" do
          object.image.should be_an_instance_of(uploader)
          object.image.current_path.should == public_path('uploads/test.jpeg')
        end

        it "assigns the filename to the database" do
          object.reload
          object.attribute_get(:image).should == 'test.jpeg'
        end

        context 'when remove_image? returns true' do
          before do
            object.remove_image = true
            object.save
            object.reload
          end

          it "removes the image" do
            object.image.should be_blank
            object.attribute_get(:image).should == ''
          end
        end
      end

      context "with validations" do
        before(:all) do
          described_class.validates_with_block(:textfile) { [false, "FAIL!"] }
        end

        it "should do nothing when a validation fails" do
          object.image.should be_an_instance_of(uploader)
          object.image.current_path.should =~ %r[^#{public_path('uploads/tmp')}]
        end

        it "should assign the filename before validation" do
          object.reload
          object.attribute_get(:image).should == 'test.jpeg'
        end
      end
    end
  end

  describe '#destroy' do
    context 'when no file has been assigned' do
      it "does nothing when no file has been assigned" do
        object.destroy
      end
    end

    context 'when a file has been assigned' do
      before do
        object.image = file
        object.save.should be_true
        File.exist?(public_path('uploads/test.jpeg')).should be_true
        object.image.should be_an_instance_of(uploader)
        object.image.current_path.should == public_path('uploads/test.jpeg')
        object.destroy
      end

      it "removes the file from the filesystem" do
        File.exist?(public_path('uploads/test.jpeg')).should be_false
      end
    end
  end
end
