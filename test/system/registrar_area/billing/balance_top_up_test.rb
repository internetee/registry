require 'application_system_test_case'

class BalanceTopUpTest < ApplicationSystemTestCase
  setup do
    sign_in users(:api_bestnames)
    @original_registry_vat_rate = Setting.registry_vat_prc

    eis_response = OpenStruct.new(body: "{\"payment_link\":\"http://link.test\"}")
    Spy.on_instance_method(EisBilling::AddDeposits, :send_invoice).and_return(eis_response)
  end

  teardown do
    Setting.registry_vat_prc = @original_registry_vat_rate
  end

  def test_creates_new_invoice
    invoice_n = Invoice.order(number: :desc).last.number
    stub_request(:post, "http://eis_billing_system:3000/api/v1/invoice_generator/invoice_number_generator").
      with(
        headers: {
              'Accept'=>'Bearer WA9UvDmzR9UcE5rLqpWravPQtdS8eDMAIynzGdSOTw==--9ZShwwij3qmLeuMJ--NE96w2PnfpfyIuuNzDJTGw==',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>'Bearer foobar',
              'Content-Type'=>'application/json',
              'User-Agent'=>'Ruby'
            }).
      to_return(status: 200, body: "{\"invoice_number\":\"#{invoice_n + 3}\"}", headers: {})
    Setting.registry_vat_prc = 0.1

    visit registrar_invoices_url
    click_link_or_button 'Add deposit'
    fill_in 'Amount', with: '25.5'

    assert_difference 'Invoice.count' do
      click_link_or_button 'Add'
    end

    invoice = Invoice.last

    assert_equal BigDecimal(10), invoice.vat_rate
    assert_equal BigDecimal('28.05'), invoice.total
    assert_text 'Please pay the following invoice'
  end
end
