require 'wax_tasks'

namespace :wax do
  desc 'push compiled site to git branch BRANCH'
  task :push do
    ARGS    = ARGV.drop(1).each { |a| task a.to_sym }
    TARGET  = slug(ARGS.first)
    TRAVIS  = ENV.fetch('CI', false)
    CONFIG  = YAML.load_file('./_config.yml')
    GH      = TARGET == 'gh-pages'

    abort "You must specify a branch after 'wax:push:branch'" if ARGS.empty?

    branch = TRAVIS ? TravisBranch.new : LocalBranch.new
    branch.build_gh_site if GH
    branch.push
  end
end
