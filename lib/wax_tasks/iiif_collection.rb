require 'wax_iiif'
require_relative 'iiif_utils'

module WaxTasks
  # A Jekyll collection with IIIF configuration + data

  # @attr iiif_config [Hash]    the iiif configuration for the collection
  # @attr target_dir  [String]  target path for iiif derivatives
  class IiifCollection < Collection
    attr_reader :target_dir, :metadata, :data

    include WaxTasks::IiifUtils

    # Creates a new IiifCollection with name @name given site config @site
    def initialize(name, site)
      super(name, site)

      @image_config = @config.dig('images')
      @src_dir      = self.image_source
      @target_dir   = Utils.make_path(@site[:source_dir], 'iiif')

      raise Error::MissingIiifSrc, "Cannot find IIIF source directory #{@src_dir}" unless Dir.exist?(@src_dir)
      raise Error::MissingIiifSrc, "No IIIF source data was found in #{@src_dir}" if Dir["#{@src_dir}/*"].empty?

      @metadata     = ingest_file(self.source_path)
      @data         = iiif_records(self.iiif_source_map)
      @manifests    = []
    end

    # @return [String]
    def image_source
      source = @image_config.dig('source')
      raise WaxIiif::Error::InvalidImageData, 'No image source directory specified.' if source.nil?
      Utils.make_path(@site[:source_dir], '_data/', source)
    end

    # @return [String]
    def label
      @image_config.dig('iiif', 'label')
    end

    # @return [String]
    def description
      @image_config.dig('iiif', 'description')
    end

    # @return [String]
    def attribution
      @image_config.dig('iiif', 'attribution')
    end

    # @return [String]
    def logo
      @image_config.dig('iiif', 'logo')
    end

    # Creates a WaxIiif::Builder object,
    # builds the IIIF derivatives and json, and
    # makes them usable for Jekyll/Wax
    #
    # @return [Nil]
    def build
      output_dir = Utils.make_path(@site[:source_dir], 'iiif')
      build_opts = {
        base_url: "{{ 'iiif' | absolute_url }}",
        output_dir: output_dir,
        variants: DEFAULT_IMAGE_VARIANTS,
        verbose: true,
        collection_label: @name
      }
      builder = WaxIiif::Builder.new(build_opts)
      builder.load(@data)
      builder.process_data
      create_info_file(builder.manifests)
      add_yaml_front_matter(output_dir)
    end
  end
end
