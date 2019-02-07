require 'rails_helper'

describe UsersAPI do
  let!(:hq) { create(:house, stripe_plan_ids: ['rent_monthly', 'cleaning_monthly']) }
  let(:stripe) { StripeMock.create_test_helper }

  describe "POST /v1/users" do

    let(:first_of_month) { 1.month.from_now.beginning_of_month }
    let(:middle_of_month) { Date.new(1.month.from_now.year, 1.month.from_now.month, 15) }
    let(:default_params) { { slug_id: hq.slug_id,
        token: App.stripe { stripe.generate_card_token }, email: 'paul@42.student.fr',
        check_in: middle_of_month, check_out: 4.months.from_now } }

    before do
      # StripeMock.toggle_live(true)
      StripeMock.start
      # App.stripe do
        stripe.create_plan(id: 'rent_monthly', amount: 1, currency: 'eur')
        stripe.create_plan(id: 'cleaning_monthly', amount: 1, currency: 'eur')
      # end
    end

    after { StripeMock.stop }

    def create_user(params={})
      post "/v1/users", params: default_params.merge(params)
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
        user = User.last
        expect(user.token).to match /tok_/
        expect(user.stripe_id).to match "cus_"
        u = json_response
        expect(u['check_in']).to eq middle_of_month.strftime("%Y-%m-%d")
        expect(u['check_out']).to eq 4.months.from_now.strftime("%Y-%m-%d")
      end

      it 'doesnt display sensible information' do
        create_user
        expect(json_response.keys).to contain_exactly "id", "firstname", "lastname",
          "bio_title", "bio_url", "check_in", "check_out",
          "active", "admin", "house_slug_id", "house_id", "avatar_url"
      end

      it 'accepts date as %d\/%m\/%Y' do
        expect {
          create_user check_in: first_of_month.strftime("%d/%m/%Y")
        }.to change { hq.users.count }.by(1)

        customer = Stripe::Customer.retrieve(hq.users.last.stripe_id)
        expect(customer.subscriptions.count).to eq 1
        expect(customer.subscriptions.first.trial_end).to eq Time.parse(first_of_month.strftime("%d/%m/%Y")).to_i
      end

      it 'accepts localized date %d\/%m\/%Y' do
        nextyear = Date.today.year + 1
        date = Date.new(nextyear, 2, 1) # next year 1st february
        expect {
          create_user check_in: date.strftime("%d/%m/%Y"), check_out: (date + 2.months).strftime("%d/%m/%Y")
        }.to change { hq.users.count }.by(1)

        customer = Stripe::Customer.retrieve(hq.users.last.stripe_id)
        expect(customer.subscriptions.count).to eq 1
        expect(customer.subscriptions.first.trial_end).to eq Time.parse("01/02/#{nextyear}").to_i
      end

      it 'creates subscriptions with custom application fee on v2 false' do
        hq.update_attributes v2: false, stripe_application_fee_percent: 30
        create_user
        customer = Stripe::Customer.retrieve(hq.users.last.stripe_id)
        expect(customer.subscriptions.count).to eq 1
        expect(customer.subscriptions.first.application_fee_percent).to eq 30
      end

      it 'creates subscriptions without application fee on v2' do
        create_user
        customer = Stripe::Customer.retrieve(hq.users.last.stripe_id)
        expect(customer.subscriptions.count).to eq 1
        expect(customer.subscriptions.first.try(:application_fee_percent)).to eq nil
      end

      it 'creates subscriptions in a middle week' do
        create_user email: 'paul+middleweek@42.com', check_in: middle_of_month.strftime("%Y-%m-%d")
        user = hq.users.last
        days_to_prorate = (middle_of_month.next_month.beginning_of_month.to_date - user.check_in).to_i
        App.stripe do
          customer = Stripe::Customer.retrieve(hq.users.last.stripe_id)
          expect(customer.subscriptions.count).to eq 1
          sub = customer.subscriptions.data[0]
          items = Stripe::InvoiceItem.list(customer: user.stripe_id)
          expect(sub.trial_end).to eq middle_of_month.next_month.beginning_of_month.to_time.to_i
          expect(items.data.map(&:amount)).to include((500.to_f / 4 / 30 * days_to_prorate).ceil * 100,
                                                               (10000.to_f / 4 / 30 * days_to_prorate).ceil * 100)
        end
        expect(user.stripe_prorata_id).to include 'in_'
      end

    end

    context 'with invalid params' do
      it 'raises error when no plan' do
        stripe.delete_plan 'rent_monthly'
        expect {
          expect {
            create_user
          }.to raise_error(Stripe::InvalidRequestError, 'No such plan: rent_monthly')
        }.to_not change { User.count }
      end

      it 'returns error when no matching house' do
        hq.destroy!
        expect {
          create_user
        }.to_not change { User.count }
        expect(response.code).to eq "404"
        expect(json_response['errors']).to have_key('not_found')
      end

      it 'raises error when check_in is in the past' do
        expect {
          expect {
            create_user check_in: '1988-10-20'
          }.to raise_error(Stripe::InvalidRequestError, /Invalid timestamp\: must be an integer Unix timestamp in the future/)
        }.to_not change { User.count }
      end

      it 'raises error when check_out is nil' do
        create_user check_out: nil
        expect(response.code).to eq "400"
        expect(json_response['error']).to eq 'check_out is empty'
      end

      it 'raises error when check_out is empty' do
        create_user check_out: ''
        expect(response.code).to eq "400"
        expect(json_response['error']).to eq 'check_out is empty'
      end

      it 'does not create duplicate users' do
        expect {
          create_user
          create_user
        }.to change { User.count }.by(1)
      end

    end
  end

  describe "PUT /v1/users/:id" do
    let(:user) { create(:user, remote_avatar_url: nil, stripe: true) }
    let(:avatar) { "https://i1.wp.com/dev.slack.com/img/avatars/ava_0010-512.v1443724322.png" }

    it 'is forbidden to guest' do
      expect {
        put "/v1/users/#{user.id}", params: { remote_avatar_url: avatar }
      }.to_not change { user.reload.avatar_url }.from(nil)
      expect(response.status).to eq 403
    end

    it 'updates its own avatar url' do
      expect {
        put "/v1/users/#{user.id}", params: { remote_avatar_url: avatar }, headers: { 'Authorization' => token(user) }
      }.to change { user.reload.avatar_url }.from(nil).to(/attachment/)
    end

    it 'updates its own avatar url using token parameter' do
      expect {
        put "/v1/users/#{user.id}", params: { remote_avatar_url: avatar, token: token(user) }
      }.to change { user.reload.avatar_url }.from(nil).to(/attachments/)
    end

    it 'is forbidden to update someone else avatar url' do
      user2 = create(:user, remote_avatar_url: nil)
      expect {
        put "/v1/users/#{user2.id}", params: { remote_avatar_url: avatar }, headers: { 'Authorization' => token(user) }
      }.to_not change { user2.reload.avatar_url }.from(nil)
      expect(response.status).to eq 403
    end

    it 'is allowed to update someone else avatar url if admin' do
      user2 = create(:user, remote_avatar_url: nil, stripe: true)
      user.set admin: true
      expect {
        put "/v1/users/#{user2.id}", params: { remote_avatar_url: avatar }, headers: { 'Authorization' => token(user) }
      }.to change { user2.reload.avatar_url }.from(nil).to(/attachments/)
      expect(response.status).to eq 200
    end

    it 'sync on intercom', :sync do
      u = create(:user, intercom: true)
      co = 3.month.from_now.to_date
      expect {
        put_as :admin, "/v1/users/#{u.id}", params: { check_out: co }
      }.to change { u.reload.check_out }.to(co)
      expect(response.status).to eq 200
      App.intercom do |i|
        i_user = i.users.find(user_id: u.id.to_s)
        expect(i_user.custom_attributes['check_out']).to eq co.to_s
      end
    end

    context 'on checkout update' do
      let!(:user) { create(:user, check_out: 3.months.from_now, house: hq) }
      let!(:sophie) { create(:user, firstname: "Sophie", check_out: 5.months.from_now, house: hq) }

      before { I18n.locale = :fr } # so expectations matches french date formats
      after { I18n.locale = :en }

      context 'when check_out changes', sync: [:mailer] do
        it 'does not email when checkout is in the past' do
          expect {
            put "/v1/users/#{user.id}", params: { check_out: 2.month.ago, token: token(user) }
          }.to change { deliveries.count }.by(0)
        end

        it 'emails active users when checkout earlier' do
          expect {
            put "/v1/users/#{user.id}", params: { check_out: 2.month.from_now, token: token(user) }
          }.to change { deliveries.count }.by(1)
          expect(last_delivery.from).to eq ["julie@hackerhouse.paris"]
          expect(last_delivery.cc).to eq ["stephane@hackerhouse.paris"]
          expect(last_delivery.to).to eq [sophie.email]
          expect(last_delivery.reply_to).to eq [user.email]
          expect(last_delivery.subject).to match /Paul nous quitte plus tôt que prévu/
          expect(last_delivery.body.encoded).to match /Paul part le #{I18n.l(user.reload.check_out, format: :pretty).to_quoted_printable}/
        end

        it 'emails active users when checkout later' do
          expect {
            put "/v1/users/#{user.id}", params: { check_out: 5.month.from_now, token: token(user) }
          }.to change { deliveries.count }.by(1)
          expect(last_delivery.from).to eq ["julie@hackerhouse.paris"]
          expect(last_delivery.to).to eq [sophie.email]
          expect(last_delivery.reply_to).to eq [user.email]
          expect(last_delivery.subject).to match /Paul reste plus longtemps que prévu ! 👍/
          expect(last_delivery.body.encoded).to match /Paul continue l'aventure avec nous jusqu'au #{I18n.l(user.reload.check_out, format: :pretty).to_quoted_printable}/
        end

        it 'does not email when user is admin' do
          user.update_attributes admin: true
          expect {
            put "/v1/users/#{user.id}", params: { check_out: 2.month.from_now, token: token(user) }
          }.to change { deliveries.count }.by(0)
        end

        it 'does not email when checkout does not change' do
          expect {
            put "/v1/users/#{user.id}", params: { check_out: 3.month.from_now, token: token(user) }
          }.to_not change { deliveries.count }
        end

      end
    end
  end

  describe "GET /v1/users" do
    let(:user) { create(:user) }

    it 'list all users' do
      user
      get "/v1/users"
      expect(response.status).to eq 200

      expect(json_response[0]['firstname']).to eq "Paul"
      expect(json_response[0]['lastname']).to eq "Amicel"
      expect(json_response[0]['avatar_url']).to start_with "/attachments/"
    end

    it 'list user from specific house' do
      user
      hq = create(:house)
      didix = create(:user, firstname: "Edmond Xavier", lastname: "Collot", house: hq)
      get "/v1/users", params: { q: { house_id: hq.id } }
      expect(response.status).to eq 200
      expect(json_response).to have(1).items
      expect(json_response[0]['firstname']).to eq "Edmond Xavier"
      expect(json_response[0]['lastname']).to eq "Collot"
    end

    it 'can filter by inactive' do
      user
      ghost = create(:user, firstname: 'Brian', lastname: 'Ghost', check_out: 2.months.ago)
      get "/v1/users", params: { q: { active: false } }
      expect(response.status).to eq 200

      expect(json_response).to have(2).items
      expect(json_response[1]['firstname']).to eq 'Brian'
      expect(json_response[1]['lastname']).to eq 'Ghost'
    end

    it 'can filter by active' do
      user.update_attributes check_out: 2.months.from_now
      ghost = create(:user, firstname: 'Brian', lastname: 'Ghost',  check_out: 2.months.ago)
      get "/v1/users", params: { q: { active: true } }
      expect(response.status).to eq 200

      expect(json_response).to have(1).items
      expect(json_response[0]['firstname']).to eq 'Paul'
      expect(json_response[0]['lastname']).to eq 'Amicel'
    end

    it 'can filter by active with integer 1' do
      user.update_attributes check_out: 2.months.from_now
      ghost = create(:user, firstname: 'Brian', lastname: 'Ghost',  check_out: 2.months.ago)
      get "/v1/users", params: { q: { active: 1 } }
      expect(response.status).to eq 200

      expect(json_response).to have(1).items
      expect(json_response[0]['firstname']).to eq 'Paul'
      expect(json_response[0]['lastname']).to eq 'Amicel'
    end

    it 'can filter upcoming' do
      user.update_attributes check_in: 2.months.from_now, check_out: 5.month.from_now
      get "/v1/users", params: { q: { upcoming: 1 } }
      expect(response.status).to eq 200

      expect(json_response).to have(1).items
      expect(json_response[0]['firstname']).to eq 'Paul'
      expect(json_response[0]['lastname']).to eq 'Amicel'
    end

    it 'can filter active_or_upcoming' do
      user.update_attributes check_in: 2.months.from_now, check_out: 5.month.from_now
      ghost = create(:user, firstname: 'Brian', lastname: 'Ghost',  check_in: Date.yesterday, check_out: 2.months.from_now)
      get "/v1/users", params: { q: { active_or_upcoming: 1 } }

      expect(response.status).to eq 200
      expect(json_response).to have(2).items
      expect(json_response[0]['firstname']).to eq 'Paul'
      expect(json_response[0]['lastname']).to eq 'Amicel'
      expect(json_response[1]['firstname']).to eq 'Brian'
      expect(json_response[1]['lastname']).to eq 'Ghost'
    end

    it 'can filter by check' do
      user.update_attributes check_in: Date.today, check_out: 5.month.from_now
      ghost = create(:user, firstname: 'Brian', lastname: 'Ghost',  check_in: 1.month.ago, check_out: 2.months.from_now)
      get "/v1/users", params: { q: { check: [Date.today.beginning_of_month, Date.today.end_of_month] } }

      expect(response.status).to eq 200
      expect(json_response).to have(1).items
      expect(json_response[0]['firstname']).to eq 'Paul'
      expect(json_response[0]['lastname']).to eq 'Amicel'
    end

    it 'can filter active_or_upcoming and by house' do
      user.update_attributes check_in: 2.months.from_now, check_out: 5.month.from_now
      ghost = create(:user, firstname: 'Brian', lastname: 'Ghost',  check_in: Date.yesterday, check_out: 2.months.from_now)
      get "/v1/users", params: { q: { active_or_upcoming: 1, house_id: user.house_id } }

      expect(response.status).to eq 200
      expect(json_response).to have(1).items
      expect(json_response[0]['firstname']).to eq 'Paul'
      expect(json_response[0]['lastname']).to eq 'Amicel'
    end

    it 'shows email and phone when admin' do
      user
      admin = create(:user, admin: true)
      get_as admin, "/v1/users"
      expect(json_response).to have(2).items
      expect(json_response[0]['email']).to match /.+\@.+\..+/
      expect(json_response[0]['phone_number']).to eq '0612345678'
    end

    it 'only show current user email' do
      user
      simple_user = create(:user)
      get_as simple_user, "/v1/users"
      expect(json_response).to have(2).items
      expect(json_response.map {|u| u['email'] }.compact).to eq [simple_user.email]
      expect(json_response.map {|u| u['phone_number'] }.compact).to eq ['0612345678']
    end

    it 'fetches multiple ids' do
      user
      user2 = create(:user)
      user3 = create(:user)
      get_as user, "/v1/users", params: { q: { "id.in" => [user.id, user2.id]} }
      expect(json_response).to have(2).items
      expect(json_response.map {|u| u['id'] }).to contain_exactly user.id.to_s, user2.id.to_s
    end
  end

  describe "GET /v1/users/:id" do
    let(:user) { create(:user) }
    let(:admin) { create(:user, admin: true) }

    it 'show user email if admin' do
      user
      get_as admin, "/v1/users/#{user.id}"
      expect(json_response.keys).to include 'firstname', 'lastname', 'email'
    end

    it 'does not show user email if guest' do
      user
      get_as Guest.new, "/v1/users/#{user.id}"
      expect(json_response.keys).to include 'avatar_url', 'firstname', 'lastname'
      expect(json_response.keys).to_not include 'email'
    end

  end
end