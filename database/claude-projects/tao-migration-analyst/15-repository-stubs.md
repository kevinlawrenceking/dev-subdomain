# Phase 13 — Repository CFC Stubs

Generated: 2026-03-16

---

## Generated Stubs

The following repository CFC stub files have been generated in `/audit-output/stubs/`:

| Repository File | Entity | Table(s) | Methods | Replaces |
|---|---|---|---|---|
| `ContactRepository.cfc` | Contact | `contactdetails`, `contactitems` | 9 | ~30 /qry files |
| `NotificationRepository.cfc` | Notification | `funotifications`, `fusystemusers`, `fuactions`, `actionusers`, `notstatuses` | 8 | ~20 /qry files |
| `EventRepository.cfc` | Event | `events`, `eventtypes` | 5 | ~15 /qry files |
| `SystemRepository.cfc` | System | `fusystems` | 4 | ~5 /qry files |
| `SystemUserRepository.cfc` | SystemUser | `fusystemusers`, `fusystems`, `contactdetails` | 5 | ~12 /qry files |
| `ActionUserRepository.cfc` | ActionUser | `actionusers`, `fuactions`, `fusystems` | 3 | ~10 /qry files |
| `NoteRepository.cfc` | Note | `notes`, `notelinks` | 7 | ~15 /qry files |
| `UserRepository.cfc` | User | `taousers` | 4 | ~6 /qry files |

**Total: 8 repositories with 45 methods**, replacing ~113 /qry files.

---

## Stub Design Principles

1. **Pure SQL only** — no business logic, no validation, no side effects
2. **All inputs parameterized** — uses `queryExecute()` with named params and `cfsqltype`
3. **Null-safe** — handles optional params with null detection
4. **MySQL-native** — uses `NOW()`, `LIMIT`, MySQL syntax only
5. **Go-ready** — each method maps 1:1 to a future Go repository function
6. **Single responsibility** — each repo handles exactly one entity's table(s)

---

## Remaining Repositories Needed (Not Yet Stubbed)

These would follow the same pattern as the generated stubs:

| Repository | Priority | Methods Needed |
|---|---|---|
| `ContactItemRepository.cfc` | HIGH | findByContact, create, update, delete (4) |
| `ReportRepository.cfc` | MEDIUM | listByUser, getColors, getItems, refresh (4) |
| `DashboardRepository.cfc` | MEDIUM | getLayout, getOptions, updateLayout (3) |
| `LocationRepository.cfc` | MEDIUM | listCities, listRegions, listCountries, listTimezones, findById (5) |
| `LookupRepository.cfc` | LOW | listDateFormats, listIncomeTypes, listEssences, listDurations, getSocialIcons (5) |
| `LinkRepository.cfc` | LOW | listByUser, create, delete (3) |
| `TeamRepository.cfc` | LOW | listByUser, addMember, removeMember (3) |
| `MediaRepository.cfc` | LOW | listHeadshots, listMaterials, getMaterialDetail, create, delete (5) |
| `ShareRepository.cfc` | LOW | findByUser, create (2) |
| `ReminderRepository.cfc` | HIGH | listActive, listByRelationship (2) |
| `RelationshipRepository.cfc` | HIGH | getFollowUp, getFollowUpBody (2) |
| `ImportRepository.cfc` | MEDIUM | listByUploadId, getErrors, getResults (3) |
| `TagRepository.cfc` | LOW | listByContact, getStatus, listValid (3) |
| `VersionRepository.cfc` | LOW | listActive (1) |
| `BillingRepository.cfc` | LOW | getDetails, listTransactions (2) |
| `ToastRepository.cfc` | LOW | listByUser (1) |
| `MenuRepository.cfc` | LOW | listItems (1) |
| `PanelRepository.cfc` | LOW | listByPage, fix (2) |
| `ProfileRepository.cfc` | LOW | findByUser (1) |
| 20x `Audition[Lookup]Repository.cfc` | MEDIUM | findAll, findById, create, update (3 each = 60) |

**Additional: ~30 repositories with ~109 methods**

---

## Migration Annotation Standard

Each stub contains migration annotations:
```
// MIGRATE: maps to Go internal/repository/[entity]_repository.go
```

Each method header documents which /qry files it replaces:
```
// Replaces: /qry/getNotificationByID.cfm
```

This creates a traceable chain:
1. `/qry/getNotificationByID.cfm` (legacy)
2. `NotificationRepository.findById()` (CF intermediate)
3. `internal/repository/notification_repository.go` → `FindById()` (Go target)
