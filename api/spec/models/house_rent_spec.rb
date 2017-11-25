require 'rails_helper'

RSpec.describe HouseRent, type: :model do
  let(:hq) { create(:house, amount: 10000_00) } # 10 000 euros / month
  let(:stripe) { StripeMock.create_test_helper }

  describe '#days_total' do
    it 'returns 28 on February' do
      expect(HouseRent.new(hq, Date.new(2017, 02, 01)).days_total).to eq 28
    end

    it 'returns 31 on January' do
      expect(HouseRent.new(hq, Date.new(2017, 01, 01)).days_total).to eq 31
    end
  end

  describe '#amount_per_day' do
    it 'is in cents' do
      expect(HouseRent.new(hq, Date.today).amount_per_day).to eq 41_66
    end

    it 'changes when max user changes' do
      hq.update_attributes max_users: 5
      expect(HouseRent.new(hq, Date.today).amount_per_day).to eq 66_66
    end
    
    it 'should not fail if amount is too small' do
      hq.update_attributes amount: 10_00
      expect(HouseRent.new(hq, Date.today).amount_per_day).to eq 4 #4 cents
    end
  end

  describe '' do

    it 'returns an array' do
      House.v2.each do |house|
        HouseRent.new(house, Date.today.month).users.each do |user, amount|
        # house.users_need_to_pay(Date.today).each do |user, amount|
          Stripe::Payment.new(user, amount)
          Mail.deliver(user.email, 'ta contribution solidaire.... #{amount}')
        end
      end

    end

  end

  describe '#users' do
    let(:rent) { HouseRent.new(hq, Date.today) }
    before do
      @nadia = create(:user, firstname: 'nadia', house: hq,
        check_in: Date.new(2017, 9, 2), check_out: Date.new(2017, 11, 15))
      @brian = create(:user, firstname: 'brian', house: hq,
        check_in: Date.new(2017, 6, 1), check_out: Date.new(2017, 12, 3))
    end

    it 'returns an array of users who needs to pay' do
      expect(rent.users).to be_instance_of(Array)
    end

    it 'returns as parameter user who have to pay' do
      expect(rent.users).to eq [[@nadia, 1000], [@brian, 10000]]
    end

    it 'is empty if no one have to pay'
    it 'is idempotent'
  end
end

