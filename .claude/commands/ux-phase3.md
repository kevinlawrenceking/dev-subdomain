Shared gallery pattern: Contacts gallery v1, v2, and Team gallery normalization.

---

You are working in the TAO ColdFusion application. This prompt covers three tasks
that build the shared gallery pattern for contacts and team views. These are
sequential — complete each fully before starting the next.

## SKILL ROUTING

Apply the following specialist disciplines per task:

| Task | Primary Skill | Secondary Skill | Tertiary Skill |
|------|--------------|----------------|----------------|
| TAO-UX-06 (Contacts gallery v1) | /tao-frontend (gallery UI, responsive grid) | /cf-expert (CF template, scope, includes) | /tao-relationship (relationship badges) |
| TAO-UX-07 (Contacts gallery v2) | /tao-frontend (pagination UI, URL state) | /cf-expert (CF template, tab state) | /tao-relationship (ribbon model) |
| TAO-UX-08 (Team gallery normalization) | /tao-frontend (visual normalization) | /cf-expert (shared card.cfm usage) | — |

For each task, follow the inspection order and stop conditions defined by the
primary skill. Cross-reference secondary/tertiary skill patterns where noted.

**Dependency:** All Phase 1 and Phase 2 tickets must be complete.

$ARGUMENTS

---

## PHASE 1 — DISCOVERY (NO EDITS)

Read the following and report:

### 1. Contacts (apply /cf-expert scope and include inspection)
- Find the current contacts list page (table view)
- Report: URL structure, tab system (All, Targeted, Follow-Up, Maintenance),
  current pagination approach, how tab state is preserved
- Report the current URL params used for contacts navigation
- Trace the include chain from the contacts page entry point

### 2. Card.cfm (apply /cf-expert variable scope verification)
- Read card.cfm
- Report:
  - Required variables (which scopes?)
  - Optional variables
  - Supported modes / flag combinations
  - Current complexity level (how many conditionals / modes)
  - Whether it can be reused for contacts or needs a wrapper
  - Any Application/session scope dependencies

### 3. Auditions Gallery (apply /tao-frontend toggle UI patterns)
- Find the Auditions page that already has a gallery/table toggle
- Report how the toggle works: URL param? JS state? Cookie?
- Report the toggle UI pattern (button group? tabs? icons?)
- Report the CSS/JS used for the toggle

### 4. Team Gallery (apply /tao-frontend card layout conventions)
- Find the current team gallery view
- Report:
  - Card structure (avatar, info rows, footer actions)
  - Fallback avatar behavior
  - Spacing/layout approach
  - How it differs from card.cfm conventions

### 5. TAO Relationship System (apply /tao-relationship system context)
- Report how Targeting, Follow-Up, and Maintenance systems surface
  on existing contact views
- Report what badge/ribbon/status indicators exist today
- Check fusystems, fusystemusers tables for system type data

Report all findings. Stop and wait for approval.

---

## PHASE 2 — PLAN (NO EDITS — REQUIRES APPROVAL)

### TASK A — TAO-UX-06: Contacts Gallery Foundation (v1)
*Skill: /tao-frontend (responsive grid, card conventions)*
*Secondary: /cf-expert (CF template, include chain, scope)*
*Tertiary: /tao-relationship (relationship badges)*

Plan:
- Add URL param: view=tbl|glry
- Add toggle UI matching the Auditions pattern
- Create contacts_gallery.cfm
- Render All Contacts tab only in gallery mode (phase 1 — other tabs in UX-07)
- Reuse card.cfm (or document why a thin wrapper is needed)
- Default page size: 24
- Card conventions:
  - Avatar first
  - Name prominent
  - Role/company second line
  - Email/phone in fixed order
  - Relationship badges/ribbons consistent (per /tao-relationship system types)
  - Footer: meaningful actions/socials only
- Toggle persists via URL param (no cookie, no JS state)
- Contact click-through goes to contact detail page
- No inline destructive actions on cards
- Responsive: cards align cleanly across breakpoints

### TASK B — TAO-UX-07: Contacts Gallery State, Pagination, Polish (v2)
*Skill: /tao-frontend (pagination UI, URL state management)*
*Secondary: /cf-expert (CF tab state, server-driven rendering)*
*Tertiary: /tao-relationship (ribbon model, system enrollment display)*

Plan:
- Support all 4 tabs in gallery mode: All, Targeted, Follow-Up, Maintenance
- Preserve tab + view + pagination in URL:
  - tab=all|targeted|followup|maintenance
  - view=tbl|glry
  - page=1
  - pageSize=24
- Integrate PaginationService (or existing pagination component)
- Add empty states per tab
- Loading/refresh consistency
- Ribbon model (informed by /tao-relationship system types):
  - One primary ribbon only: Targeting, Follow-Up, or Maintenance
  - Optional small badge: Overdue, Due Soon, Inactive
  - Never stack 3 loud ribbons on one card
- Keep state server-driven — do not invent a mini SPA

### TASK C — TAO-UX-08: Team Gallery Normalization
*Skill: /tao-frontend (visual normalization, responsive consistency)*
*Secondary: /cf-expert (shared card.cfm, scope compatibility)*

Plan:
- Apply the same visual conventions from Contacts gallery to Team cards
- Normalize:
  - Fallback avatar behavior (match Contacts)
  - Info row order (match Contacts)
  - Ribbon treatment (match Contacts)
  - Card spacing (match Contacts)
  - Footer density (match Contacts)
- Keep team-specific actions intact
- Shared card.cfm usage remains — do not fork

RISK NOTES:
- If card.cfm is too overloaded after UX-06, document required/optional vars
  and supported modes. If it feels awkward, plan a thin contacts_card_wrapper.cfm
  — not a full card.cfm rewrite.
- Contacts tabs + gallery state: use URL params deliberately. Server-driven.
  No client-side state management.

Present the plan. STOP. Wait for approval.

---

## PHASE 3 — IMPLEMENTATION (MINIMAL DIFF)

Implement in order: UX-06 first, then UX-07, then UX-08.

### TAO-UX-06: Contacts Gallery v1
*Apply /tao-frontend responsive grid + /cf-expert include discipline*
- Add view param handling
- Add toggle UI
- Create contacts_gallery.cfm with All Contacts tab
- Wire card.cfm (or wrapper) with standardized card conventions
- Page size 24, responsive grid

### TAO-UX-07: Contacts Gallery v2
*Apply /tao-frontend pagination + /cf-expert tab state + /tao-relationship ribbons*
- Expand to all 4 tabs
- Wire URL state: tab + view + page + pageSize
- Integrate pagination
- Add empty states
- Apply ribbon model (one primary, optional small badge)

### TAO-UX-08: Team Gallery Normalization
*Apply /tao-frontend visual normalization + /cf-expert shared component*
- Normalize team card visuals to match contacts gallery conventions
- Preserve team-specific functionality

Commit each task separately:
  TAO-UX-06: Contacts gallery foundation — All Contacts tab, toggle, card pattern
  TAO-UX-07: Contacts gallery v2 — all tabs, pagination, URL state, ribbons
  TAO-UX-08: Team gallery normalization — visual alignment with contacts pattern

---

## PHASE 4 — PROOF BUNDLE

### TAO-UX-06 Proof:
- Show contacts_gallery.cfm (or key sections)
- Show toggle UI diff
- Confirm view=tbl|glry param works and persists across refresh
- Confirm gallery renders for All Contacts tab
- Confirm cards follow conventions: avatar, name, role/company, email/phone, footer
- Confirm responsive: 4 cols desktop, 2 cols tablet, 1 col mobile (or approved breakpoints)
- Confirm contact click-through to detail page
- Confirm no inline destructive actions

### TAO-UX-07 Proof:
- Show diffs for tab expansion
- Confirm all 4 tabs render in gallery mode
- Confirm URL state preserved: tab + view + page + pageSize
- Confirm pagination works (page forward, page back, page size change)
- Confirm empty states render per tab
- Confirm ribbon model: one primary, optional badge, no triple-stack
- Confirm server-driven state (no SPA behavior)

### TAO-UX-08 Proof:
- Show team card diffs
- Confirm team cards visually match contacts card conventions
- Confirm fallback avatar, info row order, ribbon, spacing, footer density all match
- Confirm no loss of team-specific functionality
- Side-by-side comparison note: contacts card vs team card

### CARD.CFM DOCUMENTATION (required):
After all three tasks, output a brief reference:
- Required variables
- Optional variables
- Supported modes
- Any wrapper includes created

List all commits with hashes.

---

## PHASE 5 — KB DELTA

KB DELTA: NO DELTA (TAO repo — outside TMZ-Watch KB scope)

Update TAO-internal docs (README, CHANGELOG, or a new docs/gallery-pattern.md) with:
- Gallery toggle pattern and URL param conventions
- Card conventions (avatar, name, role, contact info, ribbons, footer)
- Ribbon model (one primary + optional badge)
- card.cfm required/optional variable reference
- Pagination integration notes

DONE_TOKEN
