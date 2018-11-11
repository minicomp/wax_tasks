require 'jekyll'
require 'logger'
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
    # @param time   [String]  message with the time of deployment
    def initialize(site, target)
      @site   = site
      @target = target
      @time   = Time.now.strftime('Updated at %H:%M on %Y-%m-%d')
    end

    # Rebuild the Jekyll site with branch @baseurl
    # @return [Nil]
    def rebuild
      if @baseurl.empty?
        msg = 'Building the gh-pages _site without a baseurl is not recommended'
        Logger.new($stdout).warn(msg.orange)
      end
      FileUtils.rm_r(SITE_DIR) if File.directory?(WaxTasks::SITE_DIR)
      opts = {
        source: @site[:source_dir] || '.',
        destination: WaxTasks::SITE_DIR,
        config: WaxTasks::DEFAULT_CONFIG,
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
        raise Error::MissingSite, "Cannot find #{WaxTasks::SITE_DIR}" unless Dir.exist? WaxTasks::SITE_DIR
        Dir.chdir(SITE_DIR)
        File.open('.info', 'w') { |f| f.write(@time) }
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
end
