# frozen_string_literal: true

#
module WaxTasks
  Derivative = Struct.new(:path, :label, :img)
  attr_reader :id, :path

  #
  class Asset
    def initialize(path, pid, variants)
      @path     = path
      @pid      = pid
      @id       = asset_id
      @variants = variants
    end

    #
    #
    def asset_id
      id = File.basename(@path, '.*')
      id.prepend "#{@pid}_" unless id == @pid
      id
    end

    #
    #
    def simple_derivatives
      @variants.map do |label, width|
        img = MiniMagick::Image.open(@path)
        raise WaxTasks::Error::InvalidConfig, "Requested variant width '#{width}' is larger than original image width." if width > img.width

        img.resize width
        img.format 'jpg'
        Derivative.new("#{@id}/#{label}.jpg", label, img)
      end
    end

    #
    #
    def to_iiif_image_record(is_only, index, base_opts)
      opts = base_opts.clone
      opts[:is_primary]    = index.zero?
      opts[:section_label] = "Page #{index + 1}" unless is_only
      opts[:path]          = @path
      opts[:manifest_id]   = @pid
      opts[:id]            = @id

      WaxIiif::ImageRecord.new(opts)
    end
  end
end
