require 'wax_iiif'

module WaxTasks
  # A Jekyll collection with IIIF configuration + data
  #
  # @attr src_data    [String]  the path to the data source file
  # @attr iiif_config [Hash]    the iiif configuration for the collection
  # @attr meta        [Array]   metadata k,v rules
  # @attr variants    [Hash]    image variants to generate e.g. { med: 650 }
  # @attr src_dir     [String]  path to existing iiif source images
  # @attr target_dir  [String]  target path for iiif derivatives
  class IiifCollection < Collection
    attr_reader :variants, :meta, :target_dir

    # Creates a new collection with name @name given site config @site
    def initialize(name, site)
      super(name, site)

      @src_data     = @config.fetch('source', nil)
      @iiif_config  = @config.fetch('iiif', {})
      @meta         = @iiif_config.fetch('meta', nil)
      @variants     = validated_variants
      @src_dir      = Utils.make_path(@site[:source_dir],
                                      '_data/iiif',
                                      @name)
      @target_dir   = Utils.make_path(@site[:source_dir],
                                      'iiif',
                                      @name)
    end

    # Main method for generating iiif derivatives and json
    # @return [Nil]
    def process
      raise Error::MissingIiifSrc, "Cannot find IIIF source directory #{@src_dir}" unless Dir.exist?(@src_dir)
      FileUtils.mkdir_p(@target_dir, verbose: false)
      builder = iiif_builder
      builder.load(iiif_records)
      builder.process_data(true)
    end

    # Creates a IiifS3::Builder object from collection config
    # @return [Object]
    def iiif_builder
      build_opts = {
        base_url: "#{@site[:baseurl]}/iiif/#{@name}",
        output_dir: @target_dir,
        verbose: true,
        variants: @variants
      }
      IiifS3::Builder.new(build_opts)
    end

    # Gets custom image variants from collection config if available
    # Else returns default variants { med: 600, lg: 1140 } to Builder
    #
    # @return [Hash]
    def validated_variants
      vars = @iiif_config.fetch('variants', false)
      if vars.is_a?(Array) && vars.all? { |v| v.is_a?(Integer) }
        variants = {}
        vars.each_with_index do |v, i|
          variants["custom_variant_#{i}".to_sym] = v
        end
      else
        variants = { med: 600, lg: 1140 }
      end
      variants
    end

    # Creates an array of IIIfS3 ImageRecords from the collection config
    # for the IiifS3 Builder to process
    #
    # @return [Array]
    def iiif_records
      records = []
      source_images = Dir["#{@src_dir}/*"].sort!
      if @meta && @src_data
        src_path = Utils.make_path(@site[:source_dir], '_data', @src_data)
        metadata = ingest_file(src_path)
      else
        metadata = false
      end
      source_images.each { |src_img| records << iiif_record(src_img, metadata) }
      records
    end

    # Creates an individual IiifS3 ImageRecord
    # with metadata from source data file if available
    #
    # @param  src_img  [String]  path to the original source image
    # @param  metadata [Hash]    metadata to add to the item if available
    # @return [Object]
    def iiif_record(src_img, metadata)
      basename = File.basename(src_img, '.*').to_s
      record_opts = { id: basename, path: src_img, label: basename }
      if metadata
        src_item = metadata.find { |i| i['pid'].to_s == basename }
        @meta.each do |i|
          record_opts[i.first[0].to_sym] = src_item.fetch(i.first[1], '')
        end
      end
      IiifS3::ImageRecord.new(record_opts)
    end
  end
end
