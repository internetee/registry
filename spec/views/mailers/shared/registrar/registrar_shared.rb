require 'rails_helper'

RSpec.shared_examples 'domain mailer registrar info' do
  let(:registrar) { instance_spy(RegistrarPresenter) }

  before :example do
    without_partial_double_verification do
      allow(view).to receive(:registrar).and_return(registrar)
    end
  end

  attributes = %i(
    name
    email
    phone
    website
  )

  attributes.each do |attr_name|
    it "has #{attr_name}" do
      expect(registrar).to receive(attr_name).and_return("test #{attr_name}")
      render
      expect(rendered).to have_text("test #{attr_name}")
    end
  end
end
