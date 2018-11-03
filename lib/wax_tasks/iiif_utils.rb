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

    # @return [Nil]
    def overwrite_metadata
      source = self.source_path
      puts "Writing IIIF image info #{source}.".cyan
      case File.extname(source)
      when '.csv'
        keys = @metadata.map(&:keys).inject(&:|)
        CSV.open(source, 'w') do |csv|
          csv << keys
          @metadata.each { |hash| csv << hash.values_at(*keys) }
        end
      when '.json'
        json = JSON.pretty_generate(@metadata)
        File.open(source, 'w') { |f| f.write(json) }
      when /\.ya?ml/
        File.open(source, 'w') { |f| f.write(@metadata.to_yaml) }
      else
        raise Error::InvalidSource
      end
    end

    # @return [Nil]
    def add_info_to_metadata(manifests)
      manifests.map do |m|
        json = JSON.parse(m.to_json)
        pid = m.base_id
        item = @metadata.find { |i| i['pid'] == pid }
        next puts "Cannot find item with pid #{pid}".yellow if item.nil?
        item.tap do |hash|
          hash['manifest']    = Utils.rm_liquid_iiif(json['@id'])
          hash['thumbnail']   = Utils.rm_liquid_iiif(json['thumbnail'])
          hash['full_image']  = hash['thumbnail'].sub('250,/0', '1140,/0')
        end
      end
      overwrite_metadata
    end
  end
end
