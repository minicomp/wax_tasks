require 'wax_iiif'

module WaxTasks
  # A Jekyll collection with IIIF configuration + data

  # @attr iiif_config [Hash]    the iiif configuration for the collection
  # @attr iiif_src    [String]  path to existing iiif source images
  # @attr target_dir  [String]  target path for iiif derivatives
  class IiifCollection < Collection
    attr_reader :target_dir, :source, :metadata

    # Creates a new IiifCollection with name @name given site config @site
    def initialize(name, site)
      super(name, site)

      @config       = self.config
      @iiif_config  = @config.fetch('iiif', {})
      @iiif_src     = Utils.make_path(@site[:source_dir], '_data/iiif', @name)
      @metadata     = ingest_file(source_path)
      @target_dir   = Utils.make_path(@site[:source_dir], 'iiif')
    end

    # @return [String]
    def label
      @iiif_config.fetch('label', nil)
    end

    # @return [String]
    def description
      @iiif_config.fetch('description', nil)
    end

    # @return [String]
    def attribution
      @iiif_config.fetch('attribution', nil)
    end

    # @return [String]
    def logo
      @iiif_config.fetch('logo', nil)
    end

    def split_pdf(pdf)
      split_opts = { output_dir: @iiif_src, verbose: true }
      WaxIiif::Utilities::PdfSplitter.split(pdf, split_opts).sort
    end

    # Creates an array of WaxIiif ImageRecords from the collection config
    # for the WaxIiif Builder to process
    #
    # @return [Array]
    def records
      raise Error::MissingIiifSrc, "Cannot find IIIF source directory #{@iiif_src}" unless Dir.exist?(@iiif_src)

      images = Dir["#{@iiif_src}/*.{jpg, jpeg, tiff, png}"]
      construct_iiif_records(images, processed_documents).flatten
    end

    def processed_documents
      documents = []
      # process documents from sub directories of images
      Dir["#{@iiif_src}/*/"].each do |d|
        pid     = File.basename(d)
        images  = Dir["#{d}/*.{jpg, jpeg, tiff, png}"].sort
        documents << { pid => images }
      end
      # process documents from pdf files
      Dir["#{@iiif_src}/*.pdf"].each do |d|
        pid = File.basename(d, '.pdf')
        if Dir.exist?("#{@iiif_src}/#{pid}")
          puts "#{d} has already been split into images. Continuing."
        else
          documents << { pid => split_pdf(d) }
        end
      end
      documents
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
    def img_opts(img)
      pid   = File.basename(img, '.*').to_s
      item  = @metadata.detect { |m| m['pid'] == pid } || {}
      opts  = {
        parent_id: @name,
        is_primary: true,
        id: pid,
        path: img,
        label: item.fetch(label.to_s, pid).to_s
      }
      opts[:description] = item.fetch(description, '') unless description.nil?
      opts[:attribution] = item.fetch(attribution, '') unless attribution.nil?
      opts[:logo] = "{{ '#{logo}' | absolute_url }}" unless logo.nil?
      opts
    end

    # @return [Hash]
    def doc_opts(manifest_id, img)
      img_id  = File.basename(img, '.*').to_s
      item    = @metadata.detect { |m| m['pid'] == manifest_id } || {}
      opts = {
        id: "#{manifest_id}_#{img_id}",
        manifest_id: manifest_id,
        is_primary: false,
        is_document: true,
        path: img,
        label: item.fetch(label.to_s, manifest_id).to_s,
        section_label: img_id
      }
      opts[:description] = item.fetch(description, '') unless description.nil?
      opts[:attribution] = item.fetch(attribution, '') unless attribution.nil?
      opts[:logo] = "{{ '#{logo}' | absolute_url }}" unless logo.nil?
      opts
    end
  end
end
