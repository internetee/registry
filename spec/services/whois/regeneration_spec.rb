require 'rails_helper'

RSpec.describe Whois::Regeneration, db: true do
  let(:service) { described_class.new(domain_name: domain_name) }
  let(:domain) { build_stubbed(:domain) }
  let(:domain_name) { instance_spy(DNS::DomainName, name: 'test.com', registered_domain: domain) }

  describe '#regenerate' do
    context 'when domain name is registered' do
      before :example do
        allow(domain_name).to receive(:registered?).and_return(true)
      end

      it 'creates whois record' do
        expect { service.regenerate }.to change { Whois::Record.count }.from(0).to(1)
      end
    end

    context 'when domain name is reserved' do
      before :example do
        allow(domain_name).to receive(:reserved?).and_return(true)
      end

      it 'creates whois record' do
        expect { service.regenerate }.to change { Whois::Record.count }.from(0).to(1)
      end
    end

    context 'when domain name is disputed' do
      before :example do
        allow(domain_name).to receive(:disputed?).and_return(true)
      end

      it 'creates whois record' do
        expect { service.regenerate }.to change { Whois::Record.count }.from(0).to(1)
      end
    end

    context 'when domain name is blocked' do
      before :example do
        allow(domain_name).to receive(:blocked?).and_return(true)
      end

      it 'creates whois record' do
        expect { service.regenerate }.to change { Whois::Record.count }.from(0).to(1)
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
        expect { service.regenerate }.to change { Whois::Record.count }.from(1).to(0)
      end
    end
  end
end
