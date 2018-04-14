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
      params: {
        check_in: 1.month.from_now,
        check_out: 3.month.from_now,
        house_id: hq.id,
        user_id: padawan.id,
        body: 'Salut, je suis Benoit, étudiant en entrepreneuriat qui vient faire un stage sur Paris en startup (Legalife) à partir du 2 Avril pour 6 mois. Je compte lancer par la suite (septembre ou janvier) ma start-up en biotech.'
      }
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

  describe "PUT /v1/messages/:id/like" do
    let(:resident) { create(:user, house: hq, check: [2.months.from_now, 6.months.from_now]) }
    let(:message) { create(:message, house: hq, user: padawan) }

    it 'responds succesfully' do
      put_as resident, "/v1/messages/#{message.id}/like", params: { like_id: resident.id }
      expect(response.status).to eq 200
      expect(json_response['like_ids']).to eq [resident.id.to_s]
      expect(message.reload.likes).to eq [resident]
    end

    it 'is error on guest' do
      put_as :guest, "/v1/messages/#{message.id}/like", params: { like_id: resident.id }
      expect(response.status).to eq 403
      expect(message.reload.likes).to be_empty
    end

    it 'is success on admin' do
      put_as admin, "/v1/messages/#{message.id}/like", params: { like_id: resident.id }
      expect(response.status).to eq 200
      expect(json_response['like_ids']).to eq [resident.id.to_s]
      expect(message.reload.likes).to eq [resident]
    end

    it 'is idempotent' do
      2.times do
        put_as resident, "/v1/messages/#{message.id}/like", params: { like_id: resident.id }
      end
      expect(response.status).to eq 200
      expect(json_response['like_ids']).to eq [resident.id.to_s]
      expect(message.reload.likes).to eq [resident]
    end

    it 'is 404 on not found message' do
      put_as resident, "/v1/messages/do-not-exist/like", params: { like_id: resident.id }
      expect(response.status).to eq 404
    end

    it 'is 403 on invalid like_id' do
      put_as resident, "/v1/messages/#{message.id}/like", params: { like_id: 'blabla' }
      expect(response.status).to eq 403
    end

    it 'is resident can not like as other' do
      put_as resident, "/v1/messages/#{message.id}/like", params: { like_id: create(:user, house: hq, check: [2.months.from_now, 6.months.from_now]).id }
      expect(response.status).to eq 403
    end
  end
end