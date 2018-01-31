require 'rails_helper'

RSpec.describe Nameserver do
  describe '::hostnames', db: false do
    before :example do
      expect(described_class).to receive(:pluck).with(:hostname).and_return('hostnames')
    end

    it 'returns names' do
      expect(described_class.hostnames).to eq('hostnames')
    end
  end
end
