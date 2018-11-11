module WaxTasks
  module Lunr
    # Class representing a directory of markdown pages
    # to be indexed by a Lunr::Index
    class PageSet
      attr_reader :data

      def initialize(name, config, site)
        @name     = name
        @fields   = config.dig('fields')

        raise Error::MissingFields, "Cannot find fields to index collection #{@name}" if @fields.nil?

        @content  = !!config.dig('content')
        @page_dir = Utils.root_path(site[:source_dir], site[:collections_dir], "_#{@name}")
        @data     = self.ingest_pages
      end

      # Finds the page_dir of markdown pages for the collection and ingests
      # them as an array of hashes
      #
      # @return [Array] array of the loaded markdown pages loaded as hashes
      def ingest_pages
        data  = []
        pages = Dir.glob("#{@page_dir}/*.md")
        puts "There are no pages in #{@page_dir} to index.".orange if pages.empty?
        pages.each do |p|
          begin
            data << load_page(p)
          rescue StandardError => e
            raise Error::LunrPageLoad, "Cannot load page #{p}\n#{e}"
          end
        end
        data
      end

      # Reads in a markdown file and converts it to a hash
      # with the values from @fields.
      # Adds the content of the file (below the YAML) if @content == true
      #
      # @param page [String] the path to a markdown page to load
      def load_page(page)
        yaml = YAML.load_file(page)
        hash = {
          'link' => "{{'#{yaml.fetch('permalink')}' | absolute_url }}",
          'collection' => @name
        }
        content         = WaxTasks::Utils.html_strip(File.read(page))
        hash['content'] = WaxTasks::Utils.remove_diacritics(content) if @content
        fields          = @fields.push('pid').push('label').uniq
        fields.push('thumbnail') if yaml.key?('thumbnail')
        fields.each { |f| hash[f] = yaml.dig(f).lunr_normalize }
        hash
      end
    end
  end
end
