require 'rails_helper'

RSpec.describe Dispute do
  it { is_expected.to alias_attribute(:create_time, :created_at) }
  it { is_expected.to alias_attribute(:update_time, :updated_at) }

  describe '::latest_on_top' do
    it 'sorts by :create_time in descending order' do
      expect(described_class).to receive(:order).with(create_time: :desc)
      described_class.latest_on_top
    end
  end

  describe '::expired', db: true do
    before :example do
      travel_to(Date.parse('05.07.2010'))

      create(:dispute, expire_date: Date.parse('03.07.2010'))
      create(:dispute, expire_date: Date.parse('04.07.2010'))
      create(:dispute, expire_date: Date.parse('05.07.2010'))
    end

    it 'returns records with past expiration date' do
      expect(described_class.expired.size).to eq(2)
    end
  end

  describe '::close_expired', db: false do
    let(:dispute) { instance_double(described_class) }
    let(:expired_disputes) { [dispute] }

    before :example do
      allow(described_class).to receive(:expired).and_return(expired_disputes)
    end

    it 'closes expired disputes' do
      expect(dispute).to receive(:close)
      described_class.close_expired
    end
  end

  describe 'domain name validation', db: false do
    let(:dispute) { described_class.new }

    it 'rejects absent' do
      dispute.domain_name = nil
      dispute.validate

      expect(dispute.errors).to have_key(:domain_name)
    end

    it 'rejects duplicate', db: true do
      create(:dispute, domain_name: 'test.com')

      dispute.domain_name = 'test.com'
      dispute.validate
      expect(dispute.errors).to have_key(:domain_name)
    end

    it 'rejects non-existent zone', db: true do
      ZonefileSetting.delete_all
      create(:zonefile_setting, origin: 'com')

      dispute.domain_name = 'test.org'
      dispute.validate(:admin)
      expect(dispute.errors).to have_key(:domain_name)
    end

    it 'accepts existing zone', db: true do
      ZonefileSetting.delete_all
      create(:zonefile_setting, origin: 'com')

      dispute.domain_name = 'test.com'
      dispute.validate(:admin)
      expect(dispute.errors).to_not have_key(:domain_name)
    end
  end

  describe 'expiration date validation', db: false do
    let(:dispute) { described_class.new }

    it 'rejects absent' do
      dispute.expire_date = nil
      dispute.validate
      expect(dispute.errors).to have_key(:expire_date)
    end

    context 'when admin' do
      it 'rejects past' do
        travel_to Date.parse('05.07.2010')

        dispute.expire_date = Date.parse('04.07.2010')
        dispute.validate(:admin)

        expect(dispute.errors).to have_key(:expire_date)
      end

      it 'accepts today' do
        travel_to Date.parse('05.07.2010')

        dispute.expire_date = Date.parse('05.07.2010')
        dispute.validate(:admin)

        expect(dispute.errors).to_not have_key(:expire_date)
      end
    end
  end

  describe 'password validation', db: false do
    let(:dispute) { described_class.new }

    it 'rejects absent' do
      dispute.password = nil
      dispute.validate
      expect(dispute.errors).to have_key(:password)
    end
  end

  describe 'comment validation', db: false do
    let(:dispute) { described_class.new }

    it 'rejects absent' do
      dispute.comment = nil
      dispute.validate
      expect(dispute.errors).to have_key(:comment)
    end
  end

  describe '#generate_password', db: false do
    let(:dispute) { described_class.new }

    it 'generates random password' do
      dispute.generate_password
      expect(dispute.password).to_not be_empty
    end
  end

  describe '#close', db: false do
    subject(:dispute) { described_class.new }
    let(:service) { instance_double(Disputes::Close) }

    before :example do
      allow(Disputes::Close).to receive(:new).with(dispute: dispute).and_return(service)
    end

    it 'closes dispute' do
      expect(service).to receive(:close)
      dispute.close
    end
  end
end
