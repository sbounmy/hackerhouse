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

      it 'returns pantry attributes if user belongs to house' do
        user = create(:user, house: hq)
        get_as user, "/v1/houses/#{hq.slug_id}"

        expect(json_response['pantry_login']).to eq 'pantry@hackerhouse.paris'
        expect(json_response['pantry_password']).to eq 'pantry42'
        expect(json_response['pantry_budget']).to eq 100
        expect(json_response['pantry_description']).to eq 'Livraison bi-mensuel'
        expect(json_response['pantry_url']).to eq 'https://courses-en-ligne.carrefour.fr'
      end

      it 'returns pantry attributes if current user is a guest' do
        user = create(:user, house: hq)
        get_as :guest, "/v1/houses/#{hq.slug_id}"

        expect(json_response.keys).to_not include('pantry_login', 'pantry_password', 'pantry_url', 'pantry_description', 'pantry_budget')
      end

      it 'returns pantry attributes if user does not belongs to house' do
        user = create(:user, house: create(:house))
        get_as user, "/v1/houses/#{hq.slug_id}"

        expect(json_response.keys).to_not include('pantry_login', 'pantry_password', 'pantry_url', 'pantry_description', 'pantry_budget')
      end
    end
  end

  describe "GET /v1/houses/" do
    context 'with valid params' do
      let!(:hq) { create(:house) }

      def get_houses(q={})
        get "/v1/houses", q: q
      end

      it "is success" do
        get_houses
        expect(response.status).to be 200
      end

      it "returns a json response" do
        get_houses
        expect(json_response).to have(1).items
        hq = json_response[0]
        expect(hq['name']).to eq "Canal Street"
        expect(hq['slug_id']).to match /hq-\d/
        expect(hq['slack_id']).to match /#hq-\d/
        expect(hq).to_not have_key 'stripe_access_token'
        expect(hq['stripe_publishable_key']).to eq "pk_public-token"
        expect(hq['stripe_id']).to match /stripe-acc-\d/
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

end