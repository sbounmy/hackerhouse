module ControllerHelper
  def json_response
    body = respond_to?(:last_response) ? last_response.body : response.body
    MultiJson.load(body)
  end
  def token u
    JsonWebToken.encode(user_id: u.id.to_s)
  end

  def user_object(role_or_record)
    case role_or_record
    when :admin then double("User", admin?: true, id: '123')
    when :guest then Guest.new
    else
      role_or_record
    end
  end

  def get_as role_or_record, url, opts={params: {}, headers: {}}
    allow_any_instance_of(AuthorizeApiRequest).to receive(:user).and_return user_object(role_or_record)
    get url, opts
  end

  def delete_as role_or_record, url, opts={params: {}, headers: {}}
    allow_any_instance_of(AuthorizeApiRequest).to receive(:user).and_return user_object(role_or_record)
    delete url, opts
  end

  def post_as role_or_record, url, opts={params: {}, headers: {}}
    allow_any_instance_of(AuthorizeApiRequest).to receive(:user).and_return user_object(role_or_record)
    post url, opts
  end

  def put_as role_or_record, url, opts={params: {}, headers: {}}
    allow_any_instance_of(AuthorizeApiRequest).to receive(:user).and_return user_object(role_or_record)
    put url, opts
  end

  def deliveries
    ActionMailer::Base.deliveries
  end

  def last_delivery
    deliveries.last
  end

  def with_funds
    yield
  rescue Stripe::InvalidRequestError => e
    puts e.message.inspect
    raise e unless e.message.include? 'Insufficient funds in Stripe account. In test mode, you can add funds to your available balance'
    puts '...Reloading account with funds...'
    App.stripe do
      Stripe::Charge.create amount: 999_999_00, currency: 'eur',
      source: { exp_month: '10', exp_year: '23', number: '4000 0000 0000 0077',
        object: 'card', cvc: '111' }
    end
    retry
  end

  def stub_synchronizers! except: []
    allow_send_action.and_return(false) #if except.empty?
    except.each do |ex|
      allow_send_action.with(anything, ex).and_call_original
    end if except
  end

  private

  def allow_send_action
    allow_any_instance_of(ApplicationSynchronizer).to receive(:send_action)
  end
end