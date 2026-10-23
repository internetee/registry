require 'test_helper'

class AutoRenewTestCase < ActiveSupport::TestCase
  setup do
    @expiry = Time.zone.parse('2027-03-20 12:00:00')
    travel_to @expiry
    @domain = domains(:shop)
    @registrar = registrars(:bestnames)
    @account = accounts(:cash)
    @price = billing_prices(:renew_one_year)
    @price.update!(valid_from: @expiry.beginning_of_year, valid_to: nil)
    @domain.update_columns(auto_renew: true, valid_to: @expiry, statuses: [], status_notes: {},
                           outzone_at: nil, delete_date: nil, force_delete_date: nil,
                           force_delete_start: nil)
    @domain.reload
  end

  private

  def with_feature(enabled = true)
    original = ENV['auto_renew_enabled']
    ENV['auto_renew_enabled'] = enabled.to_s
    yield
  ensure
    ENV['auto_renew_enabled'] = original
  end

  def open_cycle
    Domains::AutoRenew::OpenCycle.run!(domain: @domain)
  end

  def attempt(cycle)
    Domains::AutoRenew::AttemptRenewal.run!(cycle: cycle)
  end

  def renew_automatically
    cycle = open_cycle
    attempt(cycle)
    cycle.reload
  end

  def change_preference(**options)
    Domain.transaction do
      @domain.reload(lock: true)
      Domains::AutoRenew::ChangePreference.run(domain: @domain, registrar: @registrar, **options)
    end
  end

  def polls
    Notification.where(attached_obj_type: 'DomainAutoRenewal')
  end

  def assert_command_error(outcome, code)
    assert_not outcome.valid?
    assert outcome.errors.any?
    assert @domain.errors.any? { |error| error.options[:code].to_s == code.to_s },
           @domain.errors.inspect
  end
end
