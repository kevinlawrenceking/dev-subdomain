# Deploy Notes - 2026-06-22 User-Facing Error Management Flow

Extends TAO-SPEC-2026-005 (ErrorService). No second ticket system, capture path, or
admin-email sender was introduced.

## What changes for end users (READ THIS)

After this release, **user-facing emails begin sending that did not send before**:

1. **Initial "we're on it" email** - sent automatically to the affected user the first
   time the error handler creates a ticket for them, subject "We received your support
   request -- ERR-xxxxxxxx". Throttled to once per ticket and once per user per 30
   minutes. Anonymous (logged-out) errors send nothing.

2. **Completion / resolution email** - already wired in the admin ticket detail page
   ("Send Resolution Email to User"), now the single logged sender. The old, broken
   `ticketcomplete.cfm` mail path (which never fired due to an `email_user`/`emailUser`
   parameter mismatch) has been removed, so there is exactly one completion sender.

3. **3-day follow-up email** - sent 3+ days after a resolution email actually went out.

**Admin confirmation language:** "Completion and 3-day follow-up emails now reach end
users. Only tickets resolved AFTER this deploy are affected -- a ticket is eligible for
follow-up only once it has a `resolvedEmailSentAt` timestamp, which is set the first time
the resolution email is sent post-deploy."

## Historical backlog is a non-goal (no backfill)

Existing `Completed` tickets have `resolvedEmailSentAt = NULL`, so neither the completion
resender nor the follow-up job will touch them. Proof query (also in
`verify-followup-migration.cfm`):

```sql
SELECT
  SUM(ticketStatus = 'Completed') AS completed_total,
  SUM(ticketStatus = 'Completed' AND resolvedEmailSentAt IS NULL)     AS excluded_from_followup,
  SUM(ticketStatus = 'Completed' AND resolvedEmailSentAt IS NOT NULL) AS eligible
FROM tickets_tbl WHERE IsDeleted = 0;
```
Expect `eligible = 0` immediately after deploy. No retroactive sends.

## Non-prod safety

All three user emails route through a non-prod recipient redirect: on any host other than
`app` (prod), the recipient is forced to `kevinking7135@gmail.com`. No real user is emailed
from dev/UAT.

## Run order (per environment: dev first, then prod)

1. `/database/run-followup-migration.cfm?run=yes` - adds `tickets_tbl.followupEmailSentAt`
   and rebuilds the `tickets` view (29 columns). Idempotent; re-running no-ops.
2. `/database/verify-followup-migration.cfm` - confirms the column in both base table and
   view; reports `ticketslog_tbl` timestamp column + `tickets_tbl.IsDeleted` default; runs
   the backlog non-goal proof.
3. Schedule `/sched/ticket_followup.cfm` (ColdFusion Administrator scheduled task, daily)
   under localhost so the existing `sched/Application.cfc` gate admits it. No public URL.

Rollback: `/database/run-followup-rollback.cfm?run=yes` (drops the column, rebuilds the
28-column view). Raw SQL equivalents in `2026-06-22_tickets_add_followup.sql` /
`..._ROLLBACK.sql`.

## Files changed

- `services/ErrorService.cfc` - persistTicket returns error_tickets.id; createSupportTicket
  writes to `tickets_tbl`, sets `errorid`, sends the initial user email (new
  `sendInitialUserEmail` + `nonProdRecipient`).
- `templates/email/user-initial.cfm` (new), `templates/email/user-followup.cfm` (new).
- `include/ticketcomplete.cfm` - removed the dead completion cfmail; status transition only.
- `ajax/admin-support/send-resolution-email.cfm` - added non-prod recipient redirect.
- `sched/ticket_followup.cfm` (new) - 3-day follow-up job.
- `database/migrations/2026-06-22_tickets_add_followup.sql` (+ ROLLBACK), runner/verify/
  rollback CF pages.
