require 'jekyll'
require 'logger'
require 'time'
require 'tmpdir'

module WaxTasks
  # Parent class representing a Git Branch
  # that cannot be created directly. Only child classes
  # (LocalBranch, TravisBranch) can be initialized.
  #
  # @attr target      [String] the name of the Git branch to deploy to
  # @attr origin      [String] the current repository remote
  # @attr commit_msg  [String] the commit message to use on push
  # @attr baseurl     [String] the site baseurl to build with (if on gh-pages)
  # @attr success_msg [String] informative message to be output to console
  class Branch
    attr_reader :target, :origin, :commit_msg, :baseurl, :success
    private_class_method :new

    # This method ensures child classes can be instantiated eventhough
    # Branch.new cannot be.
    def self.inherited(*)
      public_class_method :new
    end

    # @param site   [Hash]    the site config from (TaskRunner.site)
    # @param target [String]  the name of the Git branch to deploy to
    def initialize(site, target)
      @site   = site
      @target = target
    end

    # Rebuild the Jekyll site with branch @baseurl
    # @return [Nil]
    def rebuild
      if @baseurl.empty?
        msg = 'Building the gh-pages _site without a baseurl is not recommended'
        Logger.new($stdout).warn(msg.orange)
      end
      FileUtils.rm_r(SITE_DIR) if File.directory?(SITE_DIR)
      opts = {
        source: '.',
        destination: SITE_DIR,
        baseurl:  @baseurl,
        verbose: true
      }
      Jekyll::Site.new(Jekyll.configuration(opts)).process
    end

    # Add, commmit, and push compiled Jekyll site to @target branch
    # @return [Nil]
    def push
      if @site[:env] == 'prod'
        rebuild if @target == 'gh-pages'
        raise Error::MissingSite, "Cannot find #{SITE_DIR}" unless Dir.exist? SITE_DIR
        Dir.chdir(SITE_DIR)
        system 'git init && git add .'
        system "git commit -m '#{@commit_msg}'"
        system "git remote add origin #{@origin}"
        puts @success_msg.cyan
        system "git push origin master:refs/heads/#{@target} --force"
      else
        puts "Skipping build for branch '#{@target}' on env='test'".orange
      end
    end
  end

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
      @baseurl      = @repo_slug.split('/').last
      @success_msg  = "Deploying to #{@target} branch from Travis as #{@user}."
    end
  end

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
      @baseurl      = @origin.split('/').last.gsub('.git', '')
      @success_msg  = "Deploying to #{@target} branch from local task."
    end
  end
end
