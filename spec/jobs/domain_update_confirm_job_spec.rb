require 'rails_helper'

RSpec.describe DomainUpdateConfirmJob do
  let(:domain) { instance_spy(Epp::Domain, registrant: registrant, errors: []) }
  let(:registrant) { instance_double(Registrant) }
  let(:registrant_change) { instance_spy(RegistrantChange) }

  it 'confirms registrant change' do
    expect(Epp::Domain).to receive(:find).and_return(domain)
    expect(RegistrantChange).to receive(:new)
                                    .with(domain: domain, old_registrant: registrant)
                                    .and_return(registrant_change)

    described_class.enqueue(domain_id = nil, action = RegistrantVerification::CONFIRMED)

    expect(registrant_change).to have_received(:confirm)
  end
end
