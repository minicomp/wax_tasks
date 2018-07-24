require 'colorize'

module WaxTasks
  # Custom WaxTasks Errors module
  module Error
    # Custom WaxTasks Error class with magenta console output
    class WaxTasksError < StandardError
      def initialize(msg = '')
        super(msg.magenta)
      end
    end

    # Custom error: site config cannot be found / parsed
    class InvalidSiteConfig < WaxTasksError; end
    # Custom error: collection specified cannot be found / parsed in site config
    class InvalidCollection < WaxTasksError; end
    # Custom error: data source for collection is not the correct type or is an invalid file
    class InvalidSource     < WaxTasksError; end
    # Custom error: data source file could not be found
    class MissingSource     < WaxTasksError; end
    # Custom error: while loading markdown pages to index, one could not be read
    class LunrPageLoad      < WaxTasksError; end
    # Custom error: a lunr collection does not have fields specified to index
    class MissingFields     < WaxTasksError; end
    # Custom error: a page layout was not specified for a pagemaster collection
    class MissingLayout     < WaxTasksError; end
    # Custom error: a collection item does not have a required pid value
    class MissingPid        < WaxTasksError; end
    # Custom error: a collection item has a non-unique pud value
    class NonUniquePid      < WaxTasksError; end
    # Custom error: a collection page item could not be generated
    class PageFailure       < WaxTasksError; end
    # Custom error: a csv file failed to lint could not be loaded
    class InvalidCSV        < WaxTasksError; end
    # Custom error: a json file failed to lint could not be loaded
    class InvalidJSON       < WaxTasksError; end
    # Custom error: a yaml file failed to lint could not be loaded
    class InvalidYAML       < WaxTasksError; end
    # Custom error: no collections in site config have the required lunr_index parameters
    class NoLunrCollections < WaxTasksError; end
  end
end
