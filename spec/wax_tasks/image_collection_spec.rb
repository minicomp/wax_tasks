describe WaxTasks::ImageCollection do
  include_context 'shared'

  before(:all) { WaxTasks::Test.reset }
  let(:iiif_derivatives_collection) { WaxTasks::ImageCollection.new('csv_collection', default_site) }
  let(:simple_derivatives_collection) { WaxTasks::ImageCollection.new('json_collection', default_site) }
  let(:pdf) { '_data/images/test_collection/pdf_imgs_item.pdf' }
  let(:pdf_image_dir) { '_data/images/test_collection/pdf_imgs_item' }
  let(:img_item) { 'img_item_1' }
  let(:dir_img_item) { 'dir_imgs_item' }
  let(:pdf_item) { 'pdf_imgs_item' }

  describe '.new' do
    it 'initializes a collection' do
      expect(iiif_derivatives_collection.name).to eq('csv_collection')
      expect(simple_derivatives_collection.name).to eq('json_collection')
    end

    it 'gets the label key when specified' do
      expect(iiif_derivatives_collection.label).to eq('gambrel')
    end

    it 'gets the description key when specified' do
      expect(iiif_derivatives_collection.description).to eq('indescribable')
    end

    it 'gets the attribution key when specified' do
      expect(iiif_derivatives_collection.attribution).to eq('blasphemous')
    end

    it 'gets the logo path when specified' do
      expect(iiif_derivatives_collection.logo).to eq('/path/to/logo')
    end
  end

  describe '.split_pdf' do
    it 'splits the pdf' do
      images = quiet_stdout { iiif_derivatives_collection.split_pdf(pdf) }
      expect(images.length).to eq(4)
      FileUtils.rm_r(pdf_image_dir)
    end
  end

  describe '.data' do
    it 'returns an array of valid image records' do
      data = quiet_stdout { iiif_derivatives_collection.data }
      expect(data).to be_an(Array)
      data.each do |d|
        expect(d).to have_key(:pid)
        expect(d).to have_key(:images)
      end
    end
  end

  describe '.build_simple_derivatives' do
    it 'runs without errors' do
      simple_derivatives_collection.build_simple_derivatives
    end

    it 'adds derivative paths to metadata' do
      item_record = simple_derivatives_collection.metadata.first
      expect(item_record).to have_key('thumbnail')
      expect(item_record).to have_key('full')

      source = simple_derivatives_collection.metadata_source_path
      metadata = simple_derivatives_collection.ingest_file(source)
      expect(metadata.first).to have_key('thumbnail')
      expect(metadata.first).to have_key('full')
    end

    context 'for items with one image asset' do
      it 'generates the thumbnail derivative' do
        thumb = "#{iiif_derivatives_collection.output_dir}/simple/#{img_item}/thumbnail.jpg"
        expect(File).to exist(thumb)
      end

      it 'generates the full width derivative' do
        full = "#{iiif_derivatives_collection.output_dir}/simple/#{img_item}/full.jpg"
        expect(File).to exist(full)
      end
    end

    context 'for items with multiple image assets from a directory' do
      it 'generates the thumbnail derivative' do
        thumb = "#{iiif_derivatives_collection.output_dir}/simple/#{dir_img_item}_0/thumbnail.jpg"
        expect(File).to exist(thumb)
      end

      it 'generates the full width derivative' do
        full = "#{iiif_derivatives_collection.output_dir}/simple/#{dir_img_item}_0/full.jpg"
        expect(File).to exist(full)
      end
    end

    context 'for items with multiple image assets from a pdf document' do
      it 'generates the thumbnail derivative' do
        thumb = "#{iiif_derivatives_collection.output_dir}/simple/#{pdf_item}_0/thumbnail.jpg"
        expect(File).to exist(thumb)
      end

      it 'generates the full width derivative' do
        full = "#{iiif_derivatives_collection.output_dir}/simple/#{pdf_item}_0/full.jpg"
        expect(File).to exist(full)
      end
    end
  end

  describe '.build_iiif_derivatives' do
    it 'runs without errors' do
      iiif_derivatives_collection.build_iiif_derivatives
    end

    it 'adds derivative paths to metadata' do
      item_record = iiif_derivatives_collection.metadata.first
      expect(item_record).to have_key('thumbnail')
      expect(item_record).to have_key('manifest')
      expect(item_record).to have_key('full')

      source = iiif_derivatives_collection.metadata_source_path
      metadata = iiif_derivatives_collection.ingest_file(source)
      expect(metadata.first).to have_key('thumbnail')
      expect(metadata.first).to have_key('manifest')
      expect(metadata.first).to have_key('full')
    end

    context 'for items with one image asset' do
      it 'builds the manifest json' do
        manifest = "#{iiif_derivatives_collection.output_dir}/iiif/#{img_item}/manifest.json"
        expect(File).to exist(manifest)
      end

      it 'builds the canvas json' do
        canvas = "#{iiif_derivatives_collection.output_dir}/iiif/canvas/#{img_item}.json"
        expect(File).to exist(canvas)
      end

      it 'builds the image json' do
        image = "#{iiif_derivatives_collection.output_dir}/iiif/images/#{img_item}/info.json"
        expect(File).to exist(image)
      end
    end

    context 'for items with multiple image assets from a directory' do
      it 'builds the manifest json' do
        manifest = "#{iiif_derivatives_collection.output_dir}/iiif/#{dir_img_item}/manifest.json"
        expect(File).to exist(manifest)
      end

      it 'builds the canvas json' do
        canvas = "#{iiif_derivatives_collection.output_dir}/iiif/canvas/#{dir_img_item}_0.json"
        expect(File).to exist(canvas)
      end

      it 'builds the image json' do
        image = "#{iiif_derivatives_collection.output_dir}/iiif/images/#{dir_img_item}_0/info.json"
        expect(File).to exist(image)
      end
    end

    context 'for items with multiple image assets from a pdf document' do
      it 'builds the manifest json' do
        manifest = "#{iiif_derivatives_collection.output_dir}/iiif/#{pdf_item}/manifest.json"
        expect(File).to exist(manifest)
      end

      it 'builds the canvas json' do
        canvas = "#{iiif_derivatives_collection.output_dir}/iiif/canvas/#{pdf_item}_0.json"
        expect(File).to exist(canvas)
      end

      it 'builds the image json' do
        image = "#{iiif_derivatives_collection.output_dir}/iiif/images/#{pdf_item}_0/info.json"
        expect(File).to exist(image)
      end
    end
  end
end
