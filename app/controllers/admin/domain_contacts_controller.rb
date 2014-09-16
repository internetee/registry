class Admin::DomainContactsController < ApplicationController
  before_action :set_domain
  before_action :set_domain_contact, only: [:destroy]

  def new
    @domain_contact = @domain.domain_contacts.build(contact_type: params[:type])
  end

  def create
    @domain_contact = @domain.domain_contacts.build(domain_contact_params)

    unless @domain_contact.contact
      flash.now[:alert] = I18n.t('shared.contact_was_not_found')
      render 'new' and return
    end

    @domain.adding_admin_contact = true if @domain_contact.admin?
    @domain.adding_admin_contact = true if @domain_contact.tech?

    if @domain.save
      flash[:notice] = I18n.t('shared.contact_added')
      redirect_to [:admin, @domain]
    else
      flash.now[:alert] = I18n.t('shared.failed_to_add_contact')
      render 'new'
    end
  end

  def destroy
    @domain.domain_contacts.select { |x| x == @domain_contact }[0].mark_for_destruction
    @domain.deleting_admin_contact = true if @domain_contact.admin?
    @domain.deleting_tech_contact = true if @domain_contact.tech?

    if @domain.save
      flash[:notice] = I18n.t('shared.contact_detached')
    else
      flash[:alert] = @domain.errors.first[1]
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
