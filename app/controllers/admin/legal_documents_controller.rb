module Admin
  class LegalDocumentsController < BaseController
    load_and_authorize_resource

    def show
      @ld = LegalDocument.find(params[:id])
      filename = @ld.path.split('/').last
      send_data File.open(@ld.path).read, filename: filename
    end
  end
end
