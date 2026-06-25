# Internal RDAP data API — registry-side contract & implementation guide

> **Provenance.** The authoritative specification lives in the **RDAP** project (the public .ee RDAP
> service), at `specs/specs/pending/08-registry-side-rdap-api/` (`proposal.md`, `requirements.txt`,
> `api-contract.md`, `registry-grounding.md`). This file is the in-repo, registry-facing copy so the
> implementation can proceed here. If the two ever diverge, the RDAP spec is the source of truth —
> sync this file. Authored 2026-06-25, grounded in this codebase (file:line below verified).
>
> **Lead decision (2026-06-25).** The public RDAP service must NOT read the registry's normalized DB
> directly. All registry-sourced data — and privileged-user authorization — move behind this
> registry-side API. RDAP already shipped the consumer side (a client interface + an in-memory mock);
> this is the real API behind that mock.
>
> **HARD rule (registry CLAUDE.md):** branch off `master`, open a PR, **never merge to master
> yourself** — human review first. Docker-only; minitest + fixtures; `db/structure.sql`.

## What RDAP needs

A new internal, machine-to-machine JSON API exposing four read lookups + one optional write. Model it
on the existing internal peer API `app/controllers/api/v1/accreditation_center/`
(`base_controller.rb:1-89`). Proposed home: `app/controllers/api/v1/internal/rdap/` →
`/api/v1/internal/rdap/*`.

| Endpoint | Returns | Replaces RDAP's |
| --- | --- | --- |
| `GET /api/v1/internal/rdap/domains/:name` | full privileged domain (PII + glue + DNSSEC) | direct read of normalized tables |
| `GET /api/v1/internal/rdap/registrars/:code` | `{code, name, phone, website}` only | entity endpoint source |
| `GET /api/v1/internal/rdap/nameservers/:host` | `{hostname, hostname_puny}` DISTINCT | nameserver endpoint source |
| `GET /api/v1/internal/rdap/grants/active?subject=:s` | the single active grant, or 404 | local `rdap_privileged_grants` table |
| `POST /api/v1/internal/rdap/grants/:id/touch` (optional) | 204 — best-effort `last_used_at` | best-effort touch |

## Global rules (review gate — all CRITICAL)

1. **No secrets, ever.** Never emit `domains.transfer_code`/`auth_info` (`structure.sql:1009`),
   `contacts.auth_info` (`:712`), `domains.registrant_verification_token` (`:1024`), or any
   `personal_id_code` on a grant. ⚠️ Do **not** reuse `Serializers::Repp::Domain` with
   `sponsored: true` — it emits `transfer_code` (`lib/serializers/repp/domain.rb:27`). Write a
   dedicated, secrets-free RDAP serializer.
2. **404 ≠ 5xx.** A lookup that matches nothing → HTTP **404** `{ "message": "..." }`. Internal
   error/unavailability → **5xx**. RDAP maps 404→RDAP-404 and 5xx→RDAP-503; never conflate (a degraded
   registry must not look like "object does not exist").
3. **No server-side redaction.** Return the **full** normalized row + the **raw** disclosure flags
   (`disclosed_attributes`, `system_disclosed_attributes`, `registrant_publishable`). RDAP applies the
   disclosure policy; the registry MUST NOT decide what a caller sees.
4. **Read-only** except the optional grant `touch`.
5. **Authenticated + confidential + not public.** **DECIDED (2026-06-25): pre-shared key +
   IP-allowlist** — the `api/v1/base_controller.rb:14-16` `authenticate_shared_key` pattern:
   `Authorization: Basic <ENV['rdap_internal_api_shared_key']>` compared via
   `ActiveSupport::SecurityUtils.secure_compare`; IP checked against
   `ENV['rdap_internal_api_allowed_ips']`. mTLS client-cert (`repp/v1/base_controller.rb:158-177`,
   `api_user.rb#pki_ok?`) is a LATER production-hardening step, not built now.

## Endpoint shapes & field→column mapping

### 1. Domain — `GET /api/v1/internal/rdap/domains/:name`
Match `domains.name` **OR** `domains.name_puny` (cf. `Domain.find_by_idn`, `domain.rb:382`). Response:

```json
{
  "name": "example.ee", "statuses": ["ok"],
  "created_at": "...", "updated_at": "...", "valid_to": "...",
  "outzone_at": null, "delete_date": null,
  "registrant": { "...contact..." },
  "admin_contacts": [ { "...contact..." } ],
  "tech_contacts": [ { "...contact..." } ],
  "registrar": { "code": "REG1", "name": "...", "email": "...", "phone": "...",
                 "website": "...", "reg_no": "..." },
  "nameservers": [ { "hostname": "ns1.example.ee", "hostname_puny": "ns1.example.ee",
                     "ipv4": ["192.0.2.1"], "ipv6": ["2001:db8::1"] } ],
  "dnskeys": [ { "flags": 257, "protocol": 3, "alg": 8, "public_key": "...",
                 "ds_key_tag": "...", "ds_alg": 8, "ds_digest_type": 2, "ds_digest": "..." } ]
}
```

- **domain**: `name`←`domains.name` (`structure.sql:1005`); `statuses`←`domains.statuses` (`:1027`,
  raw `.ee` strings — vocabulary `domain_status.rb:81-91`); `created_at`/`updated_at`/`valid_to`
  (`:1010/1011/1007`); `outzone_at` (`:1021`); `delete_date` (`:1022`, recommend effective
  `[delete_date, force_delete_date].compact.min` per `whois_record.rb:43`).
- **contact** (registrant via `domains.registrant_id`; admin/tech via `domain_contacts` STI `type`
  `AdminDomainContact`/`TechDomainContact`, `domain_contact.rb:17-18`, `domain.rb:62-77`):
  `name`/`org_name`/`email`/`phone`/`street`/`city`/`zip`/`country_code`/`ident`/`ident_type`
  (priv/org/birthday, `contact.rb:98-105`)/`ident_country_code`/`updated_at` (`structure.sql:704-724`);
  `disclosed_attributes` = **union** of `contacts.disclosed_attributes` (`:733`) and
  `contacts.system_disclosed_attributes` (`:741`); `registrant_publishable` (`:735`). Never `auth_info`.
- **registrar** (via `domains.registrar_id`): `code`/`name`/`email`/`phone`/`website`/`reg_no`
  (`structure.sql:2625-2641`). Wider than endpoint 2 — keeps `email`+`reg_no`.
- **nameservers** (`nameservers WHERE domain_id`): `hostname`/`hostname_puny`/`ipv4[]`/`ipv6[]`
  (`structure.sql:2319-2328`).
- **dnskeys** (`dnskeys WHERE domain_id`): `flags`/`protocol`/`alg`/`public_key`/`ds_key_tag`/`ds_alg`/
  `ds_digest_type`/`ds_digest` (`structure.sql:889-896`).

### 2. Registrar — `GET /api/v1/internal/rdap/registrars/:code`
`Registrar.find_by(code: code.upcase)`. Emit **only** `{code, name, phone, website}`
(`structure.sql:2640/2625/2632/2641`). `email`/`reg_no` MUST NOT appear here (they belong only inside
the domain payload, endpoint 1).

### 3. Nameserver — `GET /api/v1/internal/rdap/nameservers/:host`
Match `hostname OR hostname_puny`; **DISTINCT-collapse** to one result (a host serves many domains —
no global unique, only `(domain_id, hostname)`, `structure.sql:4222`). Emit **only**
`{hostname, hostname_puny}`. No glue, no domain list (prevents enumeration).

### 4. Active grant — `GET /api/v1/internal/rdap/grants/active?subject=:s`
`:s` is the **dash-free** country-prefixed eeID subject `EE38001085718` (matches `users.subject`,
`db/migrate/20260601120000_add_subject_to_users.rb`; NOT the dashed `RegistrantUser.registrant_ident`).
Net-new — nothing in the registry maps to this (no police/cert/ria/eis_internal concept today).
Server computes "active" authoritatively: `status='active'` AND `valid_from<=now`(or null) AND
(`valid_until` null OR `>now`); on multiple active, latest `valid_from` wins. Response:

```json
{ "grant_id": "uuid", "eeid_subject": "EE38001085718", "privilege_category": "police",
  "organization": "police", "privileges": ["police"], "status": "active",
  "valid_from": "...", "valid_until": null }
```

404 `{ "message": "No active grant" }` when none active (RDAP fails closed → never privileged).
`subject` via query string (PII — keep out of path/logs). Never emit a national-id secret.

## Implementation plan (this repo)

1. `app/controllers/api/v1/internal/base_controller.rb` (copy `accreditation_center/base_controller.rb`
   pattern: `< ActionController::API`, IP-allowlist `ENV['rdap_internal_api_allowed_ips']`, auth,
   `rescue_from`, `render_error`). Routes under `namespace :api { namespace :v1 { namespace :internal {
   namespace :rdap { ... } } } }` (`config/routes.rb:189-233`).
2. `domains_controller#show` + new `lib/serializers/rdap/domain.rb` (secrets-free). Eager-load assocs.
3. `registrars_controller#show` (slice 4 fields). `nameservers_controller#show` (DISTINCT thin).
4. Net-new `rdap_privilege_grants` table + `RdapPrivilegeGrant` model
   (`CATEGORIES=%w[police cert ria eis_internal]`, `STATUSES=%w[active revoked suspended]`,
   `active_for_subject` scope, PaperTrail). Migration in Rails 6.1 style (regenerates
   `db/structure.sql`).
5. `grants_controller#active` (+ optional `#touch`).
6. Admin CRUD `app/controllers/admin/rdap_privilege_grants_controller.rb` modeled on
   `Admin::DisputesController` (validity-window resource); `can :manage, RdapPrivilegeGrant` in
   `ability.rb`; admin routes block (`config/routes.rb:244-399`).
7. minitest integration tests under `test/integration/api/v1/internal/rdap/` (fixtures): happy paths,
   404s, **secrets-exclusion assertion**, nameserver DISTINCT-collapse, grant active/edge cases. Auth
   tests modeled on `test/integration/repp/v1/base_test.rb`.
8. Open a PR for human review. **Do not merge to master.**

## Decisions (resolved 2026-06-25)
- **Q1 auth** → **pre-shared key + IP-allowlist** (see global rule 5); mTLS later.
- **Q2 namespace** → `/api/v1/internal/rdap/*` (new `internal` namespace).
- **Q3 scope** → **BACKEND ONLY**: model + table + the 4 endpoints + resolution + tests. **No admin
  CRUD UI** in this spec (separate later spec). Grants seeded via fixtures / console until then.
- **Q4 categories/states** → confirmed `police/cert/ria/eis_internal` + `active/revoked/suspended`;
  active rule as above; no extra categories, no four-eyes for now.
- **Q5 touch** → keep the optional best-effort `POST .../grants/:id/touch` (204).
- **Q6** → `delete_date` = effective `[delete_date, force_delete_date].compact.min`; `disclosed_attributes`
  = union of the registrant + system arrays in one field.
