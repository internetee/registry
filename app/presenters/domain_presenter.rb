class DomainPresenter
  delegate :name, :transfer_code, :registrant_name, :registrant_id, :registrant_code, to: :domain

  def initialize(domain:, view:)
    @domain = domain
    @view = view
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
    view.l(domain.delete_time, format: :date) if domain.delete_time
  end

  def force_delete_date
    view.l(domain.force_delete_time, format: :date) if domain.force_delete_time
  end

  def admin_contact_names
    domain.admin_contact_names.join(', ')
  end

  def tech_contact_names
    domain.tech_contact_names.join(', ')
  end

  def nameserver_names
    domain.nameserver_hostnames.join(', ')
  end

  def force_delete_toggle_btn
    if !domain.force_delete_scheduled?
      view.content_tag(:a, view.t('admin.domains.force_delete_toggle_btn.schedule'),
                       class: 'btn btn-danger',
                       data: {
                         toggle: 'modal',
                         target: '.domain-edit-force-delete-dialog',
                       }
      )
    else
      view.link_to(view.t('admin.domains.force_delete_toggle_btn.cancel'),
                   view.cancel_force_delete_admin_domain_path(domain),
                   method: :patch,
                   data: { confirm: view.t('admin.domains.force_delete_toggle_btn.cancel_confim') },
                   class: 'btn btn-primary')
    end
  end

  private

  attr_reader :domain
  attr_reader :view
end
