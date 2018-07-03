# Custom Errors
require 'colorize'

module Error
  class WaxTasksError < StandardError
    def initialize(msg='')
      super(msg.magenta)
    end
  end
  class CollectionConfiguration < WaxTasksError; end
  class InvalidCollection < WaxTasksError; end
  class InvalidCSource < WaxTasksError; end
  class MissingPid < WaxTasksError; end
  class MissingSource < WaxTasksError; end
  class NonUniquePid < WaxTasksError; end
end



  # def self.complain(error)
  #   abort error.magenta
  # end
  #
  # def self.missing_key(key, name)
  #   complain("Key '#{key}' not found for '#{name}'. Check config and rerun.")
  # end
  #
  # def self.invalid_type(ext, name)
  #   complain("Source file for #{name} must be .csv .json  or .yml. Found #{ext}.")
  # end
  #
  # def self.duplicate_pids(duplicates, name)
  #   complain("Fix the following duplicate pids for collection '#{name}': #{duplicates}")
  # end
  #
  # def self.bad_source(source, name)
  #   complain("Cannot load source '#{source}' for collection '#{name}'. Check for typos and rebuild.")
  # end
  #
  # def self.missing_pids(source, pids)
  #   complain("Source '#{source}' is missing #{pids.count(nil)} `pid` values.")
  # end
  #
  # def self.invalid_collection(name)
  #   complain("Configuration for the collection '#{name}' is invalid.")
  # end
  #
  # def self.page_generation_failure(completed)
  #   complain("Failure after #{completed} pages, likely from missing pid.")
  # end
  #
  # def self.no_collections_to_index
  #   complain('There are no valid collections to index.')
  # end
  #
  # def self.missing_iiif_src(dir)
  #   complain("Source path '#{dir}' does not exist. Exiting.")
  # end
# end
