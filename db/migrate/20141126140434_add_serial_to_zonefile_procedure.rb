class AddSerialToZonefileProcedure < ActiveRecord::Migration
  # rubocop:disable Metrics/MethodLength
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION generate_zonefile(i_origin varchar)
      RETURNS text AS $$
      DECLARE
        zone_header text := concat('$ORIGIN ', i_origin, '.');
        serial_num varchar;
        include_filter varchar := '';
        exclude_filter varchar := '';
        ns_records text := '';
        a_records text := '';
        a4_records text := '';
        ds_records text := '';
      BEGIN
        -- define filters
        include_filter = '%' || i_origin;

        -- for %.%.%
        IF i_origin ~ '\\.' THEN
          exclude_filter := '';
        -- for %.%
        ELSE
          exclude_filter := '%.%.' || i_origin;
        END IF;

        SELECT ROUND(extract(epoch from now() at time zone 'utc')) INTO serial_num;

        -- zonefile header
        SELECT concat(
          format('%-10s', '$ORIGIN'), i_origin, '.', chr(10),
          format('%-10s', '$TTL'), zf.ttl, chr(10), chr(10),
          format('%-10s', i_origin || '.'), 'IN SOA ', zf.master_nameserver, '. ', zf.email, '. (', chr(10),
          format('%-17s', ''), format('%-12s', serial_num), '; serial number', chr(10),
          format('%-17s', ''), format('%-12s', zf.refresh), '; refresh, seconds', chr(10),
          format('%-17s', ''), format('%-12s', zf.retry), '; retry, seconds', chr(10),
          format('%-17s', ''), format('%-12s', zf.expire), '; expire, seconds', chr(10),
          format('%-17s', ''), format('%-12s', zf.minimum_ttl), '; minimum TTL, seconds', chr(10),
          format('%-17s', ''), ')'
        ) FROM zonefile_settings zf WHERE i_origin = zf.origin INTO zone_header;

        -- ns records
        SELECT array_to_string(
          array(
            SELECT concat(d.name, '. IN NS ', ns.hostname, '.')
            FROM domains d
            JOIN nameservers ns ON ns.domain_id = d.id
            WHERE d.name LIKE include_filter AND d.name NOT LIKE exclude_filter
            ORDER BY
            CASE d.name
              WHEN i_origin THEN 1
            END
          ),
          chr(10)
        ) INTO ns_records;

        -- a records
        SELECT array_to_string(
          array(
            SELECT concat(cns.hostname, '. IN A ', cns.ipv4, '.') FROM cached_nameservers cns WHERE EXISTS (
              SELECT 1
              FROM nameservers ns
              JOIN domains d ON d.id = ns.domain_id
              WHERE d.name LIKE include_filter AND d.name NOT LIKE exclude_filter
              AND ns.hostname = cns.hostname AND ns.ipv4 = cns.ipv4 AND ns.ipv6 = cns.ipv6
              AND ns.ipv4 IS NOT NULL AND ns.ipv4 <> ''
            )
          ),
          chr(10)
        ) INTO a_records;

        -- aaaa records
        SELECT array_to_string(
          array(
            SELECT concat(cns.hostname, '. IN AAAA ', cns.ipv6, '.') FROM cached_nameservers cns WHERE EXISTS (
              SELECT 1
              FROM nameservers ns
              JOIN domains d ON d.id = ns.domain_id
              WHERE d.name LIKE include_filter AND d.name NOT LIKE exclude_filter
              AND ns.hostname = cns.hostname AND ns.ipv6 = cns.ipv6 AND ns.ipv6 = cns.ipv6
              AND ns.ipv6 IS NOT NULL AND ns.ipv6 <> ''
            )
          ),
          chr(10)
        ) INTO a4_records;

        -- ds records
        SELECT array_to_string(
          array(
            SELECT concat(
              d.name, '. 86400 IN DS ', dk.ds_key_tag, ' ',
              dk.ds_alg, ' ', dk.ds_digest_type, ' ', dk.ds_digest
            )
            FROM domains d
            JOIN dnskeys dk ON dk.domain_id = d.id
            WHERE d.name LIKE include_filter AND d.name NOT LIKE exclude_filter
            ),
          chr(10)
        ) INTO ds_records;

        RETURN concat(
          zone_header, chr(10), chr(10),
          '; Zone NS Records', chr(10), ns_records, chr(10), chr(10),
          '; Zone A Records', chr(10), a_records, chr(10), chr(10),
          '; Zone AAAA Records', chr(10), a4_records, chr(10), chr(10),
          '; Zone DS Records', chr(10), ds_records
        );
      END;
      $$
      LANGUAGE plpgsql;
    SQL
  end

  def down
    execute <<-SQL
      DROP FUNCTION generate_zonefile(i_origin varchar);
    SQL
  end
end
