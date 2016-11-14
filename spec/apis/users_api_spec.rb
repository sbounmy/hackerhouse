require 'rails_helper'

describe UsersAPI do
  describe "POST /v1/users" do

    let!(:hq) { create(:house, stripe_access_token: 'sk_test_1qzvgz941TTVVpccIXEjgSiO') }
    let(:stripe) { StripeMock.create_test_helper }
    let(:default_params) { { stripe_publishable_key: 'pk_public-token',
        token: stripe.generate_card_token, email: 'paul@42.student.fr',
        moving_on: '2016-12-20' } }

    before do
      StripeMock.start
      stripe.create_plan(id: 'basic_monthly', amount: 52000)
    end

    after { StripeMock.stop }

    def create_user(params={})
      post "/v1/users", default_params.merge(params)
    end

    context 'with valid token' do

      it "creates a stripe customer" do

        # This doesn't touch stripe's servers nor the internet!
        # Specify :source in place of :card (with same value) to return customer with source data
        customer = Stripe::Customer.create({
          email: 'johnny@appleseed.com',
          card: stripe.generate_card_token
        })
        expect(customer.email).to eq('johnny@appleseed.com')
      end

      it "returns success code" do
        create_user
        expect(response.status).to be 201
      end

      it "returns a json response" do
        expect {
          create_user
        }.to change { hq.users.count }.by(1)
        expect(json_response['token']).to eq "test_tok_1"
        expect(json_response['plan']).to eq "basic_monthly"
        expect(json_response['stripe_id']).to eq "test_cus_3"
        expect(json_response['moving_on']).to eq "2016-12-20"
      end
    end

    context 'with invalid params' do
      it 'raises error when no plan' do
        stripe.delete_plan 'basic_monthly'
        expect {
          expect {
            create_user
          }.to raise_error(Stripe::InvalidRequestError, 'No such plan: basic_monthly')
        }.to_not change { User.count }
      end

      it 'raises error when no matching publishable key' do
        hq.destroy!
        expect {
          expect {
            create_user
          }.to raise_error(Mongoid::Errors::DocumentNotFound, /Document not found for class House with attributes/)
        }.to_not change { User.count }
      end

      it 'raises error when moving_on is in the past' do
        expect {
          expect {
            create_user moving_on: '1988-10-20'
          }.to raise_error(Stripe::InvalidRequestError, 'Invalid timestamp: must be an integer Unix timestamp in the future')
        }.to_not change { User.count }
      end

      it 'does not create duplicate users' do
        pending
        create_user
        expect_any_instance_of(Stripe::Customer).to receive(:delete)
        create_user
      end

    end
  end

end