require 'net/http'
require 'openssl'
require 'socket'
require 'httpi'

class ListingCompanyCodesResolver
  CACHE_VERSION = 'v1'
  STALE_GRACE_PERIOD = 24.hours
  FALLBACK_TTL = 1.day

  # Network-level errors that indicate the business registry is unreachable.
  # The company_register gem does NOT wrap these into CompanyRegister::NotAvailableError —
  # depending on the HTTP adapter in use (HTTPI or Net::HTTP), raw errors bubble up.
  NETWORK_ERRORS = [
    Net::OpenTimeout,
    Net::ReadTimeout,
    Errno::ECONNREFUSED,
    Errno::EHOSTUNREACH,
    Errno::ENETUNREACH,
    Errno::ETIMEDOUT,
    SocketError,
    OpenSSL::SSL::SSLError,
    HTTPI::Error,
  ].freeze

  attr_reader :user, :cache, :company_register, :logger

  def initialize(user, cache: Rails.cache, company_register: CompanyRegister::Client.new, logger: Rails.logger)
    @user = user
    @cache = cache
    @company_register = company_register
    @logger = logger
  end

  def call
    return [] if user.ident.include?('-')

    fetch_with_stale_fallback
  end

  private

  # Primary caching is handled by CompanyRegister::Client internally
  # (cache_store.fetch with cache_period TTL). This resolver only adds
  # a stale fallback layer: on every successful lookup (cached or live),
  # we persist codes to a stale key with an extended TTL. On error,
  # we fall back to that stale key.
  def fetch_with_stale_fallback
    codes = resolve_company_codes
    write_stale_cache(codes)
    log(:info, 'live_success')
    codes
  rescue CompanyRegister::NotAvailableError
    stale_fallback
  rescue CompanyRegister::SOAPFaultError
    log(:error, 'soap_fault_direct_only')
    []
  rescue *NETWORK_ERRORS => e
    log(:warn, 'network_error', error_class: e.class.name, error_message: e.message)
    stale_fallback
  end

  def resolve_company_codes
    results = company_register.representation_rights(
      citizen_personal_code: user.ident,
      citizen_country_code: user.country.alpha3
    )
    results.map(&:registration_number).compact.uniq
  end

  def stale_fallback
    cached_stale = cache.read(stale_key)
    if cached_stale
      log(:warn, 'stale_fallback')
      cached_stale
    else
      log(:error, 'empty_after_error')
      []
    end
  end

  # Stale-cache write is an observability concern, not the read path.
  # Any cache backend failure (Redis down, memcache timeout, etc.) must not
  # break the live lookup that already succeeded — we just lose the fallback
  # for the next outage window and log it.
  def write_stale_cache(codes)
    cache.write(stale_key, codes, expires_in: cache_ttl + STALE_GRACE_PERIOD)
  rescue StandardError => e
    log(:warn, 'cache_write_failed', error: e.message)
  end

  def cache_ttl
    period = CompanyRegister.configuration.cache_period
    if period.nil? || period <= 0
      log(:warn, 'invalid_cache_period')
      FALLBACK_TTL
    else
      period
    end
  end

  def stale_key
    "registrant/listing_company_codes_stale/#{CACHE_VERSION}/#{user.id}"
  end

  def log(level, outcome, extra = {})
    payload = { user_id: user.id, outcome: outcome }.merge(extra).to_json

    case level
    when :info then logger.info(payload)
    when :warn then logger.warn(payload)
    when :error then logger.error(payload)
    end
  end
end
