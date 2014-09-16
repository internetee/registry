class Admin::DomainContactsController < ApplicationController
  before_action :set_domain
  before_action :set_domain_contact, only: [:destroy]

  def new
    @domain_contact = @domain.domain_contacts.build
  end

  def create
    @domain.adding_admin_contact = true
    @domain_contact = @domain.domain_contacts.build(domain_contact_params)

    if @domain.save
      flash[:notice] = I18n.t('shared.contact_added')
      redirect_to [:admin, @domain]
    else
      flash.now[:alert] = I18n.t('shared.failed_to_add_contact')
      render 'new'
    end
  end

  def destroy
    @domain.deleting_admin_contact = true
    @domain.domain_contacts.select { |x| x == @domain_contact }[0].mark_for_destruction

    if @domain.save
      flash[:notice] = I18n.t('shared.contact_deleted')
    else
      flash[:alert] = I18n.t('shared.fail')
    end

    redirect_to [:admin, @domain]
  end

  private

  def set_domain
    @domain = Domain.find(params[:domain_id])
  end

  def set_domain_contact
    @domain_contact = DomainContact.find(params[:id])
  end

  def domain_contact_params
    params.require(:domain_contact).permit(:contact_id, :contact_type)
  end
end
