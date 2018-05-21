require 'rails_helper'

RSpec.describe ApplicationSynchronizer, type: :synchronizer, sync: true do
  before do
    class TestSynchronizer < ApplicationSynchronizer
      on :cry do
        to :baby do
          give_a_hug
        end

        to :dog do
          give_a_bone params[:sound]
        end
      end

      def give_a_hug
      end

      def give_a_bone noise
      end
    end
  end

  after do
    Object.send(:remove_const, :TestSynchronizer)
  end

  describe '.with' do
    it 'accepts params' do
      expect_any_instance_of(TestSynchronizer).to receive(:give_a_bone).with('waf')
      TestSynchronizer.with(sound: 'waf').cry(:dog)
    end
  end

  describe '.on & .to' do
    it 'accepts single service' do
      expect_any_instance_of(TestSynchronizer).to receive(:give_a_hug)
      TestSynchronizer.with(sound: 'ouin').cry(:baby)
    end

    it 'accepts multiple service' do
      expect_any_instance_of(TestSynchronizer).to receive(:give_a_hug)
      expect_any_instance_of(TestSynchronizer).to receive(:give_a_bone)
      TestSynchronizer.with(sound: 'youpi').cry(:baby, :dog)
    end

    it 'raise error when no service' do
      expect {
        TestSynchronizer.with(sound: '').cry()
      }.to raise_error(TestSynchronizer::MissingService, /need at least a service as argument\: TestSynchronizer\.cry\(baby\, dog\)/)
    end

    it 'raises correct error on undefined .on' do
      expect {
        TestSynchronizer.with(sound: 'youpi').happy(:baby)
      }.to raise_error(TestSynchronizer::DefinitionError, /on :happy/)
    end
  end
end