require 'raven/integrations/rack'

class ApplicationAPI < Grape::API
  version 'v1', using: :path
  format :json
  formatter :json, Grape::Formatter::ActiveModelSerializers
  insert_after Grape::Middleware::Formatter, Grape::Middleware::Logger, {
    logger: Rails.logger,
    filter: Class.new { def filter(opts) opts.reject { |k, _| k.to_s == 'password' } end }.new,
    headers: %w(version cache-control)
  }
  use Raven::Rack

  before do
    Raven.user_context(id: current_user.id.to_s,
                       email: current_user.email,
                       ip_address: request.ip) # or anything else in session
    Raven.extra_context(params: params, url: request.url)
  end

  # Helpers
  helpers do
    # Return params declared by grape block
    def declared_params
      @declared ||= ActiveSupport::HashWithIndifferentAccess.new(declared(params, include_missing: false))
    end
    include Pundit

    def current_user
      @current_user ||= AuthorizeApiRequest.call(params[:token], request.headers).result || Guest.new
    end
  end

  # Errors handling
  rescue_from Mongoid::Errors::Validations do |e|
    error_response(status: 422, message: { 'errors' => e.document.errors.as_json })
  end

  rescue_from Pundit::NotAuthorizedError do |e|
    error_response(status: 403, message: { 'errors' => { 'authorization' => 'Unauthorized' } })
  end

  rescue_from Mongoid::Errors::DocumentNotFound do |e|
    error_response(status: 404, message: { 'errors' => { 'not_found' => e.message } })
  end

  # APIs
  mount BalancesAPI
  mount MessagesAPI
  mount HousesAPI
  mount SessionsAPI
  mount SourcesAPI
  mount TransfersAPI
  mount TokensAPI
  mount UsersAPI
  mount UsersV2API
end
