require 'rails_helper'

RSpec.describe DisputePresenter do
  let(:dispute) { instance_spy(Dispute) }
  let(:presenter) { described_class.new(dispute: dispute, view: view) }

  describe '#name' do
    it 'returns dispute id with domain name' do
      expect(dispute).to receive(:id).and_return(1)
      expect(dispute).to receive(:domain_name).and_return('test.com')
      expect(presenter.name).to eq('#1 (test.com)')
    end
  end

  describe '#expire_date' do
    it 'returns localized expiration date' do
      expect(dispute).to receive(:expire_date).and_return(Date.parse('05.07.2010'))
      expect(presenter.expire_date).to eq(l(Date.parse('05.07.2010')))
    end
  end

  describe '#create_time' do
    it 'returns localized creation time ' do
      expect(dispute).to receive(:create_time).and_return(Time.zone.parse('05.07.2010'))
      expect(presenter.create_time).to eq(l(Time.zone.parse('05.07.2010')))
    end
  end

  describe '#update_time' do
    it 'returns localized last modification time' do
      expect(dispute).to receive(:update_time).and_return(Time.zone.parse('05.07.2010'))
      expect(presenter.update_time).to eq(l(Time.zone.parse('05.07.2010')))
    end
  end

  dispute_delegatable_attributes = %i(
    password
  )

  dispute_delegatable_attributes.each do |attribute_name|
    describe "##{attribute_name}" do
      let(:dispute) { instance_spy(Dispute) }

      it 'delegates to dispute' do
        presenter.send(attribute_name)
        expect(dispute).to have_received(attribute_name)
      end
    end
  end
end
