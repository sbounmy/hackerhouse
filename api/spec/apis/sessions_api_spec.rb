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

    end

    context 'with invalid params' do
      it 'raises error' do
        new_session password: 'not-good'
        expect(response.status).to be 401
      end

    end
  end

  describe "DELETE /v1/sessions/" do
  end

end