require 'rails_helper'

describe TransactionsAPI do
  describe "POST /v1/transactions" do

    context 'is a valid token' do
      let!(:hq) { create(:house) }
      let(:default_params) { { token: 'valid-token' }
        }

      def create_transaction(params={})
        post "/v1/houses/#{hq.slug_id}/transactions", { transaction: default_params.merge(params) }
      end

      let(:stripe_helper) { StripeMock.create_test_helper }
      before { StripeMock.start }
      after { StripeMock.stop }

      it "creates a stripe customer" do

        # This doesn't touch stripe's servers nor the internet!
        # Specify :source in place of :card (with same value) to return customer with source data
        customer = Stripe::Customer.create({
          email: 'johnny@appleseed.com',
          card: stripe_helper.generate_card_token
        })
        expect(customer.email).to eq('johnny@appleseed.com')
      end

      it "is success" do
        create_transaction
        expect(response.status).to be 201
      end

      it "returns a json response" do
        expect {
          create_transaction
        }.to change { hq.transactions.count }.by(1)
        puts response.body.inspect
        expect(json_response['transaction']['token']).to eq "valid-token"
        expect(json_response['transaction']['status']).to eq "success"
        expect(json_response['transaction']['plan']).to eq "month"
        expect(json_response['transaction']['stripe_cust_id']).to eq "stripe-customer-id"
      end

    end
  end

end