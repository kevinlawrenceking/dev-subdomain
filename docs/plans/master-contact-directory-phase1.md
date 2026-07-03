# Master Contact Directory — Phase 1 Project Plan

Status: DRAFT for review
Author: prepared with Claude Code recon
Scope: **Phase 1 only** (build the master contact/company directory + let users look up, link, and pull from it; denormalize the hot contact fields). Phase 2 (keeping the master data fresh from scrapers) is out of scope — but Phase 1's schema is designed so Phase 2 drops in cleanly.

---

## 1. Goal

Stop making every user re-type the acting industry. Give them a **self-corrected master directory** (companies + industry people, scraped from public sources into our tables) that they can:

1. **Search** ("Gersh", "casting director in Atlanta").
2. **Link** a master record to one of their own TAO contacts.
3. **Populate** their contact with the master's info (name, company, office, phone, email, photo, IMDb).
4. **Keep editing freely** — their private edits (met-at notes, personal cell, custom company name) are never clobbered when the master improves.

Plus a structural fix that rides along: **promote primary phone / email / company-location out of the `contactitems` EAV bag and onto `contactdetails_tbl` as real columns**, so contact lists stop fanning out into correlated subqueries.

---

## 2. Current state (verified in recon)

### Contact storage
- `contactdetails_tbl` — **base table**, one row per contact. Identity fields only (`contactFullName`, `contacttitle`, `contactNickname`, `contactBirthday`, `contactMeetingDate/Loc`, `contactPronoun`, `contactStatus`, `contactphoto`, `user_yn`, flags, `IsDeleted`). `recordname` is a **VIRTUAL GENERATED** column — do not insert/update it.
- `contactdetails` — **VIEW** over `contactdetails_tbl`. `ContactService.create/read/update` write and read through the view. **DDL and indexes target `_tbl`.**
- `contactitems_tbl` — **base table**; `contactitems` — **VIEW**. EAV: one row per attribute. `valuecategory` in (`Phone`, `Email`, `Company`, `Address`, `URL`, `Tag`, ...); `valuetype` is the subtype (`Work`, `Mobile`, `Home`, `Business`, `Personal`). Phone/Email use `valuetext`; Company uses `valuecompany`; Address uses `valueStreetAddress/City/Region/...`. "Primary" = `ORDER BY primary_yn DESC LIMIT 1`.
- `itemcategory` — lookup for categories (`catid`, `valuecategory`, `caticon`, `catfieldset`, `catArea_UCB`).

### Why lists are slow (the problem the denormalization fixes)
`ContactItemService.getContactDetails` / `REScontactitems` and the contact grids build columns like:
```sql
(SELECT valueText   FROM contactitems WHERE valueCategory='Phone'   AND contactID=d.ContactID AND itemstatus='Active' LIMIT 1) AS phone,
(SELECT valueText   FROM contactitems WHERE valueCategory='Email'   AND contactID=d.ContactID AND itemstatus='Active' LIMIT 1) AS email,
(SELECT valueCompany FROM contactitems WHERE valueCategory='Company' AND contactID=d.ContactID AND itemstatus='Active' LIMIT 1) AS company
```
Three correlated subqueries per row, every list render. Denormalizing the primary values onto `contactdetails_tbl` removes them.

### Master directory tables (exist in `new_development`, unused by app code)
- `companies` — `coid` PK, `coName` UNIQUE, aliases, `coVerificationStatus` (default `Unverified`), `coInitialSource`, region, image URLs, `coImdbID`/ranking, website, phone, socials, longtext blobs, `imdb_yn`/`cdl_yn`/`backstage_yn` source flags.
- `co_locations` — company offices (IMDb-style; **DDL not in repo — VERIFY** before writing FKs). Assumed PK e.g. `locid`, FK `coid`, plus address/region/phone/imdb location id.
- `co_contacts` — scraped industry **people**: `id` PK, `fullname` (indexed), `jobtitle_type`, `location` (indexed), `coid` FK, `imdbid`, `coimdbid`, `tag`, and a `contactid` column (single — cannot represent N per-user links; treat as legacy/scraper-side, **do not** reuse for the user link).
- `co_types` + `companies_cotypes_xref` — company categorization (Talent Agency, Casting, Management, ...).

**Implication:** a TAO contact is usually a *person* → link to `co_contacts`, which carries `coid` → `companies` → `co_locations`. Company-only contacts link straight to a `co_locations` office.

---

## 3. The core decision: how does user data stay in sync with the master?

The question you raised — *"like fuactions → actionusers cookie-cutter, or something better?"* — is the heart of Phase 1. Three candidate models:

| Model | How | Verdict |
|---|---|---|
| **A. Pure copy** (cookie-cutter, like `actionusers`) | On link, copy master fields into the user's row; then fully independent. | ❌ Master improvements never reach the user. Directory goes stale the moment it's linked. Good for *config seeding*, wrong for *living reference data*. |
| **B. Pure reference** (live join) | Store only a pointer to the master; read all display fields live via join. | ❌ Always fresh but the user can't personalize canonical fields, and every read re-joins. Violates "allow user freedom to change/add info." |
| **C. Hybrid: link + snapshot + per-field provenance** | Store a **link** to the master, **copy a snapshot** into the user's row for join-free reads, and tag each managed field as `master`-owned or `user`-overridden. Master refresh updates only still-`master` fields; `user` fields are locked. | ✅ **Recommended.** Fresh where the user hasn't cared, sticky where they have. Join-free reads. |

**Recommendation: Model C.** It's the cookie-cutter idea you already use, upgraded with the one thing the cookie-cutter pattern lacks — **override tracking** — which is exactly what "keep it fresh *and* let the user edit" requires.

### How C behaves
- **Link:** user searches the directory, picks a master person, we write the link columns onto their `contactdetails_tbl` row.
- **Populate:** we copy master → user for each managed field and stamp its source = `master`.
- **User edits a managed field:** we flip that field's source to `user`. It is now locked; no future master refresh touches it.
- **Master changes (Phase 2 job, or the Phase 1 manual "Refresh from master" button):** update only fields still sourced `master`. User fields untouched.
- **Unlink:** keep the snapshot (their data stays), just clear the link + set all sources to `user`.

Managed fields (what the master may own): `contactphoto`, primary phone, primary email, company + company-location, website, IMDb id. **Never master-managed:** `contactFullName` once the contact exists, meeting date/loc, nickname, notes, tags, birthday — these are the user's.

To keep everything in one table and reads join-free, the link columns and per-field source flags live **directly on `contactdetails_tbl`** (no extra join, matches your "single table" goal).

---

## 4. Schema changes

> All DDL targets `*_tbl`. **After altering `contactdetails_tbl` the `contactdetails` VIEW must be rebuilt** if it enumerates columns (it does) — otherwise the new columns are invisible to the app. This is the same trap as the `noteslog` V3_5/V3_6 fix. Verify with `SHOW CREATE VIEW contactdetails`.

### 4.1 Denormalized hot fields + master link (on `contactdetails_tbl`)

```sql
ALTER TABLE contactdetails_tbl
  -- Prominent, denormalized primary contact fields (source of truth for "primary")
  ADD COLUMN contactPhone        VARCHAR(100) NULL AFTER contactPronoun,
  ADD COLUMN contactEmail        VARCHAR(150) NULL AFTER contactPhone,
  ADD COLUMN contactCompany      VARCHAR(200) NULL AFTER contactEmail,   -- display name, always populated (free text OK)
  ADD COLUMN company_location_id INT          NULL AFTER contactCompany, -- FK -> co_locations when linked to master
  -- Per-field provenance for the managed fields (master vs user)
  ADD COLUMN contactPhone_src    ENUM('user','master') NOT NULL DEFAULT 'user',
  ADD COLUMN contactEmail_src    ENUM('user','master') NOT NULL DEFAULT 'user',
  ADD COLUMN contactCompany_src  ENUM('user','master') NOT NULL DEFAULT 'user',
  ADD COLUMN contactphoto_src    ENUM('user','master') NOT NULL DEFAULT 'user',
  -- Master link
  ADD COLUMN master_co_contact_id INT NULL,   -- FK -> co_contacts.id (the person)
  ADD COLUMN master_coid          INT NULL,   -- FK -> companies.coid (denormalized for fast filter)
  ADD COLUMN master_link_status   ENUM('none','linked','unlinked') NOT NULL DEFAULT 'none',
  ADD COLUMN master_linked_date   TIMESTAMP NULL,
  ADD COLUMN master_last_sync     TIMESTAMP NULL,
  ADD INDEX idx_cd_master_person (master_co_contact_id),
  ADD INDEX idx_cd_master_co     (master_coid),
  ADD INDEX idx_cd_company_loc   (company_location_id);
```
FKs to `co_locations`/`co_contacts`/`companies` are **deferred to a follow-up ALTER after `co_locations` DDL is verified** (and only if the master tables live in the same schema — cross-schema FKs are not enforceable in MySQL, so if the master stays in `new_development` while contacts are in `actorsbusinessoffice`, these stay as **soft FKs (indexed INT columns, integrity enforced in the service layer)**). See Open Questions.

### 4.2 Rebuild the `contactdetails` view
```sql
-- After capturing SHOW CREATE VIEW contactdetails, re-issue CREATE OR REPLACE VIEW
-- adding the new columns (or, preferred, redefine as SELECT ... explicit list including the new columns).
```

### 4.3 Master-side: make lookup fast + support N user links
```sql
-- Search support
ALTER TABLE companies    ADD INDEX idx_co_name (coName);            -- verify not already covered by UNIQUE
ALTER TABLE co_contacts  ADD INDEX idx_cc_name_loc (fullname(100), location(100));
-- co_contacts.coid should be indexed (it is 'MUL' already).
```
No master-side link table is needed for Phase 1 because the link lives on `contactdetails_tbl` and is inherently per-user (each user has their own contact row). The legacy `co_contacts.contactid` single column is left alone.

### 4.4 Rollback
Provide a paired `_ROLLBACK.sql` that `DROP`s the added columns/indexes and restores the previous `contactdetails` view definition (captured before the change).

---

## 5. Data migration / backfill

Existing contacts already carry phone/email/company in `contactitems`. Backfill the new columns from the current primary item, once:

```sql
-- Primary phone
UPDATE contactdetails_tbl d
JOIN (
  SELECT contactid, valuetext,
         ROW_NUMBER() OVER (PARTITION BY contactid ORDER BY primary_yn DESC, itemid) rn
  FROM contactitems_tbl
  WHERE valuecategory='Phone' AND itemstatus='Active' AND IsDeleted=0
) p ON p.contactid=d.contactid AND p.rn=1
SET d.contactPhone = p.valuetext, d.contactPhone_src='user'
WHERE d.contactPhone IS NULL;
-- Repeat pattern for Email (valuetext) and Company (valuecompany -> contactCompany).
```
Company-location backfill is best-effort (match `contactitems.valuecompany` → `companies.coName`/alias → default office); leave `company_location_id` NULL where no confident match. Backfill script must be **idempotent** (guarded by `WHERE ... IS NULL`).

---

## 6. Read/write path changes (dual-write, then cut over)

**Source-of-truth rule:** the denormalized column is the **primary**; `contactitems` holds the **long tail** ("more contact info", collapsible in the UI).

- **Writes (primary):** editing primary phone/email/company updates the `contactdetails_tbl` column *and* flips its `_src` to `user`. Keep the matching primary `contactitems` row in sync during a transition window (dual-write) so nothing that still reads items breaks.
- **Writes (secondary / "add another"):** continue to insert into `contactitems` as today.
- **Reads (hot lists first):** switch `getContactDetails`, `REScontactitems`, and the contact grid/gallery to read `d.contactPhone / d.contactEmail / d.contactCompany` directly — delete the three correlated subqueries. Detail view keeps reading `contactitems` for the full list.
- **New `ContactService` fields:** add the new columns to the `allowedFields` map (create) and to `read`/`update`. Never map to `recordname`.

Cutover order avoids a big-bang rewrite: (1) add columns + backfill + dual-write; (2) migrate hot read paths; (3) later, retire redundant item-based primary reads.

---

## 7. New services / endpoints

`MasterDirectoryService.cfc` (new):
- `searchPeople(term, location, coType, limit)` → paged `co_contacts` (+ company join).
- `searchCompanies(term, coType, region, limit)` → paged `companies` (+ types).
- `getPersonDetail(coContactId)` / `getCompanyDetail(coid)` (+ locations).
- `linkContactToMaster(contactid, coContactId)` → writes link cols, sets `master_link_status='linked'`, `master_linked_date=NOW()`.
- `populateFromMaster(contactid, {fields}, overwriteUserFields=false)` → copies master → managed fields where `_src='master'` (or all on first link), stamps `_src`, sets `master_last_sync=NOW()`. **Idempotent, transactional.**
- `unlinkMaster(contactid)` → clears link cols, sets all `_src='user'`, keeps snapshot.

AJAX endpoints under `/ajax/master/` returning the standard `{success, message, data}`:
`search.cfm`, `detail.cfm`, `link.cfm`, `refresh.cfm`, `unlink.cfm`. All parameterized; reference `form.`/`url.` scopes explicitly (implicit scope search is disabled on this server).

---

## 8. UI

- **Contact create/edit:** a "Find in industry directory" search box (AJAX, modal or inline typeahead). Results show name, job title, company, location, photo. "Link & fill" applies `populateFromMaster`.
- **Linked badge:** on a linked contact show a "Linked to directory" chip with `master_last_sync`, a "Refresh from master" button (Phase 1 manual pull), and "Unlink".
- **Field-level indicator:** managed fields that are still `master`-sourced show a subtle "from directory" marker; editing one silently converts it to user-owned.
- **Contact detail:** prominent Phone / Email / Company at top (from the new columns); "More contact info" section (the `contactitems` long tail) collapsed by default.
- AJAX/modal patterns, per-field validation, no full-page reloads.

---

## 9. Risks & mitigations

| Risk | Mitigation |
|---|---|
| View not rebuilt → new columns invisible | Explicit rebuild step + `SHOW CREATE VIEW` verification; mirrors noteslog fix. |
| Cross-schema link (`new_development` master vs `actorsbusinessoffice` contacts) | Confirm target schema; if split, use soft FKs + service-layer integrity; if same, real FKs. **Open question.** |
| Writing `recordname` (virtual generated) | Never in allowedFields; already a known landmine (WO-G). |
| Dual-write drift between column and `contactitems` | Single write path in `ContactService`; transactional; backfill idempotent. |
| Double-submit on link/populate | Endpoints idempotent; `master_link_status` guard. |
| Master data quality (`Unverified`) | Surface `coVerificationStatus`; let user override anything (Model C makes this safe). |

---

## 10. Acceptance criteria

1. A user can search the directory by name/company/location and see paged results.
2. Linking fills contactphoto, phone, email, company, company-location on their contact; managed fields marked `master`.
3. Editing a filled field flips it to `user` and a later "Refresh from master" leaves it intact while updating untouched fields.
4. Contact list/grid renders with **zero** phone/email/company correlated subqueries (verified via `EXPLAIN`).
5. Existing contacts show their primary phone/email/company from the new columns after backfill (spot-check N rows).
6. Unlink keeps the user's data and clears the link.

### Verification checklist
- `SHOW CREATE VIEW contactdetails` includes new columns.
- `EXPLAIN` on the contact grid query shows no dependent subqueries for phone/email/company.
- Backfill counts: `SELECT COUNT(*) FROM contactdetails_tbl WHERE contactPhone IS NOT NULL` vs distinct contacts with a primary phone item.
- Link → edit email → refresh: email unchanged, phone (untouched) refreshed.
- Rollback script restores prior schema + view cleanly on a dev copy.

---

## 11. Work breakdown (suggested sequencing)

- **WO-1 Schema:** ALTER `contactdetails_tbl` (cols + indexes) + rebuild view + rollback. (tao-db)
- **WO-2 Backfill:** idempotent backfill of phone/email/company; report counts. (tao-db)
- **WO-3 Master indexes + verify `co_locations` DDL.** (tao-db)
- **WO-4 `ContactService` extend** allowedFields/read/update for new cols; dual-write primary items. (tao-cfml)
- **WO-5 `MasterDirectoryService` + `/ajax/master/*`** search/detail/link/populate/unlink. (tao-cfml)
- **WO-6 Read-path cutover:** contact grid/gallery + `getContactDetails`/`REScontactitems` read columns. (tao-cfml/ui)
- **WO-7 UI:** directory search modal, linked badge, refresh/unlink, prominent-vs-more layout. (tao-ui)
- **WO-8 Gatekeeper:** proofs (EXPLAIN, backfill counts, link/refresh/unlink cycle), rollback rehearsal. (tao-gatekeeper)

---

## 12. Open questions to confirm before build

1. **Schema location of the master tables at runtime** — do `companies`/`co_contacts`/`co_locations` live in the *same* datasource/schema as `contactdetails_tbl` in prod, or stay in `new_development`? This decides real FKs vs soft FKs and whether search endpoints cross datasources.
2. **`co_locations` DDL** — need columns (PK, `coid` FK, address/region/phone, imdb location id) to wire `company_location_id`.
3. **Person vs company linking** — confirm the primary link target is `co_contacts` (person) with company derived, vs linking some contacts directly to a company/location.
4. **"Refresh from master" in Phase 1** — manual button only (recommended), with the automatic scheduled propagation deferred to Phase 2? 
5. **Company field semantics** — is `contactCompany` free text with `company_location_id` as the optional structured pointer (recommended), or should company be structured-only once linked?
