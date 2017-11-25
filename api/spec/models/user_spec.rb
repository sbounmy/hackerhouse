require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#staying_on' do
    let(:hq) { create(:house) }

    before do
      @nadia = create(:user, check_in: Date.new(2017, 9, 2), check_out: Date.new(2018, 2, 1), house: hq)
      @brian = create(:user, check_in: Date.new(2017, 6, 1), check_out: Date.new(2017, 8, 1), house: hq)
    end
    
    it 'returns users staying at a given house users' do
      expect(User.staying_on(Date.today, hq).to_a).to eq [@nadia]
    end

    it 'does not freakout when someone checkout end of previous month' do
      @nadia.update_attributes check_out: Date.new(2017, 10, 31)
      expect(User.staying_on(Date.today, hq).to_a).to eq []
    end

    it 'does not count someone who checkout the first day of current month' do
      @nadia.update_attributes check_out: Date.new(2017, 11, 01)
      expect(User.staying_on(Date.today, hq).to_a).to eq []
    end
  end
end
