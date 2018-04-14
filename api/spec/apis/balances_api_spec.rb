require 'rails_helper'

describe BalancesAPI do

  before do
    Timecop.travel(Time.parse('2017-11-30'))
    @nadia = create_user 'nadia', ['2017-09-02', '2017-11-15']
    @brian = create_user 'brian', ['2017-06-01', '2017-12-3']
    @val = create_user 'val', ['2017-06-01', '2017-12-3']
    @hugo = create_user 'hugo', ['2017-06-01', '2017-12-3']
  end

  after do
    Timecop.return
  end

  let(:hq) { create(:house, slug_id: 'hq', rent_monthly: 10_000) } # 10 000 euros / month
  let(:stripe) { StripeMock.create_test_helper }
  let(:admin) { create(:user, admin: true) }
  def create_user(firstname, dates)
      create(:user, firstname: firstname, house: hq,
      check_in: Date.parse(dates[0]), check_out: Date.parse(dates[1]),
      stripe: true)
  end

  describe "GET /v1/balances/:slug_id" do

    it 'responds succesfully' do
      get_as :admin, '/v1/balances/hq'
      expect(response.status).to eq 200
    end

    it 'is error on guest' do
      get '/v1/balances/hq'
      expect(response.status).to eq 403
    end

    it 'is error on invalid token' do
      get '/v1/balances/hq', params: { token: 'blabla' }
      expect(response.status).to eq 403
    end
  end

  describe 'POST /v1/balances/:slug_id' do

    it 'responds succesfully' do
      post_as :admin, '/v1/balances/hq'
      expect(response.status).to eq 201
    end

    it 'is forbidden on guest' do
      post '/v1/balances/hq'
      expect(response.status).to eq 403
    end

    it 'delivers email with the amount of the solidary contribution' do
      expect {
        post_as :admin, '/v1/balances/hq'
      }.to change { ActionMailer::Base.deliveries.count }.by(4)
      expect(ActionMailer::Base.deliveries.last.body).to include 'hugo', '445 €'
      expect(ActionMailer::Base.deliveries[0].body).to include 'nadia', '0 €'
      expect(ActionMailer::Base.deliveries[1].body).to include  'brian', '445 €'
      expect(ActionMailer::Base.deliveries[2].body).to include  'val', '445 €'
    end

    it 'doesnt freakout if no one have to pay' do
      @nadia.update_attributes check_out: Date.parse("2017-12-03")
      expect {
        post_as :admin, '/v1/balances/hq'
      }.to change { ActionMailer::Base.deliveries.count }.by(4)

      expect(ActionMailer::Base.deliveries.last.body).to include 'hugo', '0 €'
      expect(ActionMailer::Base.deliveries[0].body).to include 'nadia', '0 €'
      expect(ActionMailer::Base.deliveries[1].body).to include  'brian', '0 €'
      expect(ActionMailer::Base.deliveries[2].body).to include  'val', '0 €'

        App.stripe do
        [@nadia, @val, @hugo, @brian].each do |u|
          items = Stripe::InvoiceItem.list(limit: 10, customer: u.stripe_id)
          expect(items.count).to eq 1
          expect(items.first.amount).to eq 0
        end
      end
    end

    it 'shows next check outs' do
      expect {
        post_as :admin, '/v1/balances/hq'
      }.to change { ActionMailer::Base.deliveries.count }.by(4)
      expect(ActionMailer::Base.deliveries.last.body).to include '2017-12-03 : brian', '2017-12-03 : val', '2017-12-03 : hugo'
    end

    it 'charges users who needs to pay through Stripe' do
      post_as :admin, '/v1/balances/hq'
      App.stripe do
        @items = Stripe::InvoiceItem.list(limit: 10, customer: @nadia.stripe_id)
        expect(@items.count).to eq 1
        expect(@items.first.amount).to eq 0

        @items = Stripe::InvoiceItem.list(limit: 10, customer: @val.stripe_id)
        expect(@items.count).to eq 1
        expect(@items.first.amount).to eq 445_00

        @items = Stripe::InvoiceItem.list(limit: 10, customer: @brian.stripe_id)
        expect(@items.count).to eq 1
        expect(@items.first.amount).to eq 445_00
      end
    end

    it 'does not notify if false' do
      expect {
        post_as :admin, '/v1/balances/hq', params: { notify: false }
      }.to_not change { ActionMailer::Base.deliveries.count }
    end

    it 'is idempotent' do
      expect {
        post_as :admin, '/v1/balances/hq'
        post_as :admin, '/v1/balances/hq'
      }.to change { App.stripe { Stripe::InvoiceItem.list(limit: 10, customer: @nadia.stripe_id) }.count }.by(1)
    end
  end
end