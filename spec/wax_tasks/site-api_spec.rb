# frozen_string_literal: true

describe WaxTasks::Site do
  include_context 'shared'

  before(:all) do
    Test.reset
  end

  #
  # ===================================================
  # SITE.GENERATE_API (NAME)
  # ===================================================
  #
  describe '#generate_api' do
    context 'when given name of a valid csv collection' do
      it 'runs without errors' do
        expect { quiet_stdout { site_from_config_file.generate_api(csv) } }.not_to raise_error
      end
    end
  end

end
