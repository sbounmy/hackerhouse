module ControllerHelper
  def json_response
    body = respond_to?(:last_response) ? last_response.body : response.body
    MultiJson.load(body)
  end
  def token u
    JsonWebToken.encode(user_id: u.id.to_s)
  end

  def user_role(role)
    case role
    when :admin then double("User", admin?: true)
    when :guest then double("Guest", admin?: false)
    end
  end

  def get_as role, params={}, headers={}
    allow_any_instance_of(AuthorizeApiRequest).to receive(:user).and_return user_role(role)
    get params, headers
  end

  def delete_as role, params={}, headers={}
    allow_any_instance_of(AuthorizeApiRequest).to receive(:user).and_return user_role(role)
    delete params, headers
  end

  def post_as role, params={}, headers={}
    allow_any_instance_of(AuthorizeApiRequest).to receive(:user).and_return user_role(role)
    post params, headers
  end

  def put_as role, params={}, headers={}
    allow_any_instance_of(AuthorizeApiRequest).to receive(:user).and_return user_role(role)
    put params, headers
  end
end