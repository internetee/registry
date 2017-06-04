require 'rails_helper'

RSpec.describe Billing::Price do
  it { is_expected.to monetize(:price) }
  it { is_expected.to be_versioned }
  it { is_expected.to alias_attribute(:effect_time, :valid_from) }
  it { is_expected.to alias_attribute(:expire_time, :valid_to) }

  it 'should have one version' do
    with_versioning do
      price = build(:price)
      price.save!
      price.versions.size.should == 1
    end
  end

  describe '::operation_categories', db: false do
    it 'returns operation categories' do
      categories = %w[create renew]
      expect(described_class.operation_categories).to eq(categories)
    end
  end

  describe '::durations', db: false do
    it 'returns durations' do
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

  describe '::statuses', db: false do
    it 'returns statuses' do
      expect(described_class.statuses).to eq(%w[upcoming effective expired])
    end
  end

  describe '::upcoming' do
    before :example do
      travel_to Time.zone.parse('05.07.2010 00:00')

      create(:price, id: 1, effect_time: Time.zone.parse('05.07.2010 00:00'))
      create(:price, id: 2, effect_time: Time.zone.parse('05.07.2010 00:01'))
    end

    it 'returns upcoming' do
      expect(described_class.upcoming.ids).to eq([2])
    end
  end

  describe '::effective' do
    before :example do
      travel_to Time.zone.parse('05.07.2010 00:00')

      create(:price, id: 1, effect_time: '05.07.2010 00:01', expire_time: '05.07.2010 00:02')
      create(:price, id: 2, effect_time: '05.07.2010 00:00', expire_time: '05.07.2010 00:01')
      create(:price, id: 3, effect_time: '05.07.2010 00:00', expire_time: nil)
      create(:price, id: 4, effect_time: '04.07.2010', expire_time: '04.07.2010 23:59')
    end

    it 'returns effective' do
      expect(described_class.effective.ids).to eq([2, 3])
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
