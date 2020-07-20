# frozen_string_literal: true

require 'wax_tasks'

namespace :wax do
  desc 'destroy wax-generated collection files, including pages, derivatives, and search index(es)'
  task :clobber do
    args = ARGV.drop(1).each { |a| task a.to_sym }
    args.reject! { |a| a.start_with? '-' }

    raise WaxTasks::Error::MissingArguments, Rainbow("You must specify a collection after 'wax:clobber'").magenta if args.empty?

    site = WaxTasks::Site.new
    args.each { |a| site.clobber a }
  end
end
