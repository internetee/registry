class DomainPresenter
  delegate :name, :transfer_code, :registrant, :registrant_id, :id, to: :domain

  def initialize(domain:, view:)
    @domain = domain
    @view = view
  end

  def name_with_status
    html = domain.name

    if domain.discarded?
      label = view.tag.span('deleteCandidate', class: 'label label-warning')
      html += " #{label}"
    end

    if domain.locked_by_registrant?
      label = view.tag.span('registryLock', class: 'label label-danger')
      html += " #{label}"
    end

    html.html_safe
  end

  def expire_time
    view.l(domain.expire_time)
  end

  def expire_date
    view.l(domain.expire_time, format: :date)
  end

  def on_hold_date
    view.l(domain.on_hold_time, format: :date) if domain.on_hold_time
  end

  def delete_date
    view.l(domain.delete_date) if domain.delete_date
  end

  def force_delete_date
    view.l(domain.force_delete_date) if domain.force_delete_scheduled?
  end

  def force_delete_toggle_btn
    return inactive_schedule_force_delete_btn if domain.discarded?

    if domain.force_delete_scheduled?
      cancel_force_delete_btn
    else
      schedule_force_delete_btn
    end
  end

  def contact_emails_verification_failed
    domain.contact_emails_verification_failed.join(', ')
  end

  def remove_registry_lock_btn
    return unless domain.locked_by_registrant?

    view.link_to(view.t('admin.domains.registry_lock.destroy.btn'),
                 view.admin_domain_registry_lock_path(domain),
                 method: :delete,
                 data: { confirm: view.t('admin.domains.registry_lock.destroy.confirm') },
                 class: 'dropdown-item')
  end

  def keep_btn
    return unless domain.discarded?

    view.link_to view.t('admin.domains.edit.keep_btn'), view.keep_admin_domain_path(@domain),
                 method: :patch,
                 data: { confirm: view.t('admin.domains.edit.keep_btn_confirm') },
                 class: 'dropdown-item'
  end

  private

  def schedule_force_delete_btn
    view.tag.a(view.t('admin.domains.force_delete_toggle_btn.schedule'),
               class: 'dropdown-item',
               data: {
                 toggle: 'modal',
                 target: '.domain-edit-force-delete-dialog',
               })
  end

  def cancel_force_delete_btn
    view.link_to view.t('admin.domains.force_delete_toggle_btn.cancel'),
                 view.admin_domain_force_delete_path(domain),
                 method: :delete,
                 data: {
                   confirm: view.t('admin.domains.force_delete_toggle_btn.cancel_confirm'),
                 },
                 class: 'dropdown-item'
  end

  def inactive_schedule_force_delete_btn
    view.tag.button(view.t('admin.domains.force_delete_toggle_btn.schedule'),
                    title: view.t('admin.domains.force_delete_toggle_btn.unable_to_schedule'),
                    disabled: true,
                    class: 'dropdown-item')
  end

  attr_reader :domain, :view
end
