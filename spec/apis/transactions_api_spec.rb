require 'rails_helper'

describe TransactionsAPI do
  describe "POST /v1/transactions" do

    context 'is a valid token' do
      let!(:hq) { create(:house) }
      let(:default_params) { { token: 'valid-token',
          house_channel: 'hq'
        }
      }

      def create_transaction(params={})
        post "/v1/transactions", { transaction: default_params.merge(params) }
      end


      it "is success" do
        create_transaction
        expect(response.status).to be 201
      end

      it "returns a json response" do
        expect {
          create_transaction
        }.to change { hq.transactions.count }.by(1)

        expect(json_response['transaction']['token']).to eq "Loc Lac rice"
        expect(json_response['transaction']['status']).to eq "success"
        expect(json_response['transaction']['plan']).to eq "month"
        expect(json_response['transaction']['stripe_cust_id']).to eq "stripe-customer-id"
      end

    end
  end

end