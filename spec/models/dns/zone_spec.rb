require 'rails_helper'

RSpec.describe DNS::Zone do
  describe '::origins' do
    before :example do
      expect(described_class).to receive(:pluck).with(:origin).and_return('origins')
    end

    it 'returns origins' do
      expect(described_class.origins).to eq('origins')
    end
  end
end
