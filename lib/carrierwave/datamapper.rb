# encoding: utf-8

require 'carrierwave'
require 'dm-core'
require 'carrierwave/datamapper/property/uploader'

module CarrierWave
  module DataMapper

    include CarrierWave::Mount

    ##
    # See +CarrierWave::Mount#mount_uploader+ for documentation
    #
    def mount_uploader(column, uploader, options={}, &block)
      if properties.named?(column)
        warn "Defining property for an uploader is deprecated at #{caller[2]}"
        properties.delete(properties[column])
      end

      uploader_property = if options[:mount_on]
                            properties[options[:mount_on]]
                          else
                            property column, Property::Uploader
                          end

      super

      alias_method :read_uploader,  :attribute_get
      alias_method :write_uploader, :attribute_set

      pre_hook = ::DataMapper.const_defined?(:Validations) ? :valid? : :save

      before pre_hook, "write_#{column}_identifier".to_sym
      after  :save,    "store_#{column}!".to_sym
      after  :destroy, "remove_#{column}!".to_sym

      # FIXME: Hack to work around Datamapper not triggering callbacks
      # for objects that are not dirty. By explicitly calling
      # attribute_set we are marking the record as dirty.
      class_eval <<-RUBY
        def remove_#{column}=(value)
          _mounter(:#{column}).remove = value
          attribute_set(:#{uploader_property.name}, '') if _mounter(:#{column}).remove?
        end

        def #{column}=(value)
          attribute_set(:#{uploader_property.name}, value)
          super(value)
        end
      RUBY

      uploader_property
    end

  end # DataMapper
end # CarrierWave

DataMapper::Model.append_extensions(CarrierWave::DataMapper)
