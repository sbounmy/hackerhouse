require 'rails_helper'

describe HousesAPI do
  describe "GET /v1/houses/:id" do

    context 'is a valid slug id' do
      let!(:hq) { create(:house) }

      def get_house(id=nil)
        get "/v1/houses/#{id || hq.slug_id}"
      end

      it "is success" do
        get_house
        expect(response.status).to be 200
      end

      it "returns a json response" do
        get_house
        expect(json_response['name']).to eq "Canal Street"
        expect(json_response['slug_id']).to match /hq-\d/
        expect(json_response['slack_id']).to match /#hq-\d/
        expect(json_response).to_not have_key 'stripe_access_token'
        expect(json_response['stripe_publishable_key']).to eq "pk_public-token"
        expect(json_response['stripe_id']).to match /stripe-acc-\d/
      end

      it' returns users' do
        user = create(:user, house: hq)
        get_house
        expect(json_response['user_ids']).to have(1).items
        expect(json_response['user_ids']).to eq [user.id.to_s]
      end
    end
  end

  describe "POST /v1/houses" do

     def create_house(params={})
      post "/v1/houses", build(:house).attributes.merge(params)
    end

    context 'with valid params' do

      it "is success" do
        create_house
        expect(response.status).to be 201
      end

      it "returns json response" do
        create_house
        expect(json_response['name']).to eq "Canal Street"
        expect(json_response['description']).to eq "The first and original HackerHouse"
        expect(json_response['slug_id']).to match /hq-\d/
        expect(json_response['slack_id']).to match /#hq-\d/
      end

      it 'sets tokens' do
        create_house stripe_access_token: 'sk', stripe_publishable_key: 'pk', stripe_refresh_token: 'rt'
        house = House.last
        expect(house.stripe_access_token).to eq 'sk'
        expect(house.stripe_publishable_key).to eq 'pk'
        expect(house.stripe_refresh_token).to eq 'rt'
      end

      it 'default application fee is 20 and cant be set through API' do
        create_house stripe_application_fee_percent: 1
        house = House.last
        expect(house.stripe_application_fee_percent).to eq 20
        house.update_attributes stripe_application_fee_percent: 30
        expect(house.reload.stripe_application_fee_percent).to eq 30
      end
    end

    context 'with invalid params' do
      it 'can not create house with same slug' do
        h1 = create(:house)
        expect {
          create_house(slug_id: h1.slug_id)
        }.to_not change { House.count }
        expect(response.status).to eq 422
      end

      it 'requires stripe_access_token' do
        expect {
          create_house stripe_access_token: nil
        }.to_not change { House.count }
        expect(response.status).to eq 422
      end

      it 'requires stripe_id' do
        expect {
          create_house stripe_id: nil
        }.to_not change { House.count }
        expect(response.status).to eq 422
      end
    end
  end

  describe "GET /v1/houses/:id/pay" do
    let(:hq) { create(:house, slug_id: 'hq', rent_monthly: 10_000) } # 10 000 euros / month
    let(:stripe) { StripeMock.create_test_helper }

    def create_user(firstname, dates)
        create(:user, firstname: firstname, house: hq,
        check_in: Date.parse(dates[0]), check_out: Date.parse(dates[1]),
        stripe: true)
    end

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
    it 'responds succesfully' do
      expect {
        get '/v1/houses/hq/pay'
        }.to change(response, :status).to(200)
        # expect(response.status).to eq 200
    end

    it 'delivers email with the amount of the solidary contribution' do
      expect {
        get '/v1/houses/hq/pay'
      }.to change { ActionMailer::Base.deliveries.count }.by(4)
      expect(ActionMailer::Base.deliveries.last.body).to include 'hugo', '445 €'
      expect(ActionMailer::Base.deliveries[0].body).to include 'nadia', '0 €'
      expect(ActionMailer::Base.deliveries[1].body).to include  'brian', '445 €'
      expect(ActionMailer::Base.deliveries[2].body).to include  'val', '445 €'
    end

    it 'charges users who needs to pay through Stripe' do
      get '/v1/houses/hq/pay'
      App.stripe do
        @items = Stripe::InvoiceItem.list(limit: 10, customer: @val.stripe_id)
        expect(@items.count).to eq 1
        expect(@items.first.amount).to eq 445_00

        @items = Stripe::InvoiceItem.list(limit: 10, customer: @brian.stripe_id)
        expect(@items.count).to eq 1
        expect(@items.first.amount).to eq 445_00
      end
    end

  end
end