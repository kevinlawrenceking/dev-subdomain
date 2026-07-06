# Retroactive Proof Bundle — CONFORMANCE AUDIT (items 1 / 4 / 5A / 5B)

**Binding:** TAO / dev-subdomain / branch `dev` / repo `kevinlawrenceking/dev-subdomain`
**Date:** 2026-07-06 · **Author:** CC · **Method (per C5/b):** conformance audit of the
**current working tree + git history** against the re-issued spec. No thread archaeology,
no invention. Any spec row the current code fails becomes a **revision task** (listed at
the end) — **no fixes are applied in this bundle**.

**Ground-truth state at audit time:** `HEAD = a7e1c05e` (Kevin, 2026-07-06), working tree
**clean**. All audited code is committed.

---

## History section (git log `57c261b5..HEAD`) — for Kevin's mine / needs-review annotation

| commit | author | date | files | annotate |
|--------|--------|------|-------|----------|
| `a7e1c05e` | Kevin King | 2026-07-06 | `WO0-PROOF-BUNDLE.md` + `database/migrations/V3_7/8/9__*` (6) + `docs/plans/evidence/2026-07-0{4,6}-wo0b-*` (8) — 15 files, +1302 | ☐ mine ☐ review |
| `183b2542` | Kevin King | 2026-07-04 | `include/contacts.cfm` (+4/-4, reposition Find-Duplicates button) | ☐ mine ☐ review |
| `8c4cc70a` | Kevin King | 2026-07-04 | `include/contacts.cfm` (+6/-2, add find/merge button) | ☐ mine ☐ review |
| `915e533c` | Kevin King | 2026-07-03 | `include/merge_contacts_interface.cfm` (+17/-3, Keep/Discard labels) | ☐ mine ☐ review |
| `450fe1c4` | Kevin King | 2026-07-03 | `services/ContactDuplicateService.cfc` (+39/-2, local SoundEx) | ☐ mine ☐ review |

**Reconciliation flag:** the large `mergeContacts()` repoint rewrite is **not** a discrete
commit in this range, yet the conformant `mergeContacts()` (with the step-10 `contact_not_duplicate`
cleanup, `ContactDuplicateService.cfc:941`) is present in `HEAD` with a clean tree — so it
landed in an **earlier** commit (candidates `28b949fa`, `79401908`). Confirm which commit is
"the merge-repoint commit" that gates Items 1 & 3; per your own rule, **if it is already in
`HEAD`, Items 1 & 3 are unblocked.**

---

## Item 5A — findPossibleDuplicates (false-positive suppression)

Verbatim candidate SQL — `services/ContactDuplicateService.cfc:120-139`:
```sql
SELECT a.userid, a.contactid AS id_a, a.contactFullName AS name_a,
       b.contactid AS id_b, b.contactFullName AS name_b
FROM contactdetails a
JOIN contactdetails b ON b.userid = a.userid AND b.contactid > a.contactid
WHERE a.userid = :userid
  AND a.isdeleted = 0 AND b.isdeleted = 0
  AND TRIM(COALESCE(a.contactFullName,'')) <> ''
  AND TRIM(COALESCE(b.contactFullName,'')) <> ''
  AND SOUNDEX(a.contactFullName) = SOUNDEX(b.contactFullName)
  AND LOWER(REGEXP_REPLACE(TRIM(a.contactFullName),'\s+',' '))
   <> LOWER(REGEXP_REPLACE(TRIM(b.contactFullName),'\s+',' '))
ORDER BY name_a
```
Match dimensions (all NAME-based; no email dimension present):
1. **MySQL SOUNDEX** prefilter equal (SQL, cheap candidate bound).
2. **Exact-normalized exclusion** — drop pairs already identical after lower+collapse (SQL).
3. **CFML Levenshtein** on `cdNormalizeName` ≤ `max(2, int(0.2*minLen))` (`:166-177`).
4. **Surname gate** `cdSurnameMatches` — exact last-token OR local-soundex + Levenshtein≤2 (`:212-228`).
   Score = `int((1 - dist/maxLen)*100)` (`:178`).

| Spec row | Verdict | Evidence |
|----------|---------|----------|
| Original SQL captured verbatim | **PASS** | above, `:120-139` |
| Candidate query userid-scoped | **PASS** | `a.userid=:userid`, `b.userid=a.userid` `:128-130` |
| Excludes isdeleted | **PASS** | `a.isdeleted=0 AND b.isdeleted=0` `:131-132` |
| Excludes dismissed pairs | **PASS** | `getDismissedPairs` + `pairKey` cfcontinue `:158-161` (applied in CFML, not SQL) |
| Every match dimension stated | **PASS** | 4 dims above; name-only |
| Email-match → name-gate not applied to email pairs | **N/A** | no email dimension exists; rule is vacuous. Flag if email matching was expected (→ WO-PHONEBOOK-A) |
| Show match-reason per pair | **PARTIAL** | numeric `match_score` returned `:185`; **no textual reason label** per pair |
| Normalization identical to create-time matcher | **FAIL** | `cdNormalizeName` `:199-205` strips `[^a-z0-9 ]`; `DuplicateMatcherService.normalizeName` `:51-57` does **not** strip punctuation (only trim+collapse+lcase). **Not identical.** |
| 5 false pairs drop; Krystal pair + Rodriguez triplicate survive | **PROOF-OWED** | code names only **3** false pairs (Josh/Jessica, Paul Hardt/Paul Ruddy, Nancy Nayor/Nike Imoru `:113-114`); surname gate logic drops same-first/diff-surname `:174-177`; the full 5-drop + Krystal-keep + Rodriguez-triplicate-keep needs a **runtime query on the reporting user's data** (Kevin, dev) |

## Item 4 — audition filter dropdowns

`SELauditionReps` — `services/AuditionProjectService.cfc:243-269`:
```sql
SELECT DISTINCT c.contactid, c.recordname AS repname
FROM contactdetails c
INNER JOIN contactitems ci ON ci.contactid = c.contactid
WHERE c.userid = :userid AND (c.isDeleted IS NULL OR c.isDeleted = 0)
  AND ci.valueCategory = 'Tag'
  AND ci.valuetext IN ('My Team','Agent','Manager','Publicist')
  AND ci.isDeleted = 0
ORDER BY c.recordname
```
`SELauditionSources` — `:271-292`:
```sql
SELECT DISTINCT b.submitsiteid AS id, b.submitsitename AS name
FROM audsubmitsites_user b
WHERE b.userid = :userid AND (b.isDeleted IS NULL OR b.isDeleted = 0)
  AND b.submitsitename <> ''
ORDER BY b.submitsitename
```

| Spec row | Verdict | Evidence |
|----------|---------|----------|
| Both userid-scoped | **PASS** | `c.userid=:userid` `:257`; `b.userid=:userid` `:283` |
| Reps tag predicate = team/agent/manager/publicist | **PASS** | `valuetext IN ('My Team','Agent','Manager','Publicist')` `:260-262` (confirm the audition filter uses the same tag set) |
| Reps = tags **UNION** reps-on-user's-auditions | **FAIL** | code is **tag-only**; the audition-linkage join was deliberately removed (`:246-250`). A rep on an audition but **without** a team tag is not returned. Missing the in-use half of the union. |
| Sources = audsubmitsites_user **UNION** distinct in-use sources | **FAIL** | code is **master-list only** (`:274-277`); a source used on an audition but absent from `audsubmitsites_user` is not returned. Missing the in-use half. |

Note: the implemented Ticket-4 fix intentionally swapped "in-use only" → "all master/tagged."
The re-issued spec asks for the **union of both**. That is the gap.

## Item 5B — contact_not_duplicate dismissals

Table DDL — `database/migrations/2026-07-02_contact_not_duplicate.sql:20-30`; service —
`ContactDuplicateService.cfc` `getDismissedPairs :319-337`, `dismissDuplicatePair :341-385`.

| Spec row | Verdict | Evidence |
|----------|---------|----------|
| Has `userid` + `UNIQUE(userid, contactid_low, contactid_high)` | **PASS** | `userid INT NOT NULL` + `UNIQUE KEY UQ_not_dupe(...)` DDL `:22,28` |
| low < high service-enforced | **PASS** | `lo=min`, `hi=max`, rejects `lo EQ hi` `:347-352` |
| Idempotent insert; repeat POST returns success | **PASS** | `INSERT IGNORE` `:368`; `result.success=true` after `:376` (repeat no-ops, still success) |
| Migration information_schema-guarded + tested rollback | **PASS (note)** | `CREATE TABLE IF NOT EXISTS` (idempotent/replay-safe equivalent) `:20`; rollback file present; "tested" = Kevin dev-run |
| cftry read-guard transitional with cflog | **PASS** | `getDismissedPairs` cftry + `cflog file="contact_merge"` on catch `:322-334` |

**Item 5B is fully conformant.** (Plus an ownership guard `:355-364` — both contacts must
belong to the user — which exceeds the spec.)

## Item 1 — map-first value-level union (PLAN-STAGE, not a code row)

Per the PD-1 directive (value-level union inside the map-first `mergeContacts`): **plan now,
implement after the merge-repoint commit.** Recorded here as **PLAN-STAGE**. Not audited as a
code-conformance row. See the reconciliation flag above — the merge-repoint code appears
already in `HEAD`, which (per your rule) would unblock Item 1 implementation.

---

## Revision task list (failures only — NO fixes applied here)

- **R-5A-1 (FAIL):** Align `cdNormalizeName` with the create-time `normalizeName`, or record an
  approved divergence. They differ on punctuation stripping — `cdNormalizeName` strips
  `[^a-z0-9 ]`, `normalizeName` does not. Decide the single canonical normalizer.
- **R-5A-2 (PARTIAL):** Add a per-pair **match-reason** label (not just `match_score`).
- **R-5A-3 (PROOF-OWED):** Runtime proof on the reporting user: exactly the 5 false pairs drop;
  Krystal O'Conner/OConnor kept; Rodriguez triplicate pairs kept. Name the 2 false pairs not
  in code comments.
- **R-4-1 (FAIL):** `SELauditionReps` → UNION tag-derived reps **with** reps on the user's
  auditions (restore in-use half without losing the all-tagged behavior).
- **R-4-2 (FAIL):** `SELauditionSources` → UNION `audsubmitsites_user` **with** distinct in-use
  audition sources.
- **R-4-3 (VERIFY):** Confirm the audition filter's rep semantics use the same tag set.
- **R-5A/email (DECIDE):** Confirm whether an email match dimension is expected (→ WO-PHONEBOOK-A);
  if added, the name-gate must not apply to email pairs.

**STOP.** Bundle is evidence + revision list only. No code changed. Revisions gated behind the
merge-repoint commit reconciliation and your go-ahead.
