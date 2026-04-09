class ListingCompanyCodesResolver
  CACHE_VERSION = 'v1'
  STALE_GRACE_PERIOD = 24.hours
  FALLBACK_TTL = 1.day

  def initialize(user, cache: Rails.cache, company_register: CompanyRegister::Client.new, logger: Rails.logger)
    @user = user
    @cache = cache
    @company_register = company_register
    @logger = logger
  end

  def call
    return [] if @user.ident.include?('-')

    cached_primary, cached_stale = read_cache
    if cached_primary
      log(:info, 'cache_hit')
      return cached_primary
    end

    fetch_live(cached_stale)
  end

  private

  def fetch_live(cached_stale)
    results = @company_register.representation_rights(
      citizen_personal_code: @user.ident,
      citizen_country_code: @user.country.alpha3
    )
    codes = results.map(&:registration_number).compact.uniq

    write_cache(codes)
    log(:info, 'live_success')
    codes
  rescue CompanyRegister::NotAvailableError
    stale_fallback(cached_stale)
  rescue CompanyRegister::SOAPFaultError
    log(:error, 'soap_fault_direct_only')
    []
  end

  def stale_fallback(cached_stale)
    if cached_stale
      log(:warn, 'stale_fallback')
      cached_stale
    else
      log(:error, 'empty_after_error')
      []
    end
  end

  def read_cache
    primary = @cache.read(primary_key)
    stale = @cache.read(stale_key)
    [primary, stale]
  end

  def write_cache(codes)
    ttl = cache_ttl
    @cache.write(primary_key, codes, expires_in: ttl)
    @cache.write(stale_key, codes, expires_in: ttl + STALE_GRACE_PERIOD)
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

  def primary_key
    "registrant/listing_company_codes/#{CACHE_VERSION}/#{@user.id}"
  end

  def stale_key
    "registrant/listing_company_codes_stale/#{CACHE_VERSION}/#{@user.id}"
  end

  def log(level, outcome, extra = {})
    @logger.send(level, { user_id: @user.id, outcome: outcome }.merge(extra).to_json)
  end
end
