context '$ bundle exec rake' do
  include_context 'shared'

  describe 'wax:pagemaster' do
    it 'passes' do
      passes = quiet_stdout{ system("bundle exec rake wax:pagemaster #{args.join(' ')}") }
      expect(passes).to eq(true)
    end
    it 'generates pages' do
      page_dirs.each do |dir|
        pages = Dir.glob("#{dir}/*.md")
        expect(pages.length).not_to be_zero
      end
    end
  end

  describe 'wax:lunr' do
    it 'passes' do
      passes = quiet_stdout{ system("bundle exec rake wax:lunr UI=true") }
      expect(passes).to eq(true)
    end
    it 'generates an index' do
      expect(File).to exist(index_path)
    end
    it 'generates a ui' do
      expect(File).to exist(ui_path)
    end
  end

  describe 'wax:iiif' do
    it 'passes' do
      passes = quiet_stdout { system("bundle exec rake wax:iiif #{args.last}") }
      expect(passes).to eq(true)
    end
    it 'builds iiif info.json' do
      iiif_collection = WaxTasks::IiifCollection.new(args.last, task_runner.site)
      first_image = Dir.glob("#{iiif_collection.target_dir}/images/*").first
      expect(File).to exist("#{first_image}/info.json")
    end
  end

  # describe 'wax:jspackage' do
  #   it 'passes' do
  #     passes = quiet_stdout { system('bundle exec rake wax:jspackage') }
  #     expect(passes).to eq(true)
  #   end
  #   it 'writes a package.json file' do
  #     package = File.open('package.json', 'r').read
  #     expect(package.length > 90)
  #   end
  # end

  describe 'wax:test' do
    it 'passes html-proofer' do
      quiet_stdout { Bundler.with_clean_env { system('bundle exec jekyll build') } }
      passes = quiet_stdout { system('bundle exec rake wax:test') }
      expect(passes).to eq(true)
    end
  end
end
