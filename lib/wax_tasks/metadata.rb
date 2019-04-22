module WaxTasks
  module Metadata
    # Ingests the collection source data as an Array of Hashes
    #
    # @param source [String] the path to the CSV, JSON, or YAML source file
    # @return [Array] the collection data
    def ingest_metadata
      raise Error::MissingSource, "Cannot find #{@metadata_source}" unless File.exist? @metadata_source

      data = case File.extname(@metadata_source)
             when '.csv'
               WaxTasks::Utils.validate_csv(@metadata_source)
             when '.json'
               WaxTasks::Utils.validate_json(@metadata_source)
             when /\.ya?ml/
               WaxTasks::Utils.validate_yaml(@metadata_source)
             else
               raise Error::InvalidSource, "Can't load #{File.extname(@metadata_source)} files. Culprit: #{@metadata_source}"
             end

      WaxTasks::Utils.assert_pids(data)
      WaxTasks::Utils.assert_unique(data)
    end

    # Writes markdown pages from the ingested data to page_dir
    # with layout, permalink, and order info added (if applicable)
    #
    # @return [Array] a copy of the pages as hashes, for testing
    def generate_pages
      metadata = self.ingest_metadata
      FileUtils.mkdir_p(@page_dir)
      metadata.each_with_index do |item, idx|
        item['pid']       = Utils.slug(item.fetch('pid'))
        item['layout']    = @layout unless @layout.nil?
        item['order']     = Utils.padded_int(idx, metadata.length)
        path              = "#{@page_dir}/#{item['pid']}.md"
        next "#{item['pid']}.md already exits. Skipping." if File.exist?(path)
        File.open(path, 'w') { |f| f.write("#{item.to_yaml}---") }
      end
      puts "#{metadata.length} pages were generated to #{@page_dir} directory.".cyan
    end
  end
end
