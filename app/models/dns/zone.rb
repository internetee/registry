# frozen_string_literal: true

module DNS
  class Zone < ApplicationRecord
    validates :origin, :ttl, :refresh, :retry, :expire, :minimum_ttl, :email, :master_nameserver, presence: true
    validates :ttl, :refresh, :retry, :expire, :minimum_ttl, numericality: { only_integer: true }
    validates :origin, uniqueness: true
    include ::Zone::WhoisQueryable

    before_destroy do
      throw(:abort) if used?
    end

    def self.generate_zonefiles
      pluck(:origin).each do |origin|
        generate_zonefile(origin)
      end
    end

    def self.generate_zonefile(origin)
      filename = "#{origin}.zone"

      $stdout << "#{Time.zone.now.utc} - Generating zonefile #{filename}\n"

      zf = ActiveRecord::Base.connection.exec_query(
        "select generate_zonefile($1)",
        'Generate Zonefile',
        [[nil, origin]]
      )[0]['generate_zonefile']

      File.open("#{ENV['zonefile_export_dir']}/#{filename}", 'w') { |f| f.write(zf) }

      $stdout << "#{Time.zone.now.utc} - Successfully generated zonefile #{filename}\n"
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
