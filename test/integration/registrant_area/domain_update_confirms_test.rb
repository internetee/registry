require 'test_helper'

class RegistrantAreaDomainUpdateConfirmsIntegrationTest < ApplicationIntegrationTest

    setup do
        @domain = domains(:shop)
      end

      def test_show_confirm_to_update_domain
        @domain.update!(registrant_verification_asked_at: Time.zone.now,
                        registrant_verification_token: 'test',
                        statuses: [DomainStatus::PENDING_UPDATE])
    
        get registrant_domain_update_confirm_path(@domain, token: 'test', confirmed: true)
        
        assert @domain.registrant_update_confirmable?('test')
      end
end
