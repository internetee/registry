class ZonefileSetting < ActiveRecord::Base
  include Versions # version/zonefile_setting_version.rb
  validates :origin, :ttl, :refresh, :retry, :expire, :minimum_ttl, :email, presence: true
  validates :ttl, :refresh, :retry, :expire, :minimum_ttl, numericality: { only_integer: true }

  def self.generate_zonefiles
    pluck(:origin).each do |origin|
      generate_zonefile(origin)
    end
  end

  def self.generate_zonefile(origin)
    filename = "#{origin}.zone"

    STDOUT << "#{Time.now.utc} - Generating zonefile #{filename}\n"

    zf = ActiveRecord::Base.connection.execute(
      "select generate_zonefile('#{origin}')"
    )[0]['generate_zonefile']

    File.open("#{ENV['zonefile_export_dir']}/#{filename}", 'w') { |f| f.write(zf) }

    STDOUT << "#{Time.now.utc} - Successfully generated zonefile #{filename}\n"
  end

  def to_s
    origin
  end
end
