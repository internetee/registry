module Domains
  class DeleteService
    def initialize(domain:)
      @domain = domain
    end

    def delete
      domain.transaction do
        domain.destroy!
        create_poll_message
      end
    end

    private

    attr_reader :domain

    def create_poll_message
      last_domain_version = domain.versions.last

      domain.registrar.messages.create!(
        body: "#{I18n.t(:domain_deleted)}: #{domain.name}",
        attached_obj_id: last_domain_version.id,
        attached_obj_type: last_domain_version.class.to_s
      )
    end
  end
end
