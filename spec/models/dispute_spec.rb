require 'rails_helper'

RSpec.describe Dispute, db: false do
  it { is_expected.to alias_attribute(:create_time, :created_at) }
  it { is_expected.to alias_attribute(:update_time, :updated_at) }

  describe 'domain validation' do
    let(:dispute) { described_class.new }

    it 'rejects absent' do
      dispute.domain = nil
      dispute.validate
      expect(dispute.errors).to have_key(:domain)
    end

    it 'rejects duplicate', db: true do
      existing_domain = create(:domain, name: 'test.com')
      create(:dispute, domain: existing_domain)
      dispute.domain = existing_domain
      dispute.validate
      expect(dispute.errors).to have_key(:domain)
    end
  end

  describe 'expire date validation' do
    let(:dispute) { described_class.new }

    it 'rejects absent' do
      dispute.expire_date = nil
      dispute.validate
      expect(dispute.errors).to have_key(:expire_date)
    end

    it 'rejects past' do
      travel_to Date.parse('05.07.2010')
      dispute.expire_date = Date.parse('04.07.2010')
      dispute.validate
      expect(dispute.errors).to have_key(:expire_date)
    end

    it 'accepts today' do
      travel_to Date.parse('05.07.2010')
      dispute.expire_date = Date.parse('05.07.2010')
      dispute.validate
      expect(dispute.errors).to_not have_key(:expire_date)
    end
  end

  describe 'password validation' do
    let(:dispute) { described_class.new }

    it 'rejects absent' do
      dispute.password = nil
      dispute.validate
      expect(dispute.errors).to have_key(:password)
    end
  end

  describe 'comment validation' do
    let(:dispute) { described_class.new }

    it 'rejects absent' do
      dispute.comment = nil
      dispute.validate
      expect(dispute.errors).to have_key(:comment)
    end
  end

  describe '::latest_on_top' do
    it 'sorts by :create_time in descending order' do
      expect(described_class).to receive(:order).with(create_time: :desc)
      described_class.latest_on_top
    end
  end

  describe '::expired', db: true do
    before :example do
      travel_to(Date.parse('05.07.2010'))

      create(:dispute, expire_date: Date.parse('04.07.2010'))
      create(:dispute, expire_date: Date.parse('05.07.2010'))
    end

    it 'returns records with past :expire_time' do
      expect(described_class.expired.size).to eq(1)
    end
  end

  describe '::delete_expired', db: true do
    before :example do
      travel_to(Date.parse('05.07.2010'))

      create(:dispute, expire_date: Date.parse('04.07.2010'))
      create(:dispute, expire_date: Date.parse('05.07.2010'))

      described_class.delete_expired
    end

    it 'deletes expired records' do
      expect(described_class.all.size).to eq(1)
    end
  end

  describe '#domain_name' do
    let(:dispute) { described_class.new(domain: domain) }
    let(:domain) { build_stubbed(:domain) }

    it 'returns domain name' do
      expect(domain).to receive(:name).and_return('test')
      expect(dispute.domain_name).to eq('test')
    end
  end

  describe '#generate_password' do
    let(:dispute) { described_class.new }

    it 'generates random password' do
      expect(SecureRandom).to receive(:hex).and_return('test')
      dispute.generate_password
      expect(dispute.password).to eq('test')
    end
  end
end
