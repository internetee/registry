require 'rails_helper'

RSpec.describe 'mailers/domain_mailer/_registrar.et.text.erb' do
  let(:registrar) { instance_spy(RegistrarPresenter) }

  before :example do
    allow(view).to receive(:registrar).and_return(registrar)
  end

  attributes = %i(
    name
    email
    phone
    url
  )

  attributes.each do |attr_name|
    it "has #{attr_name}" do
      expect(registrar).to receive(attr_name).and_return("test #{attr_name}")
      render
      expect(rendered).to have_text("test #{attr_name}")
    end
  end
end
