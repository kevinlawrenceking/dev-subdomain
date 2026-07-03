# DEV-PROOF-RUNBOOK — contact merge repoint conformance (Phase I)

Run every block on **dev** (`new_development` / datasource `abod`). Kevin executes and
pastes outputs; I fold them into the proof bundle. Read-only MySQL MCP, once live, may
self-run the SELECT-side blocks (1, 2, 4, 5, 6, 8, 9); never the merges themselves.

Parameters used below — substitute per run:
- `:pri`  = primary (keep) contactid
- `:dup`  = duplicate contactid (soft-deleted by the merge)
- `:uid`  = owning userid
- `:mergeid` = contact_merge_log.mergeid produced by the merge under test

In-scope tables (final list): contactitems_tbl, noteslog_tbl, eventcontactsxref_tbl,
audcontacts_auditions_xref, fusystemusers_tbl, events_tbl, audprojects, auditions,
audroles, notifications_tbl, tmpcontactgroups_tbl, shares, contactdetails_tbl
(referral + soft-delete). Exempt from zero-dangling: co_contacts, bigbrother, updatelog,
contact_merge_log/map, casting_notifications, import/export/staging, `_zzq_*`/`*_bak`/
`*_backup`.

---

## Setup — pick a rich duplicate on dev

Choose a `:dup` that has, for the same `:uid`: contact items (some colliding with `:pri`),
notes, an event attendance row colliding with `:pri`, an audition xref colliding with
`:pri` (with xrefnotes), an active fusystemusers enrollment colliding with `:pri`, an
events_tbl/audprojects/audroles row, a notifications_tbl row, a tmpcontactgroups_tbl row,
a shares row, and at least one other contact whose refer_contact_id = `:dup`. Record the
pre-merge counts so the deltas are meaningful.

---

## 1. Zero-dangling UNION (must return ZERO rows)

After the merge commits, no in-scope base table may still reference `:dup`, and `:dup`
must be soft-deleted.

```sql
SELECT 'contactitems_tbl' t, COUNT(*) n FROM contactitems_tbl WHERE contactid = :dup AND (isDeleted IS NULL OR isDeleted = 0)
UNION ALL SELECT 'noteslog_tbl',              COUNT(*) FROM noteslog_tbl              WHERE contactid = :dup
UNION ALL SELECT 'eventcontactsxref_tbl',     COUNT(*) FROM eventcontactsxref_tbl     WHERE contactid = :dup AND (IsDeleted IS NULL OR IsDeleted = 0)
UNION ALL SELECT 'audcontacts_auditions_xref',COUNT(*) FROM audcontacts_auditions_xref WHERE contactid = :dup
UNION ALL SELECT 'fusystemusers_tbl',         COUNT(*) FROM fusystemusers_tbl         WHERE contactid = :dup AND (isdeleted IS NULL OR isdeleted = 0)
UNION ALL SELECT 'events_tbl',                COUNT(*) FROM events_tbl                WHERE contactid = :dup
UNION ALL SELECT 'audprojects',              COUNT(*) FROM audprojects              WHERE contactid = :dup
UNION ALL SELECT 'auditions',                COUNT(*) FROM auditions                WHERE contactid = :dup
UNION ALL SELECT 'audroles',                 COUNT(*) FROM audroles                 WHERE contactid = :dup
UNION ALL SELECT 'notifications_tbl',        COUNT(*) FROM notifications_tbl        WHERE contactid = :dup
UNION ALL SELECT 'tmpcontactgroups_tbl',     COUNT(*) FROM tmpcontactgroups_tbl     WHERE contactid = :dup
UNION ALL SELECT 'shares',                   COUNT(*) FROM shares                   WHERE contactid = :dup
UNION ALL SELECT 'refer_incoming',           COUNT(*) FROM contactdetails_tbl       WHERE refer_contact_id = :dup AND contactid <> :dup
HAVING n > 0;   -- expect: EMPTY result set

-- And the duplicate is soft-deleted:
SELECT contactid, isdeleted FROM contactdetails_tbl WHERE contactid = :dup;  -- expect isdeleted = 1
```

## 2. Map-completeness

Every repoint/delete/enrichment-carry the merge performed is mapped.

```sql
SELECT action, COUNT(*) FROM contact_merge_map WHERE mergeid = :mergeid GROUP BY action;
SELECT rows_affected FROM contact_merge_log WHERE mergeid = :mergeid;
-- rows_affected must equal SELECT COUNT(*) FROM contact_merge_map WHERE mergeid = :mergeid.
-- Every map row must carry new_contactid = :pri (A2):
SELECT COUNT(*) AS bad_new FROM contact_merge_map WHERE mergeid = :mergeid AND new_contactid <> :pri;  -- expect 0

-- LOCKED formula: total map rows == the sum across ALL NINE labels, and there is no
-- tenth label. The two documented enrichment writes (xrefnotes salvage, applyMergedFields)
-- are the ONLY mutations outside the map.
SELECT
  (SELECT COUNT(*) FROM contact_merge_map WHERE mergeid = :mergeid) AS total,
  (SELECT COUNT(*) FROM contact_merge_map WHERE mergeid = :mergeid AND action IN
     ('repointed','deleted','item_deleted','enroll_deleted','referral_repointed',
      'referral_inherited','referral_cleared','softdeleted','avatar_carried')) AS nine_label_sum,
  (SELECT COUNT(*) FROM contact_merge_map WHERE mergeid = :mergeid AND action NOT IN
     ('repointed','deleted','item_deleted','enroll_deleted','referral_repointed',
      'referral_inherited','referral_cleared','softdeleted','avatar_carried')) AS unknown_label;
-- expect: total = nine_label_sum, unknown_label = 0
```

## 3. Shares two-branch (run BOTH cases)

- **Branch A (keep already shared):** pick `:pri` that already has a `shares` row.
  Expect: dup's shares row mapped `deleted` and gone; pri's row untouched.
  ```sql
  SELECT contactid FROM shares WHERE contactid IN (:pri, :dup);  -- expect only :pri
  SELECT action FROM contact_merge_map WHERE mergeid = :mergeid AND tbl = 'shares';  -- expect 'deleted'
  ```
- **Branch B (keep not shared):** pick `:pri` with no `shares` row, `:dup` with one.
  Expect: dup's row repointed to pri.
  ```sql
  SELECT contactid FROM shares WHERE contactid IN (:pri, :dup);  -- expect only :pri
  SELECT action FROM contact_merge_map WHERE mergeid = :mergeid AND tbl = 'shares';  -- expect 'repointed'
  ```

## 4. tmpcontactgroups repoint check

```sql
SELECT COUNT(*) FROM tmpcontactgroups_tbl WHERE contactid = :dup;  -- expect 0
SELECT COUNT(*) FROM contact_merge_map WHERE mergeid = :mergeid AND tbl = 'tmpcontactgroups_tbl';  -- expect = pre-merge dup membership count
-- Possible duplicate memberships on :pri are ACCEPTED (cosmetic, zero readers) — registered.
```

## 5. Self-referral regression (no contact ends referring to itself)

```sql
SELECT contactid, refer_contact_id FROM contactdetails_tbl
WHERE  contactid IN (:pri, :dup) AND refer_contact_id = contactid;  -- expect EMPTY
-- Edge cases to construct explicitly:
--  (i) pri.refer_contact_id = dup, dup.refer_contact_id = X (X not in {pri,dup}) -> pri inherits X ('referral_inherited')
-- (ii) pri.refer_contact_id = dup, dup.refer_contact_id NULL or = pri/dup       -> pri cleared ('referral_cleared')
SELECT action, COUNT(*) FROM contact_merge_map WHERE mergeid = :mergeid AND action LIKE 'referral_%' GROUP BY action;
```

## 6. D1 block (user-linked contact cannot be merged away)

Pick a `:dup` that is a `taousers_tbl.contactid`. Attempt the merge via the UI.
Expect: standard envelope `{success:false, message:"...linked to a user account..."}`,
and ZERO writes.

```sql
SELECT COUNT(*) FROM contact_merge_log WHERE duplicate_contactid = :dup AND merge_timestamp >= :since;  -- expect 0
SELECT isdeleted FROM contactdetails_tbl WHERE contactid = :dup;  -- expect unchanged (0)
```
(Then re-run with pri and dup swapped — the user-linked contact as `:pri` must merge fine.)

## 7. contact_not_duplicate cleanup / skip

- **Present:** ensure a dismissal row pairs `:dup`. After merge:
  ```sql
  SELECT COUNT(*) FROM contact_not_duplicate WHERE userid = :uid AND :dup IN (contactid_low, contactid_high);  -- expect 0
  SELECT COUNT(*) FROM contact_merge_map WHERE mergeid = :mergeid AND tbl = 'contact_not_duplicate';  -- expect >= 1, action 'deleted'
  ```
- **Absent:** on an environment without the table, the merge still succeeds; the
  `contact_merge` log shows `contact_not_duplicate absent - cleanup skipped`.

## 8. Double-submit idempotency

Submit the identical merge POST twice (or click twice). The second call hits the qGuard
(`:dup` now soft-deleted -> recordCount != 2) and aborts.

```sql
SELECT COUNT(*) FROM contact_merge_log WHERE primary_contactid = :pri AND duplicate_contactid = :dup;  -- expect 1
```

## 9. EXPLAIN pair (unindexed contactid repoints)

`audprojects.contactid` and `audroles.contactid` are unindexed; `events_tbl`/`auditions`
are indexed. If the tool rejects `EXPLAIN UPDATE`, run EXPLAIN on the equivalent SELECT and
state the substitution.

```sql
EXPLAIN SELECT * FROM audprojects WHERE contactid = :dup;   -- substitution for the UPDATE
EXPLAIN SELECT * FROM audroles   WHERE contactid = :dup;    -- substitution for the UPDATE
```
Full-scan of ~11k rows is acceptable for a rare admin op. Index DDL is registered-only.

## 10. Failure-injection (full rollback)

Mechanism: a **temporary dev-only** throw INSIDE the transaction, host-guarded, added by
hand, run once, then removed. It is NOT part of the staged diff (isolation verification
must show `mergeContacts` contains no `cfthrow`).

Temporarily insert immediately after step 7A (events_tbl) inside `<cftransaction>`:
```cfml
<cfif listFirst(cgi.server_name, ".") NEQ "app">
    <cfthrow message="DEV failure-injection: forcing rollback" />
</cfif>
```
Run a merge, then verify NOTHING committed:
```sql
SELECT isdeleted FROM contactdetails_tbl WHERE contactid = :dup;                 -- expect 0 (still active)
SELECT COUNT(*) FROM contact_merge_map WHERE mergeid = :mergeid_attempted;       -- expect 0
SELECT COUNT(*) FROM events_tbl WHERE contactid = :pri AND ... ;                 -- expect no partial repoint
SELECT contactid FROM contactitems_tbl WHERE contactid = :dup LIMIT 5;           -- expect dup still owns its items
```
The merge returns `{success:false, message:"Error merging contacts: ..."}` and logs to
`contact_merge`. **Remove the cfthrow** and re-confirm `grep -n cfthrow
services/ContactDuplicateService.cfc` returns nothing.

## 11. Referral-ordering regression (the authorized Flag-3 fix)

Proves the pri-first edge runs on post-applyMergedFields state, so a user-submitted
`refer_contact_id = :dup` is corrected, not left dangling.

Setup on dev: choose a pair where `:pri` is (or, via the modal choice, becomes) referred by
`:dup` — i.e. `pri.refer_contact_id = :dup` — and `:dup` has its own referrer `Z`. Run the
merge accepting the modal defaults (including, if the modal offers it, a refer choice of the
duplicate).

```sql
-- keep contact must NOT end up referring to itself or to the (now soft-deleted) duplicate,
-- and must equal Z (or be NULL if Z is in {:pri,:dup}):
SELECT contactid, refer_contact_id FROM contactdetails_tbl WHERE contactid = :pri;
--   expect refer_contact_id NOT IN (:pri, :dup); = Z, or NULL when Z in {:pri,:dup}

-- the edge wrote the correct map row:
SELECT action, COUNT(*) FROM contact_merge_map
WHERE  mergeid = :mergeid AND action IN ('referral_inherited','referral_cleared')
GROUP  BY action;   -- expect one row: referral_inherited (Z valid) OR referral_cleared

-- and the zero-dangling block (1) still returns all zeros for this merge.
```
Run twice: once where `Z` is a real third contact (expect `referral_inherited`, value = Z),
once where `Z` is NULL or in {:pri,:dup} (expect `referral_cleared`, value NULL).
