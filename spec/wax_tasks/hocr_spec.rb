# frozen_string_literal: true

require_relative '../../lib/tasks/import/hocr.rb'

describe HocrOpenAnnotationCreator do
  include_context 'shared'

  before(:all) do
    Test.reset
  end

  #
  # ===================================================
  # HocrOpenAnnotationCreator.NEW
  # ===================================================
  #
  describe '#new' do
    include_context 'shared'

    context 'parses hocr file not to raise error' do
      it 'runs without errors' do
        expect { HocrOpenAnnotationCreator.new({
          hocr_path: "#{ROOT}/spec/sample_hocr/img_item_1.hocr",
          collection: 'test_collection',
          canvas: 'img_item_1',
          granularity: 'paragraph'
        }) }.not_to raise_error
      end
	  end
  end

  describe '#save' do
    include_context 'shared'

    context 'hocr yaml file' do
      hocr = HocrOpenAnnotationCreator.new({
        hocr_path: "#{ROOT}/spec/sample_hocr/img_item_1.hocr",
        collection: 'test_collection',
        canvas: 'img_item_1',
        granularity: 'paragraph'
      })

      it 'captures chars correctly' do
        expect(hocr.resources.first[:resource][:chars]).to eq('If the ax falls the')
      end
      
      it 'captures target correctly' do
        expect(hocr.resources.first[:on]).to eq("{{ '/' | absolute_url }}img/derivatives/iiif/canvas/test_collection_img_item_1.json#xywh=20,668,171,100")
      end
	  end
  end

end
