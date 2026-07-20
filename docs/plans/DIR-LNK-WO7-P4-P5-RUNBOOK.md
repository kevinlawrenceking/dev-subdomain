# DIR-LNK-WO-7 — P4 (DEPLOY) + P5 (ACCEPTANCE) RUNBOOK

**Work order:** DIR-LNK-WO-7 (link-with-preview flow + bridge disable + snapshot population)
**Binding:** project = TAO / repo = dev-subdomain / root = c:\Users\kevin\TAO\dev-subdomain / branch = dev
**Phase:** P4 (commit/push/deploy — each separately authorized) + P5 (acceptance, dev, evidence-cited)
**Authored:** 2026-07-18. This is the runbook only — no push, no deploy, no DDL executed here.

## CODE OF RECORD (local, unpushed)
- Stage 1 (service): **`dd89a403`** — bridge disable, link snapshot, preservation, unlink restore, audit writes.
- Stage 2 (UI): **`72153800`** — preview modal, confirm endpoint, photo provenance render, export repoint.
- Deploy target SHA = **`72153800`** (local HEAD). origin/dev currently = **`257df24e`** (pre-WO-7-code).

---

## P4 — DEPLOY (operator-executed; each step separately authorized)

### P4a — ROLLBACK PIN CAPTURE (do this FIRST, before any push or pull)
- **PIN_PRIOR (rollback target) = `257df24e`** — the current origin/dev / deployed SHA (pre-WO-7 code).
  Confirm live before deploying: `git ls-remote origin dev` must read `257df24e` at push time.
- **Rollback sequence** (if the deploy misbehaves): on the panel, `git fetch` then `git checkout 257df24e`
  (or `git reset --hard 257df24e` on the deploy checkout) → full CF template+component cache clear (or CF
  service restart) → liveness probe a full contact page. WO-7 wrote NO DDL, so a code rollback is complete;
  no schema step. Any P5 fixtures are soft-deleted per A-5.
- Record the captured pin in the deploy log BEFORE pulling.

### P4b — PUSH (gated on a named PUSH GO; not authorized by this runbook)
- On PUSH GO: `git push origin dev` (pushes the WO-7 docs commits + `dd89a403` + `72153800`).
- Confirm: `git ls-remote origin dev` == `72153800`.

### P4c — OPERATOR DEV DEPLOY (D-17; the D-17 gap broke WO-2's first run)
1. Panel pull to `72153800`.
2. **CF Admin: clear template cache AND component cache** (or restart the CF service) — the service layer
   changed (new CFCs + methods) and `contact_info.cfm` changed; a stale component cache would serve the old
   `MasterDirectoryService`/`ContactService`.
3. **Liveness probe on a FULL contact page** (not the /include fragment): load a real contact, confirm the
   page renders and the master-link band shows "Find in the Book".
4. Freshness marker: the confirm endpoint returns `"_build":"wo7-link-confirm-2026-07-18-v1"` — verify it in
   the first confirm response.

---

## P5 — ACCEPTANCE (dev, evidence-cited)

### Fixture discipline (A-5) — do this before assertions
1. **Baseline capture** (record pre-test counts, user 30 unless noted):
   - `ss_rows`, active contacts, `contactitems_tbl` active-row count.
   - `master_audit_tbl` row count (currently ~79 pre-WO-7-runtime; WO-7 is the first runtime writer).
   - per-field `_src` distribution among linked contacts.
2. **Register EVERY fixture contactID at creation** (add-form + any created here) with expected delta.
3. **Cleanup to baseline** at the end (soft-delete fixtures) and prove counts return — EXCEPT the permanent
   `master_audit_tbl` rows WO-7 legitimately writes (append-only; count the delta, do not expect restore).

### Test matrix (lock §P5 a–k + S-1/S-2/S-3)

| # | Test | Steps | Expected |
|---|------|-------|----------|
| a | **Link, NO existing values** | Fixture with blank phone/email/company → Find in the Book → pick a person → **short form** renders → confirm | snapshot written; `_src='master'` on all three; panel flips gold "In the Book"; audit `LINK_CREATED` + `MASTER_SNAPSHOT_POPULATED`×3 |
| b | **Link, WITH existing values** | Fixture with user phone/email/company → pick person → **full diff** renders and matches the DB → confirm | user values preserved as Additional-info items; master values in columns; audit `PRELINK_VALUE_PRESERVED` per displaced field |
| c | **Multi-office** | Company with 2–5 offices → cards render; 6+ → searchable list, confirm disabled until a pick (R-A) → choose office → confirm | chosen office's phone/email/address land; `company_location_id` = chosen colocid |
| d | **Blank-master (Q4)** | Pick an office with no phone/email | amber "check this one" row shown before confirm; on confirm the managed field mirrors blank (NULL), `_src='master'`; the user's prior value preserved as an item |
| e | **Photo picker** | Contact with a user photo; master has an image → choose "From the Book" → confirm | `contactPhoto_src='master'`; panel avatar renders the master image even though a local avatar file exists (2b). Choose "Your upload" → `_src='user'`, local file renders |
| f | **Cancel** | Open preview, switch office, toggle photo, Cancel (and "Not the right person?") at each step | zero writes (verify columns, items, audit unchanged) |
| g | **Relink** | Linked fixture → open preview for a DIFFERENT master → confirm | `MASTER_RELINKED` audited; snapshot replaced; **no duplicate preserved items** (prior master's values were `_src='master'`, not re-preserved) |
| h | **Unlink (Q2 / R-B)** | Linked fixture (with a preserved item) → unlink | restore precedence: active preserved item value → else audit `old_value` → else blank; the used item is consumed (soft-deleted); audit `PRELINK_VALUE_RESTORED` / `PRIMARY_FIELD_CLEARED_AFTER_UNLINK`; pointers NULL incl. `company_location_id` |
| i | **BRIDGE OFF (D-19 regression)** | Link a fixture; then query its Company contactitems | **ZERO** new `valueCategory='Company'` items created by the link; company lives only in the `contactCompany` column |
| j | **Negatives** | (1) confirm as user 30 on another user's contactid; (2) POST without CSRF token; (3) confirm with injected `contactCompany`/`master_coid`/`isMaster` params; (4) double-submit the same confirm | (1) "Contact not found.", zero writes; (2) 403 central gate; (3) injected master values ignored (server re-derives); (4) idempotent no-op, no double preserve/audit |
| k | **WO-6 regression** | On the newly linked fixture, attempt a primary edit via the panel; check the list | `updatePrimary` still rejects (linked, managed-by-the-Book message); `contacts_ss` shows the new master values |
| **S-1a** | **Preview, no session** | Log out / drop session, GET `/include/master_link_preview.cfm?contactid=X&masterCoContactId=Y` | renders nothing usable (no contact/master data); "session expired" message; no data leak |
| **S-1b** | **Preview, foreign contactid** | Authenticated as user 30, GET the preview with another user's contactid | neutral "Contact not found." — same as a non-existent id (no enumeration oracle) |
| **S-2** | **Export company** | Export a linked (or column-only unlinked) contact | exported Company = the `contactCompany` column value (not blank); confirms the item-reader defect is fixed |
| **S-3** | **Office-switch disclosure** | Multi-office company: pick an office WITH a phone (disclosure "your phone moves to Additional info"), then switch to an office WITHOUT one | the From-the-Book phone cell flips to the amber blank row, the "moves" tag updates, and the footer kept/moved counts recompute — the disclosure matches what confirm will actually apply |

### SQL verification (read-only; run via the ratified pymysql channel or HeidiSQL)
```sql
-- snapshot + provenance for a linked fixture
SELECT contactPhone, contactPhone_src, contactEmail, contactEmail_src,
       contactCompany, contactCompany_src, contactPhoto_src,
       master_co_contact_id, master_coid, company_location_id, master_last_sync
FROM new_development.contactdetails_tbl WHERE contactid = :fx;

-- bridge-off: zero Company items created by the link (i)
SELECT COUNT(*) FROM new_development.contactitems_tbl
WHERE contactid = :fx AND valueCategory='Company' AND itemStatus='Active' AND IsDeleted=0;

-- audit trail written by WO-7 (a/b/g/h)
SELECT auditID, action_type, field_name, old_value, new_value, previous_source, new_source, idempotency_key
FROM new_development.master_audit_tbl WHERE contactID = :fx ORDER BY auditID;

-- preserved items (b) and consumed-on-unlink (h)
SELECT itemID, valueCategory, valuetext, valueCompany, itemStatus, IsDeleted
FROM new_development.contactitems_tbl WHERE contactid = :fx ORDER BY itemID;
```

### P6 — BUNDLE + STOP (after acceptance)
Assemble `DIR-LNK-WO7-BUNDLE.md`: per-criterion PASS/FAIL, diffs by SHA (`dd89a403`, `72153800`), deploy +
rollback-capture evidence, acceptance pastes (incl. every negative + S-1/S-2/S-3), fixture register with
baseline restoration, rulings of record, remaining gaps (unlink-through-preview refinement; office-switch
"moves" disclosure now recomputed per S-3), push set. STOP for architect review → operator docs PUSH GO → close.

## HOLDS
No push without a named PUSH GO. No deploy without the operator executing D-17 with the `257df24e` rollback pin
in hand. No DDL (WO-7 wrote none). No prod. Halt-don't-guess.

*END — DIR-LNK-WO7-P4-P5-RUNBOOK.md*
