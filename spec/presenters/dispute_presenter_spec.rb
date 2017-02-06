require 'rails_helper'

RSpec.describe DisputePresenter do
  let(:dispute) { instance_double(Dispute) }
  let(:presenter) { described_class.new(dispute: dispute, view: view) }

  describe '#name' do
    it 'returns domain name' do
      expect(dispute).to receive(:domain_name).and_return('test')
      expect(presenter.name).to eq('test')
    end
  end
end
