require 'resolv'
require 'dnsruby'

class DNSValidator
  include Dnsruby
  
  attr_reader :domain, :results, :record_type, :apply_changes
  
  def initialize(domain:, name:, record_type:, apply_changes: true)
    @domain = domain.present? ? domain : Domain.find_by_name(name)
    raise "Domain not found" if @domain.blank?
    @record_type = record_type
    @apply_changes = apply_changes

    @results = {
      nameservers: {},
      dns_records: {},
      dnssec: {},
      csync: {},
      errors: [],
      warnings: []
    }
  end

  def self.validate(domain:, name:, record_type:, apply_changes: true)
    new(domain: domain, name: name, record_type: record_type, apply_changes: apply_changes).validate
  end
  
  def validate
    Rails.logger.info "Starting DNS validation for domain: #{domain.name}"
    
    case record_type
    when 'NS'
      validate_nameservers
    when 'A', 'AAAA'
      validate_dns_records
    when 'DNSKEY'
      check_dnssec_sync_records
    when 'CSYNC'
      check_csync_records
    when 'all'
      validate_nameservers
      validate_dns_records
      check_dnssec_sync_records
      check_csync_records
    else
      raise "Invalid record type: #{record_type}"
    end
    
    apply_enforcement_actions
    
    Rails.logger.info "DNS validation completed for domain: #{domain.name}"
    @results
  rescue StandardError => e
    Rails.logger.error "DNS validation failed for #{domain.name}: #{e.message}"
    @results[:errors] << "Validation failed: #{e.message}"
    @results
  end
  
  private
  
  def validate_nameservers
    Rails.logger.info "Validating nameservers for domain: #{domain.name}"
    
    domain.nameservers.each do |nameserver|
      result = validate_single_nameserver(nameserver)
      @results[:nameservers][nameserver.hostname] = result
      
      if result[:valid]
        # Update nameserver validation status
        nameserver.update_columns(
          validation_datetime: Time.current,
          validation_counter: 0,
          failed_validation_reason: nil
        )
      else
        @results[:errors] << "Nameserver #{nameserver.hostname} failed validation: #{result[:reason]}"
        
        # Update failure counter
        counter = (nameserver.validation_counter || 0) + 1
        nameserver.update_columns(
          validation_datetime: Time.current,
          validation_counter: counter,
          failed_validation_reason: result[:reason]
        )
      end
    end
  end
  
  def validate_single_nameserver(nameserver)
    result = {
      hostname: nameserver.hostname,
      valid: false,
      authoritative: false,
      ns_records: [],
      reason: nil
    }
    
    begin
      resolver = create_resolver(nameserver.hostname)
      
      # Query SOA to check if nameserver is authoritative for this domain
      soa_response = resolver.query(domain.name, 'SOA')
      
      if soa_response.answer.empty?
        result[:reason] = 'No SOA record found'
        return result
      end
      
      # Check for CNAME at domain apex (invalid)
      if soa_response.answer.any? { |a| a.type == 'CNAME' }
        result[:reason] = 'Domain has CNAME record at apex (invalid)'
        return result
      end
      
      # Check SOA record
      soa_record = soa_response.answer.find { |a| a.type == 'SOA' }
      if soa_record
        result[:authoritative] = true
      end
      
      # Query NS records to verify this nameserver is listed
      ns_response = resolver.query(domain.name, 'NS')
      result[:ns_records] = ns_response.answer.map { |a| a.nsdname.to_s if a.type == 'NS' }.compact
      
      # Check if this nameserver is in the NS records
      if result[:ns_records].any? { |ns| ns.downcase == nameserver.hostname.downcase }
        result[:valid] = true
      else
        result[:reason] = 'Nameserver not listed in zone NS records'
      end
      
    rescue Dnsruby::NXDomain
      result[:reason] = 'Domain not found'
    rescue Dnsruby::Refused
      result[:reason] = 'Query refused'
    rescue StandardError => e
      result[:reason] = "Query failed: #{e.message}"
    end
    
    result
  end
  
  # Story 2: Resolve and Validate DNS Records
  def validate_dns_records
    Rails.logger.info "Validating DNS records for domain: #{domain.name}"
    
    @results[:dns_records] = {
      a_records: [],
      aaaa_records: [],
      cname_records: []
    }
    
    # Only check records from valid nameservers
    valid_nameservers = domain.nameservers.select do |ns|
      @results[:nameservers][ns.hostname]&.dig(:valid)
    end
    
    if valid_nameservers.empty?
      @results[:warnings] << "No valid nameservers found for DNS record validation"
      return
    end
    
    valid_nameservers.each do |nameserver|
      validate_records_from_nameserver(nameserver)
    end
    
    # Check for glue records if needed
    validate_glue_records
  end
  
  def validate_records_from_nameserver(nameserver)
    resolver = create_resolver(nameserver.hostname)
    
    # Validate A records
    begin
      a_response = resolver.query(domain.name, 'A')
      a_response.answer.each do |record|
        next unless record.type == 'A'
        @results[:dns_records][:a_records] << {
          address: record.address.to_s,
          ttl: record.ttl,
          nameserver: nameserver.hostname
        }
      end
    rescue Dnsruby::NXDomain
      # No A records
    rescue StandardError => e
      @results[:warnings] << "Failed to query A records from #{nameserver.hostname}: #{e.message}"
    end
    
    # Validate AAAA records
    begin
      aaaa_response = resolver.query(domain.name, 'AAAA')
      aaaa_response.answer.each do |record|
        next unless record.type == 'AAAA'
        @results[:dns_records][:aaaa_records] << {
          address: record.address.to_s,
          ttl: record.ttl,
          nameserver: nameserver.hostname
        }
      end
    rescue Dnsruby::NXDomain
      # No AAAA records
    rescue StandardError => e
      @results[:warnings] << "Failed to query AAAA records from #{nameserver.hostname}: #{e.message}"
    end
    
    # Check for CNAME records (should not exist at apex)
    begin
      cname_response = resolver.query(domain.name, 'CNAME')
      cname_response.answer.each do |record|
        next unless record.type == 'CNAME'
        @results[:dns_records][:cname_records] << {
          target: record.cname.to_s,
          ttl: record.ttl,
          nameserver: nameserver.hostname
        }
        @results[:errors] << "CNAME record found at domain apex (invalid DNS configuration)"
      end
    rescue Dnsruby::NXDomain
      # No CNAME records (good)
    rescue StandardError => e
      @results[:warnings] << "Failed to query CNAME records from #{nameserver.hostname}: #{e.message}"
    end
  end
  
  def validate_glue_records
    domain.nameservers.each do |nameserver|
      # Check if nameserver is in-bailiwick (subdomain of the domain)
      next unless nameserver.hostname.end_with?(".#{domain.name}")
      
      # Validate IPv4 glue records
      nameserver.ipv4.each do |ip|
        if valid_ipv4?(ip)
          @results[:dns_records][:a_records] << {
            address: ip,
            ttl: 0,
            nameserver: 'glue',
            type: 'glue_record'
          }
        else
          @results[:errors] << "Invalid IPv4 glue record for #{nameserver.hostname}: #{ip}"
        end
      end
      
      # Validate IPv6 glue records
      nameserver.ipv6.each do |ip|
        if valid_ipv6?(ip)
          @results[:dns_records][:aaaa_records] << {
            address: ip,
            ttl: 0,
            nameserver: 'glue',
            type: 'glue_record'
          }
        else
          @results[:errors] << "Invalid IPv6 glue record for #{nameserver.hostname}: #{ip}"
        end
      end
    end
  end
  
  # Story 4: Check CDS/CDNSKEY records for DNSSEC synchronization
  def check_dnssec_sync_records
    Rails.logger.info "Checking DNSSEC synchronization records for domain: #{domain.name}"
    
    @results[:dnssec] = {
      cds_records: [],
      cdnskey_records: [],
      ds_updates_needed: []
    }
    
    return unless domain.dnskeys.any? # Only check if DNSSEC is enabled
    
    domain.nameservers.each do |nameserver|
      check_cds_records(nameserver)
      check_cdnskey_records(nameserver)
    end
  end
  
  def check_cds_records(nameserver)
    begin
      resolver = create_resolver(nameserver.hostname)
      response = resolver.query(domain.name, 'CDS')
      
      response.answer.each do |record|
        next unless record.type == 'CDS'
        
        cds_data = {
          key_tag: record.key_tag,
          algorithm: record.algorithm,
          digest_type: record.digest_type,
          digest: record.digest.upcase,
          nameserver: nameserver.hostname,
          validated: false
        }
        
        # Validate CDS record if DNSSEC is enabled
        if domain.dnskeys.any? && validate_dnssec_chain(nameserver)
          cds_data[:validated] = true
        end
        
        @results[:dnssec][:cds_records] << cds_data
        
        # Only process validated CDS records or if no DNSSEC validation required
        if cds_data[:validated] || domain.dnskeys.empty?
          # Check if DS record update is needed
          if record.algorithm == 0
            @results[:dnssec][:ds_updates_needed] << {
              action: 'remove_ds',
              reason: 'CDS record with algorithm 0 indicates DS removal',
              validated: cds_data[:validated]
            }
          else
            # Check if we need to update DS records
            existing_ds = domain.dnskeys.find_by(ds_key_tag: record.key_tag.to_s)
            if !existing_ds || 
               existing_ds.ds_digest != record.digest.upcase ||
               existing_ds.ds_alg != record.algorithm ||
               existing_ds.ds_digest_type != record.digest_type
              @results[:dnssec][:ds_updates_needed] << {
                action: 'update_ds',
                cds_data: cds_data,
                reason: 'CDS record indicates DS record update needed',
                validated: cds_data[:validated]
              }
            end
          end
        else
          @results[:warnings] << "CDS record from #{nameserver.hostname} not validated - skipping"
        end
      end
    rescue Dnsruby::NXDomain
      # No CDS records
    rescue StandardError => e
      @results[:warnings] << "Failed to query CDS records from #{nameserver.hostname}: #{e.message}"
    end
  end
  
  def check_cdnskey_records(nameserver)
    begin
      resolver = create_resolver(nameserver.hostname)
      response = resolver.query(domain.name, 'CDNSKEY')
      
      response.answer.each do |record|
        next unless record.type == 'CDNSKEY'
        
        # Handle the special delete CDNSKEY (algorithm 0)
        if record.algorithm == 0
          @results[:dnssec][:cdnskey_records] << {
            flags: record.flags,
            protocol: record.protocol,
            algorithm: 0,
            public_key: nil,
            nameserver: nameserver.hostname,
            validated: true,
            action: 'delete'
          }
          
          @results[:dnssec][:ds_updates_needed] << {
            action: 'remove_all_dnskeys',
            reason: 'CDNSKEY with algorithm 0 indicates removal of all DNSSEC keys',
            validated: true
          }
          next
        end
        
        cdnskey_data = {
          flags: record.flags,
          protocol: record.protocol,
          algorithm: record.algorithm,
          public_key: Base64.strict_encode64(record.key),
          nameserver: nameserver.hostname,
          validated: false
        }
        
        # Validate CDNSKEY record if DNSSEC is enabled
        if domain.dnskeys.any? && validate_dnssec_chain(nameserver)
          cdnskey_data[:validated] = true
        end
        
        @results[:dnssec][:cdnskey_records] << cdnskey_data
        
        # Only process validated CDNSKEY records or if no DNSSEC validation required
        if cdnskey_data[:validated] || domain.dnskeys.empty?
          # Check if this DNSKEY exists in our database
          existing_key = domain.dnskeys.find_by(
            flags: record.flags,
            protocol: record.protocol,
            alg: record.algorithm,
            public_key: cdnskey_data[:public_key]
          )
          
          unless existing_key
            @results[:dnssec][:ds_updates_needed] << {
              action: 'add_dnskey',
              cdnskey_data: cdnskey_data,
              reason: 'CDNSKEY record indicates new DNSKEY should be added',
              validated: cdnskey_data[:validated]
            }
          end
          
          # Check for key rotation - if CDNSKEY exists but old keys should be removed
          if cdnskey_data[:flags] == 257 # KSK
            old_keys = domain.dnskeys.where(flags: 257).where.not(
              public_key: cdnskey_data[:public_key]
            )
            if old_keys.any?
              @results[:dnssec][:ds_updates_needed] << {
                action: 'rotate_ksk',
                cdnskey_data: cdnskey_data,
                old_keys: old_keys.pluck(:id),
                reason: 'CDNSKEY indicates KSK rotation',
                validated: cdnskey_data[:validated]
              }
            end
          end
        else
          @results[:warnings] << "CDNSKEY record from #{nameserver.hostname} not validated - skipping"
        end
      end
    rescue Dnsruby::NXDomain
      # No CDNSKEY records
    rescue StandardError => e
      @results[:warnings] << "Failed to query CDNSKEY records from #{nameserver.hostname}: #{e.message}"
    end
  end
  
  # Story 5: Check CSYNC records for delegation synchronization
  def check_csync_records
    Rails.logger.info "Checking CSYNC records for domain: #{domain.name}"
    
    @results[:csync] = {
      csync_records: [],
      delegation_updates_needed: []
    }
    
    domain.nameservers.each do |nameserver|
      check_single_csync_record(nameserver)
    end
  end
  
  def check_single_csync_record(nameserver)
    begin
      resolver = create_resolver(nameserver.hostname)
      
      # Since Dnsruby doesn't support CSYNC, we need to query TYPE62
      # CSYNC is RFC 7477, type 62
      message = Dnsruby::Message.new(domain.name, 'TYPE62', 'IN')
      response = resolver.send_message(message)
      
      response.answer.each do |record|
        # Parse CSYNC record manually
        csync_data = parse_csync_record(record, nameserver)
        next unless csync_data
        
        @results[:csync][:csync_records] << csync_data
        
        # Check what needs to be synchronized based on type bitmap
        if csync_data[:type_bitmap].include?('NS')
          check_ns_sync_needed(nameserver)
        end
        
        if csync_data[:type_bitmap].include?('A')
          check_a_sync_needed(nameserver)
        end
        
        if csync_data[:type_bitmap].include?('AAAA')
          check_aaaa_sync_needed(nameserver)
        end
      end
    rescue Dnsruby::NXDomain
      # No CSYNC records
    rescue StandardError => e
      @results[:warnings] << "Failed to query CSYNC records from #{nameserver.hostname}: #{e.message}"
    end
  end
  
  def parse_csync_record(record, nameserver)
    return nil unless record.type_string == 'TYPE62' || record.type == 62
    
    # CSYNC record format: SOA serial (4 bytes) + flags (2 bytes) + type bitmap
    rdata = record.rdata
    return nil if rdata.nil? || rdata.length < 6
    
    # Parse binary data
    data = rdata.unpack('C*')
    
    # Extract SOA serial (32 bits)
    serial = (data[0] << 24) | (data[1] << 16) | (data[2] << 8) | data[3]
    
    # Extract flags (16 bits)
    flags = (data[4] << 8) | data[5]
    
    # Parse type bitmap (remaining bytes)
    type_bitmap = parse_dns_type_bitmap(data[6..-1])
    
    {
      serial: serial,
      flags: flags,
      type_bitmap: type_bitmap,
      nameserver: nameserver.hostname,
      immediate: (flags & 0x01) == 1,  # Bit 0: immediate flag
      soaminimum: (flags & 0x02) == 2  # Bit 1: soaminimum flag
    }
  rescue StandardError => e
    Rails.logger.error "Failed to parse CSYNC record: #{e.message}"
    nil
  end
  
  def parse_dns_type_bitmap(bitmap_data)
    return [] if bitmap_data.nil? || bitmap_data.empty?
    
    types = []
    i = 0
    
    while i < bitmap_data.length
      window_number = bitmap_data[i]
      bitmap_length = bitmap_data[i + 1]
      
      break if i + 2 + bitmap_length > bitmap_data.length
      
      bitmap = bitmap_data[(i + 2)...(i + 2 + bitmap_length)]
      
      bitmap.each_with_index do |byte, byte_index|
        8.times do |bit|
          if (byte & (0x80 >> bit)) != 0
            type_number = (window_number * 256) + (byte_index * 8) + bit
            types << dns_type_name(type_number)
          end
        end
      end
      
      i += 2 + bitmap_length
    end
    
    types
  end
  
  def dns_type_name(type_number)
    type_map = {
      1 => 'A',
      2 => 'NS',
      5 => 'CNAME',
      6 => 'SOA',
      12 => 'PTR',
      15 => 'MX',
      16 => 'TXT',
      28 => 'AAAA',
      33 => 'SRV',
      43 => 'DS',
      46 => 'RRSIG',
      47 => 'NSEC',
      48 => 'DNSKEY',
      50 => 'NSEC3',
      51 => 'NSEC3PARAM',
      59 => 'CDS',
      60 => 'CDNSKEY',
      62 => 'CSYNC'
    }
    
    type_map[type_number] || "TYPE#{type_number}"
  end
  
  def check_ns_sync_needed(nameserver)
    # Get NS records from child zone
    child_ns_records = @results[:nameservers].values
      .select { |ns| ns[:valid] }
      .flat_map { |ns| ns[:ns_records] }
      .uniq
    
    # Compare with current nameservers
    current_ns = domain.nameservers.map(&:hostname)
    
    to_add = child_ns_records - current_ns
    to_remove = current_ns - child_ns_records
    
    if to_add.any? || to_remove.any?
      @results[:csync][:delegation_updates_needed] << {
        type: 'ns_records',
        add: to_add,
        remove: to_remove,
        reason: 'CSYNC indicates NS record synchronization needed'
      }
    end
  end
  
  def check_a_sync_needed(nameserver)
    # Check A record synchronization for in-bailiwick nameservers
    domain.nameservers.each do |ns|
      next unless ns.hostname.end_with?(".#{domain.name}")
      
      # Query A records from child zone
      child_a_records = query_a_records_for_host(ns.hostname)
      
      if child_a_records != ns.ipv4
        @results[:csync][:delegation_updates_needed] << {
          type: 'a_records',
          hostname: ns.hostname,
          current_ips: ns.ipv4,
          child_ips: child_a_records,
          reason: 'CSYNC indicates A record glue synchronization needed'
        }
      end
    end
  end
  
  def check_aaaa_sync_needed(nameserver)
    # Check AAAA record synchronization for in-bailiwick nameservers
    domain.nameservers.each do |ns|
      next unless ns.hostname.end_with?(".#{domain.name}")
      
      # Query AAAA records from child zone
      child_aaaa_records = query_aaaa_records_for_host(ns.hostname)
      
      if child_aaaa_records != ns.ipv6
        @results[:csync][:delegation_updates_needed] << {
          type: 'aaaa_records',
          hostname: ns.hostname,
          current_ips: ns.ipv6,
          child_ips: child_aaaa_records,
          reason: 'CSYNC indicates AAAA record glue synchronization needed'
        }
      end
    end
  end
  
  # Story 6: Apply enforcement actions based on validation results
  def apply_enforcement_actions
    Rails.logger.info "Applying enforcement actions for domain: #{domain.name} (apply_changes: #{@apply_changes})"
    
    # Handle failed nameservers
    domain.nameservers.each do |nameserver|
      if nameserver.validation_counter && nameserver.validation_counter >= 3
        @results[:warnings] << "Nameserver #{nameserver.hostname} has failed validation #{nameserver.validation_counter} times"
        
        # Auto-remove if configured and we have enough nameservers
        if @apply_changes && should_auto_remove_nameserver? && domain.nameservers.count > 2
          Rails.logger.info "Auto-removing failed nameserver: #{nameserver.hostname}"
          
          # Notify registrar
          create_notification(
            "Nameserver #{nameserver.hostname} was automatically removed from domain #{domain.name} due to repeated validation failures"
          )
          
          nameserver.destroy
          @results[:warnings] << "Automatically removed nameserver #{nameserver.hostname}"
        end
      end
    end
    
    # Apply DNSSEC updates if needed (only if apply_changes is true)
    if @apply_changes
      @results[:dnssec][:ds_updates_needed].each do |update|
        # Skip non-validated updates unless explicitly allowed
        next if update[:validated] == false && require_dnssec_validation?
        
        case update[:action]
        when 'update_ds'
          update_ds_record(update[:cds_data])
        when 'remove_ds'
          remove_ds_records
        when 'remove_all_dnskeys'
          remove_all_dnskeys
        when 'add_dnskey'
          add_dnskey(update[:cdnskey_data])
        when 'rotate_ksk'
          rotate_ksk(update[:cdnskey_data], update[:old_keys])
        end
      end
      
      # Apply delegation updates if needed
      @results[:csync][:delegation_updates_needed].each do |update|
        case update[:type]
        when 'ns_records'
          update_ns_records(update)
        when 'a_records', 'aaaa_records'
          update_glue_records(update)
        end
      end
    else
      Rails.logger.info "Skipping enforcement actions (apply_changes is false)"
      
      # Log what would have been done
      if @results[:dnssec][:ds_updates_needed].any?
        @results[:warnings] << "DNSSEC updates detected but not applied (validation mode only):"
        @results[:dnssec][:ds_updates_needed].each do |update|
          @results[:warnings] << "  - #{update[:action]}: #{update[:reason]}"
        end
      end
      
      if @results[:csync][:delegation_updates_needed].any?
        @results[:warnings] << "Delegation updates detected but not applied (validation mode only):"
        @results[:csync][:delegation_updates_needed].each do |update|
          @results[:warnings] << "  - #{update[:type]}: #{update[:reason] || 'Update needed'}"
        end
      end
    end
    
    # Send notifications if there are errors
    if @results[:errors].any? && @apply_changes
      create_notification(
        "DNS validation errors found for domain #{domain.name}: #{@results[:errors].join(', ')}"
      )
    end
  end
  
  # Helper methods
  def create_resolver(nameserver_ip)
    resolver = Dnsruby::Resolver.new
    resolver.nameserver = nameserver_ip
    resolver.query_timeout = 5
    resolver.retry_times = 2
    resolver.recurse = 0 # Non-recursive queries
    resolver.do_caching = false
    resolver
  end
  
  def valid_ipv4?(ip)
    ip.match?(Nameserver::IPV4_REGEXP)
  end
  
  def valid_ipv6?(ip)
    ip.match?(Nameserver::IPV6_REGEXP)
  end
  
  def parse_type_bitmap(types)
    types.is_a?(Array) ? types : [types].compact
  end
  
  # DNSSEC validation methods
  def validate_dnssec_chain(nameserver)
    begin
      resolver = create_resolver(nameserver.hostname)
      resolver.dnssec = true
      
      # Try to get DNSKEY records with validation
      response = resolver.query(domain.name, 'DNSKEY')
      
      # Check if response is authenticated
      return response.security_level == Dnsruby::Message::SecurityLevel.SECURE
    rescue StandardError => e
      Rails.logger.warn "DNSSEC validation failed for #{domain.name} via #{nameserver.hostname}: #{e.message}"
      false
    end
  end
  
  def require_dnssec_validation?
    # Require validation if domain already has DNSSEC enabled
    # Can be configured via settings if needed
    domain.dnskeys.any?
  end
  
  def dnssec_validates?
    # Simple DNSSEC validation check
    return true unless domain.dnskeys.any?
    
    valid_nameservers = domain.nameservers.select do |ns|
      validate_dnssec_chain(ns)
    end
    
    valid_nameservers.any?
  end
  
  def query_a_records_for_host(hostname)
    resolver = Dnsruby::Resolver.new
    response = resolver.query(hostname, 'A')
    response.answer.select { |r| r.type == 'A' }.map { |r| r.address.to_s }
  rescue StandardError
    []
  end
  
  def query_aaaa_records_for_host(hostname)
    resolver = Dnsruby::Resolver.new
    response = resolver.query(hostname, 'AAAA')
    response.answer.select { |r| r.type == 'AAAA' }.map { |r| r.address.to_s }
  rescue StandardError
    []
  end
  
  def should_auto_remove_nameserver?
    # Check if auto-removal is enabled (you can add this setting)
    false # Disabled by default for safety
  end
  
  def create_notification(text)
    begin
      domain.registrar.notifications.create!(
        text: text,
        attached_obj_type: domain.class.to_s,
        attached_obj_id: domain.id
      )
    rescue StandardError => e
      Rails.logger.warn "Failed to create notification: #{e.message}"
    end
  end
  
  def update_ds_record(cds_data)
    dnskey = domain.dnskeys.find_or_initialize_by(ds_key_tag: cds_data[:key_tag])
    dnskey.ds_alg = cds_data[:algorithm]
    dnskey.ds_digest_type = cds_data[:digest_type]
    dnskey.ds_digest = cds_data[:digest]
    
    if dnskey.save
      Rails.logger.info "Updated DS record for #{domain.name}"
    else
      Rails.logger.error "Failed to update DS record: #{dnskey.errors.full_messages.join(', ')}"
    end
  end
  
  def remove_ds_records
    domain.dnskeys.update_all(
      ds_digest: nil,
      ds_alg: nil,
      ds_digest_type: nil,
      ds_key_tag: nil
    )
    Rails.logger.info "Removed DS records for #{domain.name}"
    create_notification("DS records removed for domain #{domain.name} based on CDS record")
  end
  
  def remove_all_dnskeys
    count = domain.dnskeys.count
    domain.dnskeys.destroy_all
    Rails.logger.info "Removed all #{count} DNSKEY records for #{domain.name}"
    create_notification("All DNSSEC keys removed for domain #{domain.name} based on CDNSKEY record")
  end
  
  def rotate_ksk(cdnskey_data, old_key_ids)
    # Add new KSK
    new_key = domain.dnskeys.build(
      flags: cdnskey_data[:flags],
      protocol: cdnskey_data[:protocol],
      alg: cdnskey_data[:algorithm],
      public_key: cdnskey_data[:public_key]
    )
    
    if new_key.save
      # Remove old KSKs
      domain.dnskeys.where(id: old_key_ids).destroy_all
      Rails.logger.info "Rotated KSK for #{domain.name}: added new key, removed #{old_key_ids.size} old keys"
      create_notification("KSK rotation completed for domain #{domain.name}")
    else
      Rails.logger.error "Failed to rotate KSK: #{new_key.errors.full_messages.join(', ')}"
      @results[:errors] << "Failed to rotate KSK: #{new_key.errors.full_messages.join(', ')}"
    end
  end
  
  def add_dnskey(cdnskey_data)
    dnskey = domain.dnskeys.build(
      flags: cdnskey_data[:flags],
      protocol: cdnskey_data[:protocol],
      alg: cdnskey_data[:algorithm],
      public_key: cdnskey_data[:public_key]
    )
    
    if dnskey.save
      Rails.logger.info "Added DNSKEY for #{domain.name}"
    else
      Rails.logger.error "Failed to add DNSKEY: #{dnskey.errors.full_messages.join(', ')}"
    end
  end
  
  def update_ns_records(update)
    # Add new nameservers
    update[:add].each do |hostname|
      domain.nameservers.find_or_create_by(hostname: hostname)
    end
    
    # Remove old nameservers
    update[:remove].each do |hostname|
      domain.nameservers.where(hostname: hostname).destroy_all
    end
    
    Rails.logger.info "Updated nameservers for #{domain.name}"
  end
  
  def update_glue_records(update)
    nameserver = domain.nameservers.find_by(hostname: update[:hostname])
    return unless nameserver
    
    if update[:type] == 'a_records'
      nameserver.ipv4 = update[:child_ips]
    else
      nameserver.ipv6 = update[:child_ips]
    end
    
    nameserver.save
    Rails.logger.info "Updated glue records for #{nameserver.hostname}"
  end
  
  # Class methods for easy usage
  class << self
    def validate_domain(domain, record_type: 'all', apply_changes: true)
      validator = new(domain: domain, name: domain.name, record_type: record_type, apply_changes: apply_changes)
      validator.validate
    end
    
    def check_only(domain:, name: nil, record_type: 'all')
      new(domain: domain, name: name || domain&.name, record_type: record_type, apply_changes: false).validate
    end
    
    def apply_dnssec_updates(domain:, name: nil)
      new(domain: domain, name: name || domain&.name, record_type: 'DNSKEY', apply_changes: true).validate
    end
    
    def apply_delegation_updates(domain:, name: nil)
      new(domain: domain, name: name || domain&.name, record_type: 'CSYNC', apply_changes: true).validate
    end
  end
end