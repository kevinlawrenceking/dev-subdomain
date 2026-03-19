Fast wins and defect containment: Footer fix, Link-add bug, Toast utility.

---

You are working in the TAO ColdFusion application. This prompt covers three small,
self-contained tasks that must be completed in order. Follow the phase gates exactly.

## SKILL ROUTING

Apply the following specialist disciplines per task:

| Task | Primary Skill | Secondary Skill |
|------|--------------|----------------|
| TAO-UX-01 (Footer) | /tao-frontend (CSS styling) | — |
| TAO-UX-02 (Link-add bug) | /cf-debug (CF runtime error) | /tao-frontend (graceful failure UX) |
| TAO-UX-03 (Toast utility) | /tao-frontend (JS utility) | /tao-admin (global layout integration) |

For each task, follow the inspection order and stop conditions defined by the
primary skill. Cross-reference the secondary skill's patterns where noted.

$ARGUMENTS

---

## PHASE 1 — DISCOVERY (NO EDITS)

Read the following files and report their current state. Do not edit anything.

### 1. Footer (apply /tao-frontend CSS debugging rules)
- Find the `.footer` rules in the CSS layer
- Identify where it is defined (likely app.min.css or an override file)
- Report the current `left` value and any media query overrides
- Check CSS specificity chain: which selectors compete for `.footer left`?
- Identify the correct non-minified CSS override file (do NOT plan to edit app.min.css)

### 2. Link-add (apply /cf-debug mandatory inspection order)
- Read `/include/remotelinkadd2.cfm` and `/include/customicon_single.cfm`
- Trace the full cfinclude chain from the entry page
- Report:
  - How the link-add flow works end to end
  - Where customicon_single.cfm is included
  - Whether any cftry/cfcatch wraps the icon include
  - Whether `id`, `application.retinaIcons14Path`,
    `application.secrets.iconHorseApiKey`, and `linkDetails` are
    guarded before use
  - What happens to the user if icon generation fails
  - Failure layer isolation: UI > ColdFusion > SQL > Schema > External dependency

### 3. Toast (apply /tao-frontend JavaScript patterns + /tao-admin AJAX endpoint standards)
- Search the codebase for existing toast/alert/notification patterns
- Report:
  - How many distinct approaches exist (Bootstrap alerts, custom JS, inline HTML, etc.)
  - Whether a shared toast utility already exists
  - Where Bootstrap 5 JS is loaded (we will use its toast component)
  - What the global layout/template include structure looks like

Report all findings. Stop and wait for approval before Phase 2.

---

## PHASE 2 — PLAN (NO EDITS — REQUIRES APPROVAL)

Based on discovery, produce an implementation plan for all three tasks.

### TASK A — TAO-UX-01: Footer Alignment Override
*Skill: /tao-frontend — CSS specificity and override rules*

Plan:
- Add `.footer { left: 280px; }` in the identified override CSS file
  (NOT app.min.css)
- Verify specificity wins over minified rule
- Confirm condensed sidebar and mobile (<768px) media queries still override

### TASK B — TAO-UX-02: Link-Add Graceful Failure + Logging
*Skill: /cf-debug — failure layer isolation, defensive guards*

Plan:
- In remotelinkadd2.cfm: wrap the customicon_single.cfm include in cftry/cfcatch
- In customicon_single.cfm, add these guards:
  - cfparam name="id" default="0"
  - val(id) GT 0 guard
  - isDefined/len guard on application.retinaIcons14Path
  - isDefined/len guard on application.secrets.iconHorseApiKey
  - structKeyExists guard on linkDetails before using siteurl
- On icon fetch failure: log detail, return success for link creation anyway
- No white-screen / error-page path from remotelinkadd2.cfm

### TASK C — TAO-UX-03: Shared Toast Utility
*Skill: /tao-frontend — JavaScript patterns, event delegation, DOM manipulation*
*Secondary: /tao-admin — global layout integration*

Plan:
- Create /app/assets/js/tao-toast.js
- Expose: window.taoToast = function(message, type, options) { ... }
- Supported types: success, error, warning, info
- Use Bootstrap 5 toast markup and behavior, wrapped in the TAO helper
- Auto-dismiss supported (configurable duration)
- Manual close supported
- z-index set safely above modals
- Include the script in the shared layout/template so it is available globally
- Follow /tao-frontend double-submit prevention and DOM state patterns

Present the plan. STOP. Wait for Kevin to approve before proceeding.

---

## PHASE 3 — IMPLEMENTATION (MINIMAL DIFF)

Implement all three tasks per the approved plan. Keep diffs minimal.

### TAO-UX-01: Footer
*Apply /tao-frontend CSS debugging rules*
- Add the override rule. Do not touch app.min.css.

### TAO-UX-02: Link-add
*Apply /cf-debug coding discipline + stop conditions*
- Add cftry/cfcatch in remotelinkadd2.cfm around the icon include
- Add defensive guards in customicon_single.cfm
- Ensure the link save always succeeds even if icon generation fails
- Add cflog or writeLog for the failure branch with enough detail to diagnose

### TAO-UX-03: Toast
*Apply /tao-frontend JavaScript patterns*
- Create tao-toast.js with the shared API
- Include it in the global layout
- Do NOT convert any existing alerts/toasts yet — that is a separate task

Commit each task as a separate commit with message format:
  TAO-UX-NN: [short description]

---

## PHASE 4 — PROOF BUNDLE

Produce the following proof for each task:

### TAO-UX-01 Proof:
- Show the CSS diff (override file only)
- Confirm .footer left value matches .content-page
- Confirm no regression: condensed sidebar state
- Confirm no regression: viewport < 768px

### TAO-UX-02 Proof:
- Show the diff for remotelinkadd2.cfm
- Show the diff for customicon_single.cfm
- Describe the test paths and expected outcomes:
  1. Normal URL — link created, icon fetched
  2. Malformed URL — link created, icon gracefully skipped
  3. Duplicate URL — handled per existing logic
  4. No API key present — link created, icon skipped, logged
  5. Icon service unavailable — link created, icon skipped, logged
  6. Authenticated session through real dashboard modal flow — no error page

### TAO-UX-03 Proof:
- Show the full tao-toast.js file
- Show the layout include diff
- Confirm callable from any page via window.taoToast()
- Confirm auto-dismiss works
- Confirm manual close works
- Confirm z-index renders above modals
- Confirm success/error/warning/info types render with distinct styling

List all commits with hashes.

---

## PHASE 5 — KB DELTA

KB DELTA: NO DELTA (TAO repo — outside TMZ-Watch KB scope)

If any TAO-internal documentation files exist (README, docs/, CHANGELOG),
update them to reflect:
- The new tao-toast.js utility and its API
- The link-add defensive fix
- The footer override approach

DONE_TOKEN
