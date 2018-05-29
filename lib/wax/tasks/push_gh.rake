require 'colorize'
require 'jekyll'
require 'wax_tasks'

namespace :wax do
  namespace :push do
    desc 'build site with gh-baseurl and push to gh-pages branch'
    task :gh do
      if ENV['CI']
        REPO_SLUG = ENV['TRAVIS_REPO_SLUG']
        USER = REPO_SLUG.split('/')[0]
        REPO_NAME = '1' + REPO_SLUG.split('/')[1]
        TOKEN = ENV['ACCESS_TOKEN']
        COMMIT_MSG = "Site updated via #{ENV['TRAVIS_COMMIT']}".freeze
        ORIGIN = "https://#{USER}:#{TOKEN}@github.com/#{REPO_SLUG}.git".freeze
        puts "Deploying to gh-oages branch from Travis as #{USER}"
      else
        ORIGIN = `git config --get remote.origin.url`.freeze
        COMMIT_MSG = "Site updated at #{Time.now.utc}".freeze
        puts 'Deploying to gh-pages branch from local task'
      end
      config = WaxTasks.site_config
      FileUtils.rm_rf('_site')

      opts = {
        'source' => '.',
        'destination' => '_site',
        'config' => '_config.yml',
        'baseurl' => config['gh-baseurl'] || REPO_NAME.to_s
      }

      Jekyll::Site.new(Jekyll.configuration(opts)).process
      Dir.mktmpdir do |tmp|
        FileUtils.cp_r '_site/.', tmp
        Dir.chdir tmp
        system 'git init'
        system "git add . && git commit -m '#{COMMIT_MSG}'"
        system "git remote add origin #{ORIGIN}"
        system 'git push origin master:refs/heads/gh-pages --force'
      end
    end
  end
end
