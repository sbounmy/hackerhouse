require 'rails_helper'

RSpec.describe User, type: :model do
  let(:hq) { create(:house) }
  describe '#staying_on' do

    before do
      Timecop.travel(2018, 01, 05)
      @nadia = create(:user, check_in: Date.new(2017, 9, 2), check_out: Date.new(2018, 2, 1), house: hq)
      @brian = create(:user, check_in: Date.new(2017, 6, 1), check_out: Date.new(2017, 8, 1), house: hq)
    end

    after do
      Timecop.return
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

  describe '#push!' do
    it 'pushes changes to stripe' do
      user = create(:user, house: hq, stripe: true)

      user.email = 'stephane+test@hackerhouse.paris'
      App.stripe { Stripe::Subscription.create(customer: user.stripe_id, plan: 'rent_monthly') }
      user.push!
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

  describe '.active' do
    let(:user) { create(:user, check_out: 3.months.from_now) }

    it 'fetch all active users' do
      expect {
        user.update_attributes check_out: 2.days.ago
      }.to change { User.active.to_a }.from([user]).to([])
    end

    it 'works with #search' do
      expect {
        user.update_attributes check_out: 2.days.ago
      }.to change { User.search(active: 'true').to_a }.from([user]).to([])
    end
  end

  describe '#active' do
    let(:user) { create(:user, check_out: 3.months.from_now) }

    context 'it is false when' do

      it 'changes when checkout is in the past' do
        expect {
          user.update_attributes check_out: 2.days.ago
        }.to change(user, :active).to false
      end

      it 'house is nil' do
        expect {
          user.update_attributes house_id: nil
        }.to change(user, :active).to false
      end

    end

    context 'it is true when' do

      it 'checkout in future and house_id is not null' do
        user.update_attributes check_out: 2.days.from_now
        expect(user.check_out.future?).to eq true
        expect(user.house_id).to_not eq nil
        expect(user.active).to eq true
      end

    end

  end

  context 'on update' do
    let!(:user) { create(:user, check_out: 3.months.from_now, house: hq) }
    let!(:sophie) { create(:user, firstname: "Sophie", check_out: 5.months.from_now, house: hq) }

    context 'when check_out changes' do
      before do
        I18n.locale = :fr #mailer is always in fr
      end

      after do
        I18n.locale = :en
      end

      it 'does not email when checkout is in the past' do
        expect {
          user.update_attributes check_out: 2.month.ago
        }.to change { deliveries.count }.by(0)
      end

      it 'emails active users when checkout earlier' do
        expect {
          user.update_attributes check_out: 2.month.from_now
        }.to change { deliveries.count }.by(1)
        expect(last_delivery.to).to eq [sophie.email]
        expect(last_delivery.reply_to).to eq [user.email]
        expect(last_delivery.subject).to match /Paul nous quitte plus tôt que prévu/
        expect(last_delivery.body.encoded).to match /Paul part le #{I18n.l(user.check_out, format: :pretty)}/
      end

      it 'emails active users when checkout later' do
        expect {
          user.update_attributes check_out: 5.month.from_now
        }.to change { deliveries.count }.by(1)
        expect(last_delivery.to).to eq [sophie.email]
        expect(last_delivery.reply_to).to eq [user.email]
        expect(last_delivery.subject).to match /Paul reste plus longtemps que prévu ! 👍/
        expect(last_delivery.body.encoded).to match /Paul continue l'aventure jusqu'au #{I18n.l(user.check_out, format: :pretty)}/
      end

      it 'does not email when user is admin' do
        expect {
          user.update_attributes check_out: 2.month.from_now, admin: true
        }.to change { deliveries.count }.by(0)
      end

      it 'does not email when checkout does not change' do
        expect {
          user.update_attributes check_out: 3.month.from_now #same value
        }.to_not change { deliveries.count }
      end

    end
  end
end
