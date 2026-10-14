# Admin reservation history read model: one row per reservation (live or
# ended), derived from log_reserved_domains versions plus live rows that have
# no versions yet. reserved_domain_lifecycle_rows() is the single source of
# truth for the derivation; the table is maintained by ReservedDomain::Lifecycle
# (catch-up on admin reads, nightly rebuild, rake) and never by write paths.
class CreateReservedDomainLifecycles < ActiveRecord::Migration[6.1]
  def up
    safety_assured do
      execute <<~'SQL'
        CREATE FUNCTION public.reserved_domain_lifecycle_rows(lifecycle_ids bigint[])
        RETURNS TABLE (
          id bigint, domain_name character varying, created_at timestamp without time zone,
          created_by character varying, creation_source character varying, creation_reason character varying,
          last_changed_at timestamp without time zone, last_changed_by character varying,
          last_source character varying, last_reason character varying, last_reason_note text,
          expire_at timestamp without time zone, ended_at timestamp without time zone,
          end_reason character varying, registration_recorded boolean, live boolean
        )
        LANGUAGE sql STABLE
        AS $$
          SELECT
            ids.id,
            COALESCE(rd.name, le.resolved_name)::character varying,
            COALESCE(rd.created_at, ce.created_at,
                     CASE WHEN fe.object ->> 'created_at' ~ '^\d{4}-\d{2}-\d{2}[ T]\d{2}:\d{2}:\d{2}'
                          THEN (fe.object ->> 'created_at')::timestamptz AT TIME ZONE 'UTC' END),
            COALESCE(rd.creator_str, ce.whodunnit, fe.object ->> 'creator_str')::character varying,
            ce.source,
            ce.reason,
            COALESCE(le.created_at, rd.updated_at),
            COALESCE(le.whodunnit, rd.updator_str)::character varying,
            le.source,
            le.reason,
            le.reason_note,
            CASE WHEN rd.id IS NOT NULL THEN rd.expire_at
                 WHEN le.known_expire_at ~ '^\d{4}-\d{2}-\d{2}[ T]\d{2}:\d{2}:\d{2}'
                 THEN le.known_expire_at::timestamptz AT TIME ZONE 'UTC' END,
            CASE WHEN rd.id IS NULL AND le.event = 'destroy' THEN le.created_at END,
            CASE WHEN rd.id IS NULL AND le.event = 'destroy' THEN le.reason END,
            COALESCE(r.registration_recorded, false),
            rd.id IS NOT NULL
          FROM unnest(lifecycle_ids) AS ids(id)
          LEFT JOIN public.reserved_domains rd ON rd.id = ids.id
          LEFT JOIN LATERAL (
            SELECT v.event, v.created_at, v.whodunnit, v.source, v.reason, v.reason_note,
                   COALESCE(v.domain_name,
                            CASE WHEN v.event = 'destroy' THEN v.object ->> 'name'
                                 ELSE COALESCE(v.object_changes -> 'name' ->> 1, v.object ->> 'name') END) AS resolved_name,
                   CASE WHEN v.event = 'destroy' THEN v.object ->> 'expire_at'
                        WHEN v.object_changes -> 'expire_at' IS NOT NULL THEN v.object_changes -> 'expire_at' ->> 1
                        ELSE v.object ->> 'expire_at' END AS known_expire_at
            FROM public.log_reserved_domains v
            WHERE v.item_type = 'ReservedDomain' AND v.item_id = ids.id
            ORDER BY v.id DESC LIMIT 1
          ) le ON true
          LEFT JOIN LATERAL (
            SELECT v.object FROM public.log_reserved_domains v
            WHERE v.item_type = 'ReservedDomain' AND v.item_id = ids.id
            ORDER BY v.id LIMIT 1
          ) fe ON true
          LEFT JOIN LATERAL (
            SELECT v.created_at, v.whodunnit, v.source, v.reason FROM public.log_reserved_domains v
            WHERE v.item_type = 'ReservedDomain' AND v.item_id = ids.id AND v.event = 'create'
            ORDER BY v.id LIMIT 1
          ) ce ON true
          LEFT JOIN LATERAL (
            SELECT bool_or(v.reason = 'domain_registered') AS registration_recorded
            FROM public.log_reserved_domains v
            WHERE v.item_type = 'ReservedDomain' AND v.item_id = ids.id
          ) r ON true
        $$;

        CREATE TABLE public.reserved_domain_lifecycles (
          id bigint PRIMARY KEY,
          domain_name character varying,
          created_at timestamp without time zone,
          created_by character varying,
          creation_source character varying,
          creation_reason character varying,
          last_changed_at timestamp without time zone,
          last_changed_by character varying,
          last_source character varying,
          last_reason character varying,
          last_reason_note text,
          expire_at timestamp without time zone,
          ended_at timestamp without time zone,
          end_reason character varying,
          registration_recorded boolean NOT NULL DEFAULT false,
          live boolean NOT NULL DEFAULT false
        );

        CREATE INDEX index_reserved_domain_lifecycles_on_last_changed
          ON public.reserved_domain_lifecycles (last_changed_at DESC, id DESC);
        CREATE INDEX index_reserved_domain_lifecycles_on_created_at
          ON public.reserved_domain_lifecycles (created_at);
        CREATE INDEX index_reserved_domain_lifecycles_on_domain_name
          ON public.reserved_domain_lifecycles (domain_name);
        CREATE INDEX index_reserved_domain_lifecycles_on_live_and_expire_at
          ON public.reserved_domain_lifecycles (live, expire_at);
        CREATE INDEX index_reserved_domain_lifecycles_on_end_reason
          ON public.reserved_domain_lifecycles (end_reason);
        CREATE INDEX index_reserved_domain_lifecycles_on_last_reason
          ON public.reserved_domain_lifecycles (last_reason);
        CREATE INDEX index_reserved_domain_lifecycles_on_creation_source
          ON public.reserved_domain_lifecycles (creation_source);
        CREATE INDEX index_reserved_domain_lifecycles_on_last_source
          ON public.reserved_domain_lifecycles (last_source);

        CREATE TABLE public.reserved_domain_lifecycle_syncs (
          id integer PRIMARY KEY DEFAULT 1 CHECK (id = 1),
          synced_at timestamp without time zone NOT NULL
        );
      SQL

      # Initial fill. The sync mark is taken before the fill so that the
      # first catch-up re-reads anything written while the fill ran.
      execute <<~SQL
        INSERT INTO public.reserved_domain_lifecycle_syncs (id, synced_at)
        VALUES (1, now() AT TIME ZONE 'UTC');

        INSERT INTO public.reserved_domain_lifecycles
        SELECT * FROM public.reserved_domain_lifecycle_rows(ARRAY(
          SELECT item_id::bigint FROM public.log_reserved_domains WHERE item_type = 'ReservedDomain'
          UNION
          SELECT id::bigint FROM public.reserved_domains
        ));
      SQL
    end
  end

  def down
    safety_assured do
      execute <<~SQL
        DROP TABLE public.reserved_domain_lifecycle_syncs;
        DROP TABLE public.reserved_domain_lifecycles;
        DROP FUNCTION public.reserved_domain_lifecycle_rows(bigint[]);
      SQL
    end
  end
end
