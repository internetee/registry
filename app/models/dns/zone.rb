module DNS
  class Zone < ActiveRecord::Base
    self.auto_html5_validation = false

    validates :origin, :ttl, :refresh, :retry, :expire, :minimum_ttl, :email, :master_nameserver, presence: true
    validates :ttl, :refresh, :retry, :expire, :minimum_ttl, numericality: { only_integer: true }
    validates :origin, uniqueness: true

    before_destroy do
      !used?
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

    def self.origins
      pluck(:origin)
    end

    def used?
      Domain.uses_zone?(self)
    end

    def to_s
      origin
    end

    def to_partial_path
      'zone'
    end
  end
end
