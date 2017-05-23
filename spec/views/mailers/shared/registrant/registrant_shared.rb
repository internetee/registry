require 'rails_helper'

RSpec.shared_examples 'domain mailer registrant info' do
  let(:registrant) { instance_spy(RegistrantPresenter) }

  before :example do
    without_partial_double_verification do
      allow(view).to receive(:registrant).and_return(registrant)
    end
  end

  attributes = %i(
    name
    ident
    street
    city
    country
  )

  attributes.each do |attr_name|
    it "has #{attr_name}" do
      expect(registrant).to receive(attr_name).and_return("test #{attr_name}")
      render
      expect(rendered).to have_text("test #{attr_name}")
    end
  end
end
