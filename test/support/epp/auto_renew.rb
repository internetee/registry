module EppAutoRenewSupport
  AUTO_RENEW_URI = 'https://epp.tld.ee/schema/autoRenew-ee-1.0.xsd'.freeze
  RGP_URI = 'urn:ietf:params:xml:ns:rgp-1.0'.freeze

  def auto_renew_extension(command, children)
    "<autoRenew:#{command} xmlns:autoRenew=\"#{AUTO_RENEW_URI}\">#{children}</autoRenew:#{command}>"
  end

  def auto_renew_command(command, body, extension = nil)
    <<~XML
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <#{command}>
            <domain:#{command} xmlns:domain="https://epp.tld.ee/schema/domain-ee-1.2.xsd">
              #{body}
            </domain:#{command}>
          </#{command}>
          #{"<extension>#{extension}</extension>" if extension.present?}
        </command>
      </epp>
    XML
  end

  def auto_renew_cycle(domain, state: DomainAutoRenewal::GRACE, charge: false, **attributes)
    original = Time.zone.now.beginning_of_day - 1.day
    renewed = original.advance(years: 1)
    domain.update_columns(auto_renew: true, valid_to: state == DomainAutoRenewal::AWAITING_FUNDS ? original : renewed)
    activity = if charge
                 domain.registrar.cash_account.account_activities.create!(
                   sum: -12, currency: 'EUR', activity_type: AccountActivity::RENEW,
                   description: "Automatic renewal #{domain.name}"
                 )
               end
    DomainAutoRenewal.create!({
      domain: domain, domain_name: domain.name, registrar: domain.registrar,
      account: domain.registrar.cash_account, state: state,
      original_expire_at: original, renewed_expire_at: renewed,
      cancellation_deadline_at: original.advance(days: 15),
      attempts_count: 1, charge_activity: activity,
    }.merge(attributes))
  end
end
