require 'rails_helper'

RSpec.describe HouseRent, type: :model do
  let(:hq) { create(:house) }
  let(:stripe) { StripeMock.create_test_helper }

  describe '' do

    it 'returns an array' do
      HouseRent.new(house, Date.today.month)[user]

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
    let(:rent) { HouseRent.new(hq, Date.today.month) }
    
    it 'returns an array of users who needs to pay' do
      rent.users.to be_instance_of(Array)
    end

    it 'is empty if no one have to pay'
    it 'is idempotent'
  end
end

