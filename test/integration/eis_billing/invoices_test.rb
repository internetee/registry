require 'test_helper'

class StubAuthorization < ApplicationController
  skip_authorization_check

  def authorized
    true
  end
end

EisBilling::BaseController = StubAuthorization

class EInvoiceResponseTest < ApplicationIntegrationTest
  setup do
    sign_in users(:api_bestnames)
    @invoice = invoices(:one)

    response_message = {
      message: 'got it'
    }
    stub_request(:post, 'https://eis_billing_system:3000/api/v1/invoice_generator/invoice_status')
    .to_return(status: 200, body: response_message.to_json, headers: {})
  end

  test 'it should update status of invoice if payment order is existed' do
    @invoice.update(total: 120.0)
    @invoice.reload

    incoming_params = {
      invoice: {
        invoice_number: @invoice.number,
        initiator: 'registry',
        payment_reference: '93b29d54ae08f7728e72ee3fe0e88855cd1d266912039d7d23fa2b54b7e1b349',
        transaction_amount: 120.0,
        status: 'paid',
        in_directo: false,
        everypay_response: {
          'some' => 'some'
        },
        sent_at_omniva: Time.zone.now - 10.minutes
      },
      status: 'paid'
    }

    @invoice.account_activity.delete && @invoice.reload

    assert_equal @invoice.payment_orders.pluck(:status), %w[issued issued]
    put eis_billing_invoices_path, params: incoming_params
    @invoice.reload
    @invoice.payment_orders.each(&:reload)

    invoice = Invoice.find(@invoice.id)
    assert_includes invoice.payment_orders.pluck(:status), 'paid'
    assert_includes invoice.payment_orders.pluck(:status), 'issued'
  end

  test 'it should update invoice data as directo and omniva' do
    incoming_params = { 
      invoice: {
        invoice_number: @invoice.number,
        initiator: 'registry',
        payment_reference: '93b29d54ae08f7728e72ee3fe0e88855cd1d266912039d7d23fa2b54b7e1b349',
        transaction_amount: 270.0,
        status: 'unpaid',
        in_directo: true,
        everypay_response: {
          'some' => 'some'
        },
        sent_at_omniva: Time.zone.now - 10.minutes
      },
      status: 'unpaid'
    }

    assert_equal @invoice.payment_orders.pluck(:status), %w[issued issued]
    assert_nil @invoice.e_invoice_sent_at
    refute @invoice.in_directo

    put eis_billing_invoices_path, params: incoming_params

    @invoice.payment_orders.each(&:reload)
    @invoice.reload

    assert_equal @invoice.payment_orders.pluck(:status), %w[issued issued]
    assert @invoice.in_directo
    assert_not_nil @invoice.e_invoice_sent_at
  end

  test 'it should create new payment order if payment order and activity are missing, but status has paid status' do
    invoice = invoices(:one)

    invoice.payment_orders.destroy_all and invoice.account_activity.destroy
    invoice.update(total: 120.0)
    invoice.reload

    incoming_params = {
        invoice: {
          invoice_number: invoice.number,
          initiator: 'registry',
          payment_reference: '93b29d54ae08f7728e72ee3fe0e88855cd1d266912039d7d23fa2b54b7e1b349',
          transaction_amount: 120.0,
          status: 'paid',
          in_directo: false,
          everypay_response: {
            'some' => 'some'
          },
          sent_at_omniva: Time.zone.now - 10.minutes
        },
        status: 'paid'
    }

    assert invoice.payment_orders.empty?
    assert_nil invoice.account_activity

    put eis_billing_invoices_path, params: incoming_params

    invoice.reload
    invoice.payment_orders.each(&:reload)

    assert_equal invoice.payment_orders.count, 1
    assert invoice.payment_orders.first.paid?
    assert invoice.account_activity
  end

  test 'it should ignore payment order creation if payment status is not paid and payment order not existed' do
    incoming_params = { 
      invoice: {
        invoice_number: @invoice.number,
        initiator: 'registry',
        payment_reference: '93b29d54ae08f7728e72ee3fe0e88855cd1d266912039d7d23fa2b54b7e1b349',
        transaction_amount: 270.0,
        status: 'cancelled',
        in_directo: false,
        everypay_response: {
          'some' => 'some'
        },
        sent_at_omniva: Time.zone.now - 10.minutes
      },
      status: 'cancelled'
    }

    @invoice.payment_orders.destroy_all and @invoice.account_activity.destroy
    @invoice.reload

    assert @invoice.payment_orders.empty?
    assert_nil @invoice.account_activity

    put eis_billing_invoices_path, params: incoming_params and @invoice.reload

    assert @invoice.payment_orders.empty?
    assert_nil @invoice.account_activity
  end

  test 'it should add balance if payment order mark as paid' do
    invoice = invoices(:one)
    item = invoice.items.first

    invoice.payment_orders.destroy_all and invoice.account_activity.destroy
    invoice.update(total: 120.0) && invoice.reload
    item.update(price: 100.0) && item.reload

    incoming_params = { 
      invoice: {
        invoice_number: invoice.number,
        initiator: 'registry',
        payment_reference: '93b29d54ae08f7728e72ee3fe0e88855cd1d266912039d7d23fa2b54b7e1b349',
        transaction_amount: 120.0,
        status: 'paid',
        in_directo: false,
        everypay_response: {
          'some' => 'some'
        },
        sent_at_omniva: Time.zone.now - 10.minutes
      },
      status: 'paid'
    }

    assert invoice.payment_orders.empty?
    assert_nil invoice.account_activity

    account = invoice.buyer.accounts.first

    assert_equal account.balance.to_f, 100.0

    put eis_billing_invoices_path, params: incoming_params

    invoice.reload
    invoice.payment_orders.each(&:reload)
    account.reload

    assert_equal invoice.payment_orders.count, 1
    assert invoice.payment_orders.first.paid?
    assert invoice.account_activity

    assert_equal account.balance.to_f, 200.0
  end

  test 'should change nothing if invoice is already paid' do
    assert @invoice.account_activity.present?
    assert @invoice.payment_orders.present?

    account = @invoice.buyer.accounts.first
    assert_equal account.balance.to_f, 100.0
    assert @invoice.paid?

    incoming_params = { 
      invoice: {
        invoice_number: @invoice.number,
        initiator: 'registry',
        payment_reference: '93b29d54ae08f7728e72ee3fe0e88855cd1d266912039d7d23fa2b54b7e1b349',
        transaction_amount: @invoice.total,
        status: 'paid',
        in_directo: false,
        everypay_response: {
          'some' => 'some'
        },
        sent_at_omniva: Time.zone.now - 10.minutes
      },
      status: 'paid'
    }

    put eis_billing_invoices_path, params: incoming_params
    account.reload

    assert_equal account.balance.to_f, 100.0
  end

  test 'it should decrease balance and again add if user change paid invoice to cancel and then again to paid' do
    invoice = invoices(:one)
    item = invoice.items.first

    invoice.payment_orders.destroy_all and invoice.account_activity.destroy
    invoice.update(total: 120.0) && invoice.reload
    item.update(price: 100.0) && item.reload

    add_balance_params = { 
      invoice: {
        invoice_number: invoice.number,
        initiator: 'registry',
        payment_reference: '93b29d54ae08f7728e72ee3fe0e88855cd1d266912039d7d23fa2b54b7e1b349',
        transaction_amount: 120.0,
        status: 'paid',
        in_directo: false,
        everypay_response: {
          'some' => 'some'
        },
        sent_at_omniva: Time.zone.now - 10.minutes
      },
      status: 'paid'
    }

    assert invoice.payment_orders.empty?
    assert_nil invoice.account_activity

    account = invoice.buyer.accounts.first

    assert_equal account.balance.to_f, 100.0

    put eis_billing_invoices_path, params: add_balance_params

    invoice.reload
    invoice.payment_orders.each(&:reload)
    account.reload

    assert_equal invoice.payment_orders.count, 1
    assert invoice.payment_orders.first.paid?
    assert invoice.account_activity
    assert invoice.paid?
    assert_equal account.balance.to_f, 200.0

    decrease_balance_params = { 
      invoice: {
        invoice_number: invoice.number,
        initiator: 'registry',
        payment_reference: '93b29d54ae08f7728e72ee3fe0e88855cd1d266912039d7d23fa2b54b7e1b349',
        transaction_amount: 120.0,
        status: 'unpaid',
        in_directo: false,
        everypay_response: {
          'some' => 'some'
        },
        sent_at_omniva: Time.zone.now - 10.minutes
      },
      status: 'unpaid'
    }

    put eis_billing_invoices_path, params: decrease_balance_params
    invoice.reload
    invoice.payment_orders.each(&:reload)
    account.reload
    assert invoice.unpaid?

    assert_equal account.balance.to_f, 100.0
  end

  test 'it should return an error if invoice not existing' do
    incoming_params = {
      invoice: {
        invoice_number: 'nonexisted-invoice',
        initiator: 'registry',
        payment_reference: '93b29d54ae08f7728e72ee3fe0e88855cd1d266912039d7d23fa2b54b7e1b349',
        transaction_amount: 120.0,
        status: 'paid',
        in_directo: false,
        everypay_response: {
          'some' => 'some'
        },
        sent_at_omniva: Time.zone.now - 10.minutes
      },
      status: 'paid'
    }

    put eis_billing_invoices_path, params: incoming_params
    registry_response = JSON.parse(response.body).with_indifferent_access[:error]

    assert_equal registry_response[:message], 'Invoice with nonexisted-invoice number not found'
  end
end
