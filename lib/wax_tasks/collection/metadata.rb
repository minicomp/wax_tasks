# frozen_string_literal: true

#
module WaxTasks
  #
  class Collection
    #
    module Metadata
      #
      #
      def search_fields=(fields)
        @search_fields.concat(fields).flatten.compact.uniq
      end

      #
      #
      def records_from_pages
        paths = Dir.glob("#{@page_source}/*.{md, markdown}")
        warn Rainbow("There are no pages in #{@page_source} to index.").orange if paths.empty?

        paths.map do |path|
          begin
            content = WaxTasks::Utils.content_clean File.read(path)
            Record.new(SafeYAML.load_file(path)).tap do |r|
              r.set 'content', content
              r.set 'permalink', "/#{@name}/#{r.pid}#{@ext}" unless r.permalink?
            end
          rescue StandardError => e
            raise Error::PageLoad, "Cannot load page #{path}\n#{e}"
          end
        end
      end

      #
      #
      def records_from_metadata
        raise Error::MissingSource, "Cannot find metadata source '#{@metadata_source}'" unless File.exist? @metadata_source

        metadata = Utils.ingest @metadata_source
        metadata.each_with_index.map do |meta, i|
          Record.new(meta).tap do |r|
            r.set 'order', Utils.padded_int(i, metadata.length) unless r.order?
            r.set 'layout', @config['layout'] if @config.key? 'layout'
            r.set 'collection', @name
          end
        end
      end

      #
      #
      def update_metadata(update)
        records = consolidate_records records_from_metadata, update
        reformatted = case File.extname @metadata_source
                      when '.csv'
                        csv_string records
                      when '.json'
                        json_string records
                      when /\.ya?ml/
                        yaml_string records
                      end
        File.open(@metadata_source, 'w') { |f| f.puts reformatted }
      end

      #
      #
      def consolidate_records(original, new)
        lost_record_pids = original.map(&:pid) - new.map(&:pid)
        lost_record_pids.each do |pid|
          new << original.find { |r| r.pid == pid }
        end
        new.sort_by(&:order)
      end

      #
      #
      def csv_string(records)
        keys = records.flat_map(&:keys).uniq
        CSV.generate do |csv|
          csv << keys
          records.each do |r|
            csv << keys.map { |k| r.hash.fetch(k, '') }
          end
        end
      end

      #
      #
      def json_string(records)
        hashes = records.map(&:hash)
        JSON.pretty_generate hashes
      end

      #
      #
      def yaml_string(records)
        hashes = records.map(&:hash)
        hashes.to_yaml
      end
    end
  end
end
