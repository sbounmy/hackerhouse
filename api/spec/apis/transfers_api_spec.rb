require 'rails_helper'

describe TransfersAPI do
  let!(:hq) { create(:house, utilities_monthly: 290, cleaning_monthly: 400, slug_id: 'hq', stripe: true) }
  let!(:now) { Time.now }
  let(:admin) { create(:user, admin: true) }
  def transfers(params={})
    App.stripe do
      Stripe::Transfer.list(limit: 100, destination: hq.stripe_id)
        # created: { gt: now.to_i }) this doesnt work because we created is 6-7 ahead from now i dont know why
    end
  end

  let(:transfer_name) { Date.today.strftime("Loyer-%Y-%m") }

  after :each do
    App.stripe do
      Stripe::Account.retrieve(hq.stripe_id).delete
    end
  end

  describe "POST /v1/transfers/:slug_id" do

    it 'sends payout to owner minus service fee' do
      expect {
        post_as :admin, '/v1/transfers/hq'
      }.to change { transfers.to_a.size }.by(1)
      expect(transfers.map &:amount).to contain_exactly(940721)
      expect(transfers.map &:transfer_group).to contain_exactly(transfer_name)
    end

    it 'is idempotent' do
      expect {
        post_as :admin, '/v1/transfers/hq'
        post_as :admin, '/v1/transfers/hq'
      }.to change { transfers.to_a.size }.by(1)
      expect(transfers.map &:amount).to contain_exactly(940721)
      expect(transfers.map &:transfer_group).to contain_exactly(transfer_name)
    end

    it 'works when next month' do
      expect {
        post_as :admin, '/v1/transfers/hq'
        Timecop.travel 1.month.from_now do
          post_as :admin, '/v1/transfers/hq'
        end
      }.to change { transfers.to_a.size }.by(2)
      expect(transfers.map &:amount).to contain_exactly(940721, 940721)
      expect(transfers.map &:transfer_group).to contain_exactly(transfer_name, 1.month.from_now.strftime("Loyer-%Y-%m"))
    end

    it 'can be a manual net amount' do
      expect {
        post_as :admin, '/v1/transfers/hq', amount: 3_400.75
      }.to change { transfers.to_a.size }.by(1)
      expect(transfers.map &:amount).to contain_exactly(3_400_75)
      expect(transfers.map &:transfer_group).to contain_exactly(transfer_name)
    end
  end
end