# TAO Master Contact Linking & Primary Contact Fields
## Revised Binding Technical Specification for Claude Project

**Project:** The Actors Office (TAO)  
**Initiative:** Master Contact Directory — Phase 1  
**Repository:** `kevinlawrenceking/dev-subdomain`  
**Working root:** `C:\Users\kevin\TAO\dev-subdomain`  
**Branch:** `dev`  
**Status:** Revised product architecture approved  
**Supersedes:** `TAO_Master_Contact_Snapshot_Technical_Specification.md`  
**Audience:** Claude Project, which will use this specification to prepare the execution prompt for Claude Code

---

# 1. Executive Decision

TAO will use a **master-managed snapshot model** for contacts linked to the Master Contact Directory.

The user contact record remains the application-facing record. Normal TAO pages and queries will read the user contact’s three primary fields:

- Primary phone
- Primary email
- Primary company

When a user contact is linked to a Master Contact Directory record:

- The link establishes that both records represent the same real-world person.
- The three primary fields become controlled by the master record.
- The user cannot directly edit those primary fields while the link is active.
- Master updates automatically refresh the local snapshot.
- The user may add personal, private, alternate, or secondary information through `contactitems`.
- The user may suggest a correction to the master record when master data is wrong.

Unlinking is not a normal data-management action. It exists only to correct an incorrect identity match or repair data.

---

# 2. Binding Product Rules

1. The primary phone, email, and company fields are the sole application-level primary values.
2. `contacts_ss` and all contact-list/query consumers must read those primary fields directly.
3. `contactitems` stores additional or secondary information only.
4. Master phone, email, and company values must never be inserted into `contactitems`.
5. Before linking is enabled, existing user primary values must be backfilled from `contactitems` into the primary fields.
6. A successfully migrated primary `contactitems` row must be soft-deleted.
7. Secondary `contactitems` values must remain active.
8. While a contact is unlinked, the user may edit the three primary fields directly.
9. While a contact is linked, the three primary fields are read-only and controlled by the Master Contact Directory.
10. Linking replaces the three primary fields with master values.
11. Any differing pre-link user primary value must be preserved as an additional `contactitem` before replacement.
12. Master changes automatically update all linked contact snapshots.
13. Linked users do not approve routine master changes.
14. Users may submit a master correction request when shared master data is wrong.
15. Users may always add additional phone, email, company, address, social, date, note, or other supported item data.
16. Unlinking exists only to correct a bad match, duplicate master identity, merge error, or data-repair condition.
17. Unlinking must never delete the user contact or disturb relationship history.
18. All linking, synchronization, correction, and unlinking actions must be auditable.
19. Existing useful schema and migration work must be preserved.
20. Any prior logic that creates a Company `contactitems` row during master linking must be removed after all read consumers are migrated.

---

# 3. Why Existing Work Is Still Valid

The work already completed is not wasted.

The previously added primary fields, source columns, master-link columns, migrations, indexes, and backfill work created the foundation required for the approved architecture.

The correction is limited to data flow:

- Legacy pages still read primary values from `contactitems`.
- A temporary linking behavior created a Company `contactitems` row so those pages could continue displaying a company.
- The approved architecture removes that workaround.
- All pages will instead read the actual primary phone, email, and company fields.

The implementation should preserve completed schema work and replace only the incorrect bridge behavior.

---

# 4. Domain Model

## 4.1 User contact

The user contact is the canonical TAO record for that user.

It owns:

- The application-visible primary phone
- The application-visible primary email
- The application-visible primary company
- Additional contact items
- Notes
- Relationship systems
- Notifications
- Contact history
- User-specific metadata

The user contact ID remains stable through linking, synchronization, correction, and unlinking.

## 4.2 Master contact

The master contact is curated shared directory data.

It may provide:

- Standardized contact identity
- Primary phone
- Primary email
- Primary company
- Master company relationship
- Shared directory metadata

The master record is the authority for the three primary fields while a link is active.

## 4.3 Linked contact

A linked contact is a user contact whose identity has been matched to a master contact.

While linked:

- Primary phone is master-managed.
- Primary email is master-managed.
- Primary company is master-managed.
- The user may not directly edit those three values.
- Master changes propagate automatically.
- User-specific values remain available through `contactitems`.

## 4.4 Unlinked contact

An unlinked contact has no active master relationship.

While unlinked:

- The user may edit primary phone.
- The user may edit primary email.
- The user may edit primary company.
- Additional information remains in `contactitems`.
- The user may search for and link an appropriate master record.

## 4.5 `contactitems`

`contactitems` is for additional information only.

Examples:

- Alternate phone number
- Direct phone number
- Assistant phone
- Personal email
- Alternate email
- Historical company
- Additional company affiliation
- Address
- Important date
- Social link
- Other categorized values

It must not be used as the primary-field source for normal TAO queries after migration.

---

# 5. Required Contact Metadata

Claude Project must instruct Claude Code to inspect the actual schema and reuse existing columns whenever possible. Do not create duplicate columns merely because conceptual names differ.

At minimum, the contact record needs:

- Primary phone
- Primary email
- Primary company
- Linked master contact ID
- Link active/status indicator
- Link timestamp
- Last master synchronization timestamp
- Optional master version or master modified timestamp
- Optional primary-field source markers if already implemented or useful for migration/audit

## 5.1 Source markers

Because linked contacts are fully master-managed for all three fields, per-field ownership logic is no longer required for normal operation.

However, existing source fields may still be useful to:

- Identify migrated user data
- Identify master-managed snapshots
- Support cleanup
- Support auditing
- Support safe unlink correction

If retained, valid values should remain simple, such as:

- `user`
- `master`

Do not build a complex per-field conflict engine unless recon proves another approved requirement depends on it.

---

# 6. Backfill from Existing `contactitems`

The backfill must run before the new linking workflow is enabled.

## 6.1 Purpose

Move the current user primary phone, email, and company values from `contactitems` into the actual primary fields.

This is a controlled migration from the legacy data model.

## 6.2 Candidate discovery

Process active user contacts and active items in the phone, email, and company categories.

Claude Code must verify:

- Actual category names and IDs
- Active and soft-delete fields
- Primary flag column and values
- User/contact ownership fields
- Duplicate behavior
- Existing normalization logic
- Existing migration state
- Dev/prod schema differences

## 6.3 Selection rules

### No active items

- Leave the primary field unchanged.
- Do not create data.

### Exactly one normalized value

- Use it if the primary field is blank.
- Mark the field as user-originated if source metadata is retained.
- Write migration audit history.
- Soft-delete the migrated item only after the field update succeeds.

### Multiple items with exactly one designated primary

- Use the designated primary item.
- Soft-delete only that migrated item.
- Preserve all secondary items as active additional information.

### Multiple items with no designated primary

- Do not guess.
- Add the contact/category to an exception report.
- Preserve all items.
- Leave the primary field unchanged unless already populated.

### Multiple items marked primary

- Do not guess.
- Add the contact/category to an exception report.
- Preserve all items.
- Leave the primary field unchanged unless already populated.

### Duplicate normalized values

- Normalize before counting.
- Preserve auditability.
- Do not remove distinct labels or metadata automatically.
- Claude Code must propose a safe duplicate-handling rule based on the actual schema and existing conventions.

## 6.4 Existing populated primary fields

If the primary field is already populated:

- Do not overwrite blindly.
- Compare the selected item after normalization.
- If values match, mark the legacy item migrated and soft-delete it after proof.
- If values differ, add the case to the exception report unless provenance proves which source is authoritative.
- Preserve both values until resolved.

## 6.5 Soft-delete rule

Only the specific item successfully migrated into the primary field may be soft-deleted.

Secondary values remain active.

The migration must be idempotent:

- Re-running does not repeatedly modify the same records.
- Re-running does not create duplicate history.
- Re-running does not soft-delete more items.

## 6.6 Required migration reporting

The backfill plan must include:

- Pre-migration counts
- Counts by category
- Auto-migratable records
- Ambiguous records
- Duplicate records
- Existing-field conflicts
- Migrated rows
- Soft-deleted rows
- Preserved secondary rows
- Post-migration reconciliation
- Rollback strategy
- Exception export

---

# 7. Linking Behavior

## 7.1 Purpose of linking

Linking asserts:

> This user contact and this Master Contact Directory record represent the same real-world person.

The identity link is intended to persist.

It is not a temporary subscription to contact data.

## 7.2 Link preview

Before committing the link, the UI should show:

- User contact identity
- Selected master identity
- Current user primary phone/email/company
- Master primary phone/email/company
- Any current user primary values that will be preserved as additional information
- A clear explanation that master values will control the primary fields after linking

Example:

> Linking this contact will replace the current primary phone, email, and company with the TAO Master Directory values. Any different primary values you entered will be preserved under Additional Information.

## 7.3 Pre-link preservation

Before replacing a primary field:

1. Normalize the current user value.
2. Compare it with the incoming master value.
3. If the user value is blank, do nothing.
4. If the user value matches the master value, do not create an additional item.
5. If the user value differs from the master value:
   - Insert it as an additional `contactitem`, unless an equivalent active item already exists.
   - Preserve appropriate category and display metadata.
   - Do not mark it primary.
6. Complete the preservation and primary replacement in one transaction.

## 7.4 Primary snapshot population

After preservation:

- Set primary phone to master phone.
- Set primary email to master email.
- Set primary company to master company.
- Store the linked master contact ID.
- Set link status active.
- Store link timestamp.
- Store synchronization timestamp/version.
- Mark primary fields master-managed if source columns are retained.
- Write audit history.

## 7.5 Master blank values

If the master value for a primary field is blank:

- The linked primary field should reflect the master state according to the final approved implementation.
- Pre-link user data must first be preserved as an additional item.
- Claude Code must identify whether blanking the primary field creates downstream usability issues.
- The expected default is that linked primary fields mirror the master, including blank master fields.
- Any exception to this rule requires an explicit product escalation.

## 7.6 Transaction requirements

Linking must be atomic.

A failed operation must not leave:

- A partial identity link
- Some fields updated and others not
- Duplicated `contactitems`
- Lost pre-link user values
- Inconsistent source metadata

---

# 8. Editing Linked Contacts

## 8.1 Primary fields

While linked, the user cannot directly edit:

- Primary phone
- Primary email
- Primary company

These values must be displayed read-only.

The UI should indicate:

> Managed by the TAO Master Directory

## 8.2 Additional information

While linked, the user may add, edit, and soft-delete additional information through `contactitems`.

Examples:

- Direct number
- Personal email
- Assistant’s email
- Alternate office
- Historical affiliation
- Mailing address
- Social profile
- Important date

## 8.3 Correction path

If the user believes a master-managed primary value is wrong, they should use:

> Suggest a correction

The correction request should identify:

- User contact
- Master contact
- Field
- Current master value
- Suggested value
- Optional explanation
- Requesting user
- Request timestamp
- Status
- Reviewer
- Resolution
- Resolution timestamp

The user must not directly change the shared master value from the normal contact form.

---

# 9. Master Change Synchronization

## 9.1 Governing rule

While linked, the master record controls all three primary fields.

When the master changes:

- Linked user-contact snapshots update automatically.
- No user acceptance is required.
- Additional `contactitems` remain untouched.
- Changes are logged.

## 9.2 Synchronized fields

At minimum:

- Primary phone
- Primary email
- Primary company

Claude Code must verify whether standardized name fields or other approved fields are also part of the current link model. Do not expand synchronization beyond approved scope without escalation.

## 9.3 Material and non-material changes

### Non-material

Examples:

- Phone formatting
- Email case
- Whitespace
- Safe company display normalization

These may synchronize silently.

### Material

Examples:

- Different phone digits
- Different email address
- Different company identity
- Field becoming blank
- Field becoming populated

These also synchronize automatically because the master remains authoritative, but they should create an audit or activity record.

## 9.4 Synchronization mechanism

Claude Project should require recon and recommend the safest mechanism:

- Event-driven synchronization when a master record changes
- Scheduled synchronization
- Hybrid event plus reconciliation

Preferred architecture:

- Immediate/event-driven update for affected linked contacts
- Scheduled reconciliation to repair missed events

The mechanism must be:

- Idempotent
- Retry-safe
- Auditable
- Scoped to affected contacts where practical
- Protected against stale concurrent writes

## 9.5 User visibility

Routine master updates should not require modal approval.

Optional UI:

- Passive activity entry
- “Updated from Master Directory” indicator
- Correction link

Avoid noisy email notifications for routine changes.

---

# 10. Correction Workflow

## 10.1 Purpose

The correction workflow allows users to improve the shared directory without creating private overrides to master-managed primary fields.

## 10.2 Suggested correction lifecycle

Statuses may include:

- Pending
- Approved
- Rejected
- Needs clarification
- Superseded
- Withdrawn

## 10.3 Approval behavior

When approved:

1. Update the master record.
2. Trigger master synchronization.
3. Refresh all linked user-contact snapshots.
4. Record the correction resolution and audit history.

## 10.4 Rejection behavior

When rejected:

- Leave the master unchanged.
- Leave linked snapshots unchanged.
- Record the reason.
- Preserve any user-added alternative value in `contactitems`.

## 10.5 Duplicate prevention

The system should avoid repeated identical pending corrections for the same:

- Master contact
- Field
- Suggested normalized value

---

# 11. Unlinking / Correcting a Bad Match

## 11.1 Product meaning

Unlinking is not normal contact management.

It exists only when:

- The wrong master contact was selected.
- Two people with similar names were mismatched.
- A duplicate master record is being repaired.
- A master merge or split requires correction.
- Support/admin must repair corrupted data.

The UI label should be:

- `Correct master match`
- `Remove incorrect match`
- or similar

Avoid presenting a prominent routine `Unlink` action.

## 11.2 Permissions

Claude Project should evaluate whether correction should be:

- Available to users behind a confirmation flow
- Restricted after certain activity exists
- Restricted to administrators/support
- User-initiated but admin-reviewed

The preferred default is a guarded user action with audit logging, with admin control available for complex cases.

## 11.3 What unlinking must preserve

Correcting a bad match must preserve:

- User contact ID
- Notes
- Additional `contactitems`
- Relationship systems
- `fusystemusers`
- `funotifications`
- Audition/contact relationships
- Contact history
- User-specific metadata

## 11.4 Primary fields after unlinking

Because the link may have been wrong, blindly preserving master values as user primary values may be misleading.

The preferred behavior is:

1. Restore the pre-link user primary values where reliable history exists.
2. If no prior value exists, clear the affected primary field.
3. Preserve any alternate values already stored in `contactitems`.
4. Allow the user to edit the primary fields after unlinking.

If the user immediately corrects the match by selecting a different master contact, the operation may be implemented as an atomic relink:

- Preserve user-specific data
- Replace the master identity
- Populate new master snapshots
- Keep relationship history attached to the same user contact

## 11.5 Audit requirements

Record:

- Previous master ID
- New master ID if relinked
- Reason
- Actor performing action
- Timestamp
- Restored/cleared primary values
- Any preserved data

---

# 12. `contacts_ss` and Query Simplification

## 12.1 Required source

`contacts_ss` must use the three primary fields directly:

- Primary phone
- Primary email
- Primary company

It must not determine primary values from:

- `contactitems`
- Item ranking logic
- Primary flags in `contactitems`
- Arbitrary item order
- Master-table live joins for ordinary display
- Master-created Company items

## 12.2 Related views

Review the full view family and all variants used by:

- Targeting
- Follow-Up
- Maintenance
- Contact lists
- Contact search
- Contact details
- Audition pages
- Exports
- Reports
- APIs
- Scheduled jobs
- Admin tools

Known or suspected development/production view drift must be captured before DDL changes.

## 12.3 Temporary fallback

A temporary fallback to `contactitems` may be used only during a controlled migration window if strictly necessary.

It must have:

- A documented purpose
- A removal date/gate
- Tests proving when it can be removed
- No permanent role in the final architecture

---

# 13. Contact Details Screen

## 13.1 Unlinked contact

Display editable:

- Primary phone
- Primary email
- Primary company

Display separately:

- Additional phones
- Additional emails
- Additional companies
- Other `contactitems`

Provide:

- Search/link to Master Contact Directory

## 13.2 Linked contact

Display read-only:

- Primary phone
- Primary email
- Primary company
- Master-managed badge
- Last synchronized timestamp if useful

Provide:

- Add additional information
- Suggest a correction
- Correct master match, in a guarded location

## 13.3 No hidden dual-source behavior

The screen must not silently display a master value while saving edits to another field or item source.

Display and write behavior must be explicit and consistent.

---

# 14. Relationship-System Impact

The Targeting, Follow-Up, and Maintenance systems remain functionally unchanged.

Their contact information must come from the simplified primary-field model.

The migration must prove:

- Existing `fusystemusers` records remain attached to the same contact IDs.
- Existing `funotifications` remain unchanged.
- No systems are restarted.
- No notifications are duplicated.
- No history is lost.
- Contact destinations display correct primary and additional information.
- Relationship list views are included in the consumer map.

---

# 15. Removal of the Prior Master Company Item Bridge

Any logic that inserts, updates, or soft-deletes a Company `contactitems` row solely because of master linking must be removed.

## 15.1 Removal gate

Do not remove the bridge until:

1. Backfill is proven.
2. Primary fields contain expected data.
3. `contacts_ss` reads primary fields.
4. All known consumers are migrated.
5. Development tests pass.
6. Dev/prod view drift is reconciled.
7. Rollback exists.

## 15.2 Final required behavior

After the gate:

- Linking does not create Company items.
- Linking does not create phone items.
- Linking does not create email items.
- Synchronization does not write master values to `contactitems`.
- Correcting a bad match does not delete unrelated `contactitems`.
- User-added alternatives remain independent of master synchronization.

## 15.3 Cleanup of prior master-created Company items

Legacy master-created Company items must be identified and remediated separately.

Cleanup must be:

- Match-guarded
- Auditable
- Idempotent
- Proven not to remove genuine user-created company items

No heuristic-only mass deletion is allowed without strong evidence.

---

# 16. Audit History

Use an existing audit mechanism if it fully supports the requirements. Otherwise create a dedicated history structure.

Conceptual fields:

- Contact ID
- Master contact ID
- Action type
- Field name if applicable
- Old value
- New value
- Actor
- Timestamp
- Reason
- Source context
- Related correction request
- Related synchronization run

Required action reasons include:

- `BACKFILL_FROM_CONTACTITEM`
- `LINK_CREATED`
- `PRELINK_VALUE_PRESERVED`
- `MASTER_SNAPSHOT_POPULATED`
- `MASTER_AUTO_UPDATE`
- `CORRECTION_SUBMITTED`
- `CORRECTION_APPROVED`
- `CORRECTION_REJECTED`
- `BAD_MATCH_REMOVED`
- `MASTER_RELINKED`
- `PRELINK_VALUE_RESTORED`
- `PRIMARY_FIELD_CLEARED_AFTER_UNLINK`
- `ADMIN_REPAIR`

Audit history must support:

- Explaining current values
- Restoring pre-link values
- Diagnosing bad links
- Proving synchronization
- Rolling back migration errors

---

# 17. Concurrency and Transaction Requirements

- Backfill writes must be transactional in controlled batches.
- Linking must be transactional per contact.
- Relinking/correcting a match must be transactional per contact.
- Master synchronization must use stale-write guards.
- A user adding an additional item must not be lost during synchronization.
- Retry operations must be idempotent.
- Partial operations must roll back.
- The system must avoid duplicate preserved items during repeated link attempts.
- The system must avoid duplicate audit events for the same idempotency key.

---

# 18. Normalization

Normalization is used for comparison and duplicate prevention, not necessarily display.

## Phone

- Compare normalized digits.
- Support extensions explicitly.
- Preserve user-friendly display formatting.
- Do not treat distinct extensions as equivalent without a rule.

## Email

- Trim whitespace.
- Compare case-insensitively.
- Avoid unsafe provider-specific normalization.

## Company

- Prefer stable company IDs where supported.
- Normalize whitespace and safe punctuation for comparison.
- Do not merge distinct companies based on fuzzy name similarity alone.

Normalization must be centralized and reused by:

- Backfill
- Linking
- Pre-link preservation
- Duplicate detection
- Synchronization
- Correction deduplication
- Legacy cleanup

---

# 19. Deployment Sequence

## Phase 0 — Recon

- Verify actual schema.
- Verify migration history.
- Capture relevant view DDL in dev and prod.
- Map all read/write consumers.
- Identify current linking behavior.
- Identify all master-created Company-item logic.
- Identify source/history columns.
- Quantify data states.
- Identify in-flight work that conflicts with this revised specification.

## Phase 1 — Schema completion

- Add only missing link, history, correction, index, or synchronization support.
- Reuse existing columns.
- Preserve completed useful work.
- Add constraints needed for idempotency.

## Phase 2 — Backfill dry run

- Produce counts and exceptions without writes.
- Verify categories and primary flags.
- Verify normalization.
- Review ambiguous cases.

## Phase 3 — Development backfill

- Migrate safe primary values.
- Soft-delete only migrated primary items.
- Preserve secondary items.
- Prove idempotency.
- Prove rollback.
- Reconcile counts.

## Phase 4 — Read migration

- Update `contacts_ss`.
- Update related views.
- Update page/query consumers.
- Update contact-details UI.
- Prove consistent results across surfaces.

## Phase 5 — Linking rewrite

- Add link preview.
- Preserve differing pre-link values as additional items.
- Populate master snapshots.
- Make linked primary fields read-only.
- Remove all master writes to `contactitems`.

## Phase 6 — Master synchronization

- Implement master-driven automatic refresh.
- Add audit/activity logging.
- Add reconciliation process.
- Prove retry and stale-write behavior.

## Phase 7 — Correction workflow

- Add user correction submission.
- Add admin review/resolution.
- Trigger synchronization after approved corrections.
- Prevent duplicate requests.

## Phase 8 — Bad-match correction

- Add guarded correct-match/relink behavior.
- Restore pre-link user primary values where available.
- Preserve all relationship history.
- Audit every correction.

## Phase 9 — Legacy bridge cleanup

- Identify proven master-created Company items.
- Soft-delete safely.
- Confirm genuine user items remain.
- Remove temporary fallbacks.

## Phase 10 — Production rollout

- Apply schema changes.
- Run production dry run.
- Review exceptions.
- Apply backfill.
- Deploy views and code in safe order.
- Enable linking only after gates pass.
- Monitor errors, counts, sync activity, and performance.

---

# 20. Acceptance Criteria

## Backfill

- Safe primary values migrate correctly.
- Ambiguous data is reported, not guessed.
- Only migrated primary items are soft-deleted.
- Secondary items remain active.
- Re-run is idempotent.
- Counts reconcile.

## Views

- `contacts_ss` reads primary phone/email/company directly.
- Related views use the approved source.
- No permanent primary-value item ranking remains.
- Dev/prod DDL differences are documented and resolved.

## Linking

- Linking establishes a persistent master identity.
- Existing differing user primary values are preserved as additional items.
- Duplicate additional items are not created.
- Master values populate all three primary fields.
- Linked primary fields become read-only.
- No master phone/email/company item is created.
- Linking is transactional.

## Editing

- Unlinked users may edit primary fields.
- Linked users may not edit primary fields.
- Linked users may add and edit additional information.
- Master corrections use a separate workflow.

## Synchronization

- Master changes refresh linked snapshots automatically.
- Additional items are untouched.
- Sync is idempotent and retry-safe.
- Material changes are auditable.
- Reconciliation repairs missed updates.

## Corrections

- Users can suggest field corrections.
- Approved corrections update master and all linked snapshots.
- Rejected corrections leave data unchanged.
- Duplicate pending requests are avoided.

## Bad-match correction

- The user contact ID remains unchanged.
- Relationship systems and notifications remain unchanged.
- Pre-link primary values are restored where possible.
- Incorrect master identity is removed or replaced.
- Every action is audited.

## Relationship systems

- `fusystemusers` remains intact.
- `funotifications` remains intact.
- No systems are duplicated, restarted, or deleted.
- Relationship pages display the correct primary fields.

## Performance

- Contact-list queries are simpler or no worse.
- No N+1 master lookup is introduced.
- Synchronization queries are indexed and scoped.
- Ordinary pages do not require live master joins.

---

# 21. Required Test Matrix

Minimum scenarios:

1. One phone item and blank primary phone.
2. Multiple phone items with exactly one primary.
3. Multiple phone items with no primary.
4. Multiple phone items with multiple primaries.
5. Duplicate normalized emails.
6. Existing primary value matches item.
7. Existing primary value conflicts with item.
8. Link where all local primary fields are blank.
9. Link where local values match master.
10. Link where all local values differ from master.
11. Differing pre-link values preserved as additional items.
12. Equivalent additional item already exists.
13. Master field is blank during linking.
14. Linked contact primary fields are read-only.
15. Linked user adds alternate phone.
16. Linked user adds alternate email.
17. Linked user adds alternate company.
18. Master phone changes.
19. Master email changes.
20. Master company changes.
21. Master field becomes blank.
22. Synchronization rerun.
23. Synchronization retry after transient failure.
24. Concurrent additional-item edit during sync.
25. User submits correction.
26. Duplicate correction submission.
27. Correction approved.
28. Correction rejected.
29. Wrong master link removed.
30. Wrong master link replaced with correct master.
31. Pre-link values restored after bad-match correction.
32. Relationship history survives relink.
33. Backfill rerun.
34. Dev/prod view parity.
35. Relationship list display after migration.
36. Proof that link and sync never write master phone/email/company to `contactitems`.
37. Legacy master-created Company-item cleanup preserves genuine user items.

---

# 22. Logging and Operational Proof

Required visibility:

- Backfill run ID and counts
- Link attempts and results
- Pre-link values preserved
- Master synchronization run counts
- Records updated
- Records skipped
- Retry/failure counts
- Correction requests
- Correction resolutions
- Bad-match corrections
- Legacy cleanup counts
- Reconciliation discrepancies
- Exception backlog

Do not place unnecessary personal contact values in broad application logs.

Detailed old/new values belong in authorized audit storage.

---

# 23. Non-Goals

This work does not:

- Redesign Targeting, Follow-Up, or Maintenance.
- Make master tables the live display source for every page.
- Allow private overrides of master-managed primary fields.
- Require users to approve normal master updates.
- Delete secondary contact information.
- Guess ambiguous backfill choices.
- Put master values into `contactitems`.
- Unlink contacts as a routine user preference.
- Delete or recreate user contacts when correcting a match.
- Expand master synchronization beyond approved fields without review.

---

# 24. Instructions to Claude Project

Use this specification as the binding product and architecture authority.

Prepare the complete Claude Code prompt.

The prompt must:

1. Begin with read-only recon.
2. Verify actual schema, migrations, views, application consumers, and environment drift.
3. Preserve all useful completed work.
4. Identify every conflict with the prior field-level override specification.
5. Treat this revised specification as superseding the prior document.
6. Produce a phased implementation plan before writes.
7. Separate schema, backfill, view migration, UI changes, link flow, sync, correction workflow, bad-match correction, cleanup, tests, deployment, and rollback.
8. Prevent all master phone/email/company writes to `contactitems`.
9. Prevent direct editing of linked primary fields.
10. Preserve differing pre-link user primary values as additional items.
11. Require automatic master synchronization.
12. Require a correction-request workflow rather than private primary-field overrides.
13. Treat unlinking as bad-match correction, not normal contact management.
14. Preserve user contact IDs and all relationship history.
15. Require dev/prod DDL comparison where drift exists.
16. Require dry runs, counts, exception reporting, idempotency, rollback, and acceptance proof.
17. Keep production writes held until development proof and explicit approval.
18. Escalate any product contradiction before implementation.

Claude Project may improve:

- Table names
- Column names
- Indexes
- Queue mechanics
- Scheduled-task mechanics
- Transaction implementation
- Audit implementation
- Correction workflow implementation
- UI wording

Claude Project may not change the approved behavior without a new product ruling.

---

# 25. Final Product Rule

An unlinked contact is user-managed.

A linked contact is master-managed for primary phone, email, and company.

User-specific information belongs in `contactitems`.

Master changes update linked snapshots automatically.

Wrong links are corrected; correct links persist.
