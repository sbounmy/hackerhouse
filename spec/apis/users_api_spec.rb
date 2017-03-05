require 'rails_helper'

describe UsersAPI do
  let!(:hq) { create(:house, stripe_access_token: 'sk_test_1qzvgz941TTVVpccIXEjgSiO') }

  def token u
    JsonWebToken.encode(user_id: u.id.to_s)
  end

  describe "POST /v1/users" do

    let(:stripe) { StripeMock.create_test_helper }
    let(:tomorrow) { 1.days.from_now }
    let(:default_params) { { stripe_publishable_key: 'pk_public-token',
        token: stripe.generate_card_token, email: 'paul@42.student.fr',
        moving_on: tomorrow } }

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
        expect(json_response['moving_on']).to eq tomorrow.strftime("%Y-%m-%d")
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

  describe "PUT /v1/users/:id" do
    let(:user) { create(:user) }
    let(:avatar) { "https://i1.wp.com/dev.slack.com/img/avatars/ava_0010-512.v1443724322.png" }

    it 'is forbidden to guest' do
      expect {
        put "/v1/users/#{user.id}", { avatar_url: avatar }
      }.to_not change { user.reload.avatar_url }.from(nil)
      expect(response.status).to eq 403
    end

    it 'updates its own avatar url' do
      expect {
        put "/v1/users/#{user.id}", { avatar_url: avatar }, { 'Authorization' => token(user) }
      }.to change { user.reload.avatar_url }.from(nil).to(avatar)
    end

    it 'is forbidden to update someone else avatar url' do
      user2 = create(:user)
      expect {
        put "/v1/users/#{user2.id}", { avatar_url: avatar }, { 'Authorization' => token(user) }
      }.to_not change { user2.reload.avatar_url }.from(nil)
      expect(response.status).to eq 403
    end

    it 'is forbidden to update someone else avatar url if admin' do
      user2 = create(:user)
      user.set admin: true
      expect {
        put "/v1/users/#{user2.id}", { avatar_url: avatar }, { 'Authorization' => token(user) }
      }.to change { user2.reload.avatar_url }.from(nil).to(avatar)
      expect(response.status).to eq 200
    end
  end

end