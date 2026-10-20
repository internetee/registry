require 'test_helper'

class DeathRegistryCheckJobTest < ActiveJob::TestCase
  REGISTRANT_IDENT = '39708290069'.freeze
  ADMIN_IDENT = '49001010000'.freeze
  ALIVE_IDENT = '38001010000'.freeze
  UNLINKED_IDENT = '38501010000'.freeze

  setup do
    @dir = Dir.mktmpdir
    @path = File.join(@dir, 'deaths.txt')
    @url = 'https://opendata.test/surmaandmed.csv'
    ENV['death_registry_file_path'] = @path
    ENV['death_registry_source_urls'] = @url
    ENV['death_registry_min_records'] = '1'
    ActionMailer::Base.deliveries.clear

    @registrant = contacts(:john)
    @admin = contacts(:jane)
    @alive = contacts(:william)
    @unlinked = contacts(:identical_to_william)
    make_estonian_person(@registrant, REGISTRANT_IDENT)
    make_estonian_person(@admin, ADMIN_IDENT)
    make_estonian_person(@alive, ALIVE_IDENT)
    make_estonian_person(@unlinked, UNLINKED_IDENT)

    @recent_death = Time.zone.today - 1.month
    write_death_file(REGISTRANT_IDENT => @recent_death, ADMIN_IDENT => @recent_death,
                     UNLINKED_IDENT => @recent_death)
  end

  teardown do
    ENV.delete('death_registry_file_path')
    ENV.delete('death_registry_source_urls')
    ENV.delete('death_registry_min_records')
    ENV.delete('death_registry_dry_run')
    FileUtils.rm_rf(@dir)
  end

  def test_dry_run_is_the_default_and_changes_nothing
    assert DeathRegistryCheckJob.dry_run?

    assert_no_difference ['Notification.count', 'Version::ContactVersion.count'] do
      DeathRegistryCheckJob.perform_now
    end

    [@registrant, @admin, @alive].each do |contact|
      contact.reload
      assert_nil contact.death_date
      assert_nil contact.death_registry_checked_at
    end
  end

  def test_dry_run_emails_report_of_deceased_contacts
    DeathRegistryCheckJob.perform_now

    mail = ActionMailer::Base.deliveries.last
    assert_equal 'Death registry dry run report', mail.subject.split(' - ').first
    report = CSV.parse(mail.attachments.first.decoded, headers: true)
    assert_equal [REGISTRANT_IDENT, ADMIN_IDENT].sort, report.map { |row| row['ident'] }.sort

    registrant_row = report.find { |row| row['ident'] == REGISTRANT_IDENT }
    assert_equal @registrant.code, registrant_row['contact_code']
    assert_equal @recent_death.iso8601, registrant_row['death_date']
    assert_includes registrant_row['roles'], 'registrant'
    assert_includes registrant_row['domains'], 'shop.test (registrant)'
    assert_equal 'false', registrant_row['six_months_passed']
    assert File.exist?(File.join(@dir, 'reports', "dry_run_#{Time.zone.today.iso8601}.csv"))
  end

  def test_saves_death_date_and_notifies_registrar_of_each_registrant_domain
    ENV['death_registry_dry_run'] = 'false'

    assert_difference 'Version::ContactVersion.count', 2 do
      DeathRegistryCheckJob.perform_now
    end

    @registrant.reload
    assert_equal @recent_death, @registrant.death_date
    assert_not_nil @registrant.death_registry_checked_at

    texts = Notification.where('text LIKE ?', "%(ident #{REGISTRANT_IDENT})%").pluck(:text)
    assert_equal @registrant.registrant_domains.count, texts.size
    assert texts.any? { |text| text.include?('domain shop.test') }
    assert texts.all? { |text| text.include?((@recent_death + 6.months + 1.day).to_s) }
  end

  def test_saves_only_death_date_for_deceased_admin_contact
    ENV['death_registry_dry_run'] = 'false'

    DeathRegistryCheckJob.perform_now

    assert_equal @recent_death, @admin.reload.death_date
    assert_empty Notification.where('text LIKE ?', "%#{ADMIN_IDENT}%")
  end

  def test_no_poll_when_six_months_have_passed
    ENV['death_registry_dry_run'] = 'false'
    old_death = Time.zone.today - 6.months
    write_death_file(REGISTRANT_IDENT => old_death)

    assert_no_difference 'Notification.count' do
      DeathRegistryCheckJob.perform_now
    end

    assert_equal old_death, @registrant.reload.death_date
  end

  def test_saves_check_time_for_alive_contact_without_version
    ENV['death_registry_dry_run'] = 'false'

    DeathRegistryCheckJob.perform_now

    @alive.reload
    assert_nil @alive.death_date
    assert_not_nil @alive.death_registry_checked_at
    assert_empty @alive.versions.where('created_at > ?', 1.minute.ago)
  end

  def test_skips_contacts_without_domains
    ENV['death_registry_dry_run'] = 'false'
    assert_not @unlinked.linked?

    DeathRegistryCheckJob.perform_now

    @unlinked.reload
    assert_nil @unlinked.death_date
    assert_nil @unlinked.death_registry_checked_at
  end

  def test_rechecks_contact_only_after_a_year
    ENV['death_registry_dry_run'] = 'false'
    @registrant.update_columns(death_registry_checked_at: 11.months.ago)

    DeathRegistryCheckJob.perform_now
    assert_nil @registrant.reload.death_date

    @registrant.update_columns(death_registry_checked_at: 13.months.ago)

    DeathRegistryCheckJob.perform_now
    assert_equal @recent_death, @registrant.reload.death_date
  end

  def test_skips_contacts_with_death_date
    ENV['death_registry_dry_run'] = 'false'
    @registrant.update_columns(death_date: Date.new(2020, 1, 1))

    assert_no_difference 'Notification.count' do
      DeathRegistryCheckJob.perform_now
    end

    assert_equal Date.new(2020, 1, 1), @registrant.reload.death_date
  end

  def test_rebuilds_file_older_than_seven_days
    ENV['death_registry_dry_run'] = 'false'
    File.utime(Time.now, (7.days.ago - 1.hour).to_time, @path)
    stub_request(:get, @url).to_return(status: 200, body: <<~CSV)
      isikukood;surma_kp
      #{REGISTRANT_IDENT};2026-01-02
    CSV

    DeathRegistryCheckJob.perform_now

    assert_equal "#{REGISTRANT_IDENT};2026-01-02\n", File.read(@path)
    assert_equal Date.new(2026, 1, 2), @registrant.reload.death_date
  end

  def test_uses_old_file_and_emails_admin_when_rebuild_fails
    ENV['death_registry_dry_run'] = 'false'
    File.utime(Time.now, (7.days.ago - 1.hour).to_time, @path)
    stub_request(:get, @url).to_return(status: 500)

    DeathRegistryCheckJob.perform_now

    assert_equal @recent_death, @registrant.reload.death_date
    mail = ActionMailer::Base.deliveries.last
    assert_equal 'Death registry check problem', mail.subject.split(' - ').first
    assert_includes mail.body.to_s, 'Rebuilding the death registry file failed'
  end

  def test_skips_run_and_emails_admin_when_file_is_unavailable
    ENV['death_registry_dry_run'] = 'false'
    FileUtils.rm_f(@path)
    stub_request(:get, @url).to_return(status: 500)

    assert_no_difference 'Notification.count' do
      DeathRegistryCheckJob.perform_now
    end

    assert_nil @registrant.reload.death_registry_checked_at
    assert_nil @alive.reload.death_registry_checked_at
    mail = ActionMailer::Base.deliveries.last
    assert_includes mail.body.to_s, 'Contacts were not checked'
  end

  private

  def make_estonian_person(contact, ident)
    contact.update_columns(ident: ident, ident_type: 'priv', ident_country_code: 'EE',
                           death_date: nil, death_registry_checked_at: nil)
  end

  def write_death_file(records)
    File.write(@path, records.sort.map { |ident, date| "#{ident};#{date.iso8601}\n" }.join)
  end
end
