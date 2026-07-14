# DIR-LNK-WO-3 — Reference Normalization Rules (P1a)

**Date:** 2026-07-14 · **Workstream:** DIR-LNK-WO-3 (backfill dry-run) · **Binding spec anchor:** §18 (Normalization).
**Binding:** project TAO master-linking (DIR-LNK) · repo `kevinlawrenceking/dev-subdomain` · branch `dev` · Plan Lock `docs/plans/DIR-LNK-WO3-PLANLOCK.md` (`b8ac4ac2`).

**CONFORMANCE TARGET DECLARATION (load-bearing):** These rules are the REFERENCE normalization
for the DIR-LNK program. The future CFML shared normalizer (later WO, spec §18 "centralized and
reused") MUST produce byte-identical output to these rules for every input. Any deviation found
between the CFML normalizer and this reference is a defect in the CFML normalizer, not a license
to re-derive the rules. The SQL expressions in
`2026-07-14-dir-lnk-wo3-classification-engine.sql` are the executable form of these rules.

Normalization is for COMPARISON and duplicate detection only — never for display. Original
values are never rewritten by normalization (spec §18).

---

## Column-name verification (Plan Lock P1 obligation)

Live `information_schema` on BOTH schemas (probe 2026-07-14, `kingk436@%`, MySQL 8.0.41):
`contactitems_tbl` is column-identical dev↔prod (21 columns). Corrections of record:

1. The timestamp columns are **`itemCreationDate`** and **`itemLastUpdated`** (both `timestamp`),
   NOT "itemCreatedDate/itemUpdatedDate" as written in the WO-3 primer SECTION 3. The D-19
   addendum already used the correct names; the primer's names were a paraphrase. All WO-3+
   documents must use `itemCreationDate` / `itemLastUpdated`.
2. `contactitems_tbl` has **no `itemcategory` column** on either schema (live 1054 error on
   probe). The category discriminator is **`valueCategory`** (varchar, NOT NULL) with literal
   values `'Phone'`, `'Email'`, `'Company'`. WO-1 recon §1.3's "Category IDs (`itemcategory`):
   Phone=1, Company=9, Email=10" does not describe a base-table column; the engine and all
   WO-4 SQL must filter on `valueCategory` only.
3. Value columns: Phone and Email live in **`valuetext`** (text); Company lives in
   **`valueCompany`** (varchar 255). `itemStatus` observed domain on dev: {`Active`,`Pending`}.
4. `co_locations.phone` / `co_locations.email` are **varchar(500)** (prod verified) — matches
   the V3_12 header's value-column-width rationale.

---

## Candidate predicate (applies before any normalization)

A contactitems row is a **candidate** for field F iff ALL of:

- `ci.IsDeleted = 0`
- `ci.itemStatus = 'Active'`  (excludes `Pending`)
- `ci.valueCategory = F`  (`'Phone'` | `'Email'` | `'Company'`)
- owning contact is active: `d.IsDeleted = 0` (join `contactdetails_tbl d ON d.contactID = ci.contactID`)
- the raw value is non-empty under the canonical count predicate (Plan Lock e):
  value `IS NOT NULL AND TRIM(value) <> ''`
- the NORMALIZED value is non-empty (engine addition, below)

Deviation from R-A1 disclosed: the R-A1 bucket SQL (WO-1 amendment) had no non-empty-value
condition. The engine adds it per the canonical predicate; any count drift vs the WO-1 numbers
is reconciled in the P3a section of the dry-run bundle.

**Normalized-empty rule:** a raw-non-empty value whose normalized form is empty (e.g. a phone
of `"n/a"` → no digits) cannot populate a primary column and is NOT a candidate. Contacts whose
only items are normalized-empty classify as `none_usable` (no action; reported, per spec §6.3
"No active items → leave the primary field unchanged"). These are counted separately so they
are visible, never silently dropped.

---

## N-P — Phone

Input: `valuetext`. Output: a digit string.

- **N-P1 (digits-only):** remove every character that is not `0-9`. Formatting characters
  (`()`, `-`, `.`, spaces, `+`), letters (including extension markers `x`, `ext`, `#`), and any
  other text are removed; **digits belonging to an extension are retained in sequence**.
- **N-P2 (leading-1):** if the resulting digit string is exactly 11 digits and begins with `1`,
  drop the leading `1` (NANP country code). Rationale: NANP area codes cannot begin with 1, so
  no genuine 10-digit national number starts with 1.
- **N-P3 (extensions):** because extension digits are retained (N-P1), the same base number with
  DIFFERENT extensions produces DIFFERENT normalized values — distinct extensions are never
  treated as equivalent (spec §18 Phone). The same base+extension written differently
  (`x89` / `ext 89` / `#89`) collapses to the same value, which is the desired dedup.
- **N-P4 (empty):** if no digits remain, the value is normalized-empty (see candidate predicate).

Documented limitations (accepted for the dry run, re-measured before WO-4):
- L-P1: an 11-digit string starting with 1 that is actually a 10-digit base + 1-digit extension
  would be mis-stripped by N-P2. The dev incidence of explicit extension markers is measured in
  the dry-run bundle; treatment is conservative (comparison-only; no data is modified in WO-3).
- L-P2: non-NANP international numbers are compared digit-for-digit as entered; no country-code
  canonicalization beyond N-P2 is attempted.

## N-E — Email

Input: `valuetext`. Output: a trimmed, lower-cased string.

- **N-E1 (trim):** strip leading and trailing whitespace of any class (space, tab, CR, LF).
- **N-E2 (case):** lower-case the ENTIRE string. Domain case is insensitive by RFC; local-part
  case-insensitivity is the universal de-facto behavior. (The table collation
  `utf8mb4_unicode_ci` already compares case-insensitively; explicit LOWER makes the rule
  portable to the CFML normalizer and to any binary-collation context.)
- **N-E3 (no provider folding):** NO dot-stripping, NO plus-tag stripping, NO provider-specific
  rewriting (spec §18 Email: "Avoid unsafe provider-specific normalization"). `a.b+c@gmail.com`
  and `ab@gmail.com` remain distinct.

## N-C — Company

Input: `valueCompany`. Output: a whitespace-collapsed, trimmed, lower-cased string.

- **N-C1 (whitespace collapse):** replace every run of whitespace (any class) with one space.
- **N-C2 (trim):** strip leading/trailing spaces (after N-C1 this is single-space trimming).
- **N-C3 (case):** lower-case for comparison.
- **N-C4 (no fuzzy merge):** NO punctuation stripping, NO legal-suffix folding (Inc/LLC), NO
  similarity matching. Distinct strings stay distinct (spec §18 Company: "Do not merge distinct
  companies based on fuzzy name similarity alone"). Stable company IDs (`companies.coid`) are
  preferred where a master pointer exists, but backfill candidates are user free-text and are
  compared as text only.

---

## Executable SQL forms (MySQL 8.0.41; the engine file uses these verbatim)

```sql
-- N-P (phone), applied to valuetext v:
--   digits: REGEXP_REPLACE(v, '[^0-9]', '')
--   norm  : IF(digits REGEXP '^1[0-9]{10}$', SUBSTRING(digits, 2), digits)
-- N-E (email), applied to valuetext v:
--   norm  : LOWER(REGEXP_REPLACE(v, '^[[:space:]]+|[[:space:]]+$', ''))
-- N-C (company), applied to valueCompany v:
--   norm  : LOWER(TRIM(REGEXP_REPLACE(v, '[[:space:]]+', ' ')))
```

The CFML normalizer (later WO) must implement N-P, N-E, N-C exactly as specified above and be
conformance-tested against these SQL expressions over the live data before it is trusted by
any write path.
