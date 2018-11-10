describe WaxTasks::TaskRunner do
  include_context 'shared'

  before(:all) do
    WaxTasks::Test.reset
  end

  describe '.new' do
    it 'initializes without errors' do
      expect(task_runner).to be_an_instance_of(WaxTasks::TaskRunner)
    end

    it 'gets the site config' do
      expect(default_site).to have_key(:permalink)
    end

    it 'gets the collections' do
      expect(default_site[:collections]).to be_a(Hash)
      expect(default_site[:collections]).to have_key(args.first)
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
        expect(Dir.glob("_#{args.first}/*.md")).not_to be_empty
      end
    end

    context 'without a non-existent collection specified' do
      it 'throws Error::InvalidCollection' do
        expect { quiet_stdout { task_runner.pagemaster(['not_a_collection']) } }.to raise_error(WaxTasks::Error::InvalidCollection)
      end
    end
  end

  describe '.derivatives_iiif' do
    it 'runs without errors' do
      expect { quiet_stdout { task_runner.derivatives_iiif([args.first]) } }.not_to raise_error
    end
  end

  describe '.derivatives_simple' do
    it 'runs without errors' do
      expect { quiet_stdout { task_runner.derivatives_simple([args.first]) } }.not_to raise_error
    end
  end

  describe '.lunr' do
    it 'runs without errors' do
      expect { quiet_stdout { task_runner.lunr } }.not_to raise_error
    end

    it 'generates an index' do
      expect(File).to exist(index_path)
    end

    it 'that passes json lint' do
      index = WaxTasks::Utils.remove_yaml(File.read(index_path))
      File.open(index_path, 'w') { |f| f.write(index) }
      expect { WaxTasks::Utils.validate_json(index_path) }.to_not raise_error
      expect(WaxTasks::Utils.validate_json(index_path)).not_to be_empty
    end

    context 'when generate_ui=true' do
      it 'generates a default ui' do
        quiet_stdout { task_runner.lunr(generate_ui: true) }
        expect(File).to exist(ui_path)
      end
    end
  end

  describe '.js_package' do
    it 'creates a package.json file' do
      package = task_runner.js_package
    end
  end

  describe '.push_branch' do
    context 'when given branch `test-branch` locally' do
      it 'runs without errors' do
        test_runner = WaxTasks::TaskRunner.new({},'test')
        expect { test_runner.push_branch('test-branch') }.to output(/Skipping build for branch 'test-branch'/).to_stdout
      end
    end
  end
end
