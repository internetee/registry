class ZonefileSetting < ActiveRecord::Base
  include Versions # version/zonefile_setting_version.rb
  validates :origin, :ttl, :refresh, :retry, :expire, :minimum_ttl, :email, :master_nameserver, presence: true
  validates :ttl, :refresh, :retry, :expire, :minimum_ttl, numericality: { only_integer: true }
  validates :origin, uniqueness: true

  before_destroy :check_for_dependencies
  def check_for_dependencies
    dc = Domain.where("name ILIKE ?", "%.#{origin}").count
    return if dc == 0
    errors.add(:base, I18n.t('there_are_count_domains_in_this_zone', count: dc))
    false
  end

  def self.generate_zonefiles
    pluck(:origin).each do |origin|
      generate_zonefile(origin)
    end
  end

  def self.generate_zonefile(origin)
    filename = "#{origin}.zone"

    STDOUT << "#{Time.zone.now.utc} - Generating zonefile #{filename}\n"

    zf = ActiveRecord::Base.connection.execute(
      "select generate_zonefile('#{origin}')"
    )[0]['generate_zonefile']

    File.open("#{ENV['zonefile_export_dir']}/#{filename}", 'w') { |f| f.write(zf) }

    STDOUT << "#{Time.zone.now.utc} - Successfully generated zonefile #{filename}\n"
  end

  def to_s
    origin
  end
end
