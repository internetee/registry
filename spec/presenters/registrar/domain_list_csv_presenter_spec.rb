require 'rails_helper'

RSpec.describe Registrar::DomainListCSVPresenter do
  let(:domain) { instance_spy(DomainPresenter) }
  let(:csv) { CSV.parse(described_class.new(domains: [domain], view: view).to_s, converters: :all) }

  describe 'header' do
    subject(:header) { csv.first }

    it 'is present' do
      columns = []
      columns[0] = 'Domain'
      columns[1] = 'Registrant name'
      columns[2] = 'Registrant code'
      columns[3] = 'Date of expiry'
      columns

      expect(header).to eq(columns)
    end
  end

  describe 'row' do
    subject(:row) { csv.second }

    it 'has domain name' do
      expect(domain).to receive(:name).and_return('test name')
      expect(row[0]).to eq('test name')
    end

    it 'has registrant name' do
      expect(domain).to receive(:registrant_name).and_return('test registrant name')
      expect(row[1]).to eq('test registrant name')
    end

    it 'has registrant code' do
      expect(domain).to receive(:registrant_code).and_return('test registrant code')
      expect(row[2]).to eq('test registrant code')
    end

    it 'has expire date' do
      expect(domain).to receive(:expire_date).and_return('expire date')
      expect(row[3]).to eq('expire date')
    end
  end
end
