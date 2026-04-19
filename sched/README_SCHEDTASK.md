# TAO scheduled task changes -- TAO-CAL-01

These tasks must be reconfigured in the ColdFusion Administrator after this
branch ships. The application will continue to run without these changes,
but ICS calendar files will drift if they are not completed.

Environments:
- Production: `https://app.theactorsoffice.com/sched/...`
- Dev:        `https://dev.theactorsoffice.com/sched/...`

## 1. DISABLE the legacy 10-minute ICS generator

**Current task name** (approximate): something that runs `sched/icsmaker.cfm`
every 10 minutes.

**Action:** set the task to **Paused / Disabled**. Do **not** delete yet --
leave it so a rollback can re-enable it. The `sched/icsmaker.cfm` file is
left on disk unwired for the same reason.

**Why:** `sched/icsmaker.cfm` contains SQL injection (unparameterized
`target_userid`), a hard `cfabort` on missing start dates, and a duplicate
of `include/icsmaker.cfm`. TAO-CAL-01 replaces it with event-driven
`EventService.fireIcsRegen()` hooks plus a nightly reconcile.

## 2. REGISTER the nightly reconcile task

Create a new scheduled task:

| Field      | Value                                                           |
|------------|-----------------------------------------------------------------|
| Task name  | `tao_ics_reconcile_nightly`                                     |
| Frequency  | Daily                                                           |
| Time       | 03:00 local (after `events_completed` and low-traffic window)   |
| URL (prod) | `https://app.theactorsoffice.com/sched/ics-reconcile-nightly.cfm` |
| URL (dev)  | `https://dev.theactorsoffice.com/sched/ics-reconcile-nightly.cfm` |
| Timeout    | 600 seconds                                                     |
| Save output| No                                                              |

**What it does:** iterates users with active events, writes an ICS file for
any user whose file is missing. Does **not** rewrite files that already
exist. Logs to `ics_service`.

This is a net, not the primary path. The event-driven hooks are primary.

## 3. Verification

1. Hit the reconcile URL manually with `?dbug=Y` -- you should see the
   summary panel. No crash = success.
2. Confirm the 10-minute task is Paused.
3. After 24h, check `ics_service` log for a `reconcile done` line around 03:00.

## Rollback

1. Re-enable the 10-minute legacy task.
2. Pause `tao_ics_reconcile_nightly`.
3. Revert this branch.

Legacy files kept in place for rollback: `include/icsmaker.cfm`,
`sched/icsmaker.cfm`.
