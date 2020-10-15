# frozen_string_literal: true

require_relative './import/hocr.rb'

require 'byebug'

namespace :wax do
  namespace :import do
    task :hocr, [:hocr_path, :collection, :canvas, :granularity] do |_t, args|
      desc 'generate canvas-level annotationlist yaml file from hocr file'

      # TODO: validate args

      hocr_annotations = WaxTasks::HocrOpenAnnotationCreator.new(args)
      hocr_annotations.save

      puts 'done'
    end
  end
end
