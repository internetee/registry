class Keyrelay < ActiveRecord::Base
  include EppErrors

  belongs_to :domain

  belongs_to :requester, class_name: 'Registrar'
  belongs_to :accepter, class_name: 'Registrar'

  delegate :name, to: :domain, prefix: true

  validates :expiry_relative, duration_iso8601: true

  def epp_code_map
    {
      '2005' => [
        [:expiry_relative, :unknown_pattern, { value: { obj: 'relative', val: expiry_relative } }]
      ]
    }
  end

  def status
    if expiry_relative
      exp_date = pa_date + ISO8601::Duration.new(expiry_relative).to_seconds
    elsif expiry_absolute
      exp_date = expiry_positive
    end

    if Time.now > exp_date
      return 'expired'
    else
      return 'pending'
    end
  end
end
