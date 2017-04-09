require 'rails_helper'

RSpec.describe Whois::Record do
  it { is_expected.to alias_attribute(:domain_name, :name) }

  describe '::table_name', db: false do
    it 'returns table name' do
      expect(described_class.table_name).to eq('whois_records')
    end
  end

  describe 'domain name validation', db: false do
    let(:whois_record) { described_class.new }

    it 'rejects absent' do
      whois_record.domain_name = nil
      whois_record.validate
      expect(whois_record.errors).to have_key(:domain_name)
    end
  end

  describe 'body validation', db: false do
    let(:whois_record) { described_class.new }

    it 'rejects absent' do
      whois_record.body = nil
      whois_record.validate
      expect(whois_record.errors).to have_key(:body)
    end
  end

  describe 'json validation', db: false do
    let(:whois_record) { described_class.new }

    it 'rejects absent' do
      whois_record.json = nil
      whois_record.validate
      expect(whois_record.errors).to have_key(:json)
    end
  end
end
