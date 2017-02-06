require 'rails_helper'

RSpec.describe 'admin/disputes/_form' do
  let(:dispute) { build_stubbed(:dispute) }

  before :example do
    allow(view).to receive(:dispute).and_return(dispute)
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
