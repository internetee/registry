require 'rails_helper'

RSpec.describe RegistrantPresenter do
  let(:registrant) { instance_double(Registrant) }
  let(:presenter) { described_class.new(registrant: registrant, view: view) }

  describe '#country' do
    let(:country) { instance_double(Country) }

    before :example do
      allow(registrant).to receive(:country).and_return(country)
    end

    it 'returns country name in current locale by default' do
      expect(country).to receive(:translation).with(I18n.locale).and_return('test country')
      expect(presenter.country).to eq('test country')
    end

    it 'returns country name in given locale' do
      expect(country).to receive(:translation).with(:de).and_return('test country')
      expect(presenter.country(locale: :de)).to eq('test country')
    end
  end

  describe '#ident_country' do
    let(:ident_country) { instance_double(Country) }

    before :example do
      allow(registrant).to receive(:ident_country).and_return(ident_country)
    end

    it 'returns country name in current locale by default' do
      expect(ident_country).to receive(:translation).with(I18n.locale).and_return('test country')
      expect(presenter.ident_country).to eq('test country')
    end

    it 'returns country name in given locale' do
      expect(ident_country).to receive(:translation).with(:de).and_return('test country')
      expect(presenter.ident_country(locale: :de)).to eq('test country')
    end
  end

  registrant_delegatable_attributes = %i(
    name
    ident
    email
    priv?
    street
    city
    state
    zip
    id_code
    reg_no
  )

  registrant_delegatable_attributes.each do |attr_name|
    describe "##{attr_name}" do
      it 'delegates to registrant' do
        expect(registrant).to receive(attr_name).and_return('test')
        expect(presenter.send(attr_name)).to eq('test')
      end
    end
  end
end
