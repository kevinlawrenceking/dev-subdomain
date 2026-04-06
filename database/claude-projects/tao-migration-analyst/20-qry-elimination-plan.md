# Phase 12 — /qry Elimination Plan

Generated: 2026-03-16

---

## Executive Summary

- **Total /qry files**: 1,267
- **Used (statically confirmed)**: 1,003 (referenced via cfinclude)
- **Unused (no static reference)**: 283
- **Dynamic include risk**: `pgload.cfm` loads qry files from database `pages.pgFilename` — some of the 283 "unused" files may be loaded dynamically
- **Page-specific copies** (`_NNN_N` pattern): 967 (76%)
- **Shared/original files**: 300

## Critical Discovery: Dynamic Include System

`/include/pgload.cfm` contains:
```cfml
<cfinclude template="/include/qry/#pgFilename#" />
```

Where `pgFilename` is loaded from the database `pages` table via `PageService.getPageDetails()`. This means:
- **283 files with zero static callers CANNOT be safely marked as dead code** without querying the pages table
- Any file in `/include/qry/` could theoretically be loaded through this mechanism
- All 283 "unused" files receive **Disposition D (Manual review)** until the pages table is queried

---

## Disposition Categories

### Disposition A — Absorb into Service CFC
Used by exactly one template, no complex logic. Move SQL inline into the calling service as a private method.

### Disposition B — Promote to Repository CFC
Used by multiple templates OR contains complex SQL. Create `[entity]Repository.cfc` method.

### Disposition C — Inline into Template
One-off display query, no business logic. Move to queryExecute() in the single calling .cfm.

### Disposition D — Manual Review Required
Dynamic include target, unclear variable flow, or loaded via `pgload.cfm`.

---

## Disposition Plan by Entity

### Contact Entity → ContactRepository.cfc

| /qry File | Callers | Disposition | Target Method | Notes |
|---|---|---|---|---|
| `contact.cfm` | Multiple | **B** | `ContactRepository.findById()` | |
| `contact_info.cfm` | Multiple | **B** | `ContactRepository.findDetailById()` | |
| `contacts.cfm` | Multiple | **B** | `ContactRepository.listByUser()` | |
| `contacts_all.cfm` | Multiple | **B** | `ContactRepository.listAll()` | Merge with contacts.cfm |
| `contacts_all_tabs.cfm` | Multiple | **B** | `ContactRepository.listAllWithTabs()` | Review if truly different from above |
| `contacts_check.cfm` | 1 | **A** | Absorb into ContactService | |
| `lookup_contacts.cfm` | Multiple | **B** | `ContactRepository.search()` | |
| `checkUniqueContact.cfm` | Multiple | **B** | `ContactRepository.existsByNameAndUser()` | |
| `updateContactUnique.cfm` | Multiple | **B** | `ContactRepository.updateUniqueness()` | |
| `INScontactdetails.cfm` | 0 (dynamic?) | **D** | Manual review | |
| `fetchContactItems.cfm` | Multiple | **B** | `ContactItemRepository.findByContact()` | |
| `duplicatesByEmail.cfm` | Multiple | **B** | `ContactDuplicateRepository.findByEmail()` | |
| `duplicatesByName.cfm` | Multiple | **B** | `ContactDuplicateRepository.findByName()` | |
| `tmpcontactgroups.cfm` | 1 | **A** | Absorb into ContactService | |
| `InsertContact_188_*.cfm` (3 files) | 1 each | **C** | Inline, then promote | Page-specific copies |
| `contacts_333_1.cfm` through `contacts_336_4.cfm` | 1 each | **C** | Inline → merge into listByUser() | |

### Notification Entity → NotificationRepository.cfc

| /qry File | Callers | Disposition | Target Method | Notes |
|---|---|---|---|---|
| `addNotification.cfm` | 4 | **B** | `NotificationRepository.create()` | |
| `addNotifications.cfm` | 4 | **B** | `NotificationRepository.createBatch()` | |
| `addNotification_157_*.cfm` (2) | 1 each | **C** | Inline → merge | Page-specific |
| `addNotification_315_*.cfm` (2) | 1 each | **C** | Inline → merge | Page-specific |
| `addNotification_5_4.cfm` | 1 | **C** | Inline | |
| `addNotification_71_*.cfm` (2) | 1 each | **C** | Inline | |
| `addNotification_72_1.cfm` | 1 | **C** | Inline | |
| `addNotification_326_1.cfm` | 1 | **C** | Inline | |
| `addNotification_placeholder.cfm` | 0 | **D** | May be dead or dynamic | |
| `getNotificationByID.cfm` | 5 | **B** | `NotificationRepository.findById()` | |
| `getNotificationsBySystem.cfm` | 4 | **B** | `NotificationRepository.listBySystem()` | |
| `updateNotification.cfm` | Multiple | **B** | `NotificationRepository.update()` | |
| `updateNotificationCompleted.cfm` | 4 | **B** | `NotificationRepository.markCompleted()` | |
| `updateNotificationNext.cfm` | 4 | **B** | `NotificationRepository.scheduleNext()` | |
| `notsactive.cfm` | Multiple | **B** | `NotificationRepository.listActive()` | |
| `notsactivedash.cfm` | Multiple | **B** | `NotificationRepository.listActiveDashboard()` | Merge with above + filter |
| `notsall.cfm` | Multiple | **B** | `NotificationRepository.listAll()` | |
| `notsnext.cfm` | Multiple | **B** | `NotificationRepository.listNext()` | |
| `delSystemNotifications.cfm` | Multiple | **B** | `NotificationRepository.deleteBySystem()` | |
| `deleteNotificationBySystem.cfm` | Multiple | **B** | Merge with above | 🔁 Duplicate of above |
| `systemNotificationsActive.cfm` | Multiple | **B** | Merge with listBySystem() | |

### Event Entity → EventRepository.cfc

| /qry File | Callers | Disposition | Target Method | Notes |
|---|---|---|---|---|
| `events.cfm` | Multiple | **B** | `EventRepository.listByUser()` | |
| `events_byuser.cfm` | Multiple | **B** | Merge with above | 🔁 |
| `eventresults.cfm` | Multiple | **B** | `EventRepository.listFiltered()` | |
| `eventtypes_user.cfm` | Multiple | **B** | `EventTypeRepository.listByUser()` | |
| `updateEventData.cfm` | Multiple | **B** | `EventRepository.update()` | |
| `update_cal.cfm` | Multiple | **B** | `EventRepository.updateCalendar()` | |
| `appoint-add.cfm` | 0 (dynamic?) | **D** | Manual review | |
| `appoint-info.cfm` | 0 (dynamic?) | **D** | Manual review | |
| `appoint-update.cfm` | 0 (dynamic?) | **D** | Manual review | |
| `appoint.cfm` | 0 (dynamic?) | **D** | Manual review | |
| `AUDintoEVENTS.cfm` | 0 (dynamic?) | **D** | Manual review | |
| `calendar-appoint.cfm` | 0 (dynamic?) | **D** | Manual review | |

### Relationship System → SystemRepository.cfc + SystemUserRepository.cfc

| /qry File | Callers | Disposition | Target Method |
|---|---|---|---|
| `addSystem.cfm` | Multiple | **B** | `SystemUserRepository.enrollContact()` |
| `addfuSystemUsers.cfm` | Multiple | **B** | `SystemUserRepository.create()` |
| `findSystemByScope.cfm` | 4 | **B** | `SystemRepository.findByScope()` |
| `getFuSystemUsersBySystemID.cfm` | Multiple | **B** | `SystemUserRepository.listBySystemId()` |
| `getSystemUserByID.cfm` | Multiple | **B** | `SystemUserRepository.findById()` |
| `getOldSystemDetails.cfm` | Multiple | **B** | `SystemRepository.findLegacyDetails()` |
| `getSystemIdBasedOnTag.cfm` | Multiple | **B** | `SystemRepository.findByTag()` |
| `sysActive.cfm` | Multiple | **B** | `SystemRepository.listActive()` |
| `updateSystemUserCompleted.cfm` | 4 | **B** | `SystemUserRepository.markCompleted()` |
| `CompleteTargetSystems_*.cfm` | 1 | **A** | Absorb into SystemUserService |

### Action Entity → ActionRepository.cfc + ActionUserRepository.cfc

| /qry File | Callers | Disposition | Target Method |
|---|---|---|---|
| `fu_actions.cfm` | Multiple | **B** | `ActionRepository.listBySystem()` |
| `selectActions.cfm` | Multiple | **B** | `ActionRepository.listAll()` |
| `getActionUsers.cfm` | Multiple | **B** | `ActionUserRepository.listByUser()` |
| `addActionUsers.cfm` | 0 (dynamic?) | **D** | Manual review |
| `restoreActionUsers.cfm` | Multiple | **B** | `ActionUserRepository.restore()` |
| `updateActionUsers.cfm` | Multiple | **B** | `ActionUserRepository.update()` |
| `updateActionUsersByActionUpdate.cfm` | Multiple | **B** | `ActionUserRepository.updateByAction()` |
| `updateActionUsersByExcludeAction.cfm` | Multiple | **B** | `ActionUserRepository.exclude()` |
| `update_action_users.cfm` | Multiple | **B** | 🔁 Merge with updateActionUsers |
| `update_action_users2.cfm` | Multiple | **B** | 🔁 Merge with updateActionUsers |

### Note Entity → NoteRepository.cfc

| /qry File | Callers | Disposition | Target Method |
|---|---|---|---|
| `getNoteDetails.cfm` | 4 | **B** | `NoteRepository.findById()` |
| `notesContact.cfm` | Multiple | **B** | `NoteRepository.listByContact()` |
| `notesEvent.cfm` | Multiple | **B** | `NoteRepository.listByEvent()` |
| `notesrelationship.cfm` | Multiple | **B** | `NoteRepository.listByRelationship()` |
| `getLinksByNoteId.cfm` | Multiple | **B** | `NoteRepository.getLinks()` |
| `note-add.cfm` through `note-add-event.cfm` | 0 (dynamic?) | **D** | Manual review |
| `note-update*.cfm` | 0 (dynamic?) | **D** | Manual review |
| `InsertNote_*.cfm` (8 page copies) | 1 each | **C** | Inline → merge to NoteRepository.create() |
| `DeleteNote_*.cfm` | 1 each | **C** | Inline → NoteRepository.delete() |

### User Entity → UserRepository.cfc

| /qry File | Callers | Disposition | Target Method |
|---|---|---|---|
| `findUserById.cfm` | Multiple | **B** | `UserRepository.findById()` |
| `getUserDetails.cfm` | Multiple | **B** | 🔁 Merge with findById |
| `fetchUsers.cfm` | Multiple | **B** | `UserRepository.listAll()` |
| `getUsers.cfm` | Multiple | **B** | 🔁 Merge with listAll |
| `myaccount.cfm` | Multiple | **B** | `UserRepository.getAccountDetails()` |

### Audition Lookup Tables → Dedicated Repository per table

Each audition lookup table (20+ tables) has _ins, _sel, _upd shared files plus _NNN_N page copies.

**Recommended approach**: Create ONE `AuditionLookupRepository.cfc` with generic CRUD methods parameterized by table name (whitelisted), OR individual thin repositories.

| Table Group | Shared Files | Page Copies | Disposition | Target |
|---|---|---|---|---|
| ageranges | 4 | 4 | **B** | `AuditionAgeRangeRepository` |
| categories | 4 | 3 | **B** | `AuditionCategoryRepository` |
| contracttypes | 3 | 3 | **B** | `AuditionContractTypeRepository` |
| dialects | 3 | 3 | **B** | `AuditionDialectRepository` |
| genres | 5 | 4 | **B** | `AuditionGenreRepository` |
| mediatypes | 3 | 3 | **B** | `AuditionMediaTypeRepository` |
| networks | 4 | 3 | **B** | `AuditionNetworkRepository` |
| platforms | 4 | 3 | **B** | `AuditionPlatformRepository` |
| projects | 3 | 4+ | **B** | `AuditionProjectRepository` |
| qtypes | 3 | 3 | **B** | `AuditionQuestionTypeRepository` |
| roles | 3 | 4+ | **B** | `AuditionRoleRepository` |
| roletypes | 3 | 3 | **B** | `AuditionRoleTypeRepository` |
| sources | 3 | 3 | **B** | `AuditionSourceRepository` |
| steps | 3 | 3 | **B** | `AuditionStepRepository` |
| subcategories | 3 | 3 | **B** | `AuditionSubcategoryRepository` |
| tones | 4 | 3 | **B** | `AuditionToneRepository` |
| types | 3 | 8 | **B** | `AuditionTypeRepository` |
| unions | 3 | 4 | **B** | `AuditionUnionRepository` |
| vocaltypes | 4 | 3 | **B** | `AuditionVocalTypeRepository` |

### Remaining Shared Files → Various Repositories

| /qry File | Callers | Disposition | Target |
|---|---|---|---|
| `share.cfm` | Multiple | **B** | `ShareRepository.findByUser()` |
| `reminders.cfm` | Multiple | **B** | `ReminderRepository.listActive()` |
| `getRemindersByRelationship.cfm` | 5 | **B** | `ReminderRepository.listByRelationship()` |
| `reports.cfm` | Multiple | **B** | `ReportRepository.listByUser()` |
| `reportcolors.cfm` | Multiple | **B** | `ReportRepository.getColors()` |
| `reportrefresh.cfm` | Multiple | **B** | `ReportRepository.refresh()` |
| `dashboard.cfm`, `dashboard_new.cfm` | Multiple | **B** | `DashboardRepository.getLayout()` |
| `dashboardoptions.cfm` | Multiple | **B** | `DashboardRepository.getOptions()` |
| `dashboardupdate2.cfm` | Multiple | **B** | `DashboardRepository.updateLayout()` |
| `profiles.cfm` | Multiple | **B** | `ProfileRepository.findByUser()` |
| `cities.cfm` | Multiple | **B** | `LocationRepository.listCities()` |
| `regions.cfm` | Multiple | **B** | `LocationRepository.listRegions()` |
| `getAllCountries.cfm` | Multiple | **B** | `LocationRepository.listCountries()` |
| `getAllRegions.cfm` | Multiple | **B** | `LocationRepository.listAllRegions()` |
| `getAllTimezones.cfm` | Multiple | **B** | `LocationRepository.listTimezones()` |
| `getMinimalTimezones.cfm` | Multiple | **B** | `LocationRepository.listTimezonesMini()` |
| `getAllDateFormats.cfm` | Multiple | **B** | `LookupRepository.listDateFormats()` |
| `dateformats.cfm` | Multiple | **B** | 🔁 Merge with above |
| `timezones.cfm` | Multiple | **B** | 🔁 Merge with listTimezones |
| `birthdays.cfm` | Multiple | **B** | `ContactRepository.listBirthdays()` |
| `getSocialIcons.cfm` | 4 | **B** | `LookupRepository.getSocialIcons()` |
| `getActiveTaoVersions.cfm` | Multiple | **B** | `VersionRepository.listActive()` |
| `getActiveVersions.cfm` | Multiple | **B** | 🔁 Merge with above |
| `emailcheck.cfm` | Multiple | **B** | `ContactRepository.checkEmail()` |
| `phonecheck.cfm` | Multiple | **B** | `ContactRepository.checkPhone()` |
| `categories.cfm` | Multiple | **B** | `CategoryRepository.listAll()` |
| `mylinks.cfm` | Multiple | **B** | `LinkRepository.listByUser()` |
| `myteam.cfm` | Multiple | **B** | `TeamRepository.listByUser()` |
| `getMyTeam.cfm` | Multiple | **B** | 🔁 Merge with above |
| `types.cfm` | Multiple | **B** | `TypeRepository.listAll()` |
| `sitetypes.cfm` | Multiple | **B** | `SiteTypeRepository.listAll()` |
| `items.cfm` | Multiple | **B** | `ItemRepository.listAll()` |
| `itemsAll.cfm` | Multiple | **B** | 🔁 Merge with above |
| `itemsbycatActive.cfm` | Multiple | **B** | `ItemRepository.listByCategory()` |
| `lastupdates.cfm` | 5 | **B** | `UpdateLogRepository.listRecent()` |
| `incometypes_sel.cfm` | Multiple | **B** | `LookupRepository.listIncomeTypes()` |
| `essence_sel.cfm` | Multiple | **B** | `LookupRepository.listEssences()` |
| `castingdirectors_sel.cfm` | 4 | **B** | `ContactRepository.listCastingDirectors()` |
| `duration.cfm`, `durations.cfm` | Multiple | **B** | `LookupRepository.listDurations()` 🔁 merge |
| `headshots_sel.cfm` | Multiple | **B** | `MediaRepository.listHeadshots()` |
| `headshots_sel_unused.cfm` | 0 | 💀 | **Dead — delete** |
| `materials_sel.cfm` | Multiple | **B** | `MediaRepository.listMaterials()` |
| `materials_sel_unused.cfm` | 0 | 💀 | **Dead — delete** |
| `materials_details.cfm` | Multiple | **B** | `MediaRepository.getMaterialDetail()` |
| `locationDetails.cfm` | Multiple | **B** | `LocationRepository.findById()` |
| `fetchLocationService.cfm` | 6 | **B** | `LocationRepository.findByService()` |
| `select_query.cfm` | 8 | **B** | `GenericLookupRepository.list()` |
| `select_cat_query.cfm` | 4 | **B** | `GenericLookupRepository.listByCategory()` |
| `select_user_query.cfm` | Multiple | **B** | `GenericLookupRepository.listByUser()` |
| `select_cat_user_query.cfm` | 4 | **B** | `GenericLookupRepository.listByCategoryAndUser()` |
| `select_user_query_noisdelete.cfm` | Multiple | **B** | 🔁 Merge with listByUser + param |
| `findcompany.cfm` | Multiple | **B** | `ContactRepository.findCompany()` |
| `folowup_body.cfm` | Multiple | **B** | `RelationshipRepository.getFollowUpBody()` |
| `fetch_folowup.cfm` | Multiple | **B** | `RelationshipRepository.getFollowUp()` |
| `testing.cfm`, `testings.cfm` | Low | **D** | May be test artifacts |
| `thrivecart_results.cfm`, `thrivecartdetails.cfm` | Low | **B** | `BillingRepository` |
| `toasts.cfm` | Multiple | **B** | `ToastRepository.listByUser()` |
| `menuitems.cfm` | Multiple | **B** | `MenuRepository.listItems()` |
| `pgPanelsFix.cfm` | Multiple | **B** | `PanelRepository.fix()` |

---

## Disposition Summary

| Disposition | Count | Action |
|---|---|---|
| **A — Absorb** | ~30 | Move SQL into calling service, delete file |
| **B — Promote to Repository** | ~200 | Create repository methods, update callers, delete files |
| **C — Inline into template** | ~700 | Move to queryExecute() in caller, delete file (page-specific copies) |
| **D — Manual review** | ~283+ | Query pages table, trace dynamic includes |
| **💀 Dead (confirmed)** | ~50 | Safe to delete (files with `_unused` suffix + confirmed orphans) |

---

## Repository CFC Count Needed

| Repository | Methods (approx) |
|---|---|
| ContactRepository | 12 |
| ContactItemRepository | 4 |
| ContactDuplicateRepository | 3 |
| NotificationRepository | 12 |
| EventRepository | 8 |
| SystemRepository | 6 |
| SystemUserRepository | 6 |
| ActionRepository | 3 |
| ActionUserRepository | 6 |
| NoteRepository | 8 |
| UserRepository | 5 |
| ReportRepository | 4 |
| DashboardRepository | 4 |
| LocationRepository | 8 |
| LookupRepository | 8 |
| LinkRepository | 4 |
| TeamRepository | 3 |
| MediaRepository | 5 |
| ShareRepository | 2 |
| ReminderRepository | 3 |
| RelationshipRepository | 4 |
| BillingRepository | 2 |
| ToastRepository | 2 |
| MenuRepository | 2 |
| PanelRepository | 3 |
| ProfileRepository | 2 |
| VersionRepository | 2 |
| ImportRepository | 4 |
| 20x Audition Lookup Repos | 3 each = 60 |
| **TOTAL** | **~175 methods across ~48 repositories** |

This replaces 1,267 /qry files with ~175 well-named, parameterized, reusable repository methods.
