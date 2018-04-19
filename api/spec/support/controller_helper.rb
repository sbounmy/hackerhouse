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
end