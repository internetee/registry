# frozen_string_literal: true

class ApiUserMailer < ApplicationMailer
  def identification_requested(api_user:, link:)
    @api_user = api_user
    @verification_link = link

    subject = default_i18n_subject(username: api_user.username)
    mail(to: api_user.email, subject: subject)
  end
end
