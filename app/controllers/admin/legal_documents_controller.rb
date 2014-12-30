class Admin::LegalDocumentsController < AdminController
  load_and_authorize_resource

  def show
    @ld = LegalDocument.find(params[:id])
    file = Base64.decode64(@ld.body)
    send_data file, filename: "#{@ld.created_at}.#{@ld.document_type}"
  end
end
