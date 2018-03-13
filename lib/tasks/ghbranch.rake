include FileUtils
require 'wax_tasks'
require 'jekyll'

namespace :wax do
  desc 'build site with gh-baseurl and publish to gh-pages branch'
  task :ghbranch do
    config = read_config
    rm_rf('_site')

    opts = {
      'source' => '.',
      'destination' => '_site',
      'config' => '_config.yml',
      'baseurl' => config['gh-baseurl'],
      'incremental' => true,
      'verbose' => true
    }

    Jekyll::Site.new(Jekyll.configuration(opts)).process

    origin = `git config --get remote.origin.url`

    Dir.mktmpdir do |tmp|
      cp_r '_site/.', tmp
      Dir.chdir tmp

      system 'git init' # Init the repo.
      system "git add . && git commit -m 'Site updated at #{Time.now.utc}'"
      system 'git remote add origin ' + origin
      system 'git push origin master:refs/heads/gh-pages --force'
    end
  end
end
