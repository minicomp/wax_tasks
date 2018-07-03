require 'colorize'
require 'jekyll'
require 'tmpdir'
require 'time'
require 'yaml'

# methods for building/pushing git branches
module Branch
  def build(baseurl)
    FileUtils.rm_rf('_site')
    opts = {
      source: '.',
      destination: '_site',
      config: '_config.yml',
      baseurl:  baseurl,
      verbose: true
    }
    Jekyll::Site.new(Jekyll.configuration(opts)).process
  end

  def push
    abort "Cannot find _site.".magenta unless Dir.exist? '_site'
    Dir.chdir('./_site')
    system 'git init && git add .'
    system "git commit -m '#{@commit_msg}'"
    system "git remote add origin #{@origin}"
    system "git push origin master:refs/heads/#{TARGET} --force"
  end
end

# configure git branches from travis info
class TravisBranch
  include Branch

  def initialize
    @repo_slug  = ENV['TRAVIS_REPO_SLUG']
    @user       = @repo_slug.split('/')[0]
    @repo_name  = '1' + @repo_slug.split('/')[1]
    @token      = ENV['ACCESS_TOKEN']
    @commit_msg = "Site updated via #{ENV['TRAVIS_COMMIT']} at #{Time.now.utc}"
    @origin     = "https://#{@user}:#{@token}@github.com/#{@repo_slug}.git"

    puts "Deploying to #{TARGET} branch from Travis as #{@user}.".cyan
  end

  def build_gh_site
    abort 'You must add the gh-baseurl to config.' if @repo_name.nil?
    build(@repo_name)
  end
end

# configure git branches from local info
class LocalBranch
  include Branch

  attr_reader :origin, :commit_msg

  def initialize
    @origin     = `git config --get remote.origin.url`
    @commit_msg = "Site updated via local task at #{Time.now.utc}"
    puts "Deploying to #{TARGET} branch from local task.".cyan
  end

  def build_gh_site
    abort "Cannot load config.".magenta unless CONFIG
    baseurl = CONFIG.fetch('gh-baseurl', false)
    abort "You must add the gh-baseurl to config.".magenta unless baseurl
    build(baseurl)
  end
end
