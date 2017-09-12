require 'rails_helper'

RSpec.describe User, type: :model do
  let(:hq) { create(:house) }
  let(:stripe) { StripeMock.create_test_helper }
  
  def create_subscription params={}
    customer = Stripe::Customer.create({
      email: 'johnny@appleseed.com',
      source: stripe.generate_card_token
    })
    create(:user, stripe_id: customer.id, house: hq)
    Stripe::Subscription.create({ customer: customer.id, plan: 'rent_monthly' }.merge(params))
  end

  describe 'new' do

    it 'cannot initialize past month date' do
      expect { Rent.new(hq, 1.month.ago) }.to raise_error
    end

    it 'initialize current month date' do
      expect { Rent.new(hq, Date.today) }.to_not raise_error
    end

    it 'initialize next month date' do
      expect { Rent.new(hq, 1.month.from_now) }.to_not raise_error
    end

  end

  describe '#amount' do

  before do
    StripeMock.start
    stripe.create_plan(id: 'rent_monthly', amount: 100) #1euro
    create_subscription    
  end

  after { StripeMock.stop }

    context 'when current month' do
      let(:rent) { hq.rent_on(Date.today) }

      it 'tenant pays full price when only one tenant' do
        expect(rent.amount).to eq 100_00
      end

      it 'tenants pays one third when 3 tenants' do
        create_subscription    
        create_subscription
        expect(rent.amount).to eq 33_33
      end

      it 'doesnt counts cancel_at_period_end tenant' do
        create_subscription.delete at_period_end: true
        expect(rent.amount).to eq 50_00
      end

    end

    context 'when next month' do
      let(:rent) { hq.rent_on(1.month.from_now) }

      it 'counts next month trialling tenant' do
        create_subscription trial_end: 1.month.from_now.to_i
        expect(rent.amount).to eq 50_00
      end

      it 'doesnt counts +2 months trialling tenant' do
        create_subscription trial_end: 2.month.from_now.to_i
        expect(rent.amount).to eq 100_00
      end

      it 'doesnt counts cancel_at_period_end tenant' do
        create_subscription.delete at_period_end: true
        expect(rent.amount).to eq 100_00
      end

      it 'doesnt counts fully canceled tenant' do
        create_subscription.delete
        expect(rent.amount).to eq 100_00
      end
    end
  end

  describe '#update!' do
    let(:rent) { hq.rent_on(1.month.from_now) }
    
    before do
      StripeMock.start
      stripe.create_plan(id: 'rent_monthly', amount: 1_00) #1euro
      create_subscription    
    end

    after { StripeMock.stop }

    it 'updates stripe subscriptions quantity' do
      create_subscription
      expect { rent.update! }.to change { Stripe::Subscription.list(limit: 100).map &:quantity }.to [50_00, 50_00]
    end

    it 'updates properly decimal amount' do
      create_subscription
      create_subscription
      expect { rent.update! }.to change { Stripe::Subscription.list(limit: 100).map &:quantity }.to [34_00, 34_00, 34_00]
    end
  end
end

