# frozen_string_literal: true

require 'wax_tasks'

namespace :wax do
  namespace :derivatives do
    desc 'generate iiif derivatives from local image files'
    task :simple do
      args = ARGV.drop(1).each { |a| task a.to_sym }
      raise WaxTasks::Error::MissingArguments, "You must specify a collection after 'wax:derivatives:simple'" if args.empty?

      site = WaxTasks::Site.new

      args.each do |a|
        collection = WaxTasks::Collection.new(site, a)
        WaxTasks.generate_simple_derivatives(collection)
      end
    end
  end
end
