# frozen_string_literal: true

desc 'Rake task run outzone setter task for force deleted domains by invalid emails'

task outzone_invalid_email_domains: :environment do
  OutzoneInvalidEmailDomainsJob.perform_later
end
