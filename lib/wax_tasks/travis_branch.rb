require 'time'

module WaxTasks
  # Branch object for `$ wax:push` task when run on Travis-CI VM
  # using encrypted Travis environment vars
  #
  # @attr repo_slug   [String] the 'user/repo_name'
  # @attr user        [String] the GitHub user making the commit/push
  # @attr token       [String] secret git access token
  # @attr commit_msg  [String] the commit message to use on push
  # @attr origin      [String] the current repository remote
  # @attr baseurl     [String] the site baseurl to build with (if on gh-pages)
  # @attr success_msg [String] informative message to be output to console
  class TravisBranch < Branch
    def initialize(site, target)
      super(site, target)

      @repo_slug    = ENV['TRAVIS_REPO_SLUG']
      @user         = @repo_slug.split('/').first
      @token        = ENV['ACCESS_TOKEN']

      @commit_msg   = "Updated via #{ENV['TRAVIS_COMMIT']} @#{Time.now.utc}"
      @origin       = "https://#{@user}:#{@token}@github.com/#{@repo_slug}.git"
      @baseurl      = "/#{@repo_slug.split('/').last}"
      @success_msg  = "Deploying to #{@target} branch from Travis as #{@user}."
    end
  end
end
