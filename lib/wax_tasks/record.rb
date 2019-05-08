# frozen_string_literal: true

module WaxTasks
  #
  class Record
    attr_reader :meta

    def initialize(meta)
      @meta = meta
    end

    def pid
      @meta.fetch('pid')
    end

    def order=(order)
      @meta['order'] = order
    end

    def layout=(layout)
      @meta['layout'] = layout
    end

    def write_to_page(dir)
      path = "#{dir}/#{pid}.md"
      if File.exist?(path)
        puts "#{path} already exits. Skipping."
        0
      else
        File.open(path, 'w') { |f| f.write("#{@meta.to_yaml}---") }
        1
      end
    end
  end
end
