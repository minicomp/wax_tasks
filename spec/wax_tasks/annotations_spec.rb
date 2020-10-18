# frozen_string_literal: true

describe WaxTasks::AnnotationList do
  include_context 'shared'

  before(:all) do
    Test.reset
  end

  #
  # ===================================================
  # ANNOTATION.UPDATEMANIFEST
  # ===================================================
  #
  describe '#updatemanifest' do
    context 'updates manifest' do
      it 'updates manifest' do
        FileUtils.mkdir_p "#{BUILD}/img/derivatives/iiif/test_collection/"
        FileUtils.cp Dir.glob("#{ROOT}/spec/sample_hocr/manifest.json"), "#{BUILD}/img/derivatives/iiif/test_collection/"
        FileUtils.mkdir_p "#{BUILD}/_data/annotations/test_collection/dir_imgs_item/"
        FileUtils.cp Dir.glob("#{ROOT}/spec/sample_hocr/*.yaml"), "#{BUILD}/_data/annotations/test_collection/dir_imgs_item/"

        config = WaxTasks::Config.new(config || WaxTasks.config_from_file)
        collection = config.find_collection 'csv_collection'

        collection.add_annotationlists_to_manifest(
          Dir.glob("#{BUILD}/_data/annotations/test_collection/dir_imgs_item/*.{yaml,yml,json}").sort
        )

        manifest_path = "#{BUILD}/img/derivatives/iiif/test_collection/manifest.json"
        raw_yaml, raw_json = File.read(manifest_path).match(/(---\n.+?\n---\n)(.*)/m)[1..2]
        manifest = JSON.parse(raw_json)

        expect(manifest['sequences'][0]['canvases'][0]['otherContent']).not_to be_nil
        expect(manifest['sequences'][0]['canvases'][0]['otherContent'][0]['@id']).to eq("{{ '/' | absolute_url }}img/derivatives/iiif/annotation/test_collection_img_item_1_ocr_paragraph.json")
      end
    end
  end
end
