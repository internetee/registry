class EisBilling::DirectoResponseController < EisBilling::BaseController
  def update
    response = params[:response]
    xml_data = params[:xml_data]
    @month = params.fetch(:month, false)

    process_directo_response(xml_data, response)
    render status: 200, json: { messege: 'Should return new directo number', status: :ok }
  end

  private

  def process_directo_response(xml, req)
    Rails.logger.info "[Directo] - Responded with body: #{xml}"
    Nokogiri::XML(req).css('Result').each do |res|
      if @month
        mark_invoice_as_sent(res: res, req: req)
      else
        inv = Invoice.find_by(number: res.attributes['docid'].value.to_i)

        mark_invoice_as_sent(invoice: inv, res: res, req: req)
      end
    end
  end

  def mark_invoice_as_sent(invoice: nil, res:, req:)
    directo_record = Directo.new(response: res.as_json.to_h,
                                 request: req, invoice_number: res.attributes['docid'].value.to_i)
    if invoice
      directo_record.item = invoice
      invoice.update(in_directo: true)
    end

    directo_record.save!
  end
end
