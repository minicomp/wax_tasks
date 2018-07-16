describe 'WaxTasks::TaskRunner' do
  include_context 'shared'

  describe '.new' do
    context 'with default opts' do
      it 'loads the site[:title]' do
        expect(task_runner.site[:title]).to be_kind_of(String)
      end

      it 'loads the site[:permalink]' do
        expect(task_runner.site[:permalink]).to eq('.html')
      end

      it 'loads the site[:collections]' do
        expect(task_runner.site[:collections]).to be_kind_of(Hash)
      end
    end

    context 'when overriding with opts={}' do
      it 'replaces the site[:title]' do
        expect(new_title.site[:title]).to eq('new title')
      end

      it 'replaces the site[:permalink]' do
        expect(new_perma.site[:permalink]).to eq('/')
      end

      it 'replaces the site[:collections]' do
        expect(new_collections.site[:collections]).to have_key('test_collection')
      end
    end
  end

  describe '.pagemaster' do
    include_context 'shared'

    it 'generates pages' do
      quiet_stdout { task_runner.pagemaster(args) }
      page_dirs.each do |d|
        pages = Dir.glob("#{d}/*.md")
        expect(pages).not_to be_empty
      end
    end
  end

  describe '.lunr' do
    include_context 'shared'

    it 'generates an index' do
      task_runner.lunr
      expect(File).to exist(index_path)
    end
    it 'that passes json lint' do
      index = File.read(index_path).remove_yaml
      expect { WaxTasks::Utils.validate_json(index) }.to_not raise_error
    end

    context 'when generate_ui=true' do
      it 'generates a default ui' do
        task_runner.lunr(generate_ui=true)
        expect(File).to exist(ui_path)
      end
    end
  end
end
