require 'rails_helper'

RSpec.describe RegistrantPresenter do
  let(:registrant) { instance_double(Registrant) }
  let(:presenter) { described_class.new(registrant: registrant, view: view) }

  describe '#name' do
    it 'returns name' do
      expect(registrant).to receive(:name).and_return('test name')
      expect(presenter.name).to eq('test name')
    end
  end

  describe '#ident' do
    it 'returns ident' do
      expect(registrant).to receive(:ident).and_return('test ident')
      expect(presenter.ident).to eq('test ident')
    end
  end

  describe '#email' do
    it 'returns email' do
      expect(registrant).to receive(:email).and_return('test email')
      expect(presenter.email).to eq('test email')
    end
  end

  describe '#priv?' do
    it 'delegates to registrant' do
      expect(registrant).to receive(:priv?).and_return('test')
      expect(presenter.priv?).to eq('test')
    end
  end
end
