class PaymentOrder < ApplicationRecord
  #include Versions
  include ActionView::Helpers::NumberHelper

  PAYMENT_INTERMEDIARIES = ENV['payments_intermediaries'].to_s.strip.split(', ').freeze
  PAYMENT_BANKLINK_BANKS = ENV['payments_banks'].to_s.strip.split(', ').freeze
  PAYMENT_METHODS = [PAYMENT_INTERMEDIARIES, PAYMENT_BANKLINK_BANKS].flatten.freeze

  belongs_to :invoice, optional: false

  validate :invoice_cannot_be_already_paid, on: :create
  # validates :type, inclusion: { in: PAYMENT_METHODS }

  enum status: { issued: 'issued', paid: 'paid', cancelled: 'cancelled' }

  attr_accessor :return_url, :response_url

  # Name of configuration namespace
  def self.config_namespace_name; end

  def invoice_cannot_be_already_paid
    return unless invoice&.paid?

    errors.add(:invoice, 'is already paid')
  end

  def self.supported_method?(some_class)
    raise ArgumentError unless some_class < PaymentOrder

    if PAYMENT_METHODS.include?(some_class.name)
      true
    else
      false
    end
  end

  def self.supported_methods
    enabled = []

    ENABLED_METHODS.each do |method|
      class_name = method.constantize
      raise(Errors::ExpectedPaymentOrder, class_name) unless class_name < PaymentOrder

      enabled << class_name
    end

    enabled
  end

  def channel
    type.gsub('PaymentOrders::', '')
  end

  def form_url
    ENV["payments_#{self.class.config_namespace_name}_url"]
  end
end
