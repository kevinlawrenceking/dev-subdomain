# WO-DUPES-R1 — Operator Packet (single dev visit)

**Binding:** TAO / `dev-subdomain` / branch `dev` · **Date:** 2026-07-06 · datasource: `abod` (dev)
**Status:** dev-visit steps for R-4 (implemented, uncommitted) + R-5A-3 fixture (evidence-only).
Run on the dev CF site that serves this checkout (Step 0 of the visit).

> **Step 0 (environment):** confirm dev serves THIS checkout — e.g. the phonebook tombstone
> (`services/AuditionImportService.cfc:~1614`, email resolution gone) or the modal Keep/Discard
> label change (`915e533c`) is live. If live → Phase F synthesis path. If not → Phase 0 before deploy.

---

## Part A — R-4 audition-filter dropdown proof (4 cases)

Open `/app/auditions/` as a user who has audition data. For each case, confirm the dropdown lists the
contact/source AND selecting it returns at least one audition.

| # | Case | Setup | Expected |
|---|------|-------|----------|
| 1 | **tagged-but-unlinked rep appears** | a contact tagged `My Team`/`Agent`/`Manager`/`Publicist` with **no** audition role | appears in **All Reps** dropdown (arm A) |
| 2 | **linked-but-untagged rep appears** *(the regression the UNION prevents)* | a contact on an `audroles` row for the user but with **no** team tag | appears in **All Reps** dropdown (arm B); selecting returns that audition |
| 3 | **master source with no auditions appears** | an `audsubmitsites_user` row never used on a role | appears in **All Submission Sources** (arm A) |
| 4 | **legacy in-use source appears** | an `audroles.submitsiteid` whose `audsubmitsites_user` row is soft-deleted / name-blank | appears in **All Submission Sources** (arm B); labelled by name or `(site #id)` |

**R-4-3 parity statement (confirm live):** Reps filter matches `audroles.contactid` (no tag set applied
in the filter); Sources filter matches `audroles.submitsiteid` — identical column the dropdown emits. No drift.

**DEV-VERIFY for arm B keyspace assumption (run once; confirms the R-4-2 residual assumption):**
```sql
-- Do audroles.submitsiteid values resolve inside the per-user audsubmitsites_user keyspace?
-- Expect: most/all in-use ids present for the same user; any NULLs are the "(site #id)" fallback rows.
SELECT r.submitsiteid,
       MAX(su.submitsitename) AS resolved_name,
       COUNT(*)               AS role_uses
FROM audroles r
JOIN audprojects p        ON p.audprojectid = r.audprojectid
LEFT JOIN audsubmitsites_user su
       ON su.submitsiteid = r.submitsiteid AND su.userid = p.userid
WHERE p.userid = @u AND p.isDeleted = 0 AND r.isDeleted = 0
  AND r.submitsiteid IS NOT NULL AND r.submitsiteid > 0
GROUP BY r.submitsiteid
ORDER BY role_uses DESC;
```

---

## Part B — R-5A-3 false-pair fixture (proves the CURRENT matcher at HEAD)

Proves `ContactDuplicateService.findPossibleDuplicates` suppresses false near-SOUNDEX pairs while
keeping true dupes. **Evidence-only — independent of R-5A code.**

### B.1 Set the dedicated test user
```sql
-- Use a DEDICATED dev test user id (create/pick one that holds no real data). Fill it in:
SET @u := 0;   -- <<< REPLACE with the dedicated dev test userid before running
```

### B.2 Idempotent seed (replay-safe: clears this user's fixture rows, re-inserts)
`contactdetails` is a VIEW; write to `contactdetails_tbl`. `recordname` is a generated column — omitted.
Minimal insert `(userid, contactfullname)` mirrors `ContactService.cfc:1034`.
```sql
-- Idempotent: remove prior fixture rows for the test user, then reseed exactly the spec set.
DELETE FROM contactdetails_tbl WHERE userid = @u;

INSERT INTO contactdetails_tbl (userid, contactfullname) VALUES
  (@u, 'Josh Siegel'),
  (@u, 'Jessica Kelly'),
  (@u, 'Nancy Nayor'),
  (@u, 'Nike Imoru'),
  (@u, 'Paul Hardt'),
  (@u, 'Paul Ruddy'),
  (@u, 'Scott Wojcik'),
  (@u, 'SJ Hodges'),
  (@u, 'Krystal O''Conner'),
  (@u, 'Krystal OConnor'),
  (@u, 'Brandon Henry Rodriguez'),
  (@u, 'Brandon Henry Rodriguez'),
  (@u, 'Brandon Henry Rodriguez');
```

### B.3 Confirm seed
```sql
SELECT contactid, contactfullname
FROM contactdetails
WHERE userid = @u AND isdeleted = 0
ORDER BY contactfullname, contactid;   -- expect 13 rows (3 identical Rodriguez)
```

### B.4 Expected dedupe-report outcome
Run the duplicate report for `@u` (Contacts → Find Duplicates, as that user) and confirm:

| Pair | Expected |
|------|----------|
| Josh Siegel / Jessica Kelly | **ABSENT** |
| Nancy Nayor / Nike Imoru | **ABSENT** |
| Paul Hardt / Paul Ruddy | **ABSENT** (same first, surname gate drops) |
| Scott Wojcik / SJ Hodges | **ABSENT** |
| Krystal O'Conner / Krystal OConnor | **PRESENT** (apostrophe-only difference) |
| Brandon Henry Rodriguez ×3 | **PRESENT — exactly 3 pairs** (C(3,2)) |

### B.5 Optional SQL sanity — SOUNDEX prefilter candidate bound (not the final verdict)
```sql
-- Shows which pairs even reach the CFML gate; final drop/keep is decided in CFML
-- (Levenshtein + surname gate), not here.
SELECT a.contactfullname AS name_a, b.contactfullname AS name_b
FROM contactdetails a
JOIN contactdetails b ON b.userid = a.userid AND b.contactid > a.contactid
WHERE a.userid = @u AND a.isdeleted = 0 AND b.isdeleted = 0
  AND SOUNDEX(a.contactfullname) = SOUNDEX(b.contactfullname)
ORDER BY name_a, name_b;
```

### B.6 Teardown (optional; the seed is self-idempotent on re-run)
```sql
DELETE FROM contactdetails_tbl WHERE userid = @u;
```
