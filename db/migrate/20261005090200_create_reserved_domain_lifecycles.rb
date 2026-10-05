class CreateReservedDomainLifecycles < ActiveRecord::Migration[6.1]
  def up
    safety_assured do
      execute <<~SQL
        CREATE VIEW public.reserved_domain_lifecycles AS
        WITH versions AS NOT MATERIALIZED (
          SELECT v.id, v.item_id, v.event, v.whodunnit, v.created_at, v.source, v.reason, v.reason_note,
                 v.object, v.object_changes,
                 COALESCE(
                   v.domain_name,
                   CASE WHEN v.event = 'destroy' THEN v.object ->> 'name'
                        ELSE COALESCE(v.object_changes -> 'name' ->> 1, v.object ->> 'name')
                   END
                 ) AS resolved_name
          FROM public.log_reserved_domains v
          WHERE v.item_type = 'ReservedDomain'
        ),
        first_events AS (
          SELECT DISTINCT ON (item_id) item_id, object
          FROM versions
          ORDER BY item_id, id
        ),
        create_events AS (
          SELECT DISTINCT ON (item_id) item_id, created_at, whodunnit, source, reason
          FROM versions
          WHERE event = 'create'
          ORDER BY item_id, id
        ),
        last_events AS (
          SELECT DISTINCT ON (item_id) item_id, event, created_at, whodunnit, source, reason, reason_note,
                 resolved_name,
                 CASE WHEN event = 'destroy' THEN object ->> 'expire_at'
                      WHEN object_changes -> 'expire_at' IS NOT NULL THEN object_changes -> 'expire_at' ->> 1
                      ELSE object ->> 'expire_at'
                 END AS known_expire_at
          FROM versions
          ORDER BY item_id, id DESC
        ),
        registrations AS (
          SELECT item_id, bool_or(reason = 'domain_registered') AS registration_recorded
          FROM versions
          GROUP BY item_id
        ),
        lifecycle_ids AS (
          SELECT item_id AS id FROM versions
          UNION
          SELECT id FROM public.reserved_domains
        )
        SELECT
          ids.id,
          COALESCE(rd.name, le.resolved_name) AS domain_name,
          COALESCE(rd.created_at, ce.created_at,
                   (CASE WHEN fe.object ->> 'created_at' ~ '^\\d{4}-\\d{2}-\\d{2}[ T]\\d{2}:\\d{2}:\\d{2}' THEN (fe.object ->> 'created_at')::timestamptz AT TIME ZONE 'UTC' END)) AS created_at,
          COALESCE(rd.creator_str, ce.whodunnit, fe.object ->> 'creator_str') AS created_by,
          ce.source AS creation_source,
          ce.reason AS creation_reason,
          COALESCE(le.created_at, rd.updated_at) AS last_changed_at,
          COALESCE(le.whodunnit, rd.updator_str) AS last_changed_by,
          le.source AS last_source,
          le.reason AS last_reason,
          le.reason_note AS last_reason_note,
          CASE WHEN rd.id IS NOT NULL THEN rd.expire_at
               ELSE (CASE WHEN le.known_expire_at ~ '^\\d{4}-\\d{2}-\\d{2}[ T]\\d{2}:\\d{2}:\\d{2}' THEN le.known_expire_at::timestamptz AT TIME ZONE 'UTC' END)
          END AS expire_at,
          CASE WHEN rd.id IS NULL AND le.event = 'destroy' THEN le.created_at END AS ended_at,
          CASE WHEN rd.id IS NULL AND le.event = 'destroy' THEN le.reason END AS end_reason,
          COALESCE(r.registration_recorded, false) AS registration_recorded,
          EXISTS (SELECT 1 FROM public.domains d WHERE d.name = COALESCE(rd.name, le.resolved_name)) AS domain_exists,
          CASE
            WHEN rd.id IS NOT NULL AND rd.expire_at IS NOT NULL
                 AND rd.expire_at < (now() AT TIME ZONE 'UTC') THEN 'expired'
            WHEN rd.id IS NOT NULL THEN 'active'
            WHEN le.reason = 'reservation_expired' THEN 'expired'
            WHEN le.reason = 'released_to_auction' THEN 'released_to_auction'
            WHEN le.reason = 'admin_deleted' THEN 'deleted'
            ELSE 'removed'
          END AS status
        FROM lifecycle_ids ids
        LEFT JOIN public.reserved_domains rd ON rd.id = ids.id
        LEFT JOIN first_events fe ON fe.item_id = ids.id
        LEFT JOIN create_events ce ON ce.item_id = ids.id
        LEFT JOIN last_events le ON le.item_id = ids.id
        LEFT JOIN registrations r ON r.item_id = ids.id;
      SQL
    end
  end

  def down
    safety_assured { execute 'DROP VIEW IF EXISTS public.reserved_domain_lifecycles' }
  end
end
