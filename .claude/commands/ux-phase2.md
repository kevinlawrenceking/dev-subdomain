Surface polish and stability: Calendar CSS, Dashboard Packery cleanup.

---

You are working in the TAO ColdFusion application. This prompt covers two tasks:
calendar CSS polish and dashboard JS cleanup. Follow the phase gates exactly.

## SKILL ROUTING

Apply the following specialist disciplines per task:

| Task | Primary Skill | Secondary Skill |
|------|--------------|----------------|
| TAO-UX-04 (Calendar CSS) | /tao-frontend (CSS styling, responsive) | — |
| TAO-UX-05 (Dashboard Packery) | /tao-frontend (JS event binding, AJAX) | /tao-admin (AJAX save flow, error feedback) |

For each task, follow the inspection order and stop conditions defined by the
primary skill. Cross-reference the secondary skill's patterns where noted.

**Dependency:** TAO-UX-03 (toast utility) must be complete — UX-05 uses taoToast for save feedback.

$ARGUMENTS

---

## PHASE 1 — DISCOVERY (NO EDITS)

Read the following and report:

### 1. Calendar (apply /tao-frontend CSS debugging rules)
- Find and read calendar-overrides.css (or equivalent calendar CSS file)
- Identify which FullCalendar version is loaded
- Report current styles for:
  - day cell hover
  - today cell treatment
  - event pills (border-radius, color, hover)
  - header hierarchy
  - week/day view spacing
  - button hover/focus states
  - current-time indicator (day/week views)
  - selected day/date state
  - empty-cell click affordance (if any)
- Check CSS specificity: what competes with the override file?
- Check for dark-mode rules that could regress

### 2. Dashboard (apply /tao-frontend mandatory JS inspection order + /tao-admin AJAX standards)
- Read dashboard_new.cfm
- Read packeryInit.js (or equivalent Packery initialization file)
- Trace event bindings: what binds, when, to what elements?
- Report:
  - Is Packery initialized inline in dashboard_new.cfm AND in packeryInit.js? (suspected duplicate)
  - What event bindings exist for drag/drop?
  - How is order persistence (save) triggered? Is there any debounce?
  - Is there a failure callback on save?
  - Are there duplicate event bindings?
  - Is there a dynamic include with a filename variable? If so, is it validated?
  - What are the current values for: gap, column width, breakpoint, save delay?
  - What AJAX endpoint handles save? What response shape does it return?
- Confirm tao-toast.js is available in the dashboard template (from TAO-UX-03)

Report all findings. Stop and wait for approval.

---

## PHASE 2 — PLAN (NO EDITS — REQUIRES APPROVAL)

### TASK A — TAO-UX-04: Calendar CSS Polish
*Skill: /tao-frontend — CSS specificity, responsive breakpoints, hover states*

Plan:
- Work entirely in calendar-overrides.css (or identified override file)
- NO FullCalendar theme swap
- NO JS changes unless fixing a specific broken behavior
- CSS changes:
  - Slightly stronger day cell hover state
  - Sharper header hierarchy (font weight / size differentiation)
  - Better today cell treatment (subtle background + border)
  - Event pills: 4px border-radius, left accent border, improved hover
  - More spacing in week/day views
  - Improved button hover/focus states
  - Stronger empty-cell affordance for click-to-add (if applicable)
  - Clearer current-time indicator in day/week views
  - More visible selected day/date state
- Confirm no dark-mode regressions in plan

### TASK B — TAO-UX-05: Dashboard Packery Dedupe + Debounce + Save Feedback
*Skill: /tao-frontend — JS event delegation, double-submit prevention, DOM state*
*Secondary: /tao-admin — AJAX response handling, error feedback*

Plan:
- Remove duplicate inline Packery init from dashboard_new.cfm
- Keep packeryInit.js as single source of truth
- Centralize config constants (gap, column width, breakpoint, save delay) — define once
- Add debounce around order persistence
- Add in-flight tracking: if a save is already in progress, queue the latest
  order and persist only after the current save completes (latest-write-wins)
- Add taoToast() call on save failure (apply /tao-admin error feedback pattern)
- Review and remove any duplicate event bindings
- Validate dynamic include filename (if present) to prevent path traversal
- Scope lock: single init source, debounce, error feedback, include validation — DONE.
  Do NOT improve Packery behavior beyond this.

Present the plan. STOP. Wait for approval.

---

## PHASE 3 — IMPLEMENTATION (MINIMAL DIFF)

Implement per the approved plan.

### TAO-UX-04: Calendar
*Apply /tao-frontend CSS debugging rules*
- Edit calendar-overrides.css only
- CSS-only changes
- Test readability in month/week/day views

### TAO-UX-05: Dashboard
*Apply /tao-frontend JS patterns + /tao-admin AJAX standards*
- Remove inline Packery init from dashboard_new.cfm
- Consolidate into packeryInit.js
- Add debounce + latest-write-wins save logic
- Add taoToast error feedback on failed save
- Add include filename validation if dynamic include exists
- Verify drag/drop works identically after changes

Commit each task separately:
  TAO-UX-04: Calendar CSS polish
  TAO-UX-05: Dashboard Packery dedupe, debounce, save feedback

---

## PHASE 4 — PROOF BUNDLE

### TAO-UX-04 Proof:
- Show the calendar-overrides.css diff
- Confirm NO JS changes were made (unless a specific behavior fix was needed — explain)
- Confirm NO FullCalendar theme swap
- Confirm readability improved in month view
- Confirm readability improved in week view
- Confirm readability improved in day view
- Confirm no dark-mode regressions

### TAO-UX-05 Proof:
- Show the dashboard_new.cfm diff (inline init removed)
- Show the packeryInit.js diff (consolidated init, debounce, save feedback)
- Confirm Packery initializes exactly once
- Confirm drag/drop order persistence works
- Confirm debounce prevents rapid-fire saves
- Confirm latest-write-wins under rapid drag
- Confirm taoToast fires on save failure
- Confirm no path traversal on dynamic include (if applicable)
- Show that config constants are defined once

List all commits with hashes.

---

## PHASE 5 — KB DELTA

KB DELTA: NO DELTA (TAO repo — outside TMZ-Watch KB scope)

Update any TAO-internal docs (README, CHANGELOG) to reflect:
- Calendar override approach and file location
- Dashboard JS consolidation and the taoToast dependency

DONE_TOKEN
