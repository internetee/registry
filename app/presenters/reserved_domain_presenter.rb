class ReservedDomainPresenter
  delegate :name, :password, to: :reserved_domain

  def initialize(reserved_domain:, view:)
    @reserved_domain = reserved_domain
    @view = view
  end

  def create_time
    view.l(reserved_domain.created_at)
  end

  def update_time
    view.l(reserved_domain.updated_at)
  end

  def edit_btn
    label = view.t('admin.reserved_domains.reserved_domain.edit_btn')

    if reserved_domain.updatable?
      view.link_to(label, view.edit_admin_reserved_domain_path(reserved_domain),
                   class: 'btn btn-primary btn-xs')
    else
      view.content_tag(:a, label,
                       class: 'btn btn-primary btn-xs',
                       title: view.t('admin.reserved_domains.reserved_domain.edit_prohibited'),
                       disabled: true,
                       data: {
                         toggle: 'tooltip',
                         placement: 'top',
                       })
    end
  end

  def delete_btn
    view.link_to(view.t(:delete), view.delete_admin_reserved_domain_path(reserved_domain),
                 data: { confirm: view.t(:are_you_sure) }, class: 'btn btn-danger btn-xs')
  end

  private

  attr_reader :reserved_domain
  attr_reader :view
end
