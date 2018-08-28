require 'rails_helper'

RSpec.describe DomainPresenter do
  let(:presenter) { described_class.new(domain: domain, view: view) }

  describe '#expire_time' do
    let(:domain) { instance_double(Domain, expire_time: Time.zone.parse('05.07.2010')) }

    it 'returns localized time' do
      expect(view).to receive(:l).with(Time.zone.parse('05.07.2010')).and_return('expire time')
      expect(presenter.expire_time).to eq('expire time')
    end
  end

  describe '#expire_date' do
    let(:domain) { instance_double(Domain, expire_time: Time.zone.parse('05.07.2010')) }

    it 'returns localized date' do
      expect(view).to receive(:l).with(Time.zone.parse('05.07.2010'), format: :date).and_return('expire date')
      expect(presenter.expire_date).to eq('expire date')
    end
  end

  describe '#on_hold_date' do
    subject(:on_hold_date) { presenter.on_hold_date }

    context 'when present' do
      let(:domain) { instance_double(Domain, on_hold_time: '05.07.2010') }

      it 'returns localized date' do
        expect(view).to receive(:l).with('05.07.2010', format: :date).and_return('on hold date')
        expect(on_hold_date).to eq('on hold date')
      end
    end

    context 'when absent' do
      let(:domain) { instance_double(Domain, on_hold_time: nil) }

      specify { expect(on_hold_date).to be_nil }
    end
  end

  describe '#delete_date' do
    subject(:delete_date) { presenter.delete_date }

    context 'when present' do
      let(:domain) { instance_double(Domain, delete_at: '05.07.2010') }

      it 'returns localized date' do
        expect(view).to receive(:l).with('05.07.2010', format: :date).and_return('delete date')
        expect(delete_date).to eq('delete date')
      end
    end

    context 'when absent' do
      let(:domain) { instance_double(Domain, delete_at: nil) }

      specify { expect(delete_date).to be_nil }
    end
  end

  describe '#force_delete_date' do
    subject(:force_delete_date) { presenter.force_delete_date }

    context 'when present' do
      let(:domain) { instance_double(Domain, force_delete_at: '05.07.2010') }

      it 'returns localized date' do
        expect(view).to receive(:l).with('05.07.2010', format: :date).and_return('delete date')
        expect(force_delete_date).to eq('delete date')
      end
    end

    context 'when absent' do
      let(:domain) { instance_double(Domain, force_delete_at: nil) }

      specify { expect(force_delete_date).to be_nil }
    end
  end

  describe '#admin_contact_names' do
    let(:domain) { instance_double(Domain) }

    before :example do
      expect(domain).to receive(:admin_contact_names).and_return(%w(test1 test2 test3))
    end

    it 'returns admin contact names' do
      expect(presenter.admin_contact_names).to eq('test1, test2, test3')
    end
  end

  describe '#tech_contact_names' do
    let(:domain) { instance_double(Domain) }

    before :example do
      expect(domain).to receive(:tech_contact_names).and_return(%w(test1 test2 test3))
    end

    it 'returns technical contact names' do
      expect(presenter.tech_contact_names).to eq('test1, test2, test3')
    end
  end

  describe '#nameserver_names' do
    let(:domain) { instance_double(Domain) }

    before :example do
      expect(domain).to receive(:nameserver_hostnames).and_return(%w(test1 test2 test3))
    end

    it 'returns nameserver names' do
      expect(presenter.nameserver_names).to eq('test1, test2, test3')
    end
  end

  domain_delegatable_attributes = %i(
    name
    transfer_code
    registrant_name
    registrant_id
    registrant_code
  )

  domain_delegatable_attributes.each do |attribute_name|
    describe "##{attribute_name}" do
      let(:domain) { instance_spy(Domain) }

      it 'delegates to domain' do
        presenter.send(attribute_name)
        expect(domain).to have_received(attribute_name)
      end
    end
  end
end
