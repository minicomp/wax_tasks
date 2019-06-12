# frozen_string_literal: true

require 'wax_tasks'

namespace :wax do
  desc 'generate JSONAPI from yaml or csv data source'
  task :api do
    args = ARGV.drop(1).each { |a| task a.to_sym }
    raise WaxTasks::Error::MissingArguments, Rainbow('You must specify a collection after wax:api').magenta if args.empty?

    site = WaxTasks::Site.new
    args.each { |a| site.generate_api a }
  end
end
