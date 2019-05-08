# frozen_string_literal: true

module WaxTasks
  ACCEPTED_IMAGE_ITEM_FORMATS = %w[.jpeg .jpg .tiff .png].freeze
  ACCEPTED_PAGED_ITEM_FORMATS = %w[dir .pdf].freeze
  #
  class Item
    attr_writer :record
    #
    #
    #
    def initialize(path)
      @path       = path
      @pid        = pid
      @assets     = assets
    end

    #
    #
    #
    def assets
      ext = Dir.exist?(@path) ? 'dir' : File.extname(@path)
      if ACCEPTED_IMAGE_ITEM_FORMATS.include? ext
        [@path]
      elsif ext == '.pdf'
        split_pdf(@path)
      elsif ACCEPTED_PAGED_ITEM_FORMATS.include? ext
        Dir.glob("#{@path}/*{#{ACCEPTED_IMAGE_ITEM_FORMATS.join(',')}}")
      else
        puts 'Error' # raise format Error TO DO
      end
    end

    #
    #
    #
    def pid
      @pid || File.basename(@path, '.*')
    end

    #
    #
    #
    # def record
    #   @record || {}
    # end

    #
    #
    #
    # def record=(record)
    #   @record = record
    # end

    #
    #
    # @return [Array] array of image paths generated from pdf split
    #                 or Nil if pdf has already been split
    def split_pdf(path)
      target_dir = path.gsub('.pdf', '')
      next if Dir.glob("#{target_dir}/*").any?

      opts = { output_dir: target_dir, verbose: true }
      WaxIiif::Utilities::PdfSplitter.split(path, opts).sort
    end
  end
end
