# frozen_string_literal: true

require 'csv'

# Daily check of Estonian private person contacts against the local death
# registry file. Every contact linked to a domain is checked once a year; a run
# only takes the contacts whose last check is older than CHECK_INTERVAL.
#
# The job also rebuilds the death registry file when it is older than
# FILE_REBUILD_AGE, so production needs a single cron line.
#
# In dry run mode (the default) nothing is saved and no poll messages are sent;
# the findings are written to a CSV report that is emailed to the admin.
class DeathRegistryCheckJob < ApplicationJob
  CHECK_INTERVAL = 1.year
  FORCE_DELETE_DELAY = 6.months
  FILE_REBUILD_AGE = 7.days
  BATCH_SIZE = 1000
  REPORT_HEADERS = %w[contact_code ident death_date roles domains registrars six_months_passed].freeze

  queue_as :default

  def self.dry_run?
    ENV['death_registry_dry_run'] != 'false'
  end

  def perform(dry_run: self.class.dry_run?)
    @dry_run = dry_run
    @problems = []
    @findings = []
    @checked = 0

    rebuild_file_if_old
    lookup = DeathRegistry::Lookup.new

    if lookup.available?
      ::PaperTrail.request(whodunnit: "cron - #{self.class.name}") { check_contacts(lookup) }
      report_dry_run if dry_run
      Rails.logger.info("#{self.class.name}: checked #{@checked} contacts, found #{@findings.size} " \
                        "deceased#{' (dry run)' if dry_run}")
    else
      @problems << "Death registry file #{lookup.path} is missing, stale or malformed. " \
                   'Contacts were not checked.'
    end

    notify_admin_about_problems
  end

  private

  attr_reader :dry_run

  def rebuild_file_if_old
    path = DeathRegistry.file_path
    return if File.file?(path) && File.mtime(path) >= FILE_REBUILD_AGE.ago

    count = DeathRegistry::FileBuilder.new.call
    Rails.logger.info("#{self.class.name}: rebuilt #{path} with #{count} records")
  rescue StandardError => e
    Rails.logger.error("#{self.class.name}: rebuilding #{path} failed: #{e.message}")
    @problems << "Rebuilding the death registry file failed: #{e.message}"
  end

  def check_contacts(lookup)
    due_contacts.find_in_batches(batch_size: BATCH_SIZE) do |contacts|
      checked_at = Time.zone.now
      alive_ids = []

      contacts.each do |contact|
        death_date = lookup.death_date(contact.ident)
        death_date ? handle_deceased(contact, death_date, checked_at) : alive_ids << contact.id
      end

      Contact.where(id: alive_ids).update_all(death_registry_checked_at: checked_at) unless dry_run || alive_ids.empty?
      @checked += contacts.size
    end
  end

  def due_contacts
    Contact.where(ident_type: Contact::PRIV, ident_country_code: 'EE', death_date: nil)
           .where('contacts.death_registry_checked_at IS NULL OR contacts.death_registry_checked_at < ?',
                  CHECK_INTERVAL.ago)
           .where('EXISTS (SELECT 1 FROM domains WHERE domains.registrant_id = contacts.id) ' \
                  'OR EXISTS (SELECT 1 FROM domain_contacts WHERE domain_contacts.contact_id = contacts.id)')
  end

  def handle_deceased(contact, death_date, checked_at)
    registrant_domains = contact.registrant_domains.includes(:registrar).to_a
    @findings << finding_row(contact, death_date, registrant_domains)
    return if dry_run

    contact.death_date = death_date
    contact.death_registry_checked_at = checked_at
    contact.save!(validate: false)

    notify_registrars(contact, registrant_domains) unless force_delete_due?(death_date)
  end

  def force_delete_due?(death_date)
    death_date + FORCE_DELETE_DELAY <= Time.zone.today
  end

  # Poll message A1. When six months have already passed, step 4 starts the
  # force delete instead and its own poll message is sent.
  def notify_registrars(contact, domains)
    force_delete_start = contact.death_date + FORCE_DELETE_DELAY + 1.day

    domains.each do |domain|
      domain.registrar.notifications.create!(
        text: I18n.t('death_registry_registrant_deceased',
                     domain_name: domain.name,
                     ident: contact.ident,
                     death_date: contact.death_date,
                     force_delete_start: force_delete_start),
        attached_obj_id: domain.id,
        attached_obj_type: domain.class.name
      )
    end
  end

  def finding_row(contact, death_date, registrant_domains)
    roles = Hash.new { |hash, key| hash[key] = [] }
    registrant_domains.each { |domain| roles[domain] << 'registrant' }
    contact.domain_contacts.includes(domain: :registrar).each do |domain_contact|
      roles[domain_contact.domain] << domain_contact.type.delete_suffix('DomainContact').downcase
    end

    [contact.code, contact.ident, death_date,
     roles.values.flatten.uniq.sort.join(' '),
     roles.map { |domain, domain_roles| "#{domain.name} (#{domain_roles.join(', ')})" }.sort.join(' '),
     roles.keys.map { |domain| domain.registrar.name }.uniq.sort.join(', '),
     force_delete_due?(death_date)]
  end

  def report_dry_run
    path = write_report
    AdminMailer.death_registry_dry_run_report(report_path: path, checked: @checked,
                                              found: @findings.size).deliver_now
  rescue StandardError => e
    Rails.logger.error("#{self.class.name}: dry run report failed: #{e.message}")
    @problems << "Writing or sending the dry run report failed: #{e.message}"
  end

  def write_report
    dir = File.join(File.dirname(DeathRegistry.file_path), 'reports')
    FileUtils.mkdir_p(dir)
    path = File.join(dir, "dry_run_#{Time.zone.today.iso8601}.csv")

    CSV.open(path, 'w') do |csv|
      csv << REPORT_HEADERS
      @findings.each { |row| csv << row }
    end

    path
  end

  def notify_admin_about_problems
    return if @problems.empty?

    Rails.logger.warn("#{self.class.name}: #{@problems.join(' ')}")
    AdminMailer.death_registry_problem(problems: @problems).deliver_now
  end
end
