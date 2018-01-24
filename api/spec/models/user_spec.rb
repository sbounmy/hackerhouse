require 'rails_helper'

RSpec.describe User, type: :model do
  let(:hq) { create(:house) }
  describe '#staying_on' do

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

  describe '#push!' do
    it 'pushes changes to stripe' do
      user = create(:user, house: hq, stripe: true)

      user.email = 'stephane+test@hackerhouse.paris'
      user.push!
      App.stripe do
        c = Stripe::Customer.retrieve(user.stripe_id)
        expect(c.email).to eq 'stephane+test@hackerhouse.paris'
        expect(c.metadata.to_hash).to eq({
          oid: user.id.to_s,
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

    it 'fetch user who has house' do
      expect {
        user.update_attributes house: nil
      }.to change { User.active.to_a }.from([user]).to([])
    end

    it 'works with #search' do
      expect {
        user.update_attributes check_out: 2.days.ago
      }.to change { User.search(active: 'true').to_a }.from([user]).to([])
    end

    it 'works with #search 1' do
      expect {
        user.update_attributes check_out: 2.days.ago
      }.to change { User.search(active: 1).to_a }.from([user]).to([])
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

end
