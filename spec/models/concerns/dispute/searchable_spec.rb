require 'rails_helper'

RSpec.describe Dispute, db: true do
  describe '::by_domain_name' do
    before :example do
      create(:dispute, domain_name: 'another.com')
      create(:dispute, domain_name: 'example-test.com')
      create(:dispute, domain_name: 'some-another.com')
    end

    context 'if input is present' do
      it 'returns matched records' do
        expect(described_class.by_domain_name('test').count).to eq(1)
      end
    end

    context 'if input is absent' do
      it 'returns all records' do
        expect(described_class.by_domain_name(nil).count).to eq(3)
      end
    end
  end

  describe '::by_expire_date' do
    before :example do
      create(:dispute, expire_date: Date.parse('04.07.2010'))
      create(:dispute, expire_date: Date.parse('05.07.2010'))
      create(:dispute, expire_date: Date.parse('06.07.2010'))
      create(:dispute, expire_date: Date.parse('07.07.2010'))
    end

    context 'if input is present' do
      it 'returns matched records' do
        date = Date.parse('05.07.2010')..Date.parse('06.07.2010')
        expect(described_class.by_expire_date(date).count).to eq(2)
      end
    end

    context 'if input is absent' do
      it 'returns all records' do
        expect(described_class.by_expire_date(nil).count).to eq(4)
      end
    end
  end
end
