class ZonefileSetting < ActiveRecord::Base
  validates :origin, :ttl, :refresh, :retry, :expire, :minimum_ttl, :email, presence: true
  validates :ttl, :refresh, :retry, :expire, :minimum_ttl, numericality: { only_integer: true }

  def self.generate_zonefiles
    pluck(:origin).each do |origin|
      generate_zonefile(origin)
    end
  end

  def self.generate_zonefile(origin)
    filename = "#{origin}.zone"

    puts "#{Time.now.utc} - Generating zonefile #{filename}\n"

    zf = ActiveRecord::Base.connection.execute(
      "select generate_zonefile('#{origin}')"
    )[0]['generate_zonefile']

    File.open("#{APP_CONFIG['zonefile_export_dir']}/#{filename}", 'w') { |f| f.write(zf) }

    puts "#{Time.now.utc} - Successfully generated zonefile #{filename}\n"
  end

  def to_s
    origin
  end
end
