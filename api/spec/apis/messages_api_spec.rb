require 'rails_helper'

describe MessagesAPI do

  before do
  end

  after do
    Timecop.return
  end

  let(:hq) { create(:house, slug_id: 'hq', rent_monthly: 10_000) } # 10 000 euros / month
  let(:stripe) { StripeMock.create_test_helper }
  let(:admin) { create(:user, admin: true) }
  let(:padawan) { create(:user) }

  before do
    Timecop.travel('2018-03-29')
  end

  after do
    Timecop.return
  end

  def create_message(user, params={})
    post_as user, '/v1/messages',
      check_in: 1.month.from_now,
      check_out: 3.month.from_now,
      house_id: hq.id,
      user_id: padawan.id,
      body: 'Salut, je suis Benoit, étudiant en entrepreneuriat qui vient faire un stage sur Paris en startup (Legalife) à partir du 2 Avril pour 6 mois. Je compte lancer par la suite (septembre ou janvier) ma start-up en biotech.'
  end

  describe "POST /v1/messages" do

    it 'responds succesfully' do
      create_message padawan
      expect(response.status).to eq 201
    end

    it 'is error on guest' do
      create_message :guest
      expect(response.status).to eq 403
    end

    it 'creates correct info on existing user' do
      expect {
        create_message padawan
      }.to change { padawan.messages.count }.by(1)

      expect(json_response['check_in']).to eq '2018-04-29'
      expect(json_response['check_out']).to eq '2018-06-29'
      expect(json_response['body']).to match /Salut/
      expect(json_response['status']).to eq 'pending'
    end

    it 'can post using admin token' do
      expect {
        create_message admin
      }.to change { padawan.messages.count }.by(1)
    end

  end

end