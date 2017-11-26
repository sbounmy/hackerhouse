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
      expect(HouseRent.new(hq, Date.today).amount_per_day).to eq 83_33
    end

    it 'changes when max user changes' do
      hq.update_attributes max_users: 5
      expect(HouseRent.new(hq, Date.today).amount_per_day).to eq 66_66
    end
    
    it 'should not fail if amount is too small' do
      hq.update_attributes amount: 10_00
      expect(HouseRent.new(hq, Date.today).amount_per_day).to eq 8 #4 cents
    end
  end

  describe '' do

    it 'returns an array' do
      House.v2.each do |house|
        HouseRent.new(house, Date.today.month).users.each do |user, amount|
        # house.users_need_to_pay(Date.today).each do |user, amount|
          Stripe::Charge.new(user, amount)
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
      expect(rent.users).to eq [[@nadia, 1166_62], [@brian, 5166_62]]
    end

    it 'is empty if everyone is there' do
      @nadia.update_attributes check_out: Date.new(2018, 02, 12)
      @val = create(:user, firstname: 'val', house: hq,
        check_in: Date.new(2017, 6, 1), check_out: Date.new(2017, 12, 3))
      @hugo = create(:user, firstname: 'hugo', house: hq,
        check_in: Date.new(2017, 6, 1), check_out: Date.new(2017, 12, 3))
      expect(rent.users).to contain_exactly([@val, 0], [@hugo, 0], [@nadia, 0], [@brian, 0])
    end

    it 'does not freakout when nadia leave the first day of month' do
      @nadia.update_attributes check_out: Date.new(2017, 11, 01)
      @val = create(:user, firstname: 'val', house: hq,
        check_in: Date.new(2017, 6, 1), check_out: Date.new(2017, 12, 3))
      @hugo = create(:user, firstname: 'hugo', house: hq,
        check_in: Date.new(2017, 6, 1), check_out: Date.new(2017, 12, 3))
      expect(rent.users).to contain_exactly([@val, 833_40], [@hugo, 833_40], [@brian, 833_40])      
    end
    
    it 'have few days of non-occupancy' do
      hq.update_attributes max_users: 3
      @val = create(:user, firstname: 'val', house: hq,
        check_in: Date.new(2017, 11, 18), check_out: Date.new(2018, 1, 3))
      @hugo = create(:user, firstname: 'hugo', house: hq,
        check_in: Date.new(2017, 6, 1), check_out: Date.new(2017, 12, 3))
      expect(rent.users).to contain_exactly([@hugo, 166_65], [@brian, 166_65], [@nadia, 0], [@val, 0])      
    end

    it 'Nadia 15 days in 1 month' do
      hq.update_attributes max_users: 4
      expect {
        @nadia.update_attributes! check_in: Date.new(2017, 11, 4), check_out: Date.new(2017, 11, 19)
      }.to raise_error(Mongoid::Errors::Validations, /should not be less than 2017-12-04/)
      @val = create(:user, firstname: 'val', house: hq,
        check_in: Date.new(2017, 6, 1), check_out: Date.new(2017, 12, 3))
      @hugo = create(:user, firstname: 'hugo', house: hq,
        check_in: Date.new(2017, 6, 1), check_out: Date.new(2017, 12, 3))
      expect(rent.users).to contain_exactly([@hugo, 444_48], [@brian, 444_48], [@nadia, 0], [@val, 444_48])      
    end

    it 'is idempotent'
  end
end

