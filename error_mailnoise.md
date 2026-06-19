# CC PROMPT: TAO-MAILNOISE-01 — Kill leftover debug cfmail leaks (upload + IPN)

## Context
Production CF mail log shows two recurring debug-email leaks. Both send on every
occurrence, both leak sensitive data, both must stop emailing. The diagnostic value
is preserved by converting to cflog (TAO standard: cflog for diagnostics, never email).

Evidence from mail log (do not need to reproduce):
- Subjects that are raw filesystem paths, e.g.
  `C:\home\theactorsoffice.com\media-abo\\users\\38\\avatar.jpg`
  `C:\home\theactorsoffice.com\media-abo\\users\\821\\contacts\154765\avatar.jpg`
  `C:\home\theactorsoffice.com\media-abod\\users\\30\\avatar.jpg`  (dev also firing)
- "IPN Cancelled Debug Data - <timestamp>" sent on every IPN cancellation.

## Target files (confirmed from 13-email-integrations.md audit)
1. include/image_upload2.cfm          — cfmail, subject = cookie.uploaddir
2. include/image_upload-contact2.cfm  — cfmail, subject = cookie.uploadDir_Contact
3. ipn-cancelled.cfm                  — debug cfmail with raw POST (potential payment data)

## PHASE 1 — RECON (read-only, then STOP)
Do NOT edit anything yet. Report back:

For each of the three files:
- Quote the exact cfmail block(s): from/to/subject/body, and any surrounding cftry/cfcatch.
- Confirm whether the cfmail is unconditional or gated by any flag/env check.
- For image_upload2.cfm / image_upload-contact2.cfm: confirm the subject source
  (cookie.uploaddir / cookie.uploadDir_Contact) and what the body dumps
  (cookie values, pgid, userid, paths).
- For ipn-cancelled.cfm: identify the "debug notification" cfmail vs the legitimate
  "error notification" cfmail. We are ONLY removing the debug-data send, NOT the
  error-on-failure send. Quote both so the distinction is explicit. Also confirm the
  existing cflog targets (audit notes `ipn_cancelled_debug` and `ipn_errors` logs exist).
- Note any cfdump/cfabort in these files.

Then STOP for approval. Do not proceed to Phase 2.

## PHASE 2 — PLAN (propose diffs, then STOP)
Propose, as concrete before/after diffs, the following — adjust to what recon actually finds:

image_upload2.cfm & image_upload-contact2.cfm:
- Remove the diagnostic cfmail entirely.
- Replace with a single cflog capturing the same diagnostic fields (userid, pgid,
  upload dir/path) to an application log file (reuse an existing TAO log name if one
  is already used in these files; otherwise log to "image_upload"). type="information".
- Do not change upload behavior, file handling, or any DB write. cfmail removal only.

ipn-cancelled.cfm:
- Remove the debug-data cfmail (the one titled "IPN Cancelled Debug Data").
- Preserve the existing cflog to `ipn_cancelled_debug` for the audit trail.
- Keep the error-notification cfmail (the one that fires inside the catch/fallback path)
  intact — that one is legitimate operational alerting.
- If the retained log/email anywhere echoes the raw POST body, redact obvious
  payment/PII fields (card, token, account, email) before logging — do not log the
  raw request struct verbatim. // SECURITY annotation required here.

For all three: add a `// MIGRATE:` note that the long-term fix is EmailService.cfc
centralization, and a `// TECH-DEBT:` note where a diagnostic was downgraded to cflog.

State rollback: each change is a localized block removal/replacement; rollback = git revert
of this commit. No DB or schema changes, no migration needed.

Then STOP for approval. Do not implement until approved.

## PHASE 3 — IMPLEMENT (only after Phase 2 approval)
- Apply the approved diffs only. Scoped edits, no opportunistic refactors.
- Do NOT touch the other cfmail templates in /include or /sched.
- Do NOT centralize into EmailService.cfc in this pass (that is a separate work order).

## PROOF BUNDLE (required)
- git diff for all three files.
- Grep proof that no `cfmail` referencing `cookie.uploaddir` / `cookie.uploadDir_Contact`
  remains, and that the "IPN Cancelled Debug Data" subject string no longer appears in
  any cfmail send.
- Grep proof the IPN error-notification cfmail is still present.
- The exact cflog lines that replaced each removed cfmail.
- Confirmation: no behavioral change to upload success path or IPN cancellation handling.

## HARD OUT OF SCOPE (do not touch)
- The 05/21 Application exception burst (ERR-01F5xxxx … ERR-08729C71) — needs error_tickets
  rows, separate investigation.
- ERR-254E23A6 commons-compress / ZipArchiveInputStream — environment/JAR remediation.
- application.IMAGESPATH undefined (ERR-69EAA576) and the [DEV] MissingInclude (ERR-CD65D0FC).
- EmailService.cfc centralization, output encoding, SMTP/SSL standardization.
- Any other cfmail/cfhttp file in the audit.
- test-ipn-cancelled.cfm / test-ipn-cli.cfm.

## STANDARDS
- No emojis anywhere. cfqueryparam on any SQL you happen to touch (you should touch none).
- cflog for diagnostics, not writeOutput/cfmail. Explicit scoping.
- Recon before write. If the IPN debug-vs-error cfmail distinction is not provable from
  the code, STOP and report — do not guess which send to remove.