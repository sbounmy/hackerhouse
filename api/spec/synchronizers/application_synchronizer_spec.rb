require 'rails_helper'

RSpec.describe ApplicationSynchronizer, type: :synchronizer, sync: true do
  before do
    class TestSynchronizer < ApplicationSynchronizer

      def hello(string)
      end
      def foo
        hello params[:bar]
      end

      def bar_today
      end

      def bar_tomorrow
      end
    end
  end

  after do
    Object.send(:remove_const, :TestSynchronizer)
  end

  describe '.with' do
    it 'accepts params' do
      expect_any_instance_of(TestSynchronizer).to receive(:hello).with('hello')
      TestSynchronizer.with(bar: 'hello').foo
    end
  end

  describe 'action methods' do
    it 'accepts single platform' do
      expect_any_instance_of(TestSynchronizer).to receive(:bar_today)
      TestSynchronizer.with(bar: 'hello').bar(:today, :tomorrow)
    end

    it 'accepts multiple platform' do
      expect_any_instance_of(TestSynchronizer).to receive(:bar_today)
      expect_any_instance_of(TestSynchronizer).to receive(:bar_tomorrow)
      TestSynchronizer.with(bar: 'hello').bar(:today, :tomorrow)
    end

    it 'raises error on undefined method' do
      expect {
        TestSynchronizer.with(bar: 'hello').bar(:unknown)
      }.to raise_error(NoMethodError, /undefined method `bar_unknown'/)
    end
  end
end