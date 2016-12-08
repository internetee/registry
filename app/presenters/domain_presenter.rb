class DomainPresenter
  delegate :name, :registrant_name, :registrant_id, to: :domain

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

  private

  attr_reader :domain
  attr_reader :view
end
