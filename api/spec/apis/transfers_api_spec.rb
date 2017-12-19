require 'rails_helper'

describe TransfersAPI do
  let!(:hq) { create(:house, utilities_monthly: 290, cleaning_monthly: 400, slug_id: 'hq', stripe: true) }
  let!(:now) { Time.now }

  def transfers(params={})
    App.stripe do
      Stripe::Transfer.list(limit: 100, destination: hq.stripe_id,
        created: { gt: now.to_i })
    end
  end

  after :each do
    App.stripe do
      Stripe::Account.retrieve(hq.stripe_id).delete
    end
  end

  describe "POST /v1/transfers/:slug_id" do

    it 'sends payout to owner minus service fee' do
      expect {
        post '/v1/transfers/hq'
      }.to change { transfers.to_a.size }.by(1)
      expect(transfers.map &:amount).to contain_exactly(940721)
      expect(transfers.map &:transfer_group).to contain_exactly("Loyer-2017-12")
    end

    it 'is idempotent' do
      expect {
        post '/v1/transfers/hq'
        post '/v1/transfers/hq'
      }.to change { transfers.to_a.size }.by(1)
      expect(transfers.map &:amount).to contain_exactly(940721)
      expect(transfers.map &:transfer_group).to contain_exactly("Loyer-2017-12")
    end

    it 'works when next month' do
      expect {
        post '/v1/transfers/hq'
        Timecop.travel 1.month.from_now do
          post '/v1/transfers/hq'
        end
      }.to change { transfers.to_a.size }.by(2)
      expect(transfers.map &:amount).to contain_exactly(940721, 940721)
      expect(transfers.map &:transfer_group).to contain_exactly("Loyer-2017-12", "Loyer-2018-01")
    end

  end
end