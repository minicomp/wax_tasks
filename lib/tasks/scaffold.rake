# frozen_string_literal: true

require 'wax_tasks'
require 'byebug'

namespace :wax do
  desc 'add basic scaffolding for Wax to an existing jekyll site'
  task :scaffold do
    site = WaxTasks::Site.new
    byebug
  end
end
