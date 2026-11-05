# Prod file fingerprints (2026-10-08)

Which repo version of each Book file is deployed on prod. Hashes are SHA-256 of the file bytes
with every carriage return (0x0D) removed, so CRLF and LF copies of the same version match.
The first 16 hex characters are shown.

Run on the PROD web server (PowerShell), then match each hash against the tables below:

```powershell
$root = "C:\home\theactorsoffice.com\wwwroot\app-subdomain_1.5"
$files = "ajax\master\link.cfm","ajax\master\unlink.cfm","ajax\master\search.cfm","ajax\master\link-confirm.cfm","ajax\contact\updateprimary.cfm","services\MasterDirectoryService.cfc","services\MasterAuditService.cfc","services\ContactService.cfc","include\contact_info.cfm","include\master_link_preview.cfm"
$sha = [Security.Cryptography.SHA256]::Create()
foreach ($f in $files) {
  $p = Join-Path $root $f
  if (Test-Path $p) {
    $b = [IO.File]::ReadAllBytes($p) | Where-Object { $_ -ne 13 }
    $h = -join ($sha.ComputeHash([byte[]]$b) | ForEach-Object { $_.ToString("x2") })
    "{0,-40} {1}  {2:yyyy-MM-dd HH:mm}" -f $f, $h.Substring(0,16), (Get-Item $p).LastWriteTime
  } else { "{0,-40} MISSING" -f $f }
}
```

## ajax/master/link.cfm

| commit | date | subject | sha256 (CR-stripped) |
| --- | --- | --- | --- |
| c79d89fe | 2026-07-24 | code(DIR-LNK-WO-7): unlink epoch (S-9), footer count, office and role  | 5730206ad27b8496 |
| 6d738377 | 2026-07-09 | feat(DIR-WO-2): master-link UI - MasterDirectoryService + /ajax/master | f9cc8ea6d6b72a54 |

## ajax/master/unlink.cfm

| commit | date | subject | sha256 (CR-stripped) |
| --- | --- | --- | --- |
| 6d738377 | 2026-07-09 | feat(DIR-WO-2): master-link UI - MasterDirectoryService + /ajax/master | 51e1a2a43826181d |

## ajax/master/search.cfm

| commit | date | subject | sha256 (CR-stripped) |
| --- | --- | --- | --- |
| 6d738377 | 2026-07-09 | feat(DIR-WO-2): master-link UI - MasterDirectoryService + /ajax/master | 030158a16722ee01 |

## services/MasterDirectoryService.cfc

| commit | date | subject | sha256 (CR-stripped) |
| --- | --- | --- | --- |
| 9d76d2e3 | 2026-07-28 | code(DIR-LNK-WO-8): rename resync endpoint to resyncall.cfm + repoint  | 9e8281c7a5c06bf8 |
| 5287f3e5 | 2026-07-28 | code(DIR-LNK-WO-8): on-read sync hook, admin resync sweep, L-3 contrac | ec059691279671e8 |
| 7e586e21 | 2026-07-28 | code(DIR-LNK-WO-8): master auto-sync writer with derive-or-skip and MA | 13bdeacac991aadf |
| 51ef9338 | 2026-07-28 | code(DIR-LNK-WO-8): extract deriveMasterValues helper | 112cf0acdea5cc08 |
| c79d89fe | 2026-07-24 | code(DIR-LNK-WO-7): unlink epoch (S-9), footer count, office and role  | 9613af2bc8dad81c |
| ecaec1bf | 2026-07-23 | code(DIR-LNK-WO-7): neutralize legacy link oracle (S-6 sibling) | 943a35ccccdae401 |
| 51edc8c3 | 2026-07-23 | code(DIR-LNK-WO-7): fix relink key collision (S-7), neutral not-found  | 82b37cd620bee15f |
| dd89a403 | 2026-07-19 | code(DIR-LNK-WO-7): bridge disable, link snapshot, preservation, unlin | fb1eb415b6bed49b |
| 5946ea4f | 2026-07-09 | DIR-WO-2 review fixes F-1..F-3: FK-safe coid derivation + colocid owne | 01bf6015ae0a95d2 |
| 6d738377 | 2026-07-09 | feat(DIR-WO-2): master-link UI - MasterDirectoryService + /ajax/master | a3da214bd70118ea |

## services/MasterAuditService.cfc

| commit | date | subject | sha256 (CR-stripped) |
| --- | --- | --- | --- |
| 7e586e21 | 2026-07-28 | code(DIR-LNK-WO-8): master auto-sync writer with derive-or-skip and MA | 43cb32004f56e77e |
| 51edc8c3 | 2026-07-23 | code(DIR-LNK-WO-7): fix relink key collision (S-7), neutral not-found  | 7a6cffd6598a76a5 |
| dd89a403 | 2026-07-19 | code(DIR-LNK-WO-7): bridge disable, link snapshot, preservation, unlin | bb2fed9d809fc5fc |

## services/ContactService.cfc

| commit | date | subject | sha256 (CR-stripped) |
| --- | --- | --- | --- |
| 5287f3e5 | 2026-07-28 | code(DIR-LNK-WO-8): on-read sync hook, admin resync sweep, L-3 contrac | f7840993e711f687 |
| 7e586e21 | 2026-07-28 | code(DIR-LNK-WO-8): master auto-sync writer with derive-or-skip and MA | 00e533624eee4c5f |
| dd89a403 | 2026-07-19 | code(DIR-LNK-WO-7): bridge disable, link snapshot, preservation, unlin | 1d5779e75e927ff3 |
| 2ecf3d26 | 2026-07-18 | code(DIR-LNK-WO-6): tidy batch - company icon, L-4 comment, Book vocab | 4c3cba1789bcf4b0 |
| 2bac27c1 | 2026-07-16 | code(DIR-LNK-WO-6): primary fields, enforcement, Q1b guard, UI | 03c07db61ca9fc39 |
| 6d738377 | 2026-07-09 | feat(DIR-WO-2): master-link UI - MasterDirectoryService + /ajax/master | a35982527e1c379b |
| f94da727 | 2026-06-29 | fix(audition-relationships): sync source contacts in audcontacts_audit | f0a63df61649187b |
| d8cc7f8a | 2026-06-23 | Fix/tao wizard fix 01 (#13) | 475a1780eb175a4c |
| 6f5e13be | 2026-04-21 | feat: Implement AJAX endpoint to add contacts to user's My Team with C | 23c399cc090b5b2b |
| 4e25a3b2 | 2026-04-12 | perf: add two-tier query counting -- qry file invocations (Phase 1) an | fe5d72209714aa43 |

## include/contact_info.cfm

| commit | date | subject | sha256 (CR-stripped) |
| --- | --- | --- | --- |
| c213a4d8 | 2026-08-27 | code(hotfix): gate Master Directory Book UI off prod until WO-8 depend | be8aaa90fe80ad5b |
| 5287f3e5 | 2026-07-28 | code(DIR-LNK-WO-8): on-read sync hook, admin resync sweep, L-3 contrac | 4feb89886f41a3ec |
| 1cb0e552 | 2026-07-21 | fix(DIR-LNK-WO-7): rename update-primary endpoint (WAF URI block F-2b) | 1c44c69c79325574 |
| 72153800 | 2026-07-19 | code(DIR-LNK-WO-7): link preview modal, confirm endpoint, photo proven | 71d4c41b226099ad |
| 2ecf3d26 | 2026-07-18 | code(DIR-LNK-WO-6): tidy batch - company icon, L-4 comment, Book vocab | e7d93abec45a78d0 |
| ae125b98 | 2026-07-17 | code(DIR-LNK-WO-6/UI-6): synced predicate -> company provenance (D-23) | 5885b0dee615a84e |
| d1450c2e | 2026-07-17 | code(DIR-LNK-WO-6/UI-6): panel restructure, the Book vocabulary, Book  | 0224cbb3d7b8556e |
| 12f2a921 | 2026-07-16 | code(DIR-LNK-WO-6/UI-5): linked-contact master context - office addres | df4ce714de4b5924 |
| 6121b837 | 2026-07-16 | code(DIR-LNK-WO-6/UI-4): contact panel cosmetics - header label, name/ | bc579214d6a018cb |
| 2bac27c1 | 2026-07-16 | code(DIR-LNK-WO-6): primary fields, enforcement, Q1b guard, UI | 5377fbfaca434760 |

## include/contact_info_PROD.cfm (git-ignored prod variant)

- As created 2026-08-13 (pre-today): not in git; compare against the avatar-line-reverted copy.
- Working-tree copy with today's avatar edit: f79cd116059403eb
- Same copy with today's avatar edit reverted: 9090caab12d5f6d3

## Reading the result

- link.cfm = 6d738377 (WO-2): prod can still LINK contacts with NO audit row and no value preservation.
  That alone explains an empty prod master_audit_tbl alongside any linked prod contacts (followup SQL B1/B2).
- link.cfm = c79d89fe (RETIRED stub): prod cannot link at all; an empty audit table is then simply "no Book activity".
- MasterAuditService.cfc MISSING: no code path on prod can write master_audit_tbl.
- ContactService.cfc predating 2bac27c1 (2026-07-16): no updatePrimary(); deploying only updateprimary.cfm, the call would
  throw, be caught by its cfcatch, and still answer "Save failed." - deploy ContactService with it.
