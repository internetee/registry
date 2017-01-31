require 'rails_helper'

RSpec.describe RegistrantPresenter do
  let(:registrant) { instance_double(Registrant) }
  let(:presenter) { described_class.new(registrant: registrant, view: view) }

  registrant_delegate_attributes = %i(
    name
    ident
    email
    priv?
    street
    city
    id_code
  )

  registrant_delegate_attributes.each do |attribute_name|
    describe "##{attribute_name}" do
      it 'delegetes to registrant' do
        expect(registrant).to receive(attribute_name).and_return('test')
        expect(presenter.send(attribute_name)).to eq('test')
      end
    end
  end

  describe '#country' do
    it 'returns country name' do
      expect(presenter.country).to be_nil
    end
  end
end
