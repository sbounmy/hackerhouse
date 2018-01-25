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
    when :guest then double("Guest", admin?: false, id: nil)
    else
      role_or_record
    end
  end

  def get_as role_or_record, params={}, headers={}
    allow_any_instance_of(AuthorizeApiRequest).to receive(:user).and_return user_object(role_or_record)
    get params, headers
  end

  def delete_as role_or_record, params={}, headers={}
    allow_any_instance_of(AuthorizeApiRequest).to receive(:user).and_return user_object(role_or_record)
    delete params, headers
  end

  def post_as role_or_record, params={}, headers={}
    allow_any_instance_of(AuthorizeApiRequest).to receive(:user).and_return user_object(role_or_record)
    post params, headers
  end

  def put_as role_or_record, params={}, headers={}
    allow_any_instance_of(AuthorizeApiRequest).to receive(:user).and_return user_object(role_or_record)
    put params, headers
  end
end