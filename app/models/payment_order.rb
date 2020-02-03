class PaymentOrder < ApplicationRecord
  #include Versions
  include ActionView::Helpers::NumberHelper

  PAYMENT_INTERMEDIARIES = ENV['payments_intermediaries'].to_s.strip.split(', ').freeze
  PAYMENT_BANKLINK_BANKS = ENV['payments_banks'].to_s.strip.split(', ').freeze
  PAYMENT_METHODS = [PAYMENT_INTERMEDIARIES, PAYMENT_BANKLINK_BANKS].flatten.freeze

  belongs_to :invoice, optional: false

  validate :invoice_cannot_be_already_paid, on: :create
  # validates :type, inclusion: { in: PAYMENT_METHODS }

  enum status: { issued: 'issued', paid: 'paid', cancelled: 'cancelled',
                 failed: 'failed' }

  attr_accessor :return_url, :response_url

  # Name of configuration namespace
  def self.config_namespace_name; end

  def invoice_cannot_be_already_paid
    return unless invoice&.paid?

    errors.add(:invoice, 'is already paid')
  end

  def self.type_from_shortname(shortname)
    ('PaymentOrders::' + shortname.camelize).constantize
  end

  def self.supported_method?(some_class)
    supported_methods.include? type_from_shortname(some_class)
  rescue NameError
    false
  end

  def complete_transaction(transaction)
    paid!

    transaction.save!
    transaction.bind_invoice(invoice.number)

    return unless transaction.errors.any?

    worded_errors = 'Failed to bind. '
    transaction.errors.full_messages.each do |err|
      worded_errors << "#{err}, "
    end

    update!(notes: worded_errors)
  end

  def self.supported_methods
    supported = []

    PAYMENT_METHODS.each do |method|
      class_name = ('PaymentOrders::' + method.camelize).constantize
      raise(NoMethodError, class_name) unless class_name < PaymentOrder

      supported << class_name
    end

    supported
  end

  def channel
    type.gsub('PaymentOrders::', '')
  end

  def form_url
    ENV["payments_#{self.class.config_namespace_name}_url"]
  end
end
