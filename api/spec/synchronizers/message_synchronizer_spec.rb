require 'rails_helper'

RSpec.describe MessageSynchronizer, type: :synchronizer, sync: true do
  let(:hq) { create(:house) }

  describe '#create' do
  end

end