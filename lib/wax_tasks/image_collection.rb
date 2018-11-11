require 'wax_iiif'
require 'mini_magick'

require_relative 'iiif/derivatives'
require_relative 'iiif/manifest'

module WaxTasks
  # A Jekyll collection with image configuration + data
  class ImageCollection < Collection
    attr_reader :output_dir, :metadata, :data

    include WaxTasks::Iiif::Derivatives
    include WaxTasks::Iiif::Manifest

    # Creates a new IiifCollection with name @name given site config @site
    def initialize(name, site)
      super(name, site)

      @image_config = @config.dig('images')

      raise Error::InvalidCollection, "No image configuration found for collection '#{@name}'" if @image_config.nil?

      @data_source = self.image_source_directory
      @output_dir  = Utils.root_path(@site[:source_dir], DEFAULT_DERIVATIVE_DIR)
      @data        = self.image_data
      @metadata    = ingest_file(self.metadata_source_path)
      @variants    = WaxTasks::DEFAULT_IMAGE_VARIANTS
    end

    # Combines and described source image data including:
    # single image items, items from subdirectories of images,
    # and pdf documents.
    #
    # @return [Array] array of hashes relating item pids to image asset paths
    def image_data
      [single_image_items, multi_image_items, pdf_items].flatten.compact
    end

    # @return [String]
    def image_source_directory
      source = @image_config.dig('source')
      raise WaxIiif::Error::InvalidImageData, 'No image source directory specified.' if source.nil?
      path_to_image_source = Utils.root_path(@site[:source_dir], '_data/', source, '/')
      raise Error::MissingIiifSrc, "Cannot find IIIF source directory #{path_to_image_source}" unless Dir.exist?(path_to_image_source)
      raise Error::MissingIiifSrc, "No IIIF source data was found in #{path_to_image_source}" if Dir["#{path_to_image_source}/*"].empty?
      path_to_image_source
    end

    # Gets the items with 1 image asset
    #
    # @return [Array] array of hashes relating pids to image paths
    def single_image_items
      Dir["#{@data_source}*.{jpg, jpeg, tiff, png}"].map do |d|
        { pid: File.basename(d, '.*'), images: [d] }
      end
    end

    # Gets the items with multiple image assets
    #
    # @return [Array] array of hashes relating pids to image paths
    def multi_image_items
      Dir["#{@data_source}*/"].map do |d|
        images = Dir["#{d}*.{jpg, jpeg, tiff, png}"]
        { pid: File.basename(d, '.*'), images: images.sort }
      end
    end

    # Gets the items from pdf documents
    #
    # @return [Array] array of hashes relating pids to image paths
    def pdf_items
      Dir["#{@data_source}*.pdf"].map do |d|
        pid = File.basename(d, '.pdf')
        dir = "#{@data_source}/#{pid}"
        next if Dir.exist?(dir)
        { pid: pid, images: split_pdf(d) }
      end
    end

    #
    #
    # @return [Array] array of image paths generated from pdf split
    def split_pdf(pdf)
      split_opts = { output_dir: @data_source, verbose: true }
      WaxIiif::Utilities::PdfSplitter.split(pdf, split_opts).sort
    end

    def build_simple_derivatives
      simple_output_dir = "#{@output_dir}/simple"
      @data.each do |d|
        d[:images].each_with_index do |img, index|
          asset_id    = img.gsub(@data_source, '').gsub('.jpg', '').tr('/', '_')
          asset_path  = "#{simple_output_dir}/#{asset_id}"
          item_record = @metadata.find { |record| record['pid'] == d[:pid] }

          FileUtils.mkdir_p(asset_path)

          @variants.each do |label, width|
            variant_path = "#{asset_path}/#{label}.jpg"
            unless item_record.nil? || index.positive?
              item_record[label.to_s] = variant_path.gsub(/^./, '')
            end
            next puts "skipping #{variant_path}" if File.exist?(variant_path)

            image = MiniMagick::Image.open(img)
            image.resize(width)
            image.format('jpg')
            image.write(variant_path)
          end
        end
      end
      self.overwrite_metadata
    end

    # Creates a WaxIiif::Builder object,
    # builds the IIIF derivatives and json, and
    # makes them usable for Jekyll/Wax
    #
    # @return [Nil]
    def build_iiif_derivatives
      iiif_output_dir = "#{@output_dir}/iiif"
      jekyll_prefix = "{{ '' | absolute_url }}/#{DEFAULT_DERIVATIVE_DIR}/iiif"
      build_opts = {
        base_url: jekyll_prefix,
        output_dir: iiif_output_dir,
        variants: DEFAULT_IMAGE_VARIANTS,
        verbose: true,
        collection_label: @name
      }
      builder = WaxIiif::Builder.new(build_opts)
      builder.load(iiif_records(@data))
      builder.process_data
      add_iiif_derivative_info_to_metadata(builder.manifests)
      add_yaml_front_matter(iiif_output_dir)
    end
  end
end
