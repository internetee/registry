require 'rails_helper'

RSpec.describe 'admin/disputes/_form' do
  let(:dispute) { build_stubbed(:dispute) }

  before :example do
    without_partial_double_verification do
      allow(view).to receive(:dispute).and_return(dispute)
    end
    stub_template '_form_errors.html.erb' => ''
  end

  describe 'domain name' do
    let(:field) { page.find('[name="dispute[domain_name]"]') }

    it 'is focused' do
      render
      expect(field[:autofocus]).to eq('autofocus')
    end

    it 'is required' do
      render
      expect(field[:required]).to eq('required')
    end

    context 'when dispute is new' do
      let(:dispute) { Dispute.new }

      it 'is enabled' do
        render
        expect(field[:disabled]).to be_nil
      end
    end

    context 'when dispute is persisted' do
      let(:dispute) { build_stubbed(:dispute) }

      it 'is disabled' do
        render
        expect(field[:disabled]).to eq('disabled')
      end
    end
  end

  describe 'expire date' do
    let(:field) { page.find('[name="dispute[expire_date]"]') }

    it 'is required' do
      render
      expect(field[:required]).to eq('required')
    end
  end

  describe 'comment' do
    let(:field) { page.find('[name="dispute[comment]"]') }

    it 'is required' do
      render
      expect(field[:required]).to eq('required')
    end
  end
end
