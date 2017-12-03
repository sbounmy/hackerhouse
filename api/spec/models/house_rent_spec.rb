require 'rails_helper'

RSpec.describe HouseRent, type: :model do
  let(:hq) { create(:house, rent_monthly: 10_000) } # 10 000 euros / month
  let(:stripe) { StripeMock.create_test_helper }

  before { Timecop.travel(Date.parse('2017-11-25')) }
  after { Timecop.return }

  def create_user(firstname, dates)
    create(:user, firstname: firstname, house: hq,
        check_in: Date.parse(dates[0]), check_out: Date.parse(dates[1]))
  end

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
      expect(HouseRent.new(hq, Date.today).amount_per_day).to eq 83.33333333333333
    end

    it 'changes when max user changes' do
      hq.update_attributes max_users: 5
      expect(HouseRent.new(hq, Date.today).amount_per_day).to eq 66.66666666666667
    end

    it 'should not fail if amount is too small' do
      hq.update_attributes rent_monthly: 10_00
      expect(HouseRent.new(hq, Date.today).amount_per_day).to eq 8.333333333333334
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
    let(:rent) { HouseRent.new(hq, Date.parse('2017-11-25')) }
    before do
      @nadia = create_user 'nadia', ['2017-09-02', '2017-11-15']
      @brian = create_user 'brian', ['2017-06-01', '2017-12-3']
    end

    it 'returns an array of users who needs to pay' do
      expect(rent.users).to be_instance_of(Array)
    end

    it 'returns as parameter user who have to pay' do
      expect(rent.users).to contain_exactly([@nadia, 1167], [@brian, 5167])
    end

    it 'is empty if everyone is there' do
      @nadia.update_attributes check_out: Date.new(2018, 02, 12)
      @val = create_user 'val', ['2017-06-01', '2017-12-3']
      @hugo = create_user 'hugo', ['2017-06-01', '2017-12-3']
      expect(rent.users).to contain_exactly([@val, 0], [@hugo, 0], [@nadia, 0], [@brian, 0])
    end

    it 'does not freakout when nadia leave the first day of month' do
      @nadia.update_attributes check_out: Date.new(2017, 11, 01)
      @val = create_user 'val', ['2017-06-01', '2017-12-3']
      @hugo = create_user 'hugo', ['2017-06-01', '2017-12-3']
      expect(rent.users).to contain_exactly([@val, 834], [@hugo, 834], [@brian, 834])
    end

    it 'have few days of non-occupancy' do
      hq.update_attributes max_users: 3
      @val = create_user 'val', ['2017-11-18', '2018-01-03']
      @hugo = create_user 'hugo', ['2017-06-01', '2017-12-3']
      expect(rent.users).to contain_exactly([@hugo, 167], [@brian, 167], [@nadia, 0], [@val, 0])
    end

    it 'Nadia 15 days in 1 month' do
      hq.update_attributes max_users: 4
      expect {
        @nadia.update_attributes! check_in: Date.new(2017, 11, 4), check_out: Date.new(2017, 11, 19)
      }.to raise_error(Mongoid::Errors::Validations, /should not be less than 2017-12-04/)
      @val = create_user 'val', ['2017-06-01', '2018-12-03']
      @hugo = create_user 'hugo', ['2017-06-01', '2017-12-03']
      expect(rent.users).to contain_exactly([@hugo, 445], [@brian, 445], [@nadia, 0], [@val, 445])
    end

    it 'does not count someone who arrive way later' do
      @nadia.update_attributes check_out: Date.new(2018, 02, 12)
      @val = create_user 'val', ['2017-06-01', '2017-12-3']
      @hugo = create_user 'hugo', ['2017-12-31', '2018-12-3']
      expect(rent.users).to have(3).items
      expect(rent.users).to contain_exactly([@val, 834], [@nadia, 834], [@brian, 834])
    end

    it 'is idempotent'
    it 'does not freakout if everybody leaves'
  end
end

