# Log all user issues raised by active record
# rubocop: disable Metrics/LineLength
class ActiveRecord::Base
  after_validation do |m|
    Rails.logger.info "USER MSG: ACTIVERECORD: #{m.class} ##{m.id} #{m.errors.full_messages} #{m.errors['epp_errors']}" if m.errors.present?
    true
  end
end
