require 'colorize'

# Errors module
module Error
  # Custom WaxTasks Error class with magenta console output
  class WaxTasksError < StandardError
    def initialize(msg = '')
      super(msg.magenta)
    end
  end
  class CollectionConfiguration < WaxTasksError; end
  class InvalidCollection < WaxTasksError; end
  class InvalidCSource < WaxTasksError; end
  class MissingPid < WaxTasksError; end
  class MissingSource < WaxTasksError; end
  class NonUniquePid < WaxTasksError; end
  class MissingRequiredVars < WaxTasksError; end
  class PageFailure < WaxTasksError; end
end
