require 'wax_iiif'

module WaxTasks
  # A Jekyll collection with IIIF configuration + data
  #
  # @attr src_data    [String]  the path to the data source file
  # @attr iiif_config [Hash]    the iiif configuration for the collection
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
      @src_pdf      = Utils.make_path(@site[:source_dir], '_data/iiif', "#{@name}.pdf")
      @src_dir      = Utils.make_path(@site[:source_dir], '_data/iiif', @name)
      @target_dir   = make_target_dir
      @variants     = validate_variants
    end

    # @return [Boolean]
    def document?
      !!@is_document || self.pdf?
    end

    # @return [Boolean]
    def pdf?
      File.exist? @src_pdf
    end

    # @return [Boolean]
    def sort?
      self.pdf? || !!@iiif_config.fetch('sort', false)
    end

    # Splits the @src_pdf into jpegs with WaxIiif and Ghostscript
    # @return [Nil]
    def split_pdf
      pdf_opts = { output_dir: @src_dir, verbose: true }
      WaxIiif::Utilities::PdfSplitter.split(@src_pdf, pdf_opts)
    end

    # Constructs the target directory for output iiif derivatives/json
    # @return [String]
    def make_target_dir
      dir = Utils.make_path(@site[:source_dir], 'iiif')
      dir += "/#{@name}" unless self.document?
      dir
    end

    # Gets custom image variants from collection config if available
    # Else returns default variants { med: 600, lg: 1140 } to Builder
    #
    # @return [Hash]
    def validate_variants
      vars = @iiif_config.fetch('variants', false)
      if vars.is_a?(Array) && vars.all? { |v| v.is_a?(Integer) }
        valid = {}
        vars.each_with_index do |v, i|
          valid["custom_variant_#{i}".to_sym] = v
        end
        valid
      else
        DEFAULT_IMAGE_VARIANTS
      end
    end

    # Creates an array of WaxIiif ImageRecords from the collection config
    # for the WaxIiif Builder to process
    #
    # @return [Array]
    def records
      split_pdf if self.pdf? && !Dir.exist?(@src_dir)

      raise Error::MissingIiifSrc, "Cannot find IIIF source directory #{@src_dir}" unless Dir.exist?(@src_dir)
      images = Dir["#{@src_dir}/*"]
      images.sort! if self.sort?
      raise Error::MissingIiifSrc "IIIF source directory #{@src_dir} is empty" unless images.length

      # construct records
      records = images.map do |img|
        opts = self.document? ? doc_opts(img) : img_opts(img)
        WaxIiif::ImageRecord.new(opts)
      end

      configure_primary_images(records)
    end

    # @return [Hash]
    def doc_opts(img)
      bname = File.basename(img, '.*').to_s
      id    = self.pdf? ? bname.split('_pdf_page').last : bname
      {
        parent_id: @name,
        is_document: true,
        path: img,
        id: id,
        label: @name,
        section_label: id
      }
    end

    # @return [Hash]
    def img_opts(img)
      bname = File.basename(img, '.*').to_s
      {
        parent_id: @name,
        id: bname,
        path: img,
        section_label: bname,
        label: bname
      }
    end

    # Set one primary image per document/object and return
    # updated array of records
    #
    # @return [Array]
    def configure_primary_images(records)
      if self.document?
        # set only the first image as primary to the record
        records.first.is_primary = true
        records[1..-1].each { |r| r.is_primary = false }
      else
        # set each image as primary to the record
        records.each { |r| r.is_primary = true }
      end
      records
    end
  end
end
