# frozen_string_literal: true

# Weekly rebuild of the local death registry file used by DeathRegistry::Lookup.
class DeathRegistryFileBuildJob < ApplicationJob
  queue_as :default

  def perform
    count = DeathRegistry::FileBuilder.new.call
    Rails.logger.info("DeathRegistryFileBuildJob: wrote #{count} records to #{DeathRegistry.file_path}")
  end
end
