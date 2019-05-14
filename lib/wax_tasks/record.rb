# frozen_string_literal: true

module WaxTasks
  #
  class Record
    attr_reader :meta, :pid

    def initialize(meta)
      @meta = meta
      @pid  = @meta.fetch('pid')
    end

    def order=(order)
      @meta['order'] = order
    end

    def layout=(layout)
      @meta['layout'] = layout
    end

    def content=(content)
      @meta['content'] = content
    end

    def permalink=(permalink)
      @meta['permalink'] = permalink
    end

    def permalink
      @meta['permalink']
    end

    def collection=(collection)
      @meta['collection'] = collection
    end

    def lunr_id=(lunr_id)
      @meta['lunr_id'] = lunr_id
    end

    def keep_only(fields)
      @meta.select! { |k, _v| fields.include? k }
    end

    def lunr_normalize_values
      @meta.transform_values { |v| Utils.lunr_normalize(v) }
    end

    def write_to_page(dir)
      path = "#{dir}/#{pid}.md"
      if File.exist?(path)
        0
      else
        FileUtils.mkdir_p(File.dirname(path))
        File.open(path, 'w') { |f| f.write("#{@meta.to_yaml}---") }
        1
      end
    end
  end
end
