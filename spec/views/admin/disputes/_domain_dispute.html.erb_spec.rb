require 'rails_helper'

RSpec.describe 'admin/disputes/_domain_dispute' do
  let(:dispute) { instance_spy(DisputePresenter) }

  before :example do
    allow(view).to receive(:dispute).and_return(dispute)
  end

  context 'when domain is disputed' do
    before :example do
      allow(view).to receive(:disputed).and_return(true)
    end

    it 'shows expiration date' do
      expect(dispute).to receive(:expire_date).and_return('test expire date')
      render
      expect(rendered).to have_text('test expire date')
    end

    it 'shows link' do
      expect(dispute).to receive(:link_from_domain).and_return('test link')
      render
      expect(rendered).to have_text('test link')
    end
  end

  context 'when domain is not disputed' do
    before :example do
      allow(view).to receive(:disputed).and_return(false)
    end

    it 'shows text' do
      render
      expect(rendered).to have_text('No dispute')
    end
  end
end
