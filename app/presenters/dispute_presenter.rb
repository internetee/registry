class DisputePresenter
  def initialize(dispute:, view:)
    @dispute = dispute
    @view = view
  end

  def name
    dispute.domain_name
  end

  def link
    view.link_to(name, view.admin_dispute_path(dispute))
  end

  def expire_date
    view.l(dispute.expire_date)
  end

  def create_time
    view.l(dispute.create_time)
  end

  private

  attr_reader :dispute
  attr_reader :view
end
