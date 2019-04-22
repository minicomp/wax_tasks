# frozen_string_literal: true

require 'wax_tasks'

namespace :wax do
  desc 'generate collection md pages from yaml or csv data source'
  task :pagemaster do
    args = ARGV.drop(1).each { |a| task a.to_sym }
    raise WaxTasks::Error::MissingArguments, 'You must specify a collection after wax:pagemaster' if args.empty?

    site = WaxTasks::Site.new
    args.each { |a| WaxTasks.pagemaster(site, a) }
  end
end
