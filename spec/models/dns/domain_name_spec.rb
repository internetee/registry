require 'rails_helper'

RSpec.describe DNS::DomainName, db: false do
  describe '#available?' do
    subject(:domain_name) { described_class.new('test.com') }

    context 'when domain is absent' do
      specify { expect(domain_name).to be_available }
    end

    context 'when domain is present', db: true do
      let!(:domain) { create(:domain, name: 'test.com') }
      specify { expect(domain_name).to_not be_available }
    end
  end

  describe '#registered?' do
    subject(:domain_name) { described_class.new('test.com') }

    context 'when not available' do
      before :example do
        allow(domain_name).to receive(:available?).and_return(false)
      end

      specify { expect(domain_name).to be_registered }
    end

    context 'when available' do
      before :example do
        allow(domain_name).to receive(:available?).and_return(true)
      end

      specify { expect(domain_name).to_not be_registered }
    end
  end
end
