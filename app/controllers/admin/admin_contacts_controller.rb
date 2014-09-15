class Admin::AdminContactsController < ApplicationController
  before_action :set_domain
  before_action :set_contact, only: [:destroy]

  def new; end

  def create
    contact = Contact.find_by(id: params[:contact_id])
    unless contact
      flash.now[:alert] = I18n.t('shared.contact_was_not_found')
      render 'new' and return
    end

    if @domain.admin_contacts.exists?(contact)
      flash.now[:alert] = I18n.t('shared.contact_already_exists')
      render 'new' and return
    end

    @domain.admin_contacts << contact
    flash[:notice] = I18n.t('shared.contact_added')
    redirect_to [:admin, @domain]
  end

  def destroy
    unless @domain.can_remove_admin_contact?
      flash[:alert] = @domain.errors[:admin_contacts].first
      redirect_to [:admin, @domain] and return
    end

    if @domain.admin_contacts.delete(@contact)
      flash[:notice] = I18n.t('shared.contact_detached')
    else
      flash[:alert] = I18n.t('shared.failed_to_detach_contact')
    end

    redirect_to [:admin, @domain]
  end

  private

  def set_domain
    @domain = Domain.find(params[:domain_id])
  end

  def set_contact
    @contact = Contact.find(params[:id])
  end
end
