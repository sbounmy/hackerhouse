module ControllerHelper
  def json_response
    body = respond_to?(:last_response) ? last_response.body : response.body
    MultiJson.load(body)
  end
  def token u
    JsonWebToken.encode(user_id: u.id.to_s)
  end
end