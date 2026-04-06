# Phase 11 — CRUD Overlap & Consolidation

Generated: 2026-03-16

---

## Overview

The TAO codebase has **137 service CFCs** and **1,267 /qry files** (of which **967 are page-specific copies** with `_NNN_N` suffixes and **300 are shared/original** files). This creates massive duplication.

**Key finding**: 76% of /qry files are page-specific copies of the same SQL, differing only in query name variables. The `pgload.cfm` dynamic include system loads qry files from the database `pages.pgFilename` column, making static analysis incomplete for 283 apparently unreferenced files.

---

## Entity CRUD Matrix

### Contact (Core Entity)

| Operation | Service Function(s) | /qry File(s) | Status |
|---|---|---|---|
| **Create** | ContactService.create* | `INScontactdetails.cfm`, `InsertContact_188_*.cfm` (3 copies) | 🔁 4 implementations → consolidate |
| **Read (single)** | ContactService.getById* | `contact.cfm`, `contact_info.cfm` | 🔁 2+ implementations |
| **Read (list)** | ContactService.list* | `contacts.cfm`, `contacts_all.cfm`, `contacts_all_tabs.cfm`, `contacts_check.cfm`, `lookup_contacts.cfm` | 🔁 5 read variants → consolidate to 2 (list + search) |
| **Update** | ContactService.update* | `updateContactUnique.cfm`, `remoteUpdateC.cfm`, multiple `update_*` copies | 🔁 3+ implementations |
| **Delete** | ContactService.delete* | No dedicated delete qry | ⚠️ Verify soft-delete exists |
| **Duplicate Check** | ContactDuplicateService.* | `duplicatesByEmail.cfm`, `duplicatesByName.cfm`, `checkUniqueContact.cfm` | ✅ Appropriately separated |
| **Tags** | TagService/TagsUserService | `tagsContact.cfm`, `getContactTagStatus.cfm`, `tagsvalid.cfm` | ✅ OK |
| **Items** | ContactItemService | `fetchContactItems.cfm`, `items.cfm`, `itemsAll.cfm`, `itemsbycatActive.cfm` | 🔁 4 read variants |

### Audition (Complex Entity with many lookup tables)

| Operation | Service Function(s) | /qry File(s) | Status |
|---|---|---|---|
| **Create** | AuditionProjectService.create* | `auditions_ins.cfm` + 3 page copies, `audprojects_ins.cfm` + 3 copies | 🔁 Heavy duplication |
| **Read (single)** | Multiple services | `aud_det.cfm`, `auditiondetails.cfm`, `auditionprojectdetails.cfm`, `projectDetails.cfm` + many copies | 🔁 4+ detail variants |
| **Read (list)** | AuditionProjectService.list* | `auditions.cfm`, `auds_byrole.cfm`, `getAuditions.cfm` | 🔁 3 list variants |
| **Update** | AuditionProjectService.update* | `auditions_upd.cfm`, `audprojects_upd.cfm` + copies | 🔁 Duplicated |
| **Delete** | Various | Scattered `delete_*` files | ⚠️ No centralized delete |

**Audition Lookup Tables** (each has _ins, _sel, _upd + page copies):
- AgeRanges: 3 shared + 4 page copies = 7 files for one CRUD set
- Categories: 3 shared + 3 page copies = 6 files
- ContractTypes: 3 shared + 3 page copies = 6 files
- Dialects: 3 shared + 3 page copies = 6 files
- Genres: 4 shared + 4 page copies = 8 files
- Media: 3 shared + many page copies
- MediaTypes: 3 shared + 3 page copies
- Networks: 4 shared + 3 page copies
- Platforms: 4 shared + 3 page copies
- Projects: 3 shared + many page copies
- QuestionTypes: 3 shared + 3 page copies
- Roles: 3 shared + many page copies
- RoleTypes: 3 shared + 3 page copies
- Sources: 3 shared + 3 page copies
- Steps: 3 shared + 3 page copies
- Subcategories: 3 shared + 3 page copies
- Tones: 4 shared + 3 page copies
- Types: 3 shared + 8 page copies = 11 files
- Unions: 3 shared + 4 page copies
- VocalTypes: 4 shared + 3 page copies

**Total audition lookup /qry files: ~130 shared + ~200 page copies = ~330 files** for what should be ~20 repository CRUD methods per lookup table.

### Event/Appointment

| Operation | Service Function(s) | /qry File(s) | Status |
|---|---|---|---|
| **Create** | EventService.create* | `appoint-add.cfm`, `AUDintoEVENTS.cfm` | 🔁 Merge |
| **Read (single)** | EventService.getById* | `appoint-info.cfm`, `eventdetails_*.cfm` (3 copies) | 🔁 4 variants |
| **Read (list)** | EventService.list* | `events.cfm`, `events_byuser.cfm`, `eventresults.cfm` + 8 page copies | 🔁 11 total variants |
| **Update** | EventService.update* | `appoint-update.cfm`, `updateEventData.cfm`, `update_cal.cfm` | 🔁 3 implementations |
| **Delete** | EventService.delete* | `delete_*` scattered | ⚠️ Unclear |

### Notification

| Operation | Service Function(s) | /qry File(s) | Status |
|---|---|---|---|
| **Create** | NotificationService/NotificationsService | `addNotification.cfm` + 9 page copies, `addNotifications.cfm` | 🔁 **11 implementations of addNotification** — worst duplication |
| **Read (active)** | NotificationsService | `notsactive.cfm`, `notsactivedash.cfm`, `notsall.cfm`, `notsnext.cfm` + 5 page copies | 🔁 9 read variants |
| **Read (single)** | NotificationService | `getNotificationByID.cfm` | ✅ OK |
| **Update** | NotificationService | `updateNotification.cfm`, `updateNotificationCompleted.cfm`, `updateNotificationNext.cfm` | 🔁 3 specialized updates — could be 1 with status param |
| **Delete** | NotificationService | `delSystemNotifications.cfm`, `deleteNotificationBySystem.cfm` | 🔁 2 → merge |
| **By System** | Various | `getNotificationsBySystem.cfm`, `systemNotificationsActive.cfm` | 🔁 merge |

### Relationship System (fusystems/fusystemusers)

| Operation | Service Function(s) | /qry File(s) | Status |
|---|---|---|---|
| **Create** | SystemService/SystemUserService | `addSystem.cfm` + 3 page copies, `addfuSystemUsers.cfm` | 🔁 4 create variants |
| **Read** | SystemService | `findSystemByScope.cfm`, `getFuSystemUsersBySystemID.cfm`, `getSystemUserByID.cfm`, `getOldSystemDetails.cfm`, `sysActive.cfm`, `SystemsActiveContact.cfm`, `SystemsContact.cfm` | 🔁 **7 read variants** |
| **Update** | SystemUserService | `updateSystemUserCompleted.cfm` + `updatesystem_*.cfm` (6 page copies) | 🔁 7 total |
| **Delete** | SystemService | `deletesystem_104_2.cfm` | ✅ single |
| **Complete** | SystemUserService | `CompleteTargetSystems_*.cfm` | ✅ |

### Action (fuactions/actionusers)

| Operation | Service Function(s) | /qry File(s) | Status |
|---|---|---|---|
| **Create** | ActionUserService/FUActionService | `addActionUsers.cfm`, `fu_actions.cfm` | ✅ OK |
| **Read** | ActionUserService | `getActionUsers.cfm`, `selectActions.cfm` | 🔁 2 → merge |
| **Update** | ActionUserService | `updateActionUsers.cfm`, `updateActionUsersByActionUpdate.cfm`, `updateActionUsersByExcludeAction.cfm`, `update_action_users.cfm`, `update_action_users2.cfm` | 🔁 **5 update variants** |
| **Restore** | ActionUserService | `restoreActionUsers.cfm` | ✅ |

### Note

| Operation | Service Function(s) | /qry File(s) | Status |
|---|---|---|---|
| **Create** | NoteService | `note-add.cfm`, `note-add-aud.cfm`, `note-add-event.cfm`, `InsertNote_*.cfm` (8 copies) | 🔁 **11 insert variants** |
| **Read** | NoteService | `getNoteDetails.cfm`, `notesContact.cfm`, `notesEvent.cfm`, `notesrelationship.cfm`, `NotesAud.cfm` | 🔁 5 read variants by context |
| **Update** | NoteService | `note-update.cfm`, `note-update-aud.cfm`, `note-update-event.cfm` | 🔁 3 context-specific updates |
| **Delete** | NoteService | `DeleteNote_4_2.cfm`, `DeleteNote_4_4.cfm`, `deletenote_103_1.cfm` | 🔁 3 delete variants |

### User

| Operation | Service Function(s) | /qry File(s) | Status |
|---|---|---|---|
| **Read (single)** | UserService | `findUserById.cfm`, `getUserDetails.cfm` | 🔁 2 → merge |
| **Read (list)** | UserService | `fetchUsers.cfm`, `getUsers.cfm` | 🔁 2 → merge |
| **Update** | UserService | `myaccount.cfm` | ✅ |

### Report

| Operation | Service Function(s) | /qry File(s) | Status |
|---|---|---|---|
| **Read** | ReportsMasterService et al | `reports.cfm`, `reportcolors.cfm`, `reportrefresh.cfm` + 20+ page copies (`report_*_282_*.cfm`) | 🔁 Heavy duplication |
| **Create/Update** | ReportItemService | Various `Insert_ReportItems_*` + page copies | 🔁 Merge |

### Dashboard/Panel

| Operation | Service Function(s) | /qry File(s) | Status |
|---|---|---|---|
| **Read** | PanelService et al | `dashboard.cfm`, `dashboard_new.cfm`, `dashboardoptions.cfm`, `dash_rr.cfm` + page copies | 🔁 4+ variants |
| **Update** | PanelService | `dashboardupdate2.cfm` + page copies | 🔁 merge |

### Import (Contact + Audition)

| Operation | Service Function(s) | /qry File(s) | Status |
|---|---|---|---|
| **Contact Import** | ContactImportService, V2, V3 | `import.cfm`, `imports.cfm`, `getContactsImportByUploadID.cfm` | ⚠️ 3 import service versions — V3 is current |
| **Audition Import** | AuditionImportService | `auditions_import.cfm`, `auditionsimport.cfm`, `getAuditionImportErrors.cfm`, `getAuditionImportResults.cfm` | 🔁 Some duplication |

---

## Missing CRUD Operations (Gaps)

| Entity | Missing Operation | Impact |
|---|---|---|
| Contact | Dedicated soft-delete | HIGH — no safe delete path |
| Audition | Centralized delete | HIGH — scattered deletes |
| Event | Clear delete | MEDIUM |
| Notification | Bulk archive/dismiss | MEDIUM — users need bulk ops |
| Dashboard | Create (from scratch) | LOW |

---

## Consolidation Summary

| Category | Current Count | Target Count | Reduction |
|---|---|---|---|
| /qry files total | 1,267 | ~100 repository methods | **92% reduction** |
| Page-specific copies | 967 | 0 (absorbed into repos) | 100% |
| Shared qry files | 300 | ~100 (merged/absorbed) | 67% |
| addNotification variants | 11 | 1 | 91% |
| Note insert variants | 11 | 1-3 (by context) | 73% |
| Event read variants | 11 | 2 (detail + list) | 82% |
| System read variants | 7 | 2 (detail + list) | 71% |
| Action update variants | 5 | 1-2 | 60-80% |
| Audition lookup CRUD sets | ~330 files | ~60 methods | 82% |

---

## Service Duplication Issues

| Pattern | Services Involved | Action |
|---|---|---|
| Notification vs Notifications | `NotificationService.cfc` + `NotificationsService.cfc` | 🔁 Merge into single NotificationService |
| ContactImport v1/v2/v3 | `ContactImportService.cfc`, `ContactImportV2Service.cfc`, `ContactImportV3Service.cfc` | ⚠️ V3 is current — deprecate V1/V2 |
| ContactService vs Consolidated | `ContactService.cfc`, `ContactService_Consolidated.cfc` | 🔁 Merge — consolidated should replace original |
| AuditionGenreService + standardized | `AuditionGenreService.cfc`, `AuditionGenreService_standardized.cfc` | 🔁 Standardized should replace original |
| PageAppLink vs PageAppLinks | `PageAppLinkService.cfc`, `PageAppLinks.cfc` | 🔁 Merge |
