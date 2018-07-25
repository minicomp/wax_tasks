describe WaxTasks::IiifCollection do
  include_context 'shared'

  before(:all) { WaxTasks::Test.reset }
  let(:valid_collection) { WaxTasks::IiifCollection.new(args.first, default_site) }
  let(:no_variants) do
    opts = {
      collections: {
        args.first => { 'source' => 'valid.csv', 'iiif' => { 'meta' => [{ 'label' => 'gambrel' }] } }
      }
    }
    runner = WaxTasks::TaskRunner.new.override(opts)
    WaxTasks::IiifCollection.new(args.first, runner.site)
  end
  let(:no_meta) do
    opts = {
      collections: {
        args.first => { 'layout' => 'default.html' }
      }
    }
    runner = WaxTasks::TaskRunner.new.override(opts)
    WaxTasks::IiifCollection.new(args.first, runner.site)
  end
  let(:target_dir) { valid_collection.target_dir }

  describe '.new' do
    context 'when given valid csv configuration info' do
      it 'initializes a collection' do
        expect(valid_collection.name).to eq(args.first)
      end

      it 'gets the variants' do
        expect(valid_collection.variants).to be_a(Hash)
      end

      it 'gets the metadata' do
        expect(valid_collection.meta.first).to be_a(Hash)
      end

      context 'without custom variants' do
        it 'builds without errors' do
          expect(no_variants.variants).to eq({:med=>600, :lg=>1140})
        end
      end

      context 'without custom metadata' do
        it 'builds without errors' do
          expect(no_meta.meta).to eq(nil)
        end
      end
    end
  end

  describe '.process' do
    it 'runs without errors' do
      expect{ quiet_stdout { valid_collection.process } }.not_to raise_error
    end

    it 'generates collection json' do
      expect(File.exist?("#{target_dir}/collection/top.json")).to be true
    end

    it 'generates manifest json' do
      expect(File.exist?("#{target_dir}/0/manifest.json")).to be true
    end

    it 'adds manifest metadata fields from config + source' do
      manifest = JSON.parse(File.read("#{target_dir}/0/manifest.json"))
      expect(manifest).to have_key('label')
    end

    it 'generates derivatives' do
      expect(Dir.exist?("#{target_dir}/images")).to be true
    end

    it 'generates custom image variants' do
      [100, 900].each do |size|
        expect(File.exist?("#{target_dir}/images/1-1/full/#{size},/0/default.jpg")).to be true
      end
    end
  end
end
