# frozen_string_literal: true

#
class Annotation
  def initialize(annotationlist_id, canvas_id, xywh,
                 resource = {}, options = {})
    @annotationlist_id = annotationlist_id
    @canvas_id    = canvas_id
    @xywh         = xywh            # TODO: validate xywh
    @type         = 'oa:Annotation'
    @motivation   = options[:motivation] || 'sc:painting'
    @resource     = 
      {
        :@type => resource[:type] || 'cnt:ContentAsText',
        chars:    resource[:chars] || '',
        format:   resource[:format] || 'text/plain'
        # TODO: extend or subclass this as needed for other kinds of annotations
      }
    @resource[:language] = resource[:language] unless resource[:language].nil?
  end

  def to_hash
    {
      :@context => 'http://iiif.io/api/presentation/2/context.json',
      :@id => @annotationlist_id + '#' + @xywh,
      :@type => @type,
      motivation: @motivation,
      resource: @resource,
      on: @canvas_id + '#' + @xywh
    }
  end
end
