class DomainDeleteJob < Que::Job

  def run(domain_id)
    domain = Domain.find(domain_id)

    User.whodunnit = "job - #{self.class.name}"
    WhoisRecord.where(domain_id: domain.id).destroy_all

    domain.destroy
    bye_bye = domain.versions.last
    domain.registrar.notifications.create!(
        text: "#{I18n.t(:domain_deleted)}: #{domain.name}",
        attached_obj_id: bye_bye.id,
        attached_obj_type: bye_bye.class.to_s
    )
  end
end
