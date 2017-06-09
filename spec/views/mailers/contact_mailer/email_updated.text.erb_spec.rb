require 'rails_helper'

RSpec.describe 'mailers/contact_mailer/email_updated.text.erb' do
  let(:contact) { instance_spy(Contact) }
  let(:contact_presenter) { instance_spy(RegistrantPresenter) }
  let(:registrar_presenter) { instance_spy(RegistrarPresenter) }

  before :example do
    allow(RegistrantPresenter).to receive(:new).and_return(contact_presenter)
    allow(RegistrarPresenter).to receive(:new).and_return(registrar_presenter)

    assign(:contact, contact)
    assign(:old_email, 'test@test.com')

    stub_template 'mailers/shared/registrant/_registrant.et.text' => ''
    stub_template 'mailers/shared/registrant/_registrant.en.text' => ''
    stub_template 'mailers/shared/registrar/_registrar.et.text' => ''
    stub_template 'mailers/shared/registrar/_registrar.en.text' => ''
  end

  it 'has affected domain list in estonian' do
    expect(contact_presenter).to receive(:domain_names_with_roles).with(locale: :et).and_return('test domain list et')
    render
    expect(rendered).to have_text('test domain list et')
  end

  it 'has affected domain list in english' do
    expect(contact_presenter).to receive(:domain_names_with_roles).and_return('test domain list en')
    render
    expect(rendered).to have_text('test domain list en')
  end
end
