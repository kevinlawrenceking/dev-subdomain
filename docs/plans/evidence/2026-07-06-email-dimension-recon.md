# Email-Dimension Recon — Probe SQL + Hook-Point (Evidence-Only, pre-design)

**Binding:** TAO / `dev-subdomain` / branch `dev` · **Date:** 2026-07-06 · **Author:** CC
**Status:** EVIDENCE-ONLY. Ruling 5 (bounded recon). **No code. No design commitment.** This note
gathers (a) a read-only data-shape probe for Kevin/MCP execution and (b) the exact seam in
`findPossibleDuplicates` where an email dimension would attach *after* R-5A-1 lands. It commits to
nothing beyond those two facts.
**Method:** verified against the live production path in code (Operator Addendum: Evidence-First).
**Related:** parallel follow-up seeded by `2026-07-06-r5a1-shared-normalizer-design.md`
(carries the shared-office-email hazard note). Registers under the same post-runbook consolidation.

---

## Why this dimension exists (the gap, stated from code)

`ContactDuplicateService.findPossibleDuplicates` (`services/ContactDuplicateService.cfc:109-190`)
surfaces a pair **only** when it passes the *name-gate*:

1. **SQL candidate prefilter** (`:135`): `SOUNDEX(a.contactFullName) = SOUNDEX(b.contactFullName)`.
   Two contacts whose names do not share a SOUNDEX code **never enter the candidate set**.
2. **CFML similarity gate** (`:177`): `dist LTE threshold AND cdSurnameMatches(name_a, name_b)`.

Consequence: two contacts that are the same person but were entered under **different names**
(`Bob Smith` / `Robert Smith Mgmt`, a personal vs. an agency label on one working email, a
maiden/married split) are invisible to the dedupe report today — even when they **share an email
address**. Email is the strongest identity signal we hold and it is currently unused by the report
path. That is the dimension the follow-up would add.

---

## (a) Read-only probe SQL — data shape / priority signal

**Execution contract:** both statements are pure `SELECT` (no writes, no DDL, no temp tables).
Run under the read-only MCP path or a read replica. Columns are confirmed from live code
(`getContactItems` `:418-424`; `DuplicateMatcherService` `:204,:250-251`): emails are rows in
`contactitems` (view over `contactitems_tbl`) with `valueCategory='Email'`, `valuetext` the address,
`itemStatus='Active'`. Email normalization mirrors `DuplicateMatcherService.normalizeEmail`
(`:30-33`) = `LOWER(TRIM(...))`. Different-name test mirrors the whitespace-collapsed comparison the
SQL prefilter already uses (`:136-137`).

**Schema targeting:** run against **prod (`actorsbusinessoffice`)** for the true priority signal —
real users live only in prod. The dev fixture user (R-5A-3) can be probed the same way in
`new_development` for a controlled before/after when the follow-up is built.

```sql
-- P1: PRIORITY SIGNAL — per user, how many DIFFERENT-NAME contact pairs share an email.
--     These are pairs the current name-gated report cannot surface. Higher count = higher
--     value/urgency for the email dimension, and sizes the review-list impact per user.
SELECT cd_a.userid,
       COUNT(DISTINCT cd_a.contactid, cd_b.contactid) AS shared_email_diffname_pairs,
       SUM(CASE WHEN SOUNDEX(cd_a.contactFullName) = SOUNDEX(cd_b.contactFullName)
                THEN 0 ELSE 1 END)                    AS pairs_missed_by_name_gate
FROM   contactitems   ia
JOIN   contactdetails cd_a ON cd_a.contactid = ia.contactid
JOIN   contactitems   ib   ON ib.valueCategory = 'Email'
                          AND ib.itemStatus   = 'Active'
                          AND LOWER(TRIM(ib.valuetext)) = LOWER(TRIM(ia.valuetext))
JOIN   contactdetails cd_b ON cd_b.contactid = ib.contactid
                          AND cd_b.userid     = cd_a.userid
WHERE  ia.valueCategory = 'Email'
  AND  ia.itemStatus    = 'Active'
  AND  cd_a.isdeleted   = 0
  AND  cd_b.isdeleted   = 0
  AND  cd_b.contactid   > cd_a.contactid          -- ordered pair, no self/mirror dupes
  AND  TRIM(COALESCE(ia.valuetext,'')) <> ''
  AND  LOWER(REGEXP_REPLACE(TRIM(cd_a.contactFullName), '\\s+', ' '))
    <> LOWER(REGEXP_REPLACE(TRIM(cd_b.contactFullName), '\\s+', ' '))
GROUP BY cd_a.userid
ORDER BY shared_email_diffname_pairs DESC;
```

```sql
-- P2: DETAIL SAMPLE — the actual pairs, with the shared email and whether today's pipeline
--     would ever see them. Drives the match-reason UX copy ("Same email: x@y.com") and lets a
--     human eyeball false-positive risk (shared family / assistant / agency inbox).
SELECT cd_a.userid,
       cd_a.contactid       AS id_a, cd_a.contactFullName AS name_a,
       cd_b.contactid       AS id_b, cd_b.contactFullName AS name_b,
       LOWER(TRIM(ia.valuetext)) AS shared_email,
       CASE WHEN SOUNDEX(cd_a.contactFullName) = SOUNDEX(cd_b.contactFullName)
            THEN 'name-gate MIGHT catch'
            ELSE 'name-gate MISSES (soundex differs)' END AS current_pipeline
FROM   contactitems   ia
JOIN   contactdetails cd_a ON cd_a.contactid = ia.contactid
JOIN   contactitems   ib   ON ib.valueCategory = 'Email'
                          AND ib.itemStatus   = 'Active'
                          AND LOWER(TRIM(ib.valuetext)) = LOWER(TRIM(ia.valuetext))
JOIN   contactdetails cd_b ON cd_b.contactid = ib.contactid
                          AND cd_b.userid     = cd_a.userid
WHERE  ia.valueCategory = 'Email'
  AND  ia.itemStatus    = 'Active'
  AND  cd_a.isdeleted   = 0
  AND  cd_b.isdeleted   = 0
  AND  cd_b.contactid   > cd_a.contactid
  AND  TRIM(COALESCE(ia.valuetext,'')) <> ''
  AND  LOWER(REGEXP_REPLACE(TRIM(cd_a.contactFullName), '\\s+', ' '))
    <> LOWER(REGEXP_REPLACE(TRIM(cd_b.contactFullName), '\\s+', ' '))
ORDER BY cd_a.userid, shared_email, id_a, id_b
LIMIT 200;
```

**What the results decide (recon, not design):**
- `shared_email_diffname_pairs` ranked per user → the follow-up's priority and whether it is
  worth a review-list surface at all.
- `pairs_missed_by_name_gate` (P1) and the `current_pipeline` split (P2) → quantifies *net-new*
  matches the dimension adds versus what the name-gate already reaches. A high MISSES count is the
  core justification.
- P2 sample → the shared-inbox false-positive hazard (assistant / agency / family address on many
  distinct real people). This is the signal that sets the match-reason UX and any confidence tier.
  **Flagged, not solved here.**

---

## (b) Hook-point recon — where an email dimension attaches, post-R-5A-1

**Seam (verbatim location):** the candidate set for the report is built by the single
`qCandidates` query at `services/ContactDuplicateService.cfc:120-139`; every candidate then runs the
name-gate loop at `:160-187`. An email dimension is a **second candidate source** feeding the same
review list — structurally the same *union-of-sources* shape already accepted for R-4 (tagged union
on the auditions filter). Post R-5A-1 the surrounding normalizer consolidation is settled, so the
attach point is stable: email-matched candidates are collected alongside the SOUNDEX candidates and
merged before return at `:189`.

**BINDING RULE (carry verbatim into the follow-up WO — do not paraphrase, do not soften):**

> The name-gate must NOT apply to email-matched pairs. Two contacts that share a normalized email
> are a candidate pair **on the strength of the email alone**. The SOUNDEX SQL prefilter
> (`:135`), the edit-distance threshold, and `cdSurnameMatches` (`:177`) are the *name* dimension's
> gate; they must never be allowed to reject a pair that qualified on the *email* dimension. An
> email-matched pair bypasses the name-gate entirely and carries its own match reason
> ("Same email").

Rationale, from code: the whole point (see the P1/P2 `MISSES` counts) is the different-name pair.
Routing email matches through `:177` would re-impose the name-gate and delete exactly the pairs the
dimension exists to find — a self-cancelling design. The two dimensions are OR-ed sources into one
list, each with its own admission test and its own displayed reason; they are not chained filters.

**Open hazards flagged for the follow-up (recon only — NOT decided here):**
- Shared-inbox false positives (P2 hazard above) — needs a confidence tier / suppression story.
- Pair de-dup when a pair qualifies on *both* name and email — one row, merged/ranked reasons.
- Interaction with `getDismissedPairs`/`pairKey` (`:158,:161,:310`) so an email-matched pair honors
  the same 5B dismissal suppression. `pairKey` is dimension-agnostic today, so this looks free —
  **to be confirmed at design time, not assumed.**

---

## (c) STOP

Recon complete. No code written, no design committed. The probe SQL is for Kevin/MCP read-only
execution; the hook-point + binding rule are recorded for the future email-dimension follow-up WO,
which stays gated behind the DEV-PROOF-RUNBOOK acceptance and the R-5A-1 consolidation.

---

## PROBE RESULTS — prod execution addendum (2026-07-06)

Executed read-only against `actorsbusinessoffice` by Kevin. Full data:
`docs/plans/evidence/2026-07-06-email-probe-results-prod.txt`. Priority-setting only.

**Perf KB delta:** the probes above (normalize-then-self-join) did not return after 7 then 38 min
over 44,810 active email rows — O(N^2) function-wrapped self-join, no usable index, amplified by
shared-inbox groups (one email -> 343 rows). An aggregation-only rewrite (GROUP BY, function once
per row, no pairwise join) returned in seconds. **The dimension, if built, must pre-aggregate /
index — never normalize-then-self-join at this scale.**

**Finding — email-as-identity is WEAK in TAO's real data (priority: LOW):** "same email + different
name" is dominated by **shared agency/company switchboard inboxes** — `info@caa.com` (343 contacts /
342 names), `info@unitedtalent.com` (245/244), `info@gersh.com` (107/107), plus `contact@`,
`queries@`, `feedback@`, `mailbox@`, and company gmails. `n_names ~= n_contacts` = **different real
people**, not duplicates. The email dimension's unique contribution (different-name/same-email) is
therefore mostly noise on this corpus; the genuine dupe pattern is `n_names < n_contacts` (a name
repeats), which the **name dimension** already owns.

**Reshapes the follow-up (was: "add email dimension"; now: deprioritized, guardrailed):**
1. Generic-mailbox denylist (`info`, `contact`, `queries`, `feedback`, `mailbox`, `office`, `hello`,
   …) + non-email junk guard (`"linked in"` appeared 27x for user 818).
2. Group-size cap = 2 — an email on exactly two contacts is the only plausible dupe.
3. "Personal domain only" does NOT rescue it — production-company gmails appear at 50/21 contacts.
4. userid 11 = separate data-hygiene review (agency inboxes on hundreds of contacts), not dedup.

**Verdict:** email-dimension follow-up WO **DEPRIORITIZED**; name-dimension (R-5A) remains the
primary dedup investment. Decision reserved to Kevin. Supersedes this note's original neutral
framing of the email dimension's value.
