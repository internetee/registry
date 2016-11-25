require 'rails_helper'

RSpec.describe RegistrarPresenter do
  let(:registrar) { instance_double(Registrar) }
  let(:presenter) { described_class.new(registrar: registrar, view: view) }

  describe '#name' do
    it 'returns name' do
      expect(registrar).to receive(:name).and_return('test name')
      expect(presenter.name).to eq('test name')
    end
  end

  describe '#email' do
    it 'returns email' do
      expect(registrar).to receive(:email).and_return('test email')
      expect(presenter.email).to eq('test email')
    end
  end

  describe '#phone' do
    it 'returns phone' do
      expect(registrar).to receive(:phone).and_return('test phone')
      expect(presenter.phone).to eq('test phone')
    end
  end

  describe '#url' do
    it 'returns url' do
      expect(registrar).to receive(:url).and_return('test url')
      expect(presenter.url).to eq('test url')
    end
  end
end
