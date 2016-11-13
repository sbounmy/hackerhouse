class ApplicationAPI < Grape::API
  version 'v1', using: :path
  format :json
  formatter :json, Grape::Formatter::ActiveModelSerializers

  # Helpers
  helpers do
    # Return params declared by grape block
    def declared_params
      @declared ||= ActiveSupport::HashWithIndifferentAccess.new(declared(params, include_missing: false))
    end
  end

  # Errors handling
  rescue_from Mongoid::Errors::Validations do |e|
    error_response(status: 422, message: { 'errors' => e.document.errors.as_json })
  end

  # APIs
  mount HousesAPI
  mount UsersAPI
end
