require 'time'

module WaxTasks
  # Branch object for `$ wax:push` task when run on local machine
  # using local credentials
  #
  # @attr origin      [String] the current repository remote
  # @attr commit_msg  [String] the commit message to use on push
  # @attr baseurl     [String] the site baseurl to build with (if on gh-pages)
  # @attr success_msg [String] informative message to be output to console
  class LocalBranch < Branch
    def initialize(site, target)
      super(site, target)

      @origin       = `git config --get remote.origin.url`.strip
      @commit_msg   = "Updated via local task at #{Time.now.utc}"
      @baseurl      = "/#{@origin.split('/').last.gsub('.git', '')}"
      @success_msg  = "Deploying to #{@target} branch from local task."
    end
  end
end
