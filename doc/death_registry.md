# Death Registry Check

Status as of 2026-10-21: implemented on branch `feature/death-registry-check`, not released. Everything is off by default.

## 1. Summary

The registry (EIS) checks Estonian private-person contacts against the death open data of the Estonian Population Register. Until now, domains of deceased registrants were found and handled by hand (ENTITY_BURIED force delete). This feature does it automatically:

- **At contact creation:** a new contact whose Estonian personal identity code belongs to a deceased person is refused (EPP and REPP, error 2003 "Ident is invalid").
- **Once a year per contact:** a daily job checks the contacts whose last check is older than a year, so about 1/365 of the contacts are checked each night.
- **Deceased registrant:** the registrar gets a poll message at once. A fast-track force delete starts at death date + 6 months + 1 day, unless the registrant has been changed by then (for example to an heir with a certificate of succession).
- **Deceased admin or tech contact:** an optional contact is removed from the domain. A required admin contact (organisation or minor registrant) puts the domain into a soft force delete until a new admin contact is added.
- **Notifications:** registrars get a poll message for every action. Registrants and contacts get only the existing force delete emails; no new email to the registrant is sent.

| Reader | Sections |
| --- | --- |
| Lawyer | 2 Legal basis and data handling, 3 How it works, 4 Timeline, 9 Messages |
| System administrator | 5 Production setup, 6 Go-live, 7 Operation, 8 Settings |
| Text reviewers | 9 Messages and notification texts |

## 2. Legal basis and data handling

### Legal basis

The .ee domain regulation gives EIS the right to start a deletion procedure when the registrant is a natural person who has died. Six months are given for succession; after that the domain enters a deletion procedure, as in the current manual process (the existing `private_person` email).

Death of an **admin or tech contact** does not give grounds for deleting the domain: those contacts are not domain holders. Therefore:

- a tech contact (always optional) and an admin contact of a private registrant (optional) are removed from the domain, and the registrar is informed;
- an organisation's or minor's last admin contact cannot be removed, because the domain must have one. The domain gets a **soft** force delete: it stays in the zone, but cannot be renewed or transferred until a new admin contact is added. If it is not renewed, it expires on its normal date.

Decisions: Helen and Timo, 20.10.2026 and 21.10.2026.

### Data source

- Population Register death data on the Estonian open data portal: https://andmed.eesti.ee/datasets/surmaandmed
- Files used (published by SMIT):
  - `https://opendata.smit.ee/etl/rahvastik/surmaandmed_1926_kuni_eelmise_aasta_lopuni.csv` (1926 to end of last year)
  - `https://opendata.smit.ee/etl/rahvastik/surmaandmed_jooksev_aasta.csv` (current year)
- Licence: CC BY 4.0. The data is used only inside the registry and not redistributed (see open question 1).
- The open data omits roughly the last 7 days of deaths, so the copy is refreshed weekly.

### What is stored

| Data | Where | Kept for |
| --- | --- | --- |
| Personal identity code + death date of every deceased person in the open data | Local file (`deaths.txt`) on the registry server | Replaced weekly by a fresh copy; no older copies are kept |
| Death date of a matching contact | `contacts.death_date` | Until the contact is deleted (contact archiving), or cleared when the person is no longer in the open data |
| Time of the last check | `contacts.death_registry_checked_at` | Same as the contact |
| Dry run report (CSV: contact code, ident, death date, roles, domains, registrars) | `reports/` next to the death file, and emailed to the admin address | Until deleted manually |

No names, addresses or other fields of the source data are stored. Data protection rules do not grant rights to deceased persons, so no legal assessment was deemed necessary for keeping the copy (decided earlier; see section 10 for the licence question).

### Who sees it

- The death date and the check time are shown **only in the admin interface** (contact page; contact list filter "Death registry: deceased / not checked").
- They are **not** shown in WHOIS, EPP `contact:info` or REPP.
- Registrars learn of a death only through poll messages about their own domains (texts in section 9). The poll for a deceased registrant includes the ident and death date.
- The force delete status note on the domain (visible in admin) contains the ident and death date.

### Corrections in the Population Register

If a person was wrongly marked as deceased and later disappears from the open data:

- before the force delete starts: the death date is cleared silently, nothing is sent;
- during the force delete: it is stopped and the registrar gets a poll message (A4, or A5 when an earlier force delete is restored);
- the person is re-checked from a fresh file right before the force delete starts and every day while it runs.

## 3. How it works

### 3.1 Check at contact creation

Applies to EPP and REPP `contact create`, only for `ident_type = priv` and country `EE`, only when `validate_deceased_contacts = true`.

- Person found in the file: the contact is not created, error 2003 "Ident is invalid" / "Isikukood on kehtetu".
- Person not found: the contact is created and `death_registry_checked_at` is set, so the yearly check skips it for a year.
- File missing, stale or malformed: the contact is created unchecked, a warning is logged, and the daily job checks it the next night. A file problem never blocks registrars.

Contact **updates** and the use of an existing contact on a new domain are not checked (open question 10).

### 3.2 Daily job `DeathRegistryCheckJob`

One run does, in order:

1. **Refresh the file** if it is older than 7 days (download, validate, atomic replace). On failure the old file is kept and the admin gets an email.
2. **Yearly check:** EE private contacts linked to at least one domain (as registrant, admin or tech), without a death date, whose last check is empty or older than 1 year. Each is looked up; living persons get `death_registry_checked_at = now`, deceased ones get `death_date`.
   - For a deceased registrant whose death is less than 6 months ago, the registrar gets poll **A1** for each of the person's domains.
3. **Start fast-track force deletes** for registrants who died at least 6 months ago (see 3.3).
4. **Stop force deletes of persons no longer in the file** (see 3.5).
5. **Handle deceased admin and tech contacts** (see 3.4).

In **dry run mode** (the default) only step 1 and the lookups run: nothing is saved, no polls or emails go to registrars, and a CSV report is emailed to the admin address.

Volume: after the first full run, about 1/365 of the linked contacts per night; a lookup is a binary search in the file, so the job is light.

### 3.3 Deceased registrant

- At discovery (death < 6 months ago): poll **A1** to the registrar with the expected force delete start date. No email to the registrant.
- At death + 6 months + 1 day: the person is looked up again in the fresh file, then a **fast-track force delete** starts on every domain where the person is registrant:
  - reason `deceased_person`, status note "Deceased registrant: <ident>, death date <date>";
  - starts the next day; outzone after 15 days; deletion (auction) after another 30 + 1 days (current settings);
  - registrar gets poll **A3**; registrant and admin contacts get the existing "deceased person" force delete email (**E1**, template `private_person`).
- If the registrant is changed (e.g. to an heir), every force delete on the domain is cancelled, as for any registrant change.
- If the run on the due day is missed, the next run picks the contact up and the start moves by a day.

### 3.4 Deceased admin or tech contact

| Situation | Action | Message |
| --- | --- | --- |
| Tech contact dies | Removed from the domain (domain history and WHOIS updated; the contact object stays) | Poll **B1** |
| Admin contact dies, domain still has enough admin contacts (private registrant, or organisation with another admin) | Removed from the domain | Poll **C1** |
| Last required admin contact of an organisation or minor registrant dies | Soft force delete, reason `deceased_admin_contact`; statuses `serverForceDelete`, `serverRenewProhibited`, `serverTransferProhibited` | Poll **C2**; email **E2** at the force delete start |
| A new admin contact is added afterwards | `CheckForceDeleteLift` cancels the soft force delete | Poll **A4** (standard cancel text) |
| Domain already has a force delete | Left alone | — |

Soft force delete start: if the domain expires more than a year from now, the start moves to the nearest registration anniversary; if it expires within a year, there is no start date and the domain simply cannot be renewed (open question 2).

### 3.5 Domain already has a force delete

The force delete that releases the domain **earlier** wins (Timo, 21.10.2026).

- Fast-track deletion date = today + 15 + 30 + 1 days. If the existing force delete's deletion date is the same or earlier, it stays and nothing changes.
- Otherwise the existing force delete is **saved** on the domain and the death fast track replaces it.
- When the death force delete stops (the person is no longer in the file, or an admin cancels it):
  - the saved force delete is **restored** if its reason still exists:
    - invalid email: restored only if a contact's email still fails verification;
    - deceased admin contact: restored only if the domain still lacks a living required admin contact;
    - manual (admin, ENTITY_BURIED) and invalid phone: always restored; an admin cancels it by hand if needed;
  - its dates are **not moved**; if its outzone date has already passed, the domain goes out of the zone (`clientHold`) at once;
  - the registrar gets poll **A5**; no email is sent;
  - if the reason is gone, or nothing was saved, the force delete is cancelled completely (poll **A4**).
- A registrant change cancels all force deletes, the saved one included.

### 3.6 Admin actions

- **Schedule force delete** requires a reason, which selects the email: registrant (private person) has died, registrant (company) deleted from the Business Register, invalid email, invalid phone, or other (no email). Before, the email was guessed from the domain data, and any private registrant got the "registrant has died" letter.
- **Cancel force delete** (admin → domain → Edit → Cancel force delete) on a death force delete:
  - restores a saved earlier force delete (3.5), otherwise cancels;
  - clears the contact's death date and marks it checked now, so the job does not restart the force delete; the person is checked again in a year.
- Contact list filter **Death registry**: "deceased" or "not checked".
- The domain page shows the force delete start date, deletion date and the status note with the reason.
- The daily admin force delete summary shows the reason and note (for example `deceased_person: Deceased registrant: …`).

## 4. Timeline example

Registrant dies on 15.03.2026; the yearly check finds it on 02.05.2026.

| Date | Event |
| --- | --- |
| 15.03.2026 | Death |
| ~22.03.2026 | Appears in the open data (about a week's delay) |
| 02.05.2026 | Found by the daily job; death date saved; poll A1 to the registrar ("force delete will start on 16.09.2026") |
| 15.09.2026 | 6 months after death; person looked up again |
| 16.09.2026 | Fast-track force delete starts; poll A3; email E1 to registrant and admin contacts |
| 01.10.2026 | Outzone: domain removed from the zone (`clientHold`) |
| 31.10.2026 | Deletion date: domain goes to auction (start day − 1 + 15 + 30 + 1 days) |

A registrant change at any point before the deletion date cancels the force delete. If the yearly check finds the death only after 6 months have passed, A1 is skipped and the force delete starts the next day.

## 5. Production setup

### 5.1 Release

1. Deploy the release.
2. Run migrations: `bin/rails db:migrate RAILS_ENV=production`. They add `contacts.death_date`, `contacts.death_registry_checked_at` and indexes. Existing data is not changed.

### 5.2 Configuration (`config/application.yml`)

```yaml
death_registry_file_path: '/shared/death_registry/deaths.txt'   # shared disk, see below
death_registry_source_urls: ''        # empty = the two opendata.smit.ee CSVs
death_registry_max_file_age_days: '8'
death_registry_min_records: '100000'
validate_deceased_contacts: 'false'   # turned on at go-live
death_registry_dry_run: 'true'        # turned off at go-live
admin_notification_email: 'admin@…'   # receives problems and dry run reports (existing setting)
```

### 5.3 File location

- The file must be readable by **every** process that creates contacts (EPP and REPP app servers) and by the server that runs the job. Use a shared disk if they are on different machines.
- The job's user must be able to write to the directory: the file is written as `deaths.txt.<pid>.tmp` and renamed over the old one. The `reports/` subdirectory is created next to it.
- Size: 23 bytes per record (`<11-digit ident>;<YYYY-MM-DD>\n`), sorted by ident.
- The server needs outbound HTTPS to `opendata.smit.ee`.

### 5.4 Cron

Production uses a hand-maintained crontab (`config/schedule.rb` is not used there). Add **one** line:

```
0 5 * * * cd /path/to/registry && bin/rails r -e production "DeathRegistryCheckJob.perform_now"
```

The job rebuilds the file itself when it is older than 7 days; a separate file job is not needed.

The existing `CheckForceDeleteLift` cron line (already in the production crontab) also lifts the `deceased_admin_contact` soft force delete once a new admin contact is added. It must keep running daily; no change is needed.

## 6. Go-live

1. **Build the file** on the production server and check it:
   ```
   bin/rails r -e production "DeathRegistryFileBuildJob.perform_now"
   ls -l /shared/death_registry/deaths.txt   # size divisible by 23, fresh mtime
   ```
2. **Dry run** (`death_registry_dry_run: 'true'`), run once by hand:
   ```
   bin/rails r -e production "DeathRegistryCheckJob.perform_now"
   ```
   The admin address receives "Death registry dry run report" with a CSV of every deceased contact found, their roles, domains, registrars and whether 6 months have passed. The first run checks all linked contacts, not 1/365.
3. **Review the report** (Timo, Helen):
   - check a random sample of 10–20 rows against the Population Register;
   - compare with recent manual ENTITY_BURIED cases;
   - count rows with `six_months_passed = true`: each of their domains gets a fast-track force delete on the first real run. Decide whether registrars are warned beforehand or the start is spread out (open question 8).
4. **Add the cron line** (5.4).
5. **Turn on the creation check:** `validate_deceased_contacts: 'true'`, restart the app servers.
6. **Turn off dry run:** `death_registry_dry_run: 'false'`. The next night's run saves death dates, sends polls and starts force deletes.

**Rollback:** set `death_registry_dry_run: 'true'` and `validate_deceased_contacts: 'false'`. Started force deletes stay and are cancelled by hand in admin if needed.

## 7. Operation

### 7.1 Monitoring

- **Log line** after each run (`log/production.log`):
  `DeathRegistryCheckJob: checked N contacts, found N deceased, started N and cancelled N force deletes, removed N admin and tech contacts`
- **Problem email** "Death registry check problem - <date>" to `admin_notification_email` when:
  - the file rebuild failed (download error, HTTP error, missing columns, fewer than `death_registry_min_records` records); the old file is kept;
  - the file is missing, stale (older than `death_registry_max_file_age_days`) or malformed; contacts are not checked that night;
  - the dry run report could not be written or sent.
- A stale file never blocks contact creation; it only logs a warning per contact.

### 7.2 Commands

```
# Run the check (respects death_registry_dry_run)
bin/rails r -e production "DeathRegistryCheckJob.perform_now"

# Force a dry run regardless of the setting
bin/rails r -e production "DeathRegistryCheckJob.perform_now(dry_run: true)"

# Rebuild the file now
bin/rails r -e production "DeathRegistryFileBuildJob.perform_now"

# Look up one ident
bin/rails r -e production "p DeathRegistry::Lookup.new.death_date('38001010000')"

# Contacts with a death date
bin/rails r -e production "p Contact.where.not(death_date: nil).count"

# Domains in a death force delete
bin/rails r -e production "puts Domain.where(\"force_delete_data->'template_name' = 'deceased_person'\").pluck(:name)"
```

### 7.3 Manual actions

| Case | What to do |
| --- | --- |
| Person is alive (registrant or heir contacts EIS) | Admin → domain → Edit → Cancel force delete. The death date is cleared and the contact is not checked again for a year. |
| Person is alive but the open data is not yet corrected | Same; also ask the Population Register to correct the data, otherwise the person is found again in a year. |
| Restored earlier force delete is not wanted | Cancel force delete once more. |
| Soft force delete for a deceased admin contact should be lifted | Add a living admin contact; `CheckForceDeleteLift` lifts it the next run, or cancel by hand. |

### 7.4 Troubleshooting

| Symptom | Cause / fix |
| --- | --- |
| Problem email "file is missing, stale or malformed" | Rebuild failed for 2+ weeks or the path is wrong. Run the rebuild by hand and read the error. |
| "only N records, expected at least 100000" | Source returned partial data. Old file kept; retry later. Check the source URLs. |
| "CSV is missing columns" | SMIT changed the file format. Code change needed in `DeathRegistry::FileBuilder`. |
| Contacts created without check | `validate_deceased_contacts` off, or the file is not readable from the EPP/REPP server. |
| Domain stays in `deceased_admin_contact` after admin contact replaced | Check that the `CheckForceDeleteLift` cron line ran; the domain needs as many living admin contacts as `admin_contacts_min_count`. |

## 8. Settings

| Setting | Default | Purpose |
| --- | --- | --- |
| `death_registry_file_path` | `tmp/death_registry/deaths.txt` | Location of the local copy; use a shared disk in production |
| `death_registry_source_urls` | the two opendata.smit.ee CSVs | Comma-separated source URLs |
| `death_registry_max_file_age_days` | 8 | Older file counts as stale; lookups refuse it |
| `death_registry_min_records` | 100000 | A download with fewer records is rejected |
| `validate_deceased_contacts` | false | Refuse deceased persons at contact creation |
| `death_registry_dry_run` | true | Job only reports; saves nothing and sends nothing |
| `admin_notification_email` | existing | Receives problem emails and dry run reports |
| `expire_warning_period` | existing (15) | Days from force delete start to outzone |
| `redemption_grace_period` | existing (30) | Days from outzone to deletion |
| `admin_contacts_min_count` | existing | Required admin contacts for organisation and minor registrants |

Fixed in code: check interval 1 year, force delete 6 months after death, file rebuild after 7 days.

## 9. Messages and notification texts for review

All poll texts are **English drafts** and need review (Helen, Mare). Estonian versions are to be added. Placeholders are in `%{…}`. Dates in polls follow the existing force delete messages.

### Registrar poll messages

| Code | When | Text |
| --- | --- | --- |
| **A1** | Registrant found deceased, less than 6 months ago | According to the Estonian Population Register, the registrant of domain %{domain_name} (ident %{ident}) died on %{death_date}. Force delete will start on %{force_delete_start} unless the registrant is changed. An heir can take over the domain by a registrant change with a certificate of succession. |
| **A3** | Fast-track force delete started | Force delete set on domain %{domain_name} because, according to the Estonian Population Register, the registrant (ident %{ident}) has died. Force Delete Type: Fast Track. Force Delete Start Date: %{force_delete_start_date}. Outzone date: %{outzone_date}. Purge date: %{purge_date}. |
| **A4** | Force delete cancelled (person alive, admin cancel, admin contact replaced) — existing text | Force delete is cancelled on domain %{domain_name} |
| **A5** | Death force delete stopped, earlier force delete restored | Force delete because of the registrant's death was stopped on domain %{domain_name}. The earlier force delete continues: %{reason}. Force Delete Start Date: %{force_delete_start_date}. Outzone date: %{outzone_date}. Purge date: %{purge_date}. |
| **B1** | Deceased tech contact removed | Tech contact %{contact_code} was removed from domain %{domain_name} because, according to the Estonian Population Register, the person has died. Add a new tech contact if needed. |
| **C1** | Deceased admin contact removed | Admin contact %{contact_code} was removed from domain %{domain_name} because, according to the Estonian Population Register, the person has died. |
| **C2** | Soft force delete for the last required admin contact | Force delete set on domain %{domain_name}. Admin contact %{contact_code} has died according to the Estonian Population Register. Add a new admin contact; until then the domain cannot be renewed or transferred to another registrar. Force Delete Type: Soft. Force Delete Start Date: %{force_delete_start_date}. Expire date: %{valid_to}. |

Notes for reviewers:

- A5 `%{reason}` is a technical reason code (`invalid_email`, `deceased_admin_contact`, …) or the manual status note. Consider mapping it to readable words.
- A4 is the existing generic cancel text and does not say why.

### EPP / REPP error

| When | Code | Text (en / et) |
| --- | --- | --- |
| Contact create with a deceased person's ident | 2003 | Ident is invalid / Isikukood on kehtetu |

The error deliberately does not say that the person is deceased.

### Emails to registrant and contacts

Subject (all force delete emails): "Domeen %{domain_name} on kustutusmenetluses / Domain %{domain_name} is in deletion process". The Russian line was removed from the subject.

**E1 — deceased registrant (existing template `private_person`, unchanged), sent at the fast-track start:**

> Lugupeetud domeeni %{domain} registreerija/halduskontakt
>
> Eesti Interneti Sihtasutusele (EIS) on saanud teatavaks, et füüsiline isik isikukoodiga %{ident} on surnud ja sellest on möödunud vähemalt 6 kuud.
>
> Kuna surnud isik ei saa olla domeeni registreerijaks, algas domeeni %{domain} suhtes %{delete_period_length} päevane kustutusmenetlus. Menetluse käigus on domeen %{expire_warning_period} esimest päeva internetis kättesaadav.
>
> Domeeni suhtes õigust omaval isikul on võimalus esitada domeeni %{domain} registripidajale %{registrar} domeeni üleandmise taotlus, millele tuleb lisada pärimisõiguse tõend. Dokumentatsioon tuleb esitada registripidajale %{delete_period_length} päeva jooksul.
>
> Kui üleandmine ei ole %{delete_period_length} päeva jooksul toimunud, läheb domeen %{domain} %{force_delete_date} domeenioksjonile .ee oksjonikeskkonda https://auction.internet.ee. …
>
> ---
>
> Dear registrant/administrative contact of %{domain} domain
>
> Estonian Internet Foundation (EIF) has learned that the natural person with identification code %{ident} has been deceased more than 6 months.
>
> The registrant holding a right to the domain name %{domain} can submit a domain name transfer application to the registrar %{registrar}. The application must be submitted together with succession evidence certifying the acquisition of the domain. The relevant documents should be submitted to the registrar within %{delete_period_length} days.
>
> As a deceased natural person can not be the registrant of a domain, a %{delete_period_length}-day deletion process of %{domain} domain has started. For the first %{expire_warning_period} days the domain will remain available on the Internet during the deletion process.
>
> If the transfer is not made within %{delete_period_length} days, the domain %{domain} will go to domain auction on %{force_delete_date} … (auction paragraph, registrar contacts and signature as in the existing template)

**E2 — deceased admin contact (new template `deceased_admin_contact`, draft), sent at the soft force delete start:**

> Lugupeetud domeeni %{domain} registreerija/halduskontakt
>
> Eesti Interneti Sihtasutusele (EIS) on Rahvastikuregistri andmetel saanud teatavaks, et domeeni %{domain} halduskontakt on surnud. Domeenil peab olema kehtiv halduskontakt.
>
> Et see olukord on vastuolus .ee domeenireeglitega (https://www.internet.ee/domains/ee-domain-regulation), algatas EIS %{delete_period_length} päeva pikkuse kustutusmenetluse. Kuni uus halduskontakt pole lisatud, ei saa domeeni pikendada ega registripidajat vahetada. Menetluse käigus on domeen %{expire_warning_period} esimest päeva internetis kättesaadav.
>
> Uue halduskontakti lisamiseks pöörduge palun oma registripidaja %{registrar} poole.
>
> Kui uut halduskontakti ei ole %{delete_period_length} päeva jooksul lisatud, läheb domeen %{domain} %{force_delete_date} domeenioksjonile .ee oksjonikeskkonda https://auction.internet.ee. …
>
> ---
>
> Dear registrant/administrative contact of .ee domain,
>
> According to the Estonian Population Register, the administrative contact of the domain %{domain} has died. The domain must have a valid administrative contact.
>
> Since this is a violation of Estonian domain regulations (https://www.internet.ee/domains/ee-domain-regulation), %{delete_period_length}-day deletion process has started for the %{domain} domain. Until a new administrative contact is added, the domain cannot be renewed or transferred to another registrar. For the first %{expire_warning_period} days the domain will remain available on the Internet during the deletion process.
>
> To add a new administrative contact, please contact your registrar %{registrar}.
>
> If no new administrative contact is added within %{delete_period_length} days, the domain %{domain} will go to domain auction on %{force_delete_date} … (auction paragraph, registrar contacts and signature as in the existing templates)

No email is sent for: A1 (discovery), removal of an optional contact (B1, C1), a stopped or restored force delete (A4, A5).

### Admin emails (to `admin_notification_email`)

| Subject | When | Body |
| --- | --- | --- |
| Death registry check problem - %{date} | File rebuild failed, file unusable, or report failed | List of problems, e.g. "Rebuilding the death registry file failed: …", "Death registry file … is missing, stale or malformed. Contacts were not checked." |
| Death registry dry run report - %{date} | Every run in dry run mode | "Checked contacts: N. Deceased contacts found: N. The attached CSV lists the deceased contacts. Nothing was saved and no poll messages were sent." + CSV attachment |

### Admin interface

| Where | Text |
| --- | --- |
| Domain page, force delete status note | "Deceased registrant: <ident>, death date <YYYY-MM-DD>" or "Admin contact <code> has died" |
| Domain page | "Force delete start" (new row, next to the force delete date) |
| Contact page | "Death date", "Death registry checked" (shown only when set) |
| Contact list filter | "Death registry": "Deceased" / "Not checked" |
| Daily force delete summary email (reason column) | "deceased_person: Deceased registrant: <ident>, death date <date>", "deceased_admin_contact: Admin contact <code> has died" |

**Schedule force delete dialog** (admin → domain → Edit → Schedule force delete):

| Element | Text |
| --- | --- |
| Field | Reason (required) |
| Option → email | "Registrant (private person) has died" → E1 `private_person` |
| Option → email | "Registrant (company) is deleted from the Business Register" → `legal_person` |
| Option → email | "Invalid email" → `invalid_email` (failing addresses go into the status note) |
| Option → email | "Invalid phone" → `invalid_phone` |
| Option → email | "Other (no email)" → no email to registrant and contacts |
| Hint | The reason selects the email to the registrant and administrative contacts. "Other" sends no email. |
| Error, no reason chosen | Choose the reason of the force delete |
| Error, "Invalid email" chosen but no contact email fails verification | No contact of the domain has an invalid email |

The automatic reasons `deceased_person` and `deceased_admin_contact` are not offered manually: the death registry check would stop such a force delete when the person is not in the open data.

## 10. Open questions

6. **ENTITY_BURIED manual force delete** (admin Mass actions, always soft): switch it to fast track too, now that deceased registrants and deleted companies are handled automatically with fast track? Its letter is already fixed: it now always uses `private_person` or `legal_person` by registrant type, never the invalid email letter.
9. **Existing deceased contact on a new domain or registrant change:** refuse via EPP/REPP? Not checked today.
