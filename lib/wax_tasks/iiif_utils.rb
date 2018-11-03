module WaxTasks
  # Module of helper functions for WaxTasks::IiiifCollection class
  module IiifUtils
    # Combines and described source image data including:
    # single image items, items from subdirectories of images,
    # and pdf documents.
    #
    # @return [Array] array of hashes relating pids to image paths
    def iiif_source_map
      [single_image_items, multi_image_items, pdf_items].flatten.compact
    end

    # Gets the items with 1 image asset
    #
    # @return [Array] array of hashes relating pids to image paths
    def single_image_items
      Dir["#{@src_dir}/*.{jpg, jpeg, tiff, png}"].map do |d|
        { pid: File.basename(d, '.*'), images: [d] }
      end
    end

    # Gets the items with multiple image assets
    #
    # @return [Array] array of hashes relating pids to image paths
    def multi_image_items
      Dir["#{@src_dir}/*/"].map do |d|
        images = Dir["#{d}/*.{jpg, jpeg, tiff, png}"]
        { pid: File.basename(d, '.*'), images: images.sort }
      end
    end

    # Gets the items from pdf documents
    #
    # @return [Array] array of hashes relating pids to image paths
    def pdf_items
      Dir["#{@src_dir}/*.pdf"].map do |d|
        pid = File.basename(d, '.pdf')
        dir = "#{@src_dir}/#{pid}"
        { pid: pid, images: split_pdf(d) } unless Dir.exist?(dir)
      end
    end

    #
    #
    # @return [Array] array of image paths generated from pdf split
    def split_pdf(pdf)
      split_opts = { output_dir: @src_dir, verbose: true }
      WaxIiif::Utilities::PdfSplitter.split(pdf, split_opts).sort
    end

    #
    #
    # @return [Hash] base WaxIiif::ImageRecord opts from item
    def base_opts(item)
      opts = { is_primary: false }
      opts[:description] = item.dig(description).to_s unless description.nil?
      opts[:attribution] = item.dig(attribution).to_s unless attribution.nil?
      opts[:logo]        = "{{ '#{logo}' | absolute_url }}" unless logo.nil?
      opts
    end

    #
    #
    # @return [Array] Set of WaxIiif::ImageRecords
    def iiif_records(source_data)
      records = []
      source_data.each do |d|
        item = @metadata.detect { |m| m['pid'] == d[:pid] } || {}
        opts = base_opts(item)
        if d[:images].length == 1
          opts[:id]         = d[:pid]
          opts[:path]       = d[:images].first
          opts[:label]      = item.fetch(label.to_s, d[:pid])
          opts[:is_primary] = true

          records << WaxIiif::ImageRecord.new(opts)
        else
          item_records = []
          d[:images].each do |i|
            img_id = File.basename(i, '.*').to_s

            opts[:id]             = "#{d[:pid]}_#{img_id}"
            opts[:manifest_id]    = d[:pid]
            opts[:path]           = i
            opts[:label]          = item.fetch(label.to_s, d[:pid])
            opts[:section_label]  = img_id

            item_records << WaxIiif::ImageRecord.new(opts)
          end
          item_records.first.is_primary = true
          records += item_records
        end
        records.flatten
      end
      records
    end

    # Opens IIIF JSON files and prepends yaml front matter
    # So that liquid vars can be read by Jekyll
    #
    # @return [Nil]
    def add_yaml_front_matter(dir)
      Dir["#{dir}/**/*.json"].each do |file|
        front_matter = "---\nlayout: none\n---\n"
        filestring = File.read(file)
        next if filestring.start_with?(front_matter)
        begin
          json = JSON.parse(filestring)
          File.open(file, 'w') do |f|
            f.puts(front_matter)
            f.puts(JSON.pretty_generate(json))
          end
        rescue StandardError => e
          raise Error::InvalidJSON, "IIIF JSON in #{file} is invalid.\n#{e}"
        end
      end
    end

    #
    #
    # @return [Nil]
    def create_info_file(manifests)
      items = manifests.map do |m|
        json = JSON.parse(m.to_json)
        {
          'pid'       => m.base_id,
          'manifest'  => Utils.rm_liquid_iiif(json['@id']),
          'label'     => Utils.rm_liquid_iiif(json['label']),
          'thumb'     => Utils.rm_liquid_iiif(json['thumbnail'])
        }
      end
      iiif_info = {
        'collection' => "/iiif/collection/#{@name}.json",
        'items' => items
      }
      file = Utils.make_path(@site[:source_dir], "_data/#{@name}_iiif_info.yml")
      puts "Writing IIIF path log to #{file}.".cyan
      File.open(file, 'w') { |f| f.write(iiif_info.to_yaml) }
    end
  end
end
