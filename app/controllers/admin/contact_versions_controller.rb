class Admin::ContactVersionsController < AdminController
  before_action :set_contact, only: [:show]

  def index
    @q = Contact.search(params[:q])
    @contacts = @q.result.page(params[:page])
  end

  def show
    @versions = @contact.versions
  end

  private

  def set_contact
    @contact = Contact.find(params[:id])
  end
end
