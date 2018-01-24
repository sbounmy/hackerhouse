require 'rails_helper'

describe SessionsAPI do

  let!(:user) { create(:user,
    firstname: 'john', lastname: 'snow',
    email: 'john.snow@gmail.com', password: 'got1234')}

  describe "POST /v1/sessions" do

    def new_session(params={})
      post '/v1/sessions', { email: 'john.snow@gmail.com', password: 'got1234' }.merge(params)
    end

    context 'with valid params' do

      it "returns a session" do
        new_session
        expect(json_response['token']).to match /eyJ0/
        expect(json_response['user']['firstname']).to eq 'john'
      end

      it "returns success code" do
        new_session
        expect(response.status).to be 201
      end

      it 'can use linkedin access token instead of password' do
        user.update_attributes linkedin_access_token: 'secret-lkd-token'
        new_session linkedin_access_token: 'secret-lkd-token', password: nil
        expect(response.status).to eql 201
        expect(json_response['token']).to match /eyJ0/
        expect(json_response['user']['firstname']).to eql 'john'
        expect(json_response['user']['email']).to eql 'john.snow@gmail.com' #since its current user it can see it
      end

      it "user active can be false" do
        user.update_attributes check_out: 2.days.ago
        new_session
        expect(response.status).to be 201
        expect(json_response['user']['active']).to eq false
      end
    end

    context 'with invalid params' do
      it 'raises error' do
        new_session password: 'not-good'
        expect(response.status).to be 401
      end

      it 'raise error with invalid token' do
        new_session password: nil, linkedin_access_token: 'not-good'
        expect(response.status).to be 401
      end
    end
  end

  describe "DELETE /v1/sessions/" do
  end

end