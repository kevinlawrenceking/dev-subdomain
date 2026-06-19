# SERVER_ACTIONS.md

Operational / hosting tasks that **cannot** be fixed in application code. Created
2026-06-18 alongside the production error-log remediation patch. Each item lists
the symptom from the log, the recommended action, and who/where to do it.

---

## 1. Disable / lock down ColdFusion REST (scanner noise)

**Symptoms (log):** repeated
`Application .env could not be found`,
`Application users could not be found`,
`Application login could not be found`,
`Application settings could not be found`,
`Application workflows could not be found`,
`Application executions could not be found`,
`Application credentials-for-node could not be found`,
`Application V1 could not be found`.

**Diagnosis:** These are NOT TAO routes. The wording ("Application X could not be
found") is emitted by the ColdFusion **REST servlet** (`/rest/*` /
`CFRestServlet`) when an external scanner probes generic API paths (the set
above is a classic n8n / generic-API fingerprint scan). TAO does not expose any
CF REST services — all real endpoints are `.cfm` pages under `/app`, `/ajax`,
`/setup`.

**Do NOT** create applications named `.env`, `users`, `login`, etc. to silence
these — that would invent fake routes and could mask real problems.

**Action (ColdFusion Administrator, prod + dev hosts):**
1. CF Admin → **Data & Services → REST Services**: confirm no services are
   registered. If none, the feature is unused.
2. If unused, disable the REST servlet mapping so probes get a plain 404 instead
   of a logged CF error:
   - Remove/comment the `CFRestServlet` servlet-mapping (`/rest/*`) in
     `<cf_home>/cfusion/wwwroot/WEB-INF/web.xml` (Adobe CF) or the equivalent in
     the connector config, then restart CF.
   - Alternatively, block `/rest/*` at IIS (URL Rewrite → 404) if CF REST must
     stay enabled for another site on the box.
3. The narrow **dotfile** probes (`.env`) are already handled in code: see the
   `block sensitive dotfiles` rewrite rule added to `web.config`
   (returns 404 for `.env`, `.git`, `.aws`, `.ssh`, etc.). That rule is
   intentionally scoped to dotfile names so it cannot collide with real routes.

**Acceptance:** scanner paths return a clean 404 with no `Application X could not
be found` entries; real `/app`, `/ajax`, `/setup` routes unaffected.

---

## 2. Adobe ColdFusion licensing noise

**Symptoms (log):**
`The license POST request has failed. Status Code: 400 Reason: Bad Request`,
`Failed to contact the Adobe Licensing server: java.lang.NullPointerException`.

**Diagnosis:** ColdFusion server / Adobe activation subsystem — unrelated to TAO
application code. No code change can fix this.

**Action (server admin):**
1. Verify the CF license/activation state: CF Admin → **System Information** →
   confirm the edition and that it is licensed (not an expired trial).
2. Re-run activation if needed:
   `<cf_home>/cfusion/bin/cf-license` (or CF Admin → Licensing) and re-enter the
   serial.
3. Check **outbound connectivity** from the CF box to Adobe's licensing
   endpoint (HTTPS egress, corporate proxy, TLS interception). The 400 + NPE
   pattern is typical of a proxy/TLS handshake mangling the POST.
4. Review CF licensing logs: `<cf_home>/cfusion/logs/license.log` and
   `coldfusion-out.log`.
5. If the box is intentionally offline, confirm the license is perpetual so the
   failed phone-home is cosmetic, and consider lowering the licensing log level
   to stop the noise.

**Acceptance:** licensing errors stop, or are confirmed cosmetic on a validly
licensed server.

---

## 3. ColdFusion Scheduled Task config for `sched/events_completed.cfm`

The code fix (batching + anti-overlap lock + compact summary) is in this patch.
Confirm the scheduler side:

1. CF Admin → **Scheduled Tasks** → the events_completed task (~00:13 nightly).
2. Set the task URL to use a bounded batch while the ~952-event backlog drains,
   then watch the `events_completed` log (`elapsedSec`, `eventsProcessed`,
   `batchCapped`):
   - Drain: run `…/sched/events_completed.cfm?batchSize=200` repeatedly (manual
     or temporarily every few minutes) until `eventsFound` < `maxEvents`.
   - Steady state: nightly `…/sched/events_completed.cfm` (default
     `batchSize`/`maxEvents` = 300). Raise toward 1000–1500 only if `elapsedSec`
     stays comfortably under the 600s timeout.
3. Set the task's **Timeout** (request timeout) to ~600s to match the in-page
   `cfsetting requesttimeout="600"` guard.
4. The anti-overlap lock is now in code, so overlapping fires are safe (the
   second one logs `SKIPPED … overlap` and returns
   `{"status":"skipped"}`). No need to widen the schedule gap.

---

## 4. Apply the performance-index migration

`database/2026-06-18_sched_performance_indexes.sql` is **not** auto-run.
Apply deliberately, off-peak, connected to the correct schema:
- dev / `abod` → `new_development`
- prod / `abo` → `actorsbusinessoffice`

It is idempotent (re-runnable) and reversible via
`database/2026-06-18_sched_performance_indexes_rollback.sql`. Verify with
`SHOW INDEX` afterward (queries are in the migration header).

---

## 5. Cross-subdomain redeploys (bugs already fixed in `dev-subdomain`)

Several logged errors come from the OTHER document roots
(`app-subdomain_1.5\`, `new-subdomain\`). The corresponding files in THIS repo
(`dev-subdomain`) are already correct; the fix is to **promote this repo's
versions** to those roots (or merge the equivalent change). Do not edit the
prod copies by hand.

| Log error | File (prod/new root) | Status in dev-subdomain |
|---|---|---|
| `Element IMAGESURL is undefined in APPLICATION` | `new-subdomain\auth-recoverpw.cfm:121` | **Fixed** — dev `auth-recoverpw.cfm` no longer reads `application.imagesURL`; favicon is hardcoded `/media/shared/images/favicon.ico`. |
| `Struct cannot be used as an array` | `new-subdomain\app\dashboard\index.cfm:724` | **Not present** — dev `app/dashboard/index.cfm` is a 1-line redirect to `/app/dashboard_new`; no array/struct code. Verify the live dashboard (`dashboard_new`) before promoting. |
| `Invalid token " … cfquery attribute datasa` | `app-subdomain_1.5\sched\thrivecart_process_dev.cfm:24` | **Fixed** — dev line 24 is valid: `<cfquery result="result" name="U" datasource="abod">`. Corruption was encoded-quote rot in the prod copy. Redeploy this file. |
| `File not found /app/admin-users/ajax/diag-setup-test-login.cfm` | `dev-subdomain\app\admin-users\ajax\` | **No caller** — grep finds zero references in the repo; the page was replaced by `create-test-setup.cfm`. The 404s are from a stale cached page/bookmark. No file needed; clear any stale reference. |

**For `new-subdomain` specifically:** if that root must keep its own
`auth-recoverpw.cfm` that references `application.imagesURL`, the durable fix is
to define `application.imagesURL` in that root's `Application.cfc` startup (same
pattern as `app/Application.cfc` lines ~84–88), OR replace the reference with a
literal path. Either prevents the fatal.

---

## 6. Upload size — other forms (pattern to apply)

Server-side is now universal: `app/Application.cfc onError` catches
"Post Size exceeds the maximum limit" and returns a friendly 413 (JSON for
AJAX, HTML otherwise) for every endpoint. Client-side, `remoteaddHeadshot.cfm`
got a 20 MB pre-check in this patch.

To give the same pre-submit UX on the other upload forms
(`include/attachmentadd*.cfm`, `remoteaddMaterial2.cfm`, `remotaudmatadd*.cfm`,
the import wizards), reuse the snippet:

```js
var TAO_MAX_UPLOAD_BYTES = 20 * 1024 * 1024; // matches CF post limit
input.addEventListener('change', function () {
  var f = this.files && this.files[0];
  if (f && f.size > TAO_MAX_UPLOAD_BYTES) {
    alert('That file is too large. Maximum upload size is 20 MB.');
    this.value = '';
  }
});
```

Do **not** raise CF's 20 MB post limit globally. If a specific feature genuinely
needs larger files, propose a chunked-upload endpoint or an endpoint-scoped
limit rather than a server-wide change.
