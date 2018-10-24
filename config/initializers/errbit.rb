module Patches
  module Airbrake
    module SyncSender
      def build_https(uri)
        super.tap do |req|
          req.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
      end
    end
  end
end

Airbrake::SyncSender.prepend(::Patches::Airbrake::SyncSender)

Airbrake.configure do |config|
  config.host = ENV['airbrake_host']
  config.project_id = ENV['airbrake_project_id']
  config.project_key = ENV['airbrake_project_key']

  config.environment = Rails.env
  config.ignore_environments = %w(development test)
end
