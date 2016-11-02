require 'rails_helper'

RSpec.describe Epp::Domain, db: false do
  describe '::new_from_epp' do
    let(:domain_blueprint) { described_class.new }
    subject(:domain) { described_class.new_from_epp(nil, nil) }

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

      it 'has :expire_time set to now' do
        expire_time = Time.zone.parse('05.07.2010') + 1.year + 1.day
        expect(domain.expire_time).to eq(expire_time)
      end
    end
  end
end
