require 'rails_helper'

RSpec.describe Domain do
  describe '#disputed?' do
    let(:domain) { create(:domain, name: 'test.com') }

    context 'when dispute is absent' do
      specify { expect(domain).to_not be_disputed }
    end

    context 'when dispute is present' do
      let!(:dispute) { create(:dispute, domain_name: 'test.com') }

      specify { expect(domain).to be_disputed }
    end
  end
end
