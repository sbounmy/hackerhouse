require 'rails_helper'

RSpec.describe HouseSynchronizer, type: :synchronizer, sync: true do
  let(:hq) { create(:house, intercom: true) }

  describe '#update' do

    it 'to intercom it pushes changes' do
      hq.update_attributes door_key: 'v2-key', building_key: 'main-v2-key'
      HouseSynchronizer.with(house: hq).update(:intercom)

      App.intercom do |i|
        comp = i.companies.find(company_id: hq.id)
        expect(comp.custom_attributes['door_key']).to eq 'v2-key'
        expect(comp.custom_attributes['building_key']).to eq 'main-v2-key'
      end
    end

  end

end