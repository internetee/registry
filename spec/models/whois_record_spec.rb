require 'rails_helper'

RSpec.describe WhoisRecord do
  describe '::generate_json', db: false do
    let(:registrant) { build_stubbed(:registrant) }
    let(:domain) { build_stubbed(:domain, registrant: registrant) }
    let(:whois_record) { described_class.new }
    subject(:generated_json) { whois_record.generate_json }

    before do
      allow(whois_record).to receive(:domain).and_return(domain)
    end

    it 'generates registrant kind' do
      expect(registrant).to receive(:kind).and_return('test kind')
      expect(generated_json[:registrant_kind]).to eq('test kind')
    end

    describe 'reg no' do
      subject(:reg_no) { generated_json[:registrant_reg_no] }

      before do
        allow(registrant).to receive(:reg_no).and_return('test reg no')
      end

      context 'when registrant is legal entity' do
        let(:registrant) { build_stubbed(:registrant_legal_entity) }

        it 'is present' do
          expect(reg_no).to eq('test reg no')
        end
      end

      context 'when registrant is private entity' do
        let(:registrant) { build_stubbed(:registrant_private_entity) }

        it 'is absent' do
          expect(reg_no).to be_nil
        end
      end
    end

    describe 'country code' do
      subject(:country_code) { generated_json[:registrant_ident_country_code] }

      before do
        allow(registrant).to receive(:ident_country_code).and_return('test country code')
      end

      context 'when registrant is legal entity' do
        let(:registrant) { build_stubbed(:registrant_legal_entity) }

        it 'is present' do
          expect(country_code).to eq('test country code')
        end
      end

      context 'when registrant is private entity' do
        let(:registrant) { build_stubbed(:registrant_private_entity) }

        it 'is absent' do
          expect(country_code).to be_nil
        end
      end
    end
  end
end
