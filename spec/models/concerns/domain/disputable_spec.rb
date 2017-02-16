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

  describe '#close_dispute' do
    let(:domain) { create(:domain, name: 'test.com') }
    let(:dispute) { instance_double(Dispute) }

    it 'delegates to dispute' do
      expect(Dispute).to receive(:for_domain).and_return(dispute)
      expect(dispute).to receive(:close)
      domain.close_dispute
    end
  end
end
