# frozen_string_literal: true

module WaxTasks

  Derivative = Struct.new(:path, :img)
  #
  class Asset
    def initialize(path, pid, variants)
      @path     = path
      @pid      = pid
      @id       = asset_id
      @variants = variants
    end

    def asset_id
      id = File.basename(@path, '.*')
      id.prepend("#{@pid}_") unless id == @pid
      id
    end

    def simple_derivatives
      @variants.map do |label, width|
        img = MiniMagick::Image.open(@path)
        raise WaxTasks::Error::InvalidConfig, "Requested variant width '#{width}' is larger than original image width." if width > img.width

        img.resize(width)
        img.format('jpg')
        Derivative.new("#{@id}/#{label}.jpg", img)
      end
    end
  end
end

# variant_path = "#{dir}/#{label}.jpg"
#
# puts variant_path
# return if File.exist?(variant_path)


# img.write(variant_path)
