describe WaxTasks::TaskRunner do
  include_context 'shared'

  before(:all) do
    WaxTasks::Test.reset
  end

  let(:multi_collection_runner){
    opts = {
      collections: {
        'c1' => {
          'source' => 'valid.csv',
          'layout' => 'default.html',
          'lunr_index' =>{
            'fields' => ['gambrel', 'indescribable' ,'blasphemous', 'furtive']
          }
        },
        'c2' => {
          'source' => 'valid.csv',
          'layout' => 'default.html',
          'lunr_index' =>{
            'fields' => ['gambrel', 'indescribable' ,'blasphemous', 'furtive']
          }
        }
      }
    }
    WaxTasks::TaskRunner.new.override(opts)
  }

  describe '.new' do
    it 'initializes without errors' do
      expect(task_runner).to be_an_instance_of(WaxTasks::TaskRunner)
    end

    it 'gets the site config' do
      expect(default_site).to have_key(:permalink)
    end

    it 'gets the collections' do
      expect(default_site[:collections]).to be_a(Hash)
      expect(default_site[:collections]).to have_key('my_collection')
    end

    context 'when overriding with opts={}' do
      it 'replaces the site[:title]' do
        new_title = task_runner.clone.override({ title: 'new title' })
        expect(new_title.site[:title]).to eq('new title')
      end

      it 'replaces the site[:permalink]' do
        new_perma = task_runner.clone.override({ permalink: 'pretty' })
        expect(new_perma.site[:permalink]).to eq('/')
      end

      it 'replaces the site[:collections]' do
        new_collection = task_runner.clone.override({ collections: { 'test_collection' => {} } })
        expect(new_collection.site[:collections]).to have_key('test_collection')
      end
    end
  end

  describe '.pagemaster' do
    context "with valid collection 'my_collection'" do
      it 'runs without errors' do
        expect { quiet_stdout { task_runner.pagemaster(args) } }.not_to raise_error
      end
      it 'generates pages' do
        expect(Dir.glob("my_collection/*.md")).not_to be_empty
      end
    end

    context 'without a non-existent collection specified' do
      it 'throws Error::InvalidCollection' do
        expect { task_runner.pagemaster(['not_a_collection']) }.to raise_error(WaxTasks::Error::InvalidCollection)
      end
    end
  end

  describe '.lunr' do
    it 'runs without errors' do
      expect { task_runner.lunr }.not_to raise_error
    end

    it 'generates an index' do
      expect(File).to exist(index_path)
    end

    it 'that passes json lint' do
      index = File.read(index_path).remove_yaml
      File.open(index_path, 'w') { |f| f.write(index) }
      expect { WaxTasks::Utils.validate_json(index_path) }.to_not raise_error
      expect(WaxTasks::Utils.validate_json(index_path)).not_to be_empty
    end

    context 'when generate_ui=true' do
      it 'generates a default ui' do
        task_runner.lunr(generate_ui=true)
        expect(File).to exist(ui_path)
      end
    end

    context 'when given multiple collections' do
      it 'generates an index including each collection' do
        quiet_stdout { multi_collection_runner.pagemaster(['c1', 'c2']) }
        lunr_collections = WaxTasks::Utils.get_lunr_collections(multi_collection_runner.site)
        lunr_collections.map! { |name| WaxTasks::LunrCollection.new(name, multi_collection_runner.site) }
        index = WaxTasks::LunrIndex.new(lunr_collections).to_s.remove_yaml
        expect(JSON.load(index).length).to eq(6)
      end
    end
  end

  describe '.iiif' do
    it 'runs without errors' do
      expect { quiet_stdout { task_runner.iiif(args) } }.not_to raise_error
    end

    it 'generates derivatives' do
      iiif_collection = WaxTasks::IiifCollection.new(args.first, default_site)
      first_image = Dir.glob("#{iiif_collection.target_dir}/images/*").first
      expect(File).to exist("#{first_image}/info.json")
    end
  end

  describe '.js_package' do
    it 'creates a package.json file' do
      package = task_runner.js_package
    end
  end
end
