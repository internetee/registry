require 'active_model'
require 'lib/validators/iso31661_alpha2'
require 'lib/validators/iso8601'

RSpec.describe Contact::Ident, db: false do
  let(:ident) { described_class.new }

  describe 'country code' do
    it_behaves_like 'iso31661_alpha2' do
      let(:model) { ident }
      let(:attribute) { :country_code }
    end
  end

  describe 'code validation' do
    it 'rejects absent' do
      ident.code = nil
      ident.validate
      expect(ident.errors).to be_added(:code, :blank)
    end

    context 'when type is :birthday' do
      let(:ident) { described_class.new(type: 'birthday') }

      it_behaves_like 'iso8601' do
        let(:model) { ident }
        let(:attribute) { :code }
      end
    end

    context 'when type is not :birthday' do
      let(:ident) { described_class.new(type: 'priv') }

      it 'accepts any' do
        ident.code = '%123456789%'
        ident.validate
        expect(ident.errors).to_not include(:code)
      end
    end

    context 'when country code is EE' do
      context 'when type is :priv' do
        let(:ident) { described_class.new(country_code: 'EE', type: 'priv') }

        it 'rejects invalid' do
          ident.code = 'invalid'
          ident.validate
          expect(ident.errors).to be_added(:code, :invalid_national_id, country: 'Estonia')
        end

        it 'accepts valid' do
          ident.code = '47101010033'
          ident.validate
          expect(ident.errors).to_not be_added(:code, :invalid_national_id, country: 'Estonia')
        end
      end

      context 'when ident type is :org' do
        let(:ident) { described_class.new(country_code: 'EE', type: 'org') }

        it 'rejects invalid' do
          ident.code = '1' * 7
          ident.validate
          expect(ident.errors).to be_added(:code, :invalid_reg_no, country: 'Estonia')
        end

        it 'accepts valid length' do
          ident.code = '1' * 8
          ident.validate
          expect(ident.errors).to_not be_added(:code, :invalid_reg_no, country: 'Estonia')
        end
      end
    end

    context 'when ident country code is not EE' do
      let(:ident) { described_class.new(country_code: 'US') }

      it 'accepts any' do
        ident.code = 'test-123456789'
        ident.validate
        expect(ident.errors).to_not include(:code)
      end
    end

    it 'translates :invalid_national_id error message' do
      expect(ident.errors.generate_message(:code, :invalid_national_id, country: 'Germany'))
        .to eq('does not conform to national identification number format of Germany')
    end

    it 'translates :invalid_reg_no error message' do
      expect(ident.errors.generate_message(:code, :invalid_reg_no, country: 'Germany'))
        .to eq('does not conform to registration number format of Germany')
    end
  end

  describe 'type validation' do
    before do
      allow(described_class).to receive(:types).and_return(%w(valid))
    end

    it 'rejects absent' do
      ident.type = nil
      ident.validate
      expect(ident.errors).to be_added(:type, :blank)
    end

    it 'rejects invalid' do
      ident.type = 'invalid'
      ident.validate
      expect(ident.errors).to be_added(:type, :inclusion)
    end

    it 'accepts valid' do
      ident.type = 'valid'
      ident.validate
      expect(ident.errors).to_not be_added(:type, :inclusion)
    end
  end

  describe 'country code validation' do
    it 'rejects absent' do
      ident.country_code = nil
      ident.validate
      expect(ident.errors).to be_added(:country_code, :blank)
    end
  end

  describe 'mismatch validation' do
    let(:ident) { described_class.new(type: 'test', country_code: 'DE') }

    before do
      mismatches = [Contact::Ident::MismatchValidator::Mismatch.new('test', Country.new('DE'))]
      allow(Contact::Ident::MismatchValidator).to receive(:mismatches).and_return(mismatches)
    end

    it 'rejects mismatched' do
      ident.validate
      expect(ident.errors).to be_added(:base, :mismatch, type: 'test', country: 'Germany')
    end

    it 'accepts matched' do
      ident.validate
      expect(ident.errors).to_not be_added(:base, :mismatch, type: 'another-test', country: 'Germany')
    end

    it 'translates :mismatch error message' do
      expect(ident.errors.generate_message(:base, :mismatch, type: 'test', country: 'Germany'))
        .to eq('Ident type "test" is invalid for Germany')
    end
  end

  describe '::types' do
    it 'returns types' do
      types = %w[
        org
        priv
        birthday
      ]

      expect(described_class.types).to eq(types)
    end
  end

  describe '#birthday?' do
    context 'when type is birthday' do
      subject(:ident) { described_class.new(type: 'birthday') }
      it { is_expected.to be_birthday }
    end

    context 'when type is not birthday' do
      subject(:ident) { described_class.new(type: 'priv') }
      it { is_expected.to_not be_birthday }
    end
  end

  describe '#national_id?' do
    context 'when type is priv' do
      subject(:ident) { described_class.new(type: 'priv') }
      it { is_expected.to be_national_id }
    end

    context 'when type is not' do
      subject(:ident) { described_class.new(type: 'org') }
      it { is_expected.to_not be_national_id }
    end
  end

  describe '#reg_no?' do
    context 'when type is birthday' do
      subject(:ident) { described_class.new(type: 'org') }
      it { is_expected.to be_reg_no }
    end

    context 'when type is not birthday' do
      subject(:ident) { described_class.new(type: 'priv') }
      it { is_expected.to_not be_reg_no }
    end
  end

  describe '#country' do
    let(:ident) { described_class.new(country_code: 'US') }

    it 'returns country' do
      expect(ident.country).to eq(Country.new('US'))
    end
  end

  describe '#==' do
    let(:ident) { described_class.new(code: 'test', type: 'test', country_code: 'US') }

    context 'when code, type and country code are the same' do
      let(:another_ident) { described_class.new(code: 'test', type: 'test', country_code: 'US') }

      it 'returns true' do
        expect(ident).to eq(another_ident)
      end
    end

    context 'when code, type and country code are not the same' do
      let(:another_ident) { described_class.new(code: 'another-test', type: 'test', country_code: 'US') }

      it 'returns false' do
        expect(ident).to_not eq(another_ident)
      end
    end
  end
end
