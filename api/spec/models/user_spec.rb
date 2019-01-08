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

  describe '.send_reminders', sync: [:mailer] do

    it 'sends checkout reminder by days' do
      create(:user, check_out: 30.days.from_now)
      expect {
        User.send_reminders(30.days)
      }.to change { deliveries.count }.by(1)
    end

    it 'should not send to house not v2' do
      user = create(:user, check_out: 30.days.from_now)
      user.house.update_attributes v2: false
      expect {
        User.send_reminders(30.days)
      }.to_not change { deliveries.count }.from(0)
    end

    it 'returns user reminded as value' do
      user = create(:user, check_out: 30.days.from_now)
      expect(User.send_reminders(30.days)).to eq [user]
    end

    it 'does not send when not in days' do
      create(:user, check_out: 30.days.from_now)
      expect {
        User.send_reminders(20.days)
      }.to_not change { deliveries.count }.from(0)
    end

    it 'returns empty array when no user reminded' do
      user = create(:user, check_out: 30.days.from_now)
      expect(User.send_reminders(20.days)).to eq []
    end

    it 'accepts multiple days' do
      create(:user, check_out: 30.days.from_now)
      Timecop.travel(15.day.from_now) do
        expect {
          User.send_reminders(20.days, 15.day)
        }.to change { deliveries.count }.by(1)
      end
    end

    it 'does not send email when they found someone' do
      skip 'complicated'
      leaver = create(:user, check_out: 30.days.from_now)
      comer = create(:user, house: leaver.house, check: [30.days.from_now, 3.month.from_now])
      expect {
        User.send_reminders(30.days)
      }.to_not change { deliveries.count }.from(0)
    end

    it 'sends checkout reminder in slack by days', sync: [:slack] do
      hq.update_attributes! slug_id: 'hq'
      user = create(:user, house: hq, firstname: 'Pierre', check_out: 30.days.from_now)
      expect {
        User.send_reminders(30.days)
      }.to change { slacks.count }.by(1)
      expect(slacks[0].channel).to eq "#{user.house.slack_id}"
      expect(slacks[0].text).to match "D-30: Départ de Pierre, avez-vous trouvé un nouveau coloc ?"
    end
  end

  describe '#remote_avatar_url' do
    it 'can set remote avatar' do
      u = create(:user, remote_avatar_url: "https://upload.wikimedia.org/wikipedia/commons/5/51/Google.png")
      expect(u.avatar_url).to start_with '/attachments/'
    end
  end
end
