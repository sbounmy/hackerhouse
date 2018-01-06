require 'rails_helper'

describe UsersV2API do
  let!(:hq) { create(:house, stripe_plan_ids: ['rent_monthly', 'fee_monthly']) }

  describe "POST /v2/users" do

    def create_user(params={})
      post "/v2/users", {
        email: 'stephane@hackerhouse.paris', password: "blabla1234",
        firstname: 'Stephane',
        lastname: 'Bounmy',
        bio_title: 'Software Engineer',
        bio_url: 'https://www.linkedin.com/in/stephanebounmy'
      }.merge(params)
    end

    context 'with valid params' do

      it 'is success' do
        create_user
        expect(response.status).to eq 201
      end

      it "creates an user" do
        expect {
          create_user
        }.to change(User, :count).by(1)
        expect(json_response['firstname']).to eql 'Stephane'
        expect(json_response['lastname']).to eql 'Bounmy'
      end

      it "returns success code" do
        create_user
        expect(response.status).to be 201
      end

      it "can't create twice" do
        expect {
          create_user
          create_user bio_title: 'Sushi Lover'
        }.to change { User.count }.by(1)
        expect(User.last.bio_title).to eq 'Sushi Lover'
      end

      it 'doesnt display sensible information' do
        create_user
        expect(json_response.keys).to eq ["id", "firstname", "lastname", "avatar_url", "bio_title", "bio_url", "check_in", "check_out"]
      end

    end

    context 'with invalid params' do

      it 'does not create duplicate users' do
        expect {
          create_user firstname: nil
        }.to_not change(User, :count)
      end

    end
  end

end