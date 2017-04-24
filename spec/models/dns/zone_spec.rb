require 'rails_helper'

RSpec.describe DNS::Zone do
  describe '::origins' do
    before :example do
      expect(described_class).to receive(:pluck).with(:origin).and_return('origins')
    end

    it 'returns origins' do
      expect(described_class.origins).to eq('origins')
    end
  end

  describe 'validation' do
    let(:zone) { described_class.new }

    required_attributes = %i[
      origin
      ttl
      refresh
      retry
      expire
      minimum_ttl
      email
      master_nameserver
    ]

    required_attributes.each do |attr_name|
      it "rejects absent #{attr_name}", db: false do
        zone.send("#{attr_name}=", nil)
        zone.validate
        expect(zone.errors).to have_key(attr_name)
      end
    end

    integer_attributes = %i[
      ttl
      refresh
      retry
      expire
      minimum_ttl
    ]

    integer_attributes.each do |attr_name|
      it "rejects non-integer #{attr_name}", db: false do
        zone.send("#{attr_name}=", 'test')
        zone.validate
        expect(zone.errors).to have_key(attr_name)
      end

      it "accepts integer #{attr_name}", db: false do
        zone.send("#{attr_name}=", '1')
        zone.validate
        expect(zone.errors).to_not have_key(attr_name)
      end
    end
  end

  describe '#used?', db: false do
    let!(:zone) { described_class.new }

    context 'when domain uses zone' do
      before :example do
        allow(Domain).to receive(:uses_zone?).and_return(true)
      end

      specify { expect(zone).to be_used }
    end

    context 'when domain does not use zone' do
      before :example do
        allow(Domain).to receive(:uses_zone?).and_return(false)
      end

      specify { expect(zone).to_not be_used }
    end
  end

  describe 'deletion', settings: false do
    let!(:zone) { create(:zone) }

    context 'when zone is unused' do
      before :example do
        allow(zone).to receive(:used?).and_return(false)
      end

      it 'is allowed' do
        expect { zone.destroy }.to change { described_class.count }.from(1).to(0)
      end
    end

    context 'when zone is used' do
      before :example do
        allow(zone).to receive(:used?).and_return(true)
      end

      it 'is disallowed' do
        expect { zone.destroy }.to_not change { described_class.count }
      end
    end
  end
end
