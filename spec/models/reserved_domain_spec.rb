require 'rails_helper'

RSpec.describe ReservedDomain do
  describe '#updatable?' do
    let(:reserved_domain) { described_class.new(name: 'test.com') }

    context 'when domain name is not disputed' do
      specify { expect(reserved_domain).to be_updatable }
    end

    context 'when domain name is disputed' do
      before :example do
        create(:dispute, domain_name: 'test.com')
      end

      specify { expect(reserved_domain).to_not be_updatable }
    end
  end
end
