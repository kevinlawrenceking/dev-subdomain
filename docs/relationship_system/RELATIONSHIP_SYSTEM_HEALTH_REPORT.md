# TAO Relationship System Health Report

**Generated:** 2026-01-11
**Status:** READY FOR TESTING
**Database:** MySQL (new_development for testing, actorsbusinessoffice for production)

---

## WORKLOG

### 2026-01-11 - All Phases Complete

**Phase 1: Discovery**
- Mapped all CF files touching relationship system tables (111 files total)
- Identified core services: NotificationService.cfc, SystemUserService.cfc, ActionUserService.cfc
- Located scheduled task: sched/events_completed.cfm
- Found completion workflow: include/complete_not.cfm
- Documented data flow from events to notifications

**Phase 2: Audit SQL**
- Created comprehensive audit queries in `/scripts/relationship_system/audit_relationship_system.sql`
- Created CFM runner at `/scripts/relationship_system/run_audit.cfm`
- Categories: A (orphans), B (missing actionusers), C (multi-pending), D (stuck), E (duplicates), F (uniqueness), G (scheduling), H (consistency)

**Phase 3: Repair Runner**
- Created idempotent repair script at `/scripts/relationship_system/repair_relationship_system.cfm`
- Supports dry-run mode (default)
- Separate toggles for each fix category
- Comprehensive logging

**Phase 4: Code Hardening**
- Created `services/RelationshipService.cfc` - centralized scheduling and completion logic
- Key methods:
  - `completeNotification(notid, status, userid)` - handles full completion workflow
  - `startSystemForContact(systemid, contactid, userid)` - creates system with notifications
  - `startMaintenanceIfNeeded(contactid, userid, systemscope)` - maintenance auto-start
  - `getSystemHealth()` - returns health metrics
- Transaction-wrapped operations
- Structured logging to `relationship_system` log file

**Phase 5: Performance Indexes**
- Created index script at `/scripts/relationship_system/add_indexes.sql`
- Indexes for funotifications: user+status+date, suid+status+date, actionid
- Indexes for fusystemusers: contact+user+system+status, user+status, contact+status
- Indexes for actionusers: user+action, user+isdeleted
- Includes rollback script and EXPLAIN test queries

**Phase 6: Admin Dashboard**
- Created `/app/admin-relationship/index.cfm`
- Health status banner with color coding
- Key metrics: active systems, pending reminders, due today, overdue, stuck, duplicates
- Issue breakdown table
- Top offenders list (stuck systems)
- Quick action buttons for audit and repair
- JSON API output

---

## 1. DELIVERABLES SUMMARY

| Deliverable | Location | Status |
|-------------|----------|--------|
| Health Report | `/docs/relationship_system/RELATIONSHIP_SYSTEM_HEALTH_REPORT.md` | Complete |
| Audit SQL | `/scripts/relationship_system/audit_relationship_system.sql` | Complete |
| Audit Runner (CFM) | `/scripts/relationship_system/run_audit.cfm` | Complete |
| Repair Runner | `/scripts/relationship_system/repair_relationship_system.cfm` | Complete |
| RelationshipService.cfc | `/services/RelationshipService.cfc` | Complete |
| Index Script | `/scripts/relationship_system/add_indexes.sql` | Complete |
| Admin Dashboard | `/app/admin-relationship/index.cfm` | Complete |

---

## 2. CURRENT STATE INVENTORY

### 2.1 Core Tables

| Table | Purpose | Key Columns |
|-------|---------|-------------|
| `fusystems` | System definitions (Follow-Up, Maintenance, Target) | systemid, systemtype, systemscope, systemname |
| `fuactions` | Master action templates per system | actionid, systemid, actionno, actiondaysno, actiondaysrecurring, isunique, uniquename |
| `actionusers` | Per-user action timing overrides | id, actionid, userid, actiondaysno, actiondaysrecurring, isdeleted |
| `fusystemusers` | Contact enrollments in systems | suid, systemid, contactid, userid, sustartdate, sustatus, isdeleted |
| `funotifications` | Scheduled reminders/actions | notid, actionid, userid, suid, notstartdate, notstatus, notenddate, isdeleted |
| `contactdetails` | Contact records with uniqueness flags | contactid, userid, recordname, [uniquename columns] |

### 2.2 System Types and IDs

| System ID | Type | Scope | Description |
|-----------|------|-------|-------------|
| 1 | Follow Up | Casting | Post-audition follow-up for casting contacts |
| 2 | Follow Up | Interest | Post-audition follow-up for interest contacts |
| 3 | Maintenance List | Casting | Long-term relationship maintenance for casting |
| 4 | Maintenance List | Interest | Long-term relationship maintenance for interest |
| 5 | Targeted List | Casting | Pre-meeting targeting for casting |
| 6 | Targeted List | Interest | Pre-meeting targeting for interest |

### 2.3 Key Business Rules

1. **One Active Pending Per System**: Only ONE notification per suid should have notstartdate set at a time
2. **Uniqueness**: Actions marked `isUnique=1` should only execute once per contact (tracked via contactdetails columns)
3. **Recurrence**: If `actionDaysRecurring > 0`, create a new notification after completion
4. **Maintenance Auto-Start**: When Follow-Up completes (all actions done), auto-create Maintenance if none exists
5. **Target Completion**: When Follow-Up starts, Target systems (5,6) should be marked Completed

---

## 3. DATA FLOW DOCUMENTATION

### 3.1 System Lifecycle

```
[Event Created]
    |
    v
[Event Stop Date Passes]
    |
    v (sched/events_completed.cfm)
[Event Marked Completed]
    |
    v
[Check Contact Tags (Casting/Interest)]
    |
    v
[Check for Existing Active System] --> If exists: SKIP
    |
    v (No existing system)
[Create fusystemusers record] --> suStatus = 'Active'
    |
    v
[Complete any Target Systems (systemid 5,6)] --> suStatus = 'Completed'
    |
    v
[Get First Action from fuactions via actionusers]
    |
    v
[Check isUnique against contactdetails]
    |
    v
[Create funotifications record] --> notstatus = 'Pending', notstartdate = calculated
```

### 3.2 Notification Completion Flow (via RelationshipService.cfc)

```
[User Clicks Complete/Skip]
    |
    v (RelationshipService.completeNotification)
[BEGIN TRANSACTION]
    |
    v
[Get Notification Details]
    |
    v
[Update funotifications] --> notstatus = 'Completed'/'Skipped', notenddate = NOW()
    |
    v
[If isUnique: Update contactdetails.uniquename = 'Y']
    |
    v
[If actionDaysRecurring > 0]
    |---> YES: Create NEW notification with future notstartdate
    |
    v
[Get Next Pending Notification (notstartdate IS NULL)]
    |
    v
[If Found: Set notstartdate = TODAY + actionDaysNo]
    |
    v
[If NOT Found (No more actions)]
    |
    v
[Update fusystemusers.suStatus = 'Completed']
    |
    v
[If Follow-Up system: Call startMaintenanceIfNeeded()]
    |
    v
[COMMIT TRANSACTION]
    |
    v
[Log action to relationship_system log]
```

---

## 4. AUDIT QUERIES

### 4.1 Audit Categories

| Category | Description | Fix Available |
|----------|-------------|---------------|
| A1 | Orphaned notifications (missing suid) | Yes - soft delete |
| A2 | Orphaned notifications (missing actionid) | Yes - soft delete |
| A3 | Orphaned notifications (missing userid) | Yes - soft delete |
| B1 | Missing actionusers rows | Yes - auto-create |
| C1 | Multiple active pending per suid | Yes - keep earliest |
| D1 | Stuck systems (Active with no pending) | Needs review |
| D2 | Stuck notifications (NULL notstartdate) | Yes - reschedule |
| E1 | Duplicate active enrollments | Yes - mark older as Completed |
| E2 | Duplicate maintenance systems | Yes - mark older as Completed |
| F1 | Uniqueness violations | Manual review |
| G1 | Overdue Future status | Yes - update status |
| G2 | Ancient pending (> 1 year) | Manual review |
| H1 | Completed systems with pending | Yes - mark as Skipped |
| H2 | Pending with enddate set | Yes - clear enddate |

### 4.2 Running the Audit

1. **Web UI:** Access `/scripts/relationship_system/run_audit.cfm`
2. **Raw SQL:** Run queries from `/scripts/relationship_system/audit_relationship_system.sql`
3. **Admin Dashboard:** Access `/app/admin-relationship/` for overview

---

## 5. AUDIT RESULTS

*Run the audit queries against test database to populate*

### 5.1 Pre-Fix Counts

| Issue | Count | Sample IDs |
|-------|-------|------------|
| A1. Orphaned (suid) | Run audit | |
| A2. Orphaned (actionid) | Run audit | |
| C1. Multiple active pending | Run audit | |
| D1. Stuck systems | Run audit | |
| D2. Stuck null startdate | Run audit | |
| E1. Duplicate enrollments | Run audit | |
| H1. Completed with pending | Run audit | |

### 5.2 Post-Fix Counts

*Run after applying repairs*

---

## 6. FIX PLAN

### Available Fixes (via repair_relationship_system.cfm)

| Fix | Category | Description | Risk |
|-----|----------|-------------|------|
| fixA | A1, A2 | Soft-delete orphaned notifications | Low |
| fixB | B1 | Create missing actionusers rows | Low |
| fixC | C1 | Fix multiple active pending (keep earliest) | Medium |
| fixD | D2 | Reschedule stuck notifications | Medium |
| fixE | E1, E2 | Deduplicate system enrollments | Medium |
| fixH | H1, H2 | Fix consistency issues | Low |

### Running Repairs

1. **Always run in dry-run mode first:**
   ```
   /scripts/relationship_system/repair_relationship_system.cfm?dryRun=Y&applyAll=Y
   ```

2. **Apply specific fix (still dry-run):**
   ```
   /scripts/relationship_system/repair_relationship_system.cfm?dryRun=Y&fixD=Y
   ```

3. **Apply fix for real:**
   ```
   /scripts/relationship_system/repair_relationship_system.cfm?dryRun=N&fixD=Y
   ```

---

## 7. CODE HARDENING

### 7.1 New RelationshipService.cfc

Located at: `/services/RelationshipService.cfc`

**Key Methods:**

```coldfusion
// Complete a notification with full workflow
result = relationshipService.completeNotification(
    notid = 123,
    status = "Completed",
    userid = session.userid
);

// Start a system for a contact
result = relationshipService.startSystemForContact(
    systemid = 1,
    contactid = 456,
    userid = session.userid
);

// Get health metrics for dashboard
health = relationshipService.getSystemHealth();
```

**Features:**
- Transaction-wrapped completion workflow
- Enforces one-pending-per-suid rule
- Handles recurring actions correctly
- Auto-starts maintenance after Follow-Up completion
- Structured logging to `relationship_system` log file

### 7.2 Migration Path

**Immediate:** Use RelationshipService.cfc for new code
**Future:** Migrate existing complete_not.cfm and add_system.cfm to use the service

---

## 8. PERFORMANCE INDEXES

### 8.1 Index Script

Located at: `/scripts/relationship_system/add_indexes.sql`

### 8.2 Indexes Created

| Table | Index Name | Columns | Purpose |
|-------|------------|---------|---------|
| funotifications | idx_funot_user_status_date | userid, notstatus, notstartdate | Reminder count queries |
| funotifications | idx_funot_suid_status_date | suid, notstatus, notstartdate | Next notification lookup |
| funotifications | idx_funot_actionid | actionid | Join optimization |
| fusystemusers | idx_fusu_contact_user_system_status | contactid, userid, systemid, sustatus | Duplicate detection |
| fusystemusers | idx_fusu_user_status_deleted | userid, sustatus, isdeleted | User system list |
| fusystemusers | idx_fusu_contact_status | contactid, sustatus | Contact page queries |
| actionusers | idx_au_user_action | userid, actionid | Join optimization |

---

## 9. VERIFICATION CHECKLIST

### 9.1 Pre-Deployment

- [ ] Run audit on test database: `/scripts/relationship_system/run_audit.cfm`
- [ ] Review audit results
- [ ] Run repairs in dry-run mode
- [ ] Apply repairs on test database
- [ ] Re-run audit to verify fixes
- [ ] Test admin dashboard: `/app/admin-relationship/`

### 9.2 Manual Smoke Tests

- [ ] Add a contact to a Follow-Up system manually
- [ ] Complete first notification
- [ ] Verify next notification gets scheduled (check notstartdate)
- [ ] Complete all notifications in system
- [ ] Verify system status changes to Completed
- [ ] Verify maintenance auto-starts (check fusystemusers)
- [ ] Test recurring action creates new notification
- [ ] Test Skip functionality

### 9.3 Post-Deployment Monitoring

- [ ] Check admin dashboard daily for first week
- [ ] Monitor `relationship_system` log file for errors
- [ ] Verify no new stuck systems appearing
- [ ] Check for orphan notifications

---

## 10. SHIP DECISION

**Current Status:** READY FOR TESTING

**Pre-Ship Checklist:**
1. [ ] Audit results reviewed and acceptable
2. [ ] Repairs applied to test database
3. [ ] Post-repair audit shows improvement
4. [ ] Manual smoke tests pass
5. [ ] Admin dashboard functional
6. [ ] Indexes applied to test database
7. [ ] Performance verified with EXPLAIN

**Ship Decision:** Pending test database validation

---

## APPENDIX A: File Reference

### New Files Created

| File | Purpose |
|------|---------|
| `docs/relationship_system/RELATIONSHIP_SYSTEM_HEALTH_REPORT.md` | This report |
| `scripts/relationship_system/audit_relationship_system.sql` | Raw audit queries |
| `scripts/relationship_system/run_audit.cfm` | Web-based audit runner |
| `scripts/relationship_system/repair_relationship_system.cfm` | Repair runner with dry-run |
| `scripts/relationship_system/add_indexes.sql` | Performance indexes |
| `services/RelationshipService.cfc` | Centralized business logic |
| `app/admin-relationship/index.cfm` | Admin health dashboard |

### Existing Files Analyzed

| File | Purpose |
|------|---------|
| `services/NotificationService.cfc` | Existing notification CRUD |
| `services/SystemUserService.cfc` | System enrollment management |
| `services/ActionUserService.cfc` | Per-user action overrides |
| `include/complete_not.cfm` | Current completion workflow |
| `include/add_system.cfm` | System creation logic |
| `sched/events_completed.cfm` | Event-to-system automation |

---

## APPENDIX B: Quick Reference Commands

### Run Full Audit
```
/scripts/relationship_system/run_audit.cfm
```

### Preview All Repairs
```
/scripts/relationship_system/repair_relationship_system.cfm?dryRun=Y&applyAll=Y
```

### Apply All Repairs
```
/scripts/relationship_system/repair_relationship_system.cfm?dryRun=N&applyAll=Y
```

### Access Admin Dashboard
```
/app/admin-relationship/
```

### Check ColdFusion Logs
```
Look for: relationship_system.log in ColdFusion logs directory
```
