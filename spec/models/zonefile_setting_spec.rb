require 'rails_helper'

RSpec.describe ZonefileSetting, db: false do
  it 'has versions' do
    expect(described_class.new.versions).to eq([])
  end

  describe '::origins' do
    before :example do
      expect(described_class).to receive(:pluck).with(:origin).and_return('origins')
    end

    it 'returns origins' do
      expect(described_class.origins).to eq('origins')
    end
  end
end
