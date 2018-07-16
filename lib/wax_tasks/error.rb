require 'colorize'

module WaxTasks
  # Errors module
  module Error
    # Custom WaxTasks Error class with magenta console output
    class WaxTasksError < StandardError
      def initialize(msg = '')
        super(msg.magenta)
      end
    end
    class InvalidSiteConfig < WaxTasksError; end
    class InvalidCollection < WaxTasksError; end
    class InvalidSource     < WaxTasksError; end
    class LunrPageLoad      < WaxTasksError; end
    class MissingSource     < WaxTasksError; end
    class MissingLayout     < WaxTasksError; end
    class MissingPid        < WaxTasksError; end
    class NonUniquePid      < WaxTasksError; end
    class PageFailure       < WaxTasksError; end
    class InvalidCSV        < WaxTasksError; end
    class InvalidJSON       < WaxTasksError; end
    class InvalidYAML       < WaxTasksError; end
    class NoLunrCollections < WaxTasksError; end
  end
end
