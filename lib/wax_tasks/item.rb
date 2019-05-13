# frozen_string_literal: true

module WaxTasks
  #
  class Item
    attr_accessor :record
    attr_reader :type, :pid, :assets

    #
    #
    #
    def initialize(path, type, variants = {})
      @path       = path
      @type       = type
      @pid        = File.basename(@path, '.*')
      @assets     = asset_array
      @variants   = variants.merge(DEFAULT_IMAGE_VARIANTS)
    end

    #
    #
    def asset_array
      if ACCEPTED_IMAGE_FORMATS.include? @type
        [@path]
      elsif @type == 'dir'
        Dir.glob("#{@path}/*{#{ACCEPTED_IMAGE_FORMATS.join(',')}}")
      else
        []
      end
    end

    #
    #
    #
    def build_simple_derivatives(dir = nil)
      output_dir = dir || "#{IMAGE_DERIVATIVE_DIRECTORY}/simple"
      @assets.each do |asset|
        asset_id = File.basename(asset, '.*')
        asset_id.prepend("#{@pid}_") unless asset_id == @pid
        asset_dir = "#{output_dir}/#{asset_id}"
        FileUtils.mkdir_p(asset_dir)
        puts Rainbow("Processing #{asset_id}...").cyan
        @variants.each { |l, w| generate_variant(asset, asset_dir, l, w) }
      end
    end

    #
    #
    def generate_variant(asset, dir, label, width)
      path = "#{dir}/#{label}.jpg"
      return if File.exist?(path)

      variant = MiniMagick::Image.open(asset)
      variant.resize(width)
      variant.format('jpg')
      variant.write(path)
    end
  end
end
