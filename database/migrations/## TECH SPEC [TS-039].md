## TECH SPEC [TS-039]
Work Order: WO-039
Notion Key: LSW-001-C
Date: 2026-03-31
Technical Spec Lead: Claude

---

### Restatement

The Go scheduler CLI (`cmd/scheduler/main.go` in `legacy/streamwatch-api-legacy`) is the last job-creation path in StreamWatch that doesn't feed jobs into the SQS→worker pipeline. It has three bugs: it writes an invalid `source` column value (`'scheduler'` instead of `'url'`), it leaves `source_url` unpopulated (so the worker would have no video to process), and it does not enqueue an SQS message after INSERT (so the worker never knows the job exists). This WO fixes all three, adds SQS enqueue with graceful degradation when `SQS_QUEUE_URL` is unset, and closes the entire podcast/scheduling pipeline end-to-end.

---

### KB Sources Consulted

- **`21_STREAMWATCH_CLAUDE.md`** — Section 19.7 documents the three gaps verbatim. Section 19.5 confirms `jobs.source = 'url'` maps to Go constant `JobSourceURL`. Section 19.4 documents the graceful degradation pattern from the Python RSS poller.
- **`22_STREAMWATCH_WORKER_CONTRACT.md`** — Section 1 defines the canonical SQS message format: required fields `job_id`, `source_path`, `callback_url`; optional fields `transcription_engine`, `segment_duration`, `title`, `description`, `is_live`, `capture_seconds`.
- **`11_INTEGRATION_MAP.md`** — Section 2 confirms `internal/worker/sqs_enqueue.go` is the Go-side enqueue source. Notes the Go scheduler INSERT-only gap as deferred to LSW-001-C.
- **`09_SERVICE_CATALOG.tsv`** — Confirms `streamwatch-api` entrypoint `cmd/api/main.go`, Go 1.23, gorilla/mux, SQS via `sqs_enqueue.go`. Lambda env vars include `SQS_QUEUE_URL` and `ECS_CALLBACK_URL`.
- **`21_STREAMWATCH_CLAUDE.md`** — Section 6 (Infrastructure Facts): Lambda env vars `SQS_QUEUE_URL`, `ECS_CALLBACK_URL` confirmed. API Gateway endpoint: `https://u0o3w9ciwh.execute-api.us-east-1.amazonaws.com`.
- **`AUTH-009-B-caller-contract.md`** — Not directly relevant (this is Go→SQS, not Python→Go HTTP), but confirms the `ECS_CALLBACK_URL` value used in SQS messages is `https://u0o3w9ciwh.execute-api.us-east-1.amazonaws.com/internal/events`.

**KB GAP:** The KB does not document the internal structure of `cmd/scheduler/main.go` — specifically how it currently constructs job rows, what CLI arguments or flags it accepts, where the video URL originates, or whether it already imports the `internal/worker` package. **Claude Code must discover this in Phase A.** This is a read-only discovery, not a blocking question for Kevin.

**KB GAP:** The KB does not document the exact function signature of the enqueue function in `internal/worker/sqs_enqueue.go` (name, parameters, return type). The WO refers to `EnqueueJob()` — CC must confirm the actual exported name and adapt accordingly in Phase A.

---

### Scope

**IN SCOPE:**
- `legacy/streamwatch-api-legacy/cmd/scheduler/main.go` — all three fixes
- `legacy/streamwatch-api-legacy/internal/worker/sqs_enqueue.go` — consumed (read, not modified)
- New import of `internal/worker` package from `cmd/scheduler/` (if not already present)

**OUT OF SCOPE:**
- `rss_poll_youtube.py` / any Python code (WO-034 complete)
- Podcast REST API handlers (WO-033 complete)
- Exemplar/TypeControl files (WO-035 in-flight, disjoint files)
- Any schema migrations or DB DDL
- Any ECS task definition or Lambda env var changes (env vars `SQS_QUEUE_URL` and `ECS_CALLBACK_URL` already exist on the Lambda)
- Any changes to `internal/worker/sqs_enqueue.go` itself

---

### Implementation Design

This is a single-phase implementation (no phased gating needed — all three fixes are in one file and the design decisions are fully constrained by the worker contract). CC should do a brief read pass before editing.

**Step 0 — Discovery Read (read-only)**

CC reads `cmd/scheduler/main.go` end-to-end and `internal/worker/sqs_enqueue.go` to answer:
1. How does the scheduler currently build a job struct/row? What fields does it populate?
2. Where does the video URL come from (CLI arg, flag, env var, hardcoded)?
3. What is the exact exported function name and signature in `sqs_enqueue.go`?
4. Does the scheduler already import `internal/worker`?
5. Does the scheduler already have an AWS session/SQS client, or does `sqs_enqueue.go` handle its own client creation?

CC reports these five answers before proceeding to edits. **STOP GATE: If the scheduler does not accept a URL as input (i.e., there's no obvious source for `source_url`), escalate to Kevin.**

**Step 1 — Fix `source` value**

Change the `source` field assignment from the literal `"scheduler"` to the `JobSourceURL` constant (or `"url"` literal if no constant is in scope). Rationale: `ValidateJobSource()` only accepts `"upload"` and `"url"`. The scheduler creates URL-based jobs, so `"url"` is semantically correct and matches Section 19.5 of the CLAUDE doc.

**Step 2 — Populate `source_url`**

Set `source_url` on the job row to whatever URL the scheduler is using as the video source (discovered in Step 0). This is the value the SQS message will carry as `source_path`. Rationale: the worker needs `source_path` to know what to download/process; without it, the job is useless even if enqueued.

**Step 3 — Add SQS enqueue after INSERT**

After the successful INSERT (and within the same success path / after transaction commit), call the enqueue function from `internal/worker/sqs_enqueue.go`. The SQS message must conform to Section 1 of `22_STREAMWATCH_WORKER_CONTRACT.md`:

```json
{
  "job_id":     "<the ULID just inserted>",
  "source_path": "<the source_url value from Step 2>",
  "callback_url": "<from ECS_CALLBACK_URL env var>"
}
```

Only the three required fields are mandatory. Optional fields (`title`, `description`, `is_live`, `capture_seconds`, `transcription_engine`, `segment_duration`) should be populated if the scheduler has them available; omit if not.

Rationale for reusing `sqs_enqueue.go`: the WO explicitly requires using the existing pattern, and the integration map confirms this is the canonical Go-side enqueue path.

**Step 4 — Graceful degradation**

Before calling enqueue, check `os.Getenv("SQS_QUEUE_URL")`. If empty:
- Log a warning (using whatever logger the scheduler already uses — likely `log.Printf` or `zerolog`)
- Skip the enqueue call
- Do NOT fail the job creation — the INSERT should still succeed

This matches the `rss_poll_youtube.py` pattern from WO-034. Rationale: the scheduler may run locally or in contexts without SQS access; hard-failing would break backward compatibility.

**Step 5 — Build verification**

Run `go build ./...` from the repo root to confirm no compilation errors. This is the minimum bar — there are no existing scheduler-specific tests in the KB.

---

### Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| `sqs_enqueue.go` function signature doesn't match expected pattern (e.g., requires a context, DB handle, or SQS client that the scheduler doesn't have) | MEDIUM | Scheduler can't call enqueue without refactoring | Phase A discovery catches this. If signature requires objects the scheduler can't easily construct, escalate to Kevin for scoping decision (may need a lightweight wrapper). |
| Scheduler doesn't accept a URL as input — `source_url` has no obvious source | LOW | Can't populate `source_url` without a design decision | STOP GATE in Step 0. Kevin decides whether to add a CLI flag or derive the URL from another field. |
| `ECS_CALLBACK_URL` not available to the scheduler at runtime (e.g., scheduler is run outside the Lambda env) | MEDIUM | SQS message would have empty `callback_url`, causing worker to fail callbacks | Apply same graceful-degradation pattern: if `ECS_CALLBACK_URL` is unset, log warning and skip enqueue (no point enqueuing without a valid callback URL). |
| SQS enqueue succeeds but job INSERT was in a transaction that rolls back | LOW | Orphaned SQS message for a job that doesn't exist in DB. Worker would fail on first callback. | Worker idempotency (`.done` marker) handles this at the consumer side. Additionally, the scheduler's INSERT path appears to be a simple exec, not a complex transaction — CC should verify in discovery. |
| Merge conflict with WO-035 (exemplar work) | VERY LOW | Git conflict | WO-035 touches exemplar schema/routes, this WO touches only `cmd/scheduler/main.go`. No file overlap confirmed in WO text and verified by scope analysis. |

---

### Rollback Plan

1. `git revert <commit-hash>` on the single commit to `cmd/scheduler/main.go`.
2. Redeploy. The scheduler reverts to INSERT-only behavior (jobs sit in DB without SQS enqueue) — this is the current known-broken state, not a regression.
3. No infrastructure rollback needed (no env vars, task defs, or schemas changed).

---

### KB Delta Forecast

**Files that WILL need updating after this work:**

- **`21_STREAMWATCH_CLAUDE.md`** — Section 19.7 (Go Scheduler Gaps): mark all three gaps as RESOLVED with commit hash and WO-039 reference. Add a new subsection (e.g., 19.8 or append to 19.7) documenting the fix: source value, source_url population, SQS enqueue with graceful degradation.
- **`22_STREAMWATCH_WORKER_CONTRACT.md`** — Section 1: update the note that says the Go scheduler CLI "does NOT enqueue" → change to "enqueues as of WO-039 (LSW-001-C)". Update the "Additional enqueue source" paragraph.
- **`11_INTEGRATION_MAP.md`** — Section 2 (Message Queues): remove or update the note "The Go scheduler CLI (`cmd/scheduler/main.go`) still does INSERT-only with no SQS enqueue (deferred to LSW-001-C)" → mark resolved.

**Files that will NOT need updating:**

- `09_SERVICE_CATALOG.tsv` — no new services, routes, or auth changes
- `04_AUTHN_AUTHZ.md` — no auth changes
- `24_STREAMWATCH_TYPECONTROL.md` — disjoint (exemplar subsystem)
- `03_API_STANDARDS.md` — no API surface changes
- `AUTH-009-B-caller-contract.md` — no Python callback changes

---

### Acceptance Criteria

- [ ] `source` column value is `'url'` (not `'scheduler'`) — verified by: `grep -rn "'scheduler'" cmd/scheduler/main.go` → expected: **zero matches**
- [ ] `source` uses `JobSourceURL` constant or `"url"` literal — verified by: `grep -n "source" cmd/scheduler/main.go` → expected: assignment to `"url"` or `JobSourceURL`
- [ ] `source_url` is populated on the job row before INSERT — verified by: `grep -n "source_url" cmd/scheduler/main.go` → expected: **at least one assignment hit**
- [ ] SQS enqueue fires after successful job INSERT — verified by: `grep -n "nqueue" cmd/scheduler/main.go` → expected: call to enqueue function from `internal/worker`
- [ ] Graceful degradation when `SQS_QUEUE_URL` is unset — verified by: `grep -n "SQS_QUEUE_URL" cmd/scheduler/main.go` → expected: env var check with conditional skip + warning log
- [ ] SQS message includes required fields (`job_id`, `source_path`, `callback_url`) — verified by: code review of message struct construction matching `22_STREAMWATCH_WORKER_CONTRACT.md` Section 1
- [ ] `ECS_CALLBACK_URL` absence handled gracefully — verified by: `grep -n "ECS_CALLBACK_URL" cmd/scheduler/main.go` → expected: env var read with empty-check
- [ ] Build compiles clean — verified by: `cd legacy/streamwatch-api-legacy && go build ./...` → expected: **exit 0, no errors**
- [ ] **Negative case:** No references to `'scheduler'` as a source value remain — verified by: `grep -rn "scheduler" cmd/scheduler/main.go | grep -i source` → expected: **zero matches**
- [ ] **Negative case:** No hardcoded SQS queue URL — verified by: `grep -n "sqs.us-east" cmd/scheduler/main.go` → expected: **zero matches** (must read from env var)

---

### Notes for Release Gatekeeper

1. **Phase A discovery is critical.** CC must read `cmd/scheduler/main.go` and `internal/worker/sqs_enqueue.go` before writing any code. The two KB gaps (scheduler structure and enqueue function signature) can only be resolved by reading the source. Have CC report back the five discovery questions from Step 0 before authorizing edits.

2. **STOP GATE:** If the scheduler doesn't currently accept a video URL as input (no flag, no arg, no env var), this WO cannot proceed as written. Escalate to Kevin for a design decision on how `source_url` should be supplied.

3. **`ECS_CALLBACK_URL` availability:** The Lambda env has this var, but the scheduler CLI may also be run locally. The spec requires graceful degradation for both `SQS_QUEUE_URL` and `ECS_CALLBACK_URL`. If either is missing, log a warning and skip enqueue — don't crash.

4. **Parallel safety confirmed:** WO-035 (exemplar, LSW-002-A) touches exemplar schema/routes. This WO touches only `cmd/scheduler/main.go`. No file overlap. Both can run concurrently.

5. **Proof bundle must include:** commit hash, grep outputs for all acceptance criteria, the enqueue code snippet showing graceful degradation, and clean `go build ./...` output. KB delta is a separate commit.

6. **Worker contract compliance:** The SQS message struct must match Section 1 of `22_STREAMWATCH_WORKER_CONTRACT.md` exactly. The three required fields are `job_id`, `source_path`, `callback_url`. CC should map: `source_url` (DB column) → `source_path` (SQS field). This naming asymmetry is documented in the KB and is intentional.