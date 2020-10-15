# frozen_string_literal: true

describe WaxTasks::AnnotationList do
  include_context 'shared'

  include_context 'shared'
  let(:config)          { site_from_config_file.config }
  let(:source)          { config.source }
  let(:collections_dir) { config.collections_dir }

  before(:all) do
    Test.reset
  end

  #
  # ===================================================
  # ANNOTATION.NEW
  # ===================================================
  #
  describe '#new' do
    context 'generates json' do
      it 'works' do
      byebug
          expect { WaxTasks::AnnotationList.new({}) }.not_to raise_error
      end
    end
  end
end
