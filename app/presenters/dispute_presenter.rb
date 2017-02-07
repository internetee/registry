class DisputePresenter
  delegate :password, to: :dispute

  def initialize(dispute:, view:)
    @dispute = dispute
    @view = view
  end

  def name
    "##{dispute.id} (#{dispute.domain_name})"
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

  def update_time
    view.l(dispute.update_time)
  end

  def edit_btn
    view.link_to view.t('admin.disputes.dispute.edit_btn'), view.edit_admin_dispute_path(dispute),
                 class: 'btn btn-primary btn-xs'
  end

  def delete_btn
    view.link_to view.t('admin.disputes.dispute.delete_btn'), view.admin_dispute_path(dispute),
                 method: :delete,
                 data: { confirm: view.t('admin.disputes.dispute.delete_btn_confirm') },
                 class: 'btn btn-danger btn-xs'
  end

  private

  attr_reader :dispute
  attr_reader :view
end
