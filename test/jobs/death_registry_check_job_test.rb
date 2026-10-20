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

  def test_removes_deceased_admin_contact_found_in_same_run
    ENV['death_registry_dry_run'] = 'false'

    DeathRegistryCheckJob.perform_now

    assert_equal @recent_death, @admin.reload.death_date
    assert_not_includes domains(:shop).reload.admin_contacts, @admin
    assert_empty Notification.where('text LIKE ?', "%#{ADMIN_IDENT}%")
  end

  def test_starts_force_delete_instead_of_death_poll_when_six_months_have_passed
    ENV['death_registry_dry_run'] = 'false'
    old_death = Time.zone.today - 6.months
    write_death_file(REGISTRANT_IDENT => old_death)

    DeathRegistryCheckJob.perform_now

    assert_equal old_death, @registrant.reload.death_date
    assert_not Notification.where('text LIKE ?', 'According to the Estonian Population Register%').exists?
    assert domains(:shop).reload.force_delete_scheduled?
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

  def test_does_not_check_contacts_with_death_date_again
    ENV['death_registry_dry_run'] = 'false'
    @registrant.update_columns(death_date: @recent_death)

    DeathRegistryCheckJob.perform_now

    assert_not Notification.where('text LIKE ?', "%(ident #{REGISTRANT_IDENT}) died%").exists?

    assert_nil @registrant.reload.death_registry_checked_at
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

  def test_starts_fast_track_force_delete_six_months_after_death
    ENV['death_registry_dry_run'] = 'false'
    death_date = Time.zone.today - 6.months
    mark_deceased(@registrant, death_date)

    DeathRegistryCheckJob.perform_now

    @registrant.registrant_domains.each do |domain|
      assert domain.force_delete_scheduled?, domain.name
      assert_equal 'fast_track', domain.force_delete_type
      assert_equal 'deceased_person', domain.template_name
      assert_equal Time.zone.tomorrow, domain.force_delete_start.to_date
      assert_includes domain.status_notes[DomainStatus::FORCE_DELETE], REGISTRANT_IDENT
    end

    polls = Notification.where('text LIKE ?', 'Force delete set on domain % because%').pluck(:text)
    assert_equal @registrant.registrant_domains.count, polls.size
    assert polls.all? { |text| text.include?("(ident #{REGISTRANT_IDENT}) has died") }

    mail = ActionMailer::Base.deliveries.find { |m| m.subject.include?('shop.test') }
    assert_includes mail.text_part.body.to_s, 'on surnud ja sellest on möödunud vähemalt 6 kuud'
  end

  def test_force_delete_starts_on_last_day_of_shorter_month
    ENV['death_registry_dry_run'] = 'false'
    mark_deceased(@registrant, Date.new(2026, 8, 31))

    travel_to Time.zone.parse('2027-02-27 05:00') do
      File.utime(Time.now, Time.now, @path)
      DeathRegistryCheckJob.perform_now
      assert_not domains(:shop).reload.force_delete_scheduled?
    end

    travel_to Time.zone.parse('2027-02-28 05:00') do
      File.utime(Time.now, Time.now, @path)
      DeathRegistryCheckJob.perform_now
      assert_equal Date.new(2027, 3, 1), domains(:shop).reload.force_delete_start.to_date
    end
  end

  def test_no_force_delete_before_six_months
    ENV['death_registry_dry_run'] = 'false'
    mark_deceased(@registrant, Time.zone.today - 6.months + 1.day)

    DeathRegistryCheckJob.perform_now

    assert_not domains(:shop).reload.force_delete_scheduled?
  end

  def test_clears_death_date_instead_of_force_delete_when_person_left_registry
    ENV['death_registry_dry_run'] = 'false'
    mark_deceased(@registrant, Time.zone.today - 7.months)
    write_death_file(UNLINKED_IDENT => @recent_death)

    assert_no_difference 'Notification.count' do
      DeathRegistryCheckJob.perform_now
    end

    assert_nil @registrant.reload.death_date
    assert_not_nil @registrant.death_registry_checked_at
    assert_not domains(:shop).reload.force_delete_scheduled?
  end

  def test_leaves_existing_force_delete_alone
    ENV['death_registry_dry_run'] = 'false'
    domain = domains(:shop)
    domain.schedule_force_delete(type: :soft, notify_by_email: true, reason: 'invalid_email',
                                 email: 'john@inbox.test')
    mark_deceased(@registrant, Time.zone.today - 7.months)

    DeathRegistryCheckJob.perform_now

    assert_equal 'invalid_email', domain.reload.template_name
    assert_equal 'soft', domain.force_delete_type
    assert_equal 'deceased_person', domains(:airport).reload.template_name
  end

  def test_cancels_force_delete_when_person_leaves_registry
    ENV['death_registry_dry_run'] = 'false'
    mark_deceased(@registrant, Time.zone.today - 7.months)
    DeathRegistryCheckJob.perform_now
    assert domains(:shop).reload.force_delete_scheduled?

    write_death_file(ADMIN_IDENT => @recent_death)
    DeathRegistryCheckJob.perform_now

    domain = domains(:shop).reload
    assert_not domain.force_delete_scheduled?
    assert_nil domain.template_name
    assert_nil @registrant.reload.death_date
    assert Notification.exists?(text: 'Force delete is cancelled on domain shop.test')
  end

  def test_keeps_force_delete_while_person_is_in_registry
    ENV['death_registry_dry_run'] = 'false'
    mark_deceased(@registrant, Time.zone.today - 7.months)
    DeathRegistryCheckJob.perform_now

    assert_no_difference 'Notification.count' do
      DeathRegistryCheckJob.perform_now
    end

    assert domains(:shop).reload.force_delete_scheduled?
  end

  def test_valid_contact_email_does_not_cancel_deceased_registrant_force_delete
    ENV['death_registry_dry_run'] = 'false'
    mark_deceased(@registrant, Time.zone.today - 7.months)
    DeathRegistryCheckJob.perform_now

    @registrant.reload.remove_force_delete_for_valid_contact

    assert domains(:shop).reload.force_delete_scheduled?
  end

  private

  def mark_deceased(contact, death_date)
    contact.update_columns(death_date: death_date, death_registry_checked_at: Time.zone.now)
    write_death_file(contact.ident => death_date)
  end

  def make_estonian_person(contact, ident)
    contact.update_columns(ident: ident, ident_type: 'priv', ident_country_code: 'EE',
                           death_date: nil, death_registry_checked_at: nil)
  end

  def write_death_file(records)
    File.write(@path, records.sort.map { |ident, date| "#{ident};#{date.iso8601}\n" }.join)
  end
end
