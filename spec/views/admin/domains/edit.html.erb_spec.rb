require 'rails_helper'

RSpec.describe 'admin/domains/edit' do
  let(:domain) { build_stubbed(:domain) }
  let(:domain_presenter) { DomainPresenter.new(domain: domain, view: view) }

  before :example do
    allow(DomainPresenter).to receive(:new).and_return(domain_presenter)

    without_partial_double_verification do
      allow(view).to receive(:force_delete_templates)
    end

    assign(:domain, domain)

    stub_template '_form.html.erb' => ''
    stub_template '_force_delete_dialog.html.erb' => ''
  end

  it 'has force_delete_toggle_btn' do
    expect(domain_presenter).to receive(:force_delete_toggle_btn).and_return('force_delete_toggle_btn')
    render
    expect(rendered).to have_content('force_delete_toggle_btn')
  end
end
