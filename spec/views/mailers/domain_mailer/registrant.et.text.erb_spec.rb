require 'rails_helper'

RSpec.describe 'mailers/domain_mailer/_registrant.et.text.erb' do
  let(:registrant) { instance_spy(RegistrantPresenter) }

  before :example do
    allow(view).to receive(:registrant).and_return(registrant)
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
