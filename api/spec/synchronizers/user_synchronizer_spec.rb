require 'rails_helper'

RSpec.describe UserSynchronizer, type: :synchronizer, sync: true do
  let(:hq) { create(:house) }

  describe '#create' do

    it 'to intercom it pushes changes' do
      user = create(:user, intercom: true, stripe_id: 'cus_some_id')
      co = 3.month.from_now.to_date

      expect {
        user.update_attributes check_out: co
      }.to change { user.reload.check_out }.to(co)

      UserSynchronizer.with(user: user).create(:intercom)

      App.intercom do |i|
        i_user = i.users.find(user_id: user.id.to_s)
        expect(i_user.custom_attributes['check_out']).to eq co.to_s
        expect(i_user.custom_attributes['bio_url']).to eq 'https://linkedin.com/in/blabla'
        expect(i_user.custom_attributes['stripe_id']).to eq 'cus_some_id'
      end
    end

    it 'to stripe it pushes changes' do
    end
  end

  describe '#update' do

    it 'to intercom it pushes changes' do
      user = create(:user, intercom: true)
      co = 3.month.from_now.to_date

      expect {
        user.update_attributes check_out: co
      }.to change { user.reload.check_out }.to(co)

      UserSynchronizer.with(user: user).update(:intercom)

      App.intercom do |i|
        i_user = i.users.find(user_id: user.id.to_s)
        expect(i_user.custom_attributes['check_out']).to eq co.to_s
        expect(i_user.phone).to eq '0612345678'
      end
    end

    it 'to stripe it pushes changes' do
      user = create(:user, house: hq, stripe: true)

      user.email = 'stephane+test@hackerhouse.paris'
      App.stripe { Stripe::Subscription.create(customer: user.stripe_id, plan: 'rent_monthly') }

      UserSynchronizer.with(user: user).update(:stripe)

      App.stripe do
        s = Stripe::Subscription.list(customer: user.stripe_id).data[0]
        expect(s.metadata.to_hash).to eq({
          house: hq.slug_id,
          check_in: '2016-12-20',
          check_out: '2017-02-20'
        })
      end
    end
  end

end