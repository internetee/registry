require 'rails_helper'

RSpec.describe Dispute, db: false do
  it { is_expected.to alias_attribute(:create_time, :created_at) }
  it { is_expected.to alias_attribute(:update_time, :updated_at) }

  describe 'domain name validation' do
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
  end

  describe 'expiration date validation' do
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
      expect(described_class.count).to eq(1)
    end
  end

  describe '::for_domain', db: true do
    context 'when dispute exists' do
      let!(:dispute) { create(:dispute, domain_name: 'test.com') }

      it 'returns dispute' do
        expect(described_class.for_domain('test.com')).to eq(dispute)
      end
    end

    context 'when dispute does not exist' do
      specify { expect(described_class.for_domain('test.com')).to be_nil }
    end
  end

  describe '#generate_password' do
    let(:dispute) { described_class.new }

    it 'generates random password' do
      dispute.generate_password
      expect(dispute.password).to_not be_empty
    end
  end

  describe '#close', db: false do
    let(:dispute) { described_class.new }
    let(:dispute_close) { instance_double(Disputes::Close) }

    it 'closes dispute' do
      expect(Disputes::Close).to receive(:new).with(dispute: dispute).and_return(dispute_close)
      expect(dispute_close).to receive(:close).and_return(true)
      expect(dispute.close).to be true
    end
  end
end
