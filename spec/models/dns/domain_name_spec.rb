require 'rails_helper'

RSpec.describe DNS::DomainName, db: false do
  describe '::update_whois' do
    let(:domain_name) { instance_double(described_class) }

    before :example do
      allow(described_class).to receive(:new).with('test.com').and_return(domain_name)
    end

    it 'creates new object and updates whois' do
      expect(domain_name).to receive(:update_whois)
      described_class.update_whois(domain_name: 'test.com')
    end
  end

  describe '#name' do
    subject(:domain_name) { described_class.new('test.com') }

    it 'returns domain name' do
      expect(domain_name.name).to eq('test.com')
    end
  end

  describe '#available?' do
    subject(:domain_name) { described_class.new('test.com') }

    context 'when not registered' do
      specify { expect(domain_name).to be_available }
    end

    context 'when registered', db: true do
      let!(:registered_domain) { create(:domain, name: 'test.com') }
      specify { expect(domain_name).to_not be_available }
    end
  end

  describe '#registered?' do
    subject(:domain_name) { described_class.new('test.com') }

    context 'when not available', db: true do
      let!(:registered_domain) { create(:domain, name: 'test.com') }
      specify { expect(domain_name).to be_registered }
    end

    context 'when available' do
      specify { expect(domain_name).to_not be_registered }
    end
  end

  describe '#reserved?' do
    subject(:domain_name) { described_class.new('test.com') }

    context 'when reserved domain exists', db: true do
      let!(:reserved_domain) { create(:reserved_domain, name: 'test.com') }
      specify { expect(domain_name).to be_reserved }
    end

    context 'when reserved domain does not exist' do
      specify { expect(domain_name).to_not be_reserved }
    end
  end

  describe '#disputed?' do
    subject(:domain_name) { described_class.new('test.com') }

    context 'when dispute exists', db: true do
      let!(:dispute) { create(:dispute, domain_name: 'test.com') }

      specify { expect(domain_name).to be_disputed }
    end

    context 'when dispute does not exist' do
      specify { expect(domain_name).to_not be_disputed }
    end
  end

  describe '#blocked?' do
    subject(:domain_name) { described_class.new('test.com') }

    context 'when blocked domain exists', db: true do
      let!(:blocked_domain) { create(:blocked_domain, name: 'test.com') }

      specify { expect(domain_name).to be_blocked }
    end

    context 'when blocked domain does not exist' do
      specify { expect(domain_name).to_not be_blocked }
    end
  end

  describe '#update_whois' do
    subject(:domain_name) { described_class.new('test.com') }

    it 'delegates to Whois::Record' do
      expect(Whois::Record).to receive(:regenerate).with(domain_name: domain_name)
      domain_name.update_whois
    end
  end

  describe '#registered_domain' do
    subject(:domain_name) { described_class.new('test.com') }

    context 'when registered domain exists', db: true do
      let!(:registered_domain) { create(:domain, name: 'test.com') }

      it 'returns registered domain' do
        expect(domain_name.registered_domain).to eq(registered_domain)
      end
    end

    context 'when registered domain does not exist' do
      specify { expect(domain_name.registered_domain).to be_nil }
    end
  end
end
