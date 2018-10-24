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
      @src_dir      = Utils.make_path(@site[:source_dir], '_data/iiif', @name)
      @target_dir   = Utils.make_path(@site[:source_dir], 'iiif')
      @variants     = validate_variants
    end

    # @return [Boolean]
    def sort?
      !!@iiif_config.fetch('sort', false)
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
      raise Error::MissingIiifSrc, "Cannot find IIIF source directory #{@src_dir}" unless Dir.exist?(@src_dir)

      images    = process_images
      documents = process_documents

      construct_iiif_records(images, documents).flatten
    end

    # @return [Hash]
    def img_opts(img)
      bname = File.basename(img, '.*').to_s
      {
        parent_id: @name,
        is_primary: true,
        id: bname,
        path: img,
        section_label: bname,
        label: bname
      }
    end

    def process_documents
      documents = []
      # process documents from sub directories of images
      Dir["#{@src_dir}/*/"].each do |d|
        pid     = File.basename(d)
        images  = Dir["#{d}/*.{jpg, jpeg, tiff, png}"].sort
        documents << { pid => images }
      end
      # process documents from pdf files
      Dir["#{@src_dir}/*.pdf"].each do |d|
        pid = File.basename(d, '.pdf')
        if Dir.exist?("#{@src_dir}/#{pid}")
          puts "#{d} has already been split into images. Continuing."
        else
          documents << { pid => split_pdf(d) }
        end
      end

      documents
    end

    def process_images
      images = Dir["#{@src_dir}/*.{jpg, jpeg, tiff, png}"]
      images.sort! if self.sort?
      images
    end

    def split_pdf(pdf)
      split_opts = { output_dir: @src_dir, verbose: true }
      WaxIiif::Utilities::PdfSplitter.split(pdf, split_opts).sort
    end

    def construct_iiif_records(images, documents)
      records = images.map do |img|
        WaxIiif::ImageRecord.new(img_opts(img))
      end

      doc_records = documents.each do |doc|
        manifest_id = doc.keys.first
        doc_images  = doc.values.first
        doc_records = doc_images.map do |img|
          WaxIiif::ImageRecord.new(doc_opts(manifest_id, img))
        end
        doc_records.first.is_primary = true
        records << doc_records
      end.flatten

      records
    end

    # @return [Hash]
    def doc_opts(manifest_id, img)
      id = File.basename(img, '.*').to_s
      {
        id: "#{manifest_id}_#{id}",
        manifest_id: manifest_id,
        is_primary: false,
        is_document: true,
        path: img,
        label: manifest_id,
        section_label: id
      }
    end
  end
end
