require 'rails_helper'

module RequiredAddressFieldsHelper
  def define_field_examples(attr_name)
    describe "#{attr_name} field" do
      let(:field) { page.find("[name='depp_contact[#{attr_name}]']") }

      context 'when address processing is enabled' do
        before do
          allow(view).to receive(:address_processing?).and_return(true)
        end

        it 'is required' do
          render
          expect(field[:required]).to eq('required')
        end
      end

      context 'when address processing is disabled' do
        before do
          allow(view).to receive(:address_processing?).and_return(false)
        end

        it 'is optional' do
          render
          expect(field[:required]).to be_nil
        end
      end
    end
  end
end

RSpec.describe 'registrar/contacts/form_partials/_address' do
  extend RequiredAddressFieldsHelper
  let(:contact) { instance_spy(Depp::Contact) }

  before do
    allow(view).to receive(:f).and_return(ActionView::Helpers::FormBuilder.new(:depp_contact, contact, view, {}))
  end

  required_address_attributes = %i(
    street
    city
    zip
    country_code
  )

  required_address_attributes.each do |attr_name|
    define_field_examples(attr_name)
  end
end
