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
        expect(json_response['slug_id']).to eq "hq"
        expect(json_response['slack_id']).to eq "#hq"
        expect(json_response['stripe_access_token']).to eq "very-secret-token"
        expect(json_response['stripe_id']).to eq "stripe-acc-id"
        expect(json_response['stripe_client_id']).to eq "ca_stripe-client-id"
        expect(json_response['stripe_oauth_url']).to eq "https://connect.stripe.com/oauth/authorize?response_type=code&client_id=ca_stripe-client-id&scope=read_write"
      end

    end
  end

end