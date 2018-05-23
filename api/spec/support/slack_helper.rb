class TestSlack < Slack::Web::Client
  cattr_accessor :live

  def self.deliveries
    @@deliveries ||= []
  end

  def self.chat_postMessage(*args)
    Slack::Web::Client.new.chat_postMessage(*args)
    deliveries << TestSlack::Delivery.new(*args)
  end

  class Delivery
    attr_accessor :channel, :text

    def initialize(*args)
      @channel = args[0][:channel]
      @text = args[0][:text]
    end
  end
end

module SlackHelper
  extend ActiveSupport::Concern

  included do
    RSpec.configure do |config|
      config.before(:each) do |example|
        allow(App).to receive(:slack).and_return TestSlack
      end

      def slacks
        TestSlack.deliveries
      end

    end
  end
end