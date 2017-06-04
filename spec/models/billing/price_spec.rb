require 'rails_helper'

RSpec.describe Billing::Price do
  it { is_expected.to monetize(:price) }

  describe '::operation_categories', db: false do
    it 'returns available operation categories' do
      categories = %w[create renew]
      expect(described_class.operation_categories).to eq(categories)
    end
  end

  describe '::durations', db: false do
    it 'returns available durations' do
      durations = [
        '3 mons',
        '6 mons',
        '9 mons',
        '1 year',
        '2 years',
        '3 years',
        '4 years',
        '5 years',
        '6 years',
        '7 years',
        '8 years',
        '9 years',
        '10 years',
      ]

      expect(described_class.durations).to eq(durations)
    end
  end

  describe 'zone validation', db: false do
    subject(:price) { described_class.new }

    it 'rejects absent' do
      price.zone = nil
      price.validate
      expect(price.errors).to have_key(:zone)
    end
  end

  describe 'price validation', db: false do
    subject(:price) { described_class.new }

    it 'rejects absent' do
      price.price = nil
      price.validate
      expect(price.errors).to have_key(:price)
    end

    it 'rejects negative' do
      price.price = -1
      price.validate
      expect(price.errors).to have_key(:price)
    end

    it 'accepts zero' do
      price.price = 0
      price.validate
      expect(price.errors).to_not have_key(:price)
    end

    it 'accepts greater than zero' do
      price.price = 1
      price.validate
      expect(price.errors).to_not have_key(:price)
    end

    it 'accepts fraction' do
      price.price = "1#{I18n.t('number.currency.format.separator')}5"
      price.validate
      expect(price.errors).to_not have_key(:price)
    end
  end

  describe 'duration validation', db: false do
    subject(:price) { described_class.new }

    it 'rejects absent' do
      price.duration = nil
      price.validate
      expect(price.errors).to have_key(:duration)
    end

    it 'rejects invalid' do
      price.duration = 'invalid'
      price.validate
      expect(price.errors).to have_key(:duration)
    end

    it 'accepts valid' do
      price.duration = described_class.durations.first
      price.validate
      expect(price.errors).to_not have_key(:duration)
    end
  end

  describe 'operation category validation', db: false do
    subject(:price) { described_class.new }

    it 'rejects absent' do
      price.operation_category = nil
      price.validate
      expect(price.errors).to have_key(:operation_category)
    end

    it 'rejects invalid' do
      price.operation_category = 'invalid'
      price.validate
      expect(price.errors).to have_key(:operation_category)
    end

    it 'accepts valid' do
      price.operation_category = described_class.operation_categories.first
      price.validate
      expect(price.errors).to_not have_key(:operation_category)
    end
  end

  describe '#name', db: false do
    let(:price) { described_class.new }

    before :example do
      allow(price).to receive(:operation_category).and_return('category')
      allow(price).to receive(:zone_name).and_return('zone')
    end

    it 'returns operation_category and zone name' do
      expect(price.name).to eq('category zone')
    end
  end

  describe '#zone_name', db: false do
    let(:price) { described_class.new(zone: zone) }
    let(:zone) { build_stubbed(:zone, origin: 'test') }

    it 'returns zone name' do
      expect(price.zone_name).to eq('test')
    end
  end
end
