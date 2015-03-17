namespace :zonefile do
  desc 'Replace procedure'
  task replace_procedure: :environment do
    ActiveRecord::Base.connection.execute <<-SQL
      CREATE OR REPLACE FUNCTION generate_zonefile(i_origin varchar)
      RETURNS text AS $$
      DECLARE
        zone_header text := concat('$ORIGIN ', i_origin, '.');
        serial_num varchar;
        include_filter varchar := '';
        exclude_filter varchar := '';
        tmp_var text;
        ret text;
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
          format('%-10s', '$ORIGIN .'), chr(10),
          format('%-10s', '$TTL'), zf.ttl, chr(10), chr(10),
          format('%-10s', i_origin || '.'), 'IN SOA ', zf.master_nameserver, '. ', zf.email, '. (', chr(10),
          format('%-17s', ''), format('%-12s', serial_num), '; serial number', chr(10),
          format('%-17s', ''), format('%-12s', zf.refresh), '; refresh, seconds', chr(10),
          format('%-17s', ''), format('%-12s', zf.retry), '; retry, seconds', chr(10),
          format('%-17s', ''), format('%-12s', zf.expire), '; expire, seconds', chr(10),
          format('%-17s', ''), format('%-12s', zf.minimum_ttl), '; minimum TTL, seconds', chr(10),
          format('%-17s', ''), ')'
        ) FROM zonefile_settings zf WHERE i_origin = zf.origin INTO tmp_var;

        ret = concat(tmp_var, chr(10), chr(10));

        -- ns records
        SELECT array_to_string(
          array(
            SELECT concat(d.name_puny, '. IN NS ', ns.hostname, '.')
            FROM domains d
            JOIN nameservers ns ON ns.domain_id = d.id
            WHERE d.name LIKE include_filter AND d.name NOT LIKE exclude_filter
            ORDER BY d.name
          ),
          chr(10)
        ) INTO tmp_var;

        ret := concat(ret, '; Zone NS Records', chr(10), tmp_var, chr(10), chr(10));

        -- a glue records for origin nameservers
        SELECT array_to_string(
          array(
            SELECT concat(ns.hostname, '. IN A ', ns.ipv4)
            FROM nameservers ns
            JOIN domains d ON d.id = ns.domain_id
            WHERE d.name = i_origin
            AND ns.hostname LIKE '%.' || d.name
            AND ns.ipv4 IS NOT NULL AND ns.ipv4 <> ''
          ), chr(10)
        ) INTO tmp_var;

        ret := concat(ret, '; Zone A Records', chr(10), tmp_var);

        -- a glue records for other nameservers
        SELECT array_to_string(
          array(
            SELECT concat(ns.hostname, '. IN A ', ns.ipv4)
            FROM nameservers ns
            JOIN domains d ON d.id = ns.domain_id
            WHERE d.name LIKE include_filter AND d.name NOT LIKE exclude_filter
            AND ns.hostname LIKE '%.' || d.name
            AND d.name <> i_origin
            AND ns.ipv4 IS NOT NULL AND ns.ipv4 <> ''
            AND NOT EXISTS ( -- filter out glue records that already appeared in origin glue recrods
              SELECT 1 FROM nameservers nsi
              JOIN domains di ON nsi.domain_id = di.id
              WHERE di.name = i_origin
              AND nsi.hostname = ns.hostname
            )
          ), chr(10)
        ) INTO tmp_var;

        -- TODO This is a possible subtitition to the previous query, stress testing is needed to see which is faster

        -- SELECT ns.*
        -- FROM nameservers ns
        -- JOIN domains d ON d.id = ns.domain_id
        -- WHERE d.name LIKE '%ee' AND d.name NOT LIKE '%pri.ee'
        -- AND ns.hostname LIKE '%.' || d.name
        -- AND d.name <> 'ee'
        -- AND ns.ipv4 IS NOT NULL AND ns.ipv4 <> ''
        -- AND ns.hostname NOT IN (
        --   SELECT ns.hostname FROM domains d JOIN nameservers ns ON d.id = ns.domain_id WHERE d.name = 'ee'
        -- )

        ret := concat(ret, chr(10), tmp_var, chr(10), chr(10));

        -- aaaa glue records for origin nameservers
        SELECT array_to_string(
          array(
            SELECT concat(ns.hostname, '. IN AAAA ', ns.ipv6)
            FROM nameservers ns
            JOIN domains d ON d.id = ns.domain_id
            WHERE d.name = i_origin
            AND ns.hostname LIKE '%.' || d.name
            AND ns.ipv6 IS NOT NULL AND ns.ipv6 <> ''
          ), chr(10)
        ) INTO tmp_var;

        ret := concat(ret, '; Zone AAAA Records', chr(10), tmp_var);

        -- aaaa glue records for other nameservers
        SELECT array_to_string(
          array(
            SELECT concat(ns.hostname, '. IN AAAA ', ns.ipv6)
            FROM nameservers ns
            JOIN domains d ON d.id = ns.domain_id
            WHERE d.name LIKE include_filter AND d.name NOT LIKE exclude_filter
            AND ns.hostname LIKE '%.' || d.name
            AND d.name <> i_origin
            AND ns.ipv6 IS NOT NULL AND ns.ipv6 <> ''
            AND NOT EXISTS ( -- filter out glue records that already appeared in origin glue recrods
              SELECT 1 FROM nameservers nsi
              JOIN domains di ON nsi.domain_id = di.id
              WHERE di.name = i_origin
              AND nsi.hostname = ns.hostname
            )
          ), chr(10)
        ) INTO tmp_var;

        ret := concat(ret, chr(10), tmp_var, chr(10), chr(10));

        -- ds records
        SELECT array_to_string(
          array(
            SELECT concat(
              d.name_puny, '. IN DS ', dk.ds_key_tag, ' ',
              dk.ds_alg, ' ', dk.ds_digest_type, ' ( ', dk.ds_digest, ' )'
            )
            FROM domains d
            JOIN dnskeys dk ON dk.domain_id = d.id
            WHERE d.name LIKE include_filter AND d.name NOT LIKE exclude_filter
            ),
          chr(10)
        ) INTO tmp_var;

        ret := concat(ret, '; Zone DS Records', chr(10), tmp_var, chr(10));

        RETURN ret;
      END;
      $$
      LANGUAGE plpgsql;
    SQL
  end
end
