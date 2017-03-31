require 'rails_helper'

RSpec.describe Whois::Record do
  it { is_expected.to alias_attribute(:domain_name, :name) }

  describe '::table_name', db: false do
    it 'returns table name' do
      expect(described_class.table_name).to eq('whois_records')
    end
  end

  describe '::regenerate_all' do
    let!(:whois_record) { create(:whois_record, updated_at: Time.zone.parse('04.07.2010')) }

    before :example do
      travel_to Time.zone.parse('05.07.2010')
    end

    it 'regenerates all whois records' do
      expect { described_class.regenerate_all; whois_record.reload }
        .to change { whois_record.updated_at }.from(Time.zone.parse('04.07.2010'))
              .to(Time.zone.parse('05.07.2010'))
    end
  end

  describe '::regenerate' do
    let(:domain_name) { instance_spy(DNS::DomainName, name: 'test.com') }

    def regenerate
      described_class.regenerate(domain_name: domain_name)
    end

    context 'when domain name is registered' do
      before :example do
        allow(domain_name).to receive(:registered?).and_return(true)
      end

      it 'creates whois record' do
        expect { regenerate }.to change { described_class.count }.from(0).to(1)
      end
    end

    context 'when domain name is reserved' do
      before :example do
        allow(domain_name).to receive(:reserved?).and_return(true)
      end

      it 'creates whois record' do
        expect { regenerate }.to change { described_class.count }.from(0).to(1)
      end
    end

    context 'when domain name is disputed' do
      before :example do
        allow(domain_name).to receive(:disputed?).and_return(true)
      end

      it 'creates whois record' do
        expect { regenerate }.to change { described_class.count }.from(0).to(1)
      end
    end

    context 'when domain name is blocked' do
      before :example do
        allow(domain_name).to receive(:blocked?).and_return(true)
      end

      it 'creates whois record' do
        expect { regenerate }.to change { described_class.count }.from(0).to(1)
      end
    end

    context 'when domain name is nor registered or limited' do
      let!(:whois_record) { create(:whois_record, domain_name: 'test.com') }

      before :example do
        allow(domain_name).to receive(:registered?).and_return(false)
        allow(domain_name).to receive(:reserved?).and_return(false)
        allow(domain_name).to receive(:disputed?).and_return(false)
        allow(domain_name).to receive(:blocked?).and_return(false)
      end

      it 'deletes whois record' do
        expect { regenerate }.to change { described_class.count }.from(1).to(0)
      end
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
