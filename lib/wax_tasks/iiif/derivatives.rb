module WaxTasks
  # Module of helper functions for WaxTasks::IiiifCollection class
  module Iiif
    # Helpers for creating Iiif derivatives for a Collection
    # via `wax:derivatives:iiif` Rake task
    module Derivatives
      # @return [Hash] base WaxIiif::ImageRecord opts from item
      def base_opts(item)
        opts = { is_primary: false }
        opts[:description] = item.dig(description).to_s unless description.nil?
        opts[:attribution] = item.dig(attribution).to_s unless attribution.nil?
        opts[:logo]        = "{{ '#{logo}' | absolute_url }}" unless logo.nil?
        opts
      end

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
      def add_iiif_derivative_info_to_metadata(manifests)
        manifests.map do |m|
          json = JSON.parse(m.to_json)
          pid = m.base_id
          @metadata.find { |i| i['pid'] == pid }.tap do |hash|
            hash['manifest']  = Utils.rm_liquid(json['@id'])
            hash['thumbnail'] = Utils.rm_liquid(json['thumbnail'])
            hash['full']      = hash['thumbnail'].sub('250,/0', '1140,/0')
          end
        end
        overwrite_metadata
      end
    end
  end
end
