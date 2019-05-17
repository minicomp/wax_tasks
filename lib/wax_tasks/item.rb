# frozen_string_literal: true

module WaxTasks
  #
  class Item
    attr_accessor :record
    attr_reader :pid

    #
    #
    #
    def initialize(path, variants)
      @path       = path
      @variants   = variants
      @type       = type
      @pid        = File.basename(@path, '.*')
      @assets     = assets
      @record     = nil
    end

    def accepted_image_formats
      %w[.png .jpg .jpeg .tiff]
    end

    def type
      Dir.exist?(@path) ? 'dir' : File.extname(@path)
    end

    def valid?
      accepted_image_formats.include?(@type) || @type == 'dir'
    end

    def record?
      @record.is_a? Record
    end

    #
    #
    def assets
      if accepted_image_formats.include? @type
        [Asset.new(@path, @pid, @variants)]
      elsif @type == 'dir'
        paths = Dir.glob("#{@path}/*{#{accepted_image_formats.join(',')}}")
        paths.map { |p| Asset.new(p, @pid, @variants) }
      else
        []
      end
    end

    #
    #
    #
    def simple_derivatives
      @assets.map(&:simple_derivatives).flatten
    end
  end
end
