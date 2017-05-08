require 'rails_helper'

RSpec.describe Depp::Domain do
  describe '::default_period', db: false, settings: false do
    it 'returns default period' do
      expect(described_class.default_period).to eq('1y')
    end
  end
end
