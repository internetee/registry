class DisputePresenter
  delegate :domain_name, to: :dispute

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

  def link_from_domain
    view.link_to(view.t('admin.disputes.domain_dispute.view_btn'),
                 view.admin_dispute_path(dispute))
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

  def comment
    view.simple_format(dispute.comment)
  end

  def edit_btn(css_class: 'btn btn-primary')
    view.link_to view.t('admin.disputes.dispute.edit_btn'), view.edit_admin_dispute_path(dispute),
                 class: css_class
  end

  def list_edit_btn
    edit_btn(css_class: 'btn btn-primary btn-xs')
  end

  def delete_btn(css_class: 'btn btn-danger')
    view.link_to view.t('admin.disputes.dispute.delete_btn'), view.admin_dispute_path(dispute),
                 method: :delete,
                 data: { confirm: view.t('admin.disputes.dispute.delete_btn_confirm') },
                 class: css_class
  end

  def list_delete_btn
    delete_btn(css_class: 'btn btn-danger btn-xs')
  end

  def password
    view.tag('input', value: dispute.password, type: 'text', readonly: true, class: 'form-control')
  end

  private

  attr_reader :dispute
  attr_reader :view
end
