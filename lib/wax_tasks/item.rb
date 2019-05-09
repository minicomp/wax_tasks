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
      @assets     = assets
      @variants   = variants.merge(DEFAULT_IMAGE_VARIANTS)
    end

    #
    #
    def assets
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
    def build_simple_derivatives(dir =  nil)
      output_dir = dir || "#{IMAGE_DERIVATIVE_DIRECTORY}/simple"

      @assets.each_with_index do |asset, i|
        asset_id = File.basename(asset, '.*')
        asset_id.prepend("#{@pid}_") unless asset_id == @pid
        asset_dir = "#{output_dir}/#{asset_id}"

        FileUtils.mkdir_p(asset_dir)

        puts Rainbow("Processing #{asset_id}...").cyan

        @variants.each do |label, width|
          path = "#{asset_dir}/#{label}.jpg"
          next if File.exist?(path)

          variant = MiniMagick::Image.open(asset)
          variant.resize(width)
          variant.format('jpg')
          variant.write(path)
        end
      end
    end
  end
end
