require 'test_helper'

class DirectoResponseTest < ApplicationIntegrationTest
  setup do
    sign_in users(:api_bestnames)

    @invoice = invoices(:one)
    @response_xml = '<?xml version="1.0" encoding="UTF-8"?><results><Result Type="0" Desc="OK" docid="1" doctype="ARVE" submit="Invoices"/></results>'
    Spy.on_instance_method(EisBilling::BaseController, :authorized).and_return(true)
  end

  def test_should_created_directo_instance
    if Feature.billing_system_integrated?
      directo_response_from_billing = {
        response: 'this is response',
        xml_data: @response_xml,
        month: true
      }

      assert_difference 'Directo.count', 1 do
        put eis_billing_directo_response_path, params: JSON.parse(directo_response_from_billing.to_json),
        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
      end
    end
  end

  def test_should_update_related_invoice
    if Feature.billing_system_integrated?
      directo_response_from_billing = {
        response: 'this is response',
        xml_data: @response_xml
      }

      refute @invoice.in_directo

      assert_difference 'Directo.count', 1 do
        put eis_billing_directo_response_path, params: JSON.parse(directo_response_from_billing.to_json),
        headers: { 'HTTP_COOKIE' => 'session=api_bestnames' }
      end

      @invoice.reload
      assert @invoice.in_directo
    end
  end
end
