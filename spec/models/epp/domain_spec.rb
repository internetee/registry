require 'rails_helper'

RSpec.describe Epp::Domain, db: false do
  describe '::new_from_epp' do
    let(:frame) do
      frame = Object.new

      def frame.css(selector)
        OpenStruct.new(text: nil)
      end

      frame
    end
    let(:domain_blueprint) { described_class.new }
    subject(:domain) { described_class.new_from_epp(frame, nil) }

    before :example do
      travel_to Time.zone.parse('05.07.2010')

      domain_blueprint.period = 1
      domain_blueprint.period_unit = 'y'

      expect(described_class).to receive(:new).and_return(domain_blueprint)
      expect(domain_blueprint).to receive(:attrs_from).and_return({})
      expect(domain_blueprint).to receive(:attach_default_contacts)
    end

    describe 'domain' do
      it 'has :registered_at set to now' do
        expect(domain.registered_at).to eq(Time.zone.parse('05.07.2010'))
      end

      it 'has :valid_from set to now' do
        expect(domain.valid_from).to eq(Time.zone.parse('05.07.2010'))
      end

      it 'has :valid_to set to the beginning of next day after :valid_from' do
        expect(domain.valid_to).to eq(Time.zone.parse('06.07.2011 00:00'))
      end
    end
  end

  describe '#apply_pending_update!' do
    let(:domain) { described_class.new(name: 'test.com') }

    before :example do
      allow(ApiUser).to receive(:find).and_return(instance_spy(ApiUser, registrar: nil))
      allow(domain).to receive(:update).and_return(true)
      allow(domain).to receive(:clean_pendings!)
      allow(domain).to receive(:save!)
    end

    it 'updates whois' do
      expect(DNS::DomainName).to receive(:update_whois).with(domain_name: 'test.com')
      domain.apply_pending_update!
    end
  end
end
