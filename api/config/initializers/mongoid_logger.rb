unless defined?(Rails::Console)
  Mongoid.logger = Rails.logger
end
