# R-5A-1 — Shared Normalizer: Design + KB Delta (Evidence-First, pre-implementation)

**Binding:** TAO / `dev-subdomain` / branch `dev` · **Date:** 2026-07-06 · **Author:** CC
**Status:** DESIGN ONLY. R-5A-1 implementation stays gated (touches `ContactDuplicateService.cfc`;
consolidated with Item-1, post DEV-PROOF-RUNBOOK acceptance). No code changed by this note.
**Method:** verified the actual production path in code (Operator Addendum: Evidence-First).

---

## Two normalizers today (verbatim)

**A. Dedupe report** — `services/ContactDuplicateService.cfc:199-205`, `private cdNormalizeName`,
punctuation-stripping. Call sites: `:162-163` (candidate names), `:215-216` (`cdNamesAreNearMatch`).
```
s = lcase(trim(name)); s = reReplace(s,'[^a-z0-9 ]','','ALL'); s = reReplace(s,'\s+',' ','ALL'); return trim(s)
```

**B. Create-time + importers** — `services/DuplicateMatcherService.cfc:51-57`, `public normalizeName`,
**no punctuation strip**.
```
result = trim(name); result = reReplace(result,'\s+',' ','ALL'); return lcase(result)
```

## KB DELTA (drift from the WO-DUPES-R1 plan — record before implementing)

The plan (`2026-07-06-wo-dupes-r1-plan.md`, R-5A-1) framed create-time adoption as a "one-line
follow-up." **Runtime path evidence contradicts the framing:**

`DuplicateMatcherService.normalizeName` is **not** create-time-only. It is the shared normalizer for
the entire scored-duplicate subsystem — 11 internal call sites (`buildUserDupeIndex`,
`findDuplicatesWithIndex`, `getCandidatesByName`, `findDuplicates`, `findDuplicatesBatch`:
`:517, :598-599, :609, :619, :849, :993, :1073-1074, :1084, :1094`) reached by:
- **create-time contact warning** — `ajax/contacts/check-duplicate.cfm:43` (`request.svc("DuplicateMatcherService")`)
- **V2 importer** — `services/ContactImportV2Service.cfc:13` (`new DuplicateMatcherService()`)
- **V3 importer diag** — `ajax/importv3/diag.cfm:99`

Therefore flipping `normalizeName` to punctuation-stripping is a **behavior change to the dominant
production dedupe path** (create-time + both importers), not a cosmetic one-liner. It broadens match
sensitivity (e.g. `O'Conner` ≡ `OConnor`) everywhere at once. **Scope correction:** the create-time
adoption is its own follow-up WO carrying a canary/proof, per the Diagnostic-First standard — not a
trivial edit folded into R-5A-1.

## Design (when the R-5A gate opens)

1. **Single shared home:** add `public normalizeNameStrict(name)` to `DuplicateMatcherService`
   (body = `cdNormalizeName`'s punctuation-stripping logic). One canonical strict normalizer both
   services can call.
2. **Dedupe adopts now (the R-5A-1 primary):** `ContactDuplicateService.cdNormalizeName` delegates to
   `DuplicateMatcherService.normalizeNameStrict` (or calls it directly at `:162-163,:215-216`).
   **Zero dedupe behavior change** — identical semantics; pure consolidation. (Still gated because it
   edits `ContactDuplicateService.cfc`.)
3. **Create-time + importer adoption = registered follow-up WO** (`WO-DUPES-R5A1-FOLLOWUP`): flip the
   `DuplicateMatcherService` consumers to `normalizeNameStrict` behind a canary that proves no silent
   change in dupe verdicts on a known corpus (existing callers unchanged until proven). Carries the
   shared-office-email hazard note for the parallel email-dimension follow-up.

## Acceptance (for the gated implementation)
- `cdNormalizeName` and `normalizeNameStrict` produce byte-identical output on a fixture set
  (incl. `O'Conner`/`OConnor`, `SJ Hodges`, `Brandon Henry Rodriguez`).
- Dedupe report output for the R-5A-3 fixture user is unchanged vs pre-consolidation (regression guard).
- Create-time/importer paths untouched until the follow-up WO's canary passes.
