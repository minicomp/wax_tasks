# frozen_string_literal: true

require 'wax_tasks'

namespace :wax do
  desc 'generate annotationlists from local yaml files'
  task :annotations do
    args = ARGV.drop(1).each { |a| task a.to_sym }
    args.reject! { |a| a.start_with? '-' }

    raise WaxTasks::Error::MissingArguments, Rainbow("You must specify a collection after 'wax:annotations'").magenta if args.empty?

    site = WaxTasks::Site.new
    args.each { |a| site.generate_annotations(a) }
  end
end
