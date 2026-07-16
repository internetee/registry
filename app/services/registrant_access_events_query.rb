# Read-only PORO (spec 13, Surface A). Reconstructs the caller's HALF-OPEN tenure
# intervals on THIS domain's item_id from log_domains (PaperTrail), then returns the
# disclosable RdapAccessEvent rows for the domain: delay-filtered, ordered
# requested_at DESC, capped at 100.
#
# The load-bearing correctness property lives here: every returned event's
# requested_at MUST fall inside one of the caller's [start_i, end_i) intervals for
# item_id = domain.id. This excludes a prior/later owner's accesses (per-tenure) and
# a same-name event that belongs to a different (deleted-namesake) item_id (the
# per-interval LOWER bound is what does that — a name-only + upper-bound filter would
# leak it and is FORBIDDEN).
#
# PII (N1): reads only the caller's OWN contact ids (server-side, from
# current_registrant_user) and event ids/timestamps; writes NOTHING PII-bearing to any
# log/error line. Issues only SELECTs (N5) — never writes, mutates, or reschemas the
# store. No defensive rescue/retry/circuit-breaker — a plain SELECT pipeline.
class RegistrantAccessEventsQuery
  FALLBACK_DELAY_MINUTES = 5
  RESULT_CAP = 100

  def initialize(domain:, registrant_user:, now: Time.current)
    @domain = domain
    @now = now
    # R5a: the caller's OWN contact id(s), resolved SERVER-SIDE from current_registrant_user.
    # DIRECT (ident-matched personal) contact(s) only this release; never a client value.
    @own_ids = Contact.registrant_user_direct_contacts(registrant_user).ids
  end

  def call
    intervals = own_tenure_intervals
    return RdapAccessEvent.none if intervals.empty?

    scope = RdapAccessEvent.where(domain_name: @domain.name)
                           .where('requested_at <= ?', cutoff)
    scope = scope.where(interval_predicate(intervals), *interval_binds(intervals))
    scope.order(requested_at: :desc).limit(RESULT_CAP)
  end

  private

  # Delay cutoff with a SAFE NON-ZERO fallback (R11/R14/N4). Setting.<code> returns nil
  # for a missing/blank row; the `|| 5` and the `<= 0 => 5` clamp guarantee the path can
  # never reach an effective 0-delay (never real-time disclosure).
  def cutoff
    delay = (Setting.rdap_access_transparency_disclosure_delay || FALLBACK_DELAY_MINUTES).to_i
    delay = FALLBACK_DELAY_MINUTES if delay <= 0
    @now - delay.minutes
  end

  # Ordered [start, end) intervals (end = @now for the still-current tenure) during which
  # the effective registrant of item_id = @domain.id was one of @own_ids. Built from the
  # ordered log_domains timeline for this item_id.
  def own_tenure_intervals
    rows = Version::DomainVersion.where(item_id: @domain.id).order(:created_at)
                                 .pluck(:created_at,
                                        Arel.sql("object_changes->>'registrant_id'"),
                                        Arel.sql("object->>'registrant_id'"))
    build_intervals(rows)
  end

  # Pure walk (unit-testable in isolation). rows = [created_at, object_changes_registrant, object_registrant].
  # Derives the effective registrant AFTER each event: prefer the NEW value of
  # object_changes.registrant_id ([old, new] array), else the object.registrant_id
  # scalar snapshot, else carry forward the previous effective value. Emits half-open
  # [start, end) intervals for consecutive runs where the effective registrant is one of
  # @own_ids; the still-current tenure is closed at @now.
  def build_intervals(rows)
    intervals = []
    effective = nil
    current_start = nil
    current_owned = false

    rows.each do |created_at, changes_registrant, object_registrant|
      new_effective = effective_registrant(changes_registrant, object_registrant, effective)
      owned_now = own?(new_effective)

      if owned_now && !current_owned
        current_start = created_at
      elsif !owned_now && current_owned
        intervals << [current_start, created_at]
        current_start = nil
      end

      effective = new_effective
      current_owned = owned_now
    end

    # The live tail: whoever domain.registrant_id currently is closes at @now. Trust the
    # live domain over the reconstructed run so the open interval is anchored to reality.
    if own?(@domain.registrant_id)
      current_start ||= rows.first&.first
      intervals << [current_start, @now]
    elsif current_owned && current_start
      # Reconstructed run left the caller owning but the live domain is no longer theirs
      # without a closing version row — close at @now defensively (should not normally happen).
      intervals << [current_start, @now]
    end

    intervals
  end

  # Effective registrant AFTER an event. object_changes.registrant_id is a [old, new]
  # JSON array (take [1]); object.registrant_id is a scalar. Mirror the string-vs-parsed
  # handling in legal_document.rb:102-111. When neither is present, carry forward.
  def effective_registrant(changes_registrant, object_registrant, carry)
    if changes_registrant.present?
      parsed = parse_json(changes_registrant)
      return parsed[1] if parsed.is_a?(Array)

      return parsed
    end

    return to_id(object_registrant) if object_registrant.present?

    carry
  end

  def parse_json(value)
    JSON.parse(value)
  rescue JSON::ParserError, TypeError
    value
  end

  def to_id(value)
    Integer(value)
  rescue ArgumentError, TypeError
    value
  end

  def own?(registrant_id)
    return false if registrant_id.nil?

    @own_ids.include?(to_id(registrant_id))
  end

  # OR of per-interval half-open bounds: (requested_at >= ? AND requested_at < ?).
  def interval_predicate(intervals)
    Array.new(intervals.size, '(requested_at >= ? AND requested_at < ?)').join(' OR ')
  end

  def interval_binds(intervals)
    intervals.flat_map { |start_at, end_at| [start_at, end_at] }
  end
end
