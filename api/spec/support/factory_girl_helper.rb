RSpec.configure do |config|
  # additional factory_girl configuration
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    begin
      # do not lint embedded factories
      factories = FactoryGirl.factories.reject do |factory|
        %i(photo item).include? factory.name
      end

      FactoryGirl.lint factories
    ensure
      Mongoid::Config.purge!
    end
  end
end