class P12GeneratorJob < ApplicationJob
  queue_as :default
  
  sidekiq_options(
    unique: :until_executed,
    lock_timeout: 1.hour
  )

  def perform(api_user_id)
    api_user = ApiUser.find(api_user_id)
    
    Certificates::CertificateGenerator.new(
      api_user_id: api_user_id,
      interface: 'registrar'
    ).execute
  end
end
