# TAO-EXLOG-01 Item 8 - Rename mistyped Thrivecart scheduled task (CF Admin, manual)

Status: manual CF Admin change. No repo code references the typo, so there is no code edit for this item.

## Symptom

Exception log: `File not found:` (1x) for `thrivecart_proces.cfm`.

## Root cause

The ColdFusion Administrator scheduled-task URL has a typo: `thrivecart_proces.cfm` (single "s").
The correct, existing file in the repo is `sched/thrivecart_process.cfm`.

## Old URL

```
https://app.theactorsoffice.com/sched/thrivecart_proces.cfm
```

## New URL

```
https://app.theactorsoffice.com/sched/thrivecart_process.cfm
```

Use the production hostname `app.theactorsoffice.com`. Never use `127.0.0.1` or a raw IP:
an IP URL flips `Application.cfc` into the DEV branch and 500s on prod.

## Click path

1. Open ColdFusion Administrator and log in.
2. Left nav: Server Settings -> Scheduled Tasks.
3. Locate the task whose URL contains `thrivecart` (it ends in `thrivecart_proces.cfm`).
4. Click the Edit (pencil) icon for that task.
5. In the URL field, change `thrivecart_proces.cfm` to `thrivecart_process.cfm`.
6. Click Submit.

## Verify immediately

On the Scheduled Tasks list, click Run Now for that task. Expected: status returns OK,
no "File not found".

## Confirm success

1. Scheduled Tasks list shows an updated Last Run timestamp with no error.
2. The Next Run timestamp is populated.
3. `TAO_sched_errors` shows no new `File not found: ...thrivecart_proces.cfm`.
4. Downstream side effects of `thrivecart_process.cfm` (it cfincludes
   `thrivecart_process_audition.cfm` at line 129) fire as expected on the next real run.

## Rollback

Revert the URL field back to `thrivecart_proces.cfm` and Submit. No code rollback (CF Admin only).
