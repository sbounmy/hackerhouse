require 'rails_helper'

describe App do

  describe '.stripe' do

    def stripe &block
      App.stripe &block
    end

    context 'on success' do
      it 'resets api_key to nil' do
        expect {
          stripe { }
        }.to_not raise_error
        expect(Stripe.api_key).to eq nil
      end
    end

    context 'on exception' do
      it 'raises error' do
        expect {
          stripe { raise Stripe::InvalidRequestError.new('card', 'error') }
        }.to raise_error Stripe::InvalidRequestError
      end

      it 'resets api_key to nil' do
        expect {
          stripe { raise Stripe::InvalidRequestError.new('card', 'error') }
        }.to raise_error Stripe::InvalidRequestError
        expect(Stripe.api_key).to eq nil
      end
    end

  end

end