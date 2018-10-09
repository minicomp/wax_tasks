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
    attr_reader :variants, :target_dir
    attr_writer :is_document

    # Creates a new IiifCollection with name @name given site config @site
    def initialize(name, site)
      super(name, site)

      @iiif_config  = @config.fetch('iiif', {})
      @is_document  = @iiif_config.fetch('is_document', false)
      @variants     = validated_variants
      @src_pdf      = Utils.make_path(@site[:source_dir], '_data/iiif', "#{@name}.pdf")
      @src_dir      = Utils.make_path(@site[:source_dir], '_data/iiif', @name)
      @target_dir   = Utils.make_path(@site[:source_dir], 'iiif')
      @target_dir   += "/#{@name}" unless self.is_document?
    end

    def is_document?
      @is_document || self.is_pdf?
    end

    def is_pdf?
      File.exist? @src_pdf
    end

    def records
      if self.is_pdf?
        load_pdf_records
      elsif @is_document
        load_document_records
      else
        load_image_records
      end
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

    # Splits the pdf and creates an array of WaxIiif ImageRecords
    # from the collection config for the WaxIiif Builder to
    # process as a single document / manifest
    #
    # @return [Array]
    def load_pdf_records
      WaxIiif::Utilities::PdfSplitter.split(@src_pdf, output_dir: @src_dir, verbose: true)
      records = load_document_records
    end

    # Creates an array of WaxIiif ImageRecords from the collection config
    # for the WaxIiif Builder to process
    #
    # @return [Array]
    def load_image_records
      raise Error::MissingIiifSrc, "Cannot find IIIF source directory #{@src_dir}" unless Dir.exist?(@src_dir)
      images = Dir["#{@src_dir}/*"].sort
      raise Error::MissingIiifSrc "IIIF source directory #{@src_dir} is empty" unless images.length

      # construct records
      records = images.map do |img|
        name = "#{@name}-#{File.basename(img, '.*').to_s}"
        record_opts = { id: name, path: img, label: name }
        WaxIiif::ImageRecord.new(record_opts)
      end

      # set each image as primary to the record
      records.each { |r| r.is_primary = true }
      records
    end

    # Creates an array of WaxIiif ImageRecords from the collection config
    # for the WaxIiif Builder to process as a single document / manifest
    #
    # @return [Array]
    def load_document_records
      raise Error::MissingIiifSrc, "Cannot find IIIF source directory #{@src_dir}" unless Dir.exist?(@src_dir)
      images = Dir["#{@src_dir}/*"].sort
      raise Error::MissingIiifSrc "IIIF source directory #{@src_dir} is empty" unless images.length

      # construct records
      records = images.map.with_index do |img, idx|
        bname = File.basename(img, '.*').to_s
        pn    = self.is_pdf? ? bname.split('_pdf_page').last : (idx + 1)
        WaxIiif::ImageRecord.new(id: @name, path: img, page_number: pn, label: @name, is_document: true)
      end

      # set only the first image as primary to the record
      records.first.is_primary = true
      records[1..-1].each { |r| r.is_primary = false }
      records
    end
  end
end
