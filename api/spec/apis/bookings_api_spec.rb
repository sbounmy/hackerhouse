require 'rails_helper'

describe BookingsAPI do

  before do
  end

  after do
    Timecop.return
  end

  let(:hq) { create(:house, slug_id: 'hq', rent_monthly: 10_000) } # 10 000 euros / month
  let(:stripe) { StripeMock.create_test_helper }
  let(:admin) { create(:user, admin: true) }
  let(:user) { create(:user) }

  def create_booking(user, params={})
    post_as user, '/v1/bookings',
      check_in: 1.month.from_now,
      check_out: 3.month.from_now,
      house_id: hq.id,
      message: 'Salut, je suis Benoit, étudiant en entrepreneuriat qui vient faire un stage sur Paris en startup (Legalife) à partir du 2 Avril pour 6 mois. Je compte lancer par la suite (septembre ou janvier) ma start-up en biotech.'
  end

  describe "POST /v1/bookings" do

    it 'responds succesfully' do
      create_booking user
      expect(response.status).to eq 201
    end

    it 'is error on guest' do
      create_booking :guest
      expect(response.status).to eq 403
    end

    it 'creates correct info on existing user' do
      expect {
        create_booking user
      }.to change { user.bookings.count }.by(1)

      expect(json_response['check_in']).to eq '2018-04-29'
      expect(json_response['check_out']).to eq '2018-06-29'
      expect(json_response['message']).to match /Salut/
      expect(json_response['status']).to eq 'pending'
    end
  end

end