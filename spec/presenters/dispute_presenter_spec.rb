require 'rails_helper'

RSpec.describe DisputePresenter do
  let(:dispute) { instance_spy(Dispute) }
  let(:presenter) { described_class.new(dispute: dispute, view: view) }

  describe '#name' do
    it 'returns domain name' do
      expect(dispute).to receive(:domain_name).and_return('test')
      expect(presenter.name).to eq('test')
    end
  end

  describe '#expire_date' do
    it 'returns localized :expire_date' do
      expect(dispute).to receive(:expire_date).and_return(Date.parse('05.07.2010'))
      expect(presenter.expire_date).to eq(l(Date.parse('05.07.2010')))
    end
  end

  describe '#create_time' do
    it 'returns localized :create_time' do
      expect(dispute).to receive(:create_time).and_return(Time.zone.parse('05.07.2010'))
      expect(presenter.create_time).to eq(l(Time.zone.parse('05.07.2010')))
    end
  end
end
