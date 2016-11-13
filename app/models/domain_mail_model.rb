class DomainMailModel
  # Capture current values used in app/views/mailers/domain_mailer/* and app/mailers/domain_mailer will send later

  def initialize(domain)
    @domain = domain
    @params = {errors: [], deliver_emails: domain.deliver_emails, id: domain.id}
  end

  def pending_update_expired_notification_for_new_registrant
    registrant_pending
    subject(:pending_update_expired_notification_for_new_registrant_subject)
    domain_info
    compose
  end

  def pending_delete_rejected_notification
    registrant
    subject(:pending_delete_rejected_notification_subject)
    compose
  end

  def pending_delete_expired_notification
    registrant
    subject(:pending_delete_expired_notification_subject)
    compose
  end

  def delete_confirmation
    registrant
    subject(:delete_confirmation_subject)
    compose
  end

  def force_delete
    admins
    subject(:force_delete_subject)
    compose
  end

  private

  def registrant_old
    @params[:recipient] = format Registrant.find(@domain.registrant_id_was).email
  end

  def registrant
    @params[:recipient] = format @domain.registrant.email
  end

  def registrant_pending
    @params[:recipient] = format @domain.pending_json['new_registrant_email']
    @params[:new_registrant_name] = @domain.pending_json['new_registrant_name']
    @params[:old_registrant_name] = @domain.registrant.name
  end

  # registrant and domain admin contacts
  def admins
    emails = ([@domain.registrant.email] + @domain.admin_contacts.map { |x| format(x.email) })
    @params[:recipient] = emails.uniq.map { |x| format(x) }
  end

  # puny internet domain name, TODO: username<email>
  def format(email)
    return warn_no_email if email.nil?
    user, host = email.split('@')
    host = SimpleIDN.to_ascii(host)
    "#{user}@#{host}"
  end

  def subject(subject)
    @params[:name] = @domain.name
    @params[:subject] = "#{I18n.t(subject, name: @domain.name)}, [#{@domain.name}]"
  end

  def confirm_update
    verification_url('domain_update_confirms')
  end

  def compose
    @params
  end

  def verification_url(path)
    token = verification_token or return
    @params[:verification_url] = "#{ENV['registrant_url']}/registrant/#{path}/#{@domain.id}?token=#{token}"
  end

  def verification_token
    return warn_missing(:registrant_verification_token) if @domain.registrant_verification_token.blank?
    return warn_missing(:registrant_verification_asked_at) if @domain.registrant_verification_asked_at.blank?
    @domain.registrant_verification_token
  end

  def domain_info
    [:name, :registrar_name,
     :registrant_name, :registrant_ident, :registrant_email,
     :registrant_street,:registrant_city
    ].each do |attr|
      @params.store attr, @domain.send(attr)
    end
    @params.store :registrant_country, @domain.registrant_country.name
    @params.store :registrant_priv, @domain.registrant.priv?
    @params.store :old_registrant_name, Registrant.find(@domain.registrant_id_was).name
    @params
  end

  def warn_no_email(item = 'email')
    warn_missing item
    nil
  end

  def warn_missing(item)
    warn_not_delivered "#{item.to_s} is missing for #{@domain.name}"
  end

  def warn_not_delivered(reason)
    message = "EMAIL NOT DELIVERED: #{reason}"
    @params[:errors] << message
#    Rails.logger.warn message
    nil
  end

end

