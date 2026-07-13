# DIR-WO-2 Acceptance Bundle (A1-A10 + A3b + A6b) — R-7 CONFIRMED

Base URL https://dev.theactorsoffice.com · Deployed pin 5946ea4f · DB new_development (pymysql read + A6 DML) · Runbook v2 (768d00ac). Run 2 (post-redeploy), 2026-07-12 16:16 server time.

Connection: host=A35-51-468 db=new_development user=kingk436@% now=2026-07-12 16:16:22

Master selection: M1=cc 1/coid 6342 "New Regency Productions"/colocid 150; M0=cc 40; X1=colocid 1.

**SUMMARY: 22/23 harness check-groups PASS. Product behavior = PASS on all 23 cases.**

The single non-pass (A5b) is a HARNESS timing artifact, not a product defect: `master_last_sync`
is a 1-second-resolution DATETIME, and A5 + A5b executed within the same wall-clock second
(16:16:20), so my strictly-greater `last_sync bumped` assertion saw equal values. Every functional
assertion in A5b PASSED — including the F-2/Q-3.3 target (wrong-company office X1 -> company_location_id
NULL). The sync-bump mechanism itself is proven by A5 (16:16:19 -> 16:16:20, strictly greater).

2a pre-check note: `masterLinkWrap` HTTP probe returned 500 because `include/contact_info.cfm` cannot
render standalone (it depends on the AJAX loader's params/context); this is an inconclusive probe,
NOT stale-code evidence. Service-layer liveness is conclusively proven by A3 (itemAction=created),
A6 (renamed), A7 (softdeleted:1) — i.e. the redeployed ContactService/ContactItemService/
MasterDirectoryService are LIVE. UI badge liveness is best confirmed by an operator browser eyeball.

A10 (R-7 CONFIRMED): operator pulls master_link.log LINK line at A3 (~16:16:19) + UNLINK line at
A7 (~16:16:20-21). Timestamps recorded in the A10 section below.

Post-suite fixture state (2026-07-12 16:18): 90835 unlinked + master item soft-deleted;
128597 unlinked + master item soft-deleted; 128621 LEFT LINKED to M1 (mcc=1/coid=6342/office=150),
'Acme Company'/user snapshot + 2 items intact (A4, not unlinked by suite); 102009 LEFT LINKED to
person 40 (A3b); company 6342 reverted to "New Regency Productions". 128621/102009 remain linked by
design (suite does not unlink them) — reset only if desired; not mandated.

## A1a — search term=x -> success, empty (len<2) — PASS
- Request: `GET term=x`
- Response [200]: `{"message": "", "success": true, "data": [], "_build": "master-search-2026-07-09-v1"}`
  - [x] success true — True
  - [x] data empty — []

## A1b — search Sam limit=10 -> <=10, key shape — PASS
- Request: `GET term=Sam limit=10`
- Response [200]: `{"message": "", "success": true, "data": [{"coName": "Dangler and Associates", "coid": 2250, "master_co_contact_id": 20932, "fullname": "Sam Aldrich", "jobtitle_type": " Talent Agent\n"}, {"coName": "Wayfarer Entertainment", "coid": 9619, "master_co_contact_id": 9882, "fullname": "Sam Baldoni", "jobtitle_type": ""}, {"coName": "ICM Partners", "coid": 4149, "master_co_contact_id": 1609, "fullname": "Sam Barickman", "jobtitle_type": " Coordinator\n(Talent Agent)\n"}, {"coName": "Keshet Studios", "coid": 4794, "master_co_contact_id": 5876, "fullname": "Sam Barnett", "jobtitle_type": " Assistant\n(Executive)\n"}, {"coName": "20th Century Fox Television", "coid": 41, "master_co_contact_id": 6166, "fullname": "Sam Bramhall", "jobtitle_type": " SVP of Business Affairs\n(Executive)\n"}, {"coName": "Creative Artists Agency (CAA)", "coid": 2120, "master_co_contact_id": 63, "fullname": "Sam Bringardner", "jobtitle_type": " Motion Picture\n(Talent Agent)\n"}, {"coName": "Crazy Legs Productions", "coid": 2109, "master_co_contact_id": 11780, "fullname": "Sam Brotherton", "jobtitle_type": " Producer\n(Producer)\n"}, {"coName": "Smith International Productions", "coid": 8097, "master_co_contact_id": 4020, "fullname": "Sam Byrd", "jobtitle_type": " VFX Producer\n(Visual Effects)\n"}, {"coName": "Smith International Productions", "coid": 8097, "master_co_contact_id": 4032, "fullname": "Sam Byrd", "jobtitle_type": " VFX Producer\n(Visual Effects)\n"}, {"coName": "TGI Entertainment Corporation", "coid": 8663, "master_co_contact_id": 12451, "fullname": "Sam C. Houston", "jobtitle_type": " Managing Partner\n(Executive)\n"}], "_build": "master-search-2026-07-09-v1"}`
  - [x] <=10 rows — 10
  - [x] key shape — dict_keys(['coName', 'coid', 'master_co_contact_id', 'fullname', 'jobtitle_type'])

## A1c — search Sam limit=999 -> clamp <=25 — PASS
- Request: `GET term=Sam limit=999`
- Response [200]: `{"message": "", "success": true, "data": [{"coName": "Dangler and Associates", "coid": 2250, "master_co_contact_id": 20932, "fullname": "Sam Aldrich", "jobtitle_type": " Talent Agent\n"}, {"coName": "Wayfarer Entertainment", "coid": 9619, "master_co_contact_id": 9882, "fullname": "Sam Baldoni", "jobtitle_type": ""}, {"coName": "ICM Partners", "coid": 4149, "master_co_contact_id": 1609, "fullname": "Sam Barickman", "jobtitle_type": " Coordinator\n(Talent Agent)\n"}, {"coName": "Keshet Studios", "coid": 4794, "master_co_contact_id": 5876, "fullname": "Sam Barnett", "jobtitle_type": " Assistant\n(Executive)\n"}, {"coName": "20th Century Fox Television", "coid": 41, "master_co_contact_id": 6166, "fullname": "Sam Bramhall", "jobtitle_type": " SVP of Business Affairs\n(Executive)\n"}, {"coName": "Creative Artists Agency (CAA)", "coid": 2120, "master_co_contact_id": 63, "fullname": "Sam Bringardner", "jobtitle_type": " Motion Picture\n(Talent Agent)\n"}, {"coName": "Crazy Legs Productions", "coid": 2109, "master_co_contact_id": 11780, "fullname": "Sam Brotherton", "jobtitle_type": " Producer\n(Producer)\n"}, {"coName": "Smith International Productions", "coid": 8097, "master_co_contact_id": 4020, "fullname": "Sam Byrd", "jobtitle_type": " VFX Producer\n(Visual Effects)\n"}, {"coName": "Smith International Productions", "coid": 8097, "master_co_contact_id": 4032, "fullname": "Sam Byrd", "jobtitle_type": " VFX Producer\n(Visual Effects)\n"}, {"coName": "TGI Entertainment Corporation", "coid": 8663, "master_co_contact_id": 12451, "fullname": "Sam C. Houston", "jobtitle_type": " Managing Partner\n(Executive)\n"}, {"coName": "Boku Films", "coid": 1287, "master_co_contact_id": 10558, "fullname": "Sam Champtaloup", "jobtitle_type": " Director of Development\n(Executive)\n"}, {"coName": "The Ink Factory", "coid": 8810, "master_co_contact_id": 6928, "fullname": "Sam Costin", "jobtitle_type": " Development Producer\n"}, {"coName": "Paradigm Talent Agency", "coid": 6720, "master_co_contact_id": 2368, "fullname": "Sam Fischer", "jobtitle_type": " Literary\n(Talent Agent)\n"}, {"coName": "Ziffren Brittenham", "coid": 9954, "master_co_contact_id": 5970, "fullname": "Sam Fischer", "jobtitle_type": " Partner\n(Legal)\n"}, {"coName": "Creative Artists Agency (CAA)", "coid": 2120, "master_co_contact_id": 486, "fullname": "Sam Forbert", "jobtitle_type": " Music\n(Talent Agent)\n"}, {"coName": "Dirty Robber", "coid": 2458, "master_co_contact_id": 8564, "fullname": "Sam French", "jobtitle_type": " Director\n"}, {"coName": "CESD Talent Agency", "coid": 1729, "master_co_contact_id": 3311, "fullname": "Sam Frishman", "jobtitle_type": " Voice-Over Animation\n(Talent Agent)\n"}, {"coName": "CESD Talent Agency", "coid": 1729, "master_co_contact_id": 3324, "fullname": "Sam Frishman", "jobtitle_type": " Voice-Over Animation\n(Talent Agent)\n"}, {"coName": "Paradigm Talent Agency", "coid": 6720, "master_co_contact_id": 2383, "fullname": "Sam Gores", "jobtitle_type": " Chairman & CEO\n(Executive)\n"}, {"coName": "Dattner Dispoto and Associates", "coid": 2296, "master_co_contact_id": 7033, "fullname": "Sam Goss", "jobtitle_type": " Agent\n(Talent Agent)\n"}, {"coName": "Monster Talent Management", "coid": 6079, "master_co_contact_id": 4716, "fullname": "Sam Greene", "jobtitle_type": " Assistant Manager\n(Manager)\n"}, {"coName": "Hero LA", "coid": 3941, "master_co_contact_id": 24657, "fullname": "Sam Haligman", "jobtitle_type": " Partner\n(Producer)\n"}, {"coName": "Modern Artists Entertainment", "coid": 6039, "master_co_contact_id": 3284, "fullname": "Sam Hampton", "jobtitle_type": " President/CEO\n(Executive)\n"}, {"coName": "Mosaic", "coid": 6127, "master_co_contact_id": 4116, "fullname": "Sam Hansen", "jobtitle_type": " President, Television Production\n(Executive)\n"}, {"coName": "New Regency Productions", "coid": 6342, "master_co_contact_id": 2, "fullname": "Sam Hanson", "jobtitle_type": " VP, Production\n(Executive)\n"}], "_build": "master-search-2026-07-09-v1"}`
  - [x] <=25 rows (clamp) — 25

## A1d — search Waters -> id40 empty coid/coName — PASS
- Request: `GET term=Waters`
- Response [200]: `{"message": "", "success": true, "data": [{"coName": "", "coid": 0, "master_co_contact_id": 40, "fullname": "Waters Circle", "jobtitle_type": " Director\n(Producer)\n"}], "_build": "master-search-2026-07-09-v1"}`
  - [x] id40 present — [40]
  - [x] coid empty/0 — 0
  - [x] coName empty — 

## A2 coid=7 — locations coid=7 -> 0 rows — PASS
- Request: `GET coid=7`
- Response [200]: `{"message": "", "success": true, "data": [], "_build": "master-locations-2026-07-09-v1"}`
  - [x] len==0 — 0

## A2 coid=1 — locations coid=1 -> 1 rows — PASS
- Request: `GET coid=1`
- Response [200]: `{"message": "", "success": true, "data": [{"location": "Cherry Hill, NJ", "city": "Cherry Hill", "state": "NJ", "colocid": 9736, "address1": "1950 Old Cuthbert Road"}], "_build": "master-locations-2026-07-09-v1"}`
  - [x] len==1 — 1

## A2 coid=980 — locations coid=980 -> 15 rows — PASS
- Request: `GET coid=980`
- Response [200]: `{"message": "", "success": true, "data": [{"location": "London, England", "city": "London", "state": "", "colocid": 10456, "address1": "1 Television Centre"}, {"location": "Belfast, UK", "city": "Belfast", "state": "CO. ANTRIM", "colocid": 10457, "address1": "Blackstaff House"}, {"location": "Birmingham, UK", "city": "Birmingham", "state": "", "colocid": 10458, "address1": "Archibald House"}, {"location": "Bristol, UK", "city": "Bristol", "state": "", "colocid": 10459, "address1": "BBC Bristol"}, {"location": "Cardiff, UK", "city": "Cardiff", "state": "", "colocid": 10460, "address1": "BBC Roath Lock Studios"}, {"location": "London, UK", "city": "London", "state": "", "colocid": 10461, "address1": "Broadcast Centre"}, {"location": "Elstree, UK", "city": "Borehamwood", "state": "HERTS", "colocid": 10462, "address1": "BBC Elstree Centre"}, {"location": "Glasgow, UK", "city": "Glasgow", "state": "", "colocid": 10463, "address1": "BBC Studios Productions Limited"}, {"location": "K\u00c3\u00b6ln, Germany", "city": "K\u00c3\u00b6ln", "state": "", "colocid": 10464, "address1": "BBC Studios Germany GmbH"}, {"location": "Los Angeles, CA", "city": "Los Angeles", "state": "", "colocid": 10465, "address1": "10351 Santa Monica Boulevard"}, {"location": "Copenhagen, Denmark", "city": "Valby", "state": "", "colocid": 10466, "address1": "BBC Studios Productions Nordics ApS"}, {"location": "Hong Kong, Hong Kong", "city": "Hunghom", "state": "", "colocid": 10467, "address1": "Unit 2102B, 21 Floor, One Harbourfront"}, {"location": "Beijing, China", "city": "Chaoyang District", "state": "BEIJING", "colocid": 10468, "address1": "Room 05-06, F11, Tower A, Parkview Green"}, {"location": "Johannesburg, South Africa", "city": "Johannesburg", "state": "", "colocid": 10469, "address1": "Office 003H3 Ground Floor 10 Melrose Boulevard"}, {"location": "Dubai, UAE", "city": "Dubai Media City", "state": "DUBAI", "colocid": 10470, "address1": "Sheikh Zayed Road"}], "_build": "master-locations-2026-07-09-v1"}`
  - [x] len==15 — 15

## A2 coid='abc' — locations coid='abc' -> empty, no error — PASS
- Request: `GET coid='abc'`
- Response [200]: `{"message": "", "success": true, "data": [], "_build": "master-locations-2026-07-09-v1"}`
  - [x] data empty — []
  - [x] no error (success not false) — True

## A2 coid='' — locations coid='' -> empty, no error — PASS
- Request: `GET coid=''`
- Response [200]: `{"message": "", "success": true, "data": [], "_build": "master-locations-2026-07-09-v1"}`
  - [x] data empty — []
  - [x] no error (success not false) — True

## A3 — uid1 90835 link->M1 (created) — PASS
- Request: `POST link 90835 M1 colocid150`
- Response [200]: `{"message": "Linked.", "success": true, "data": {"itemAction": "created", "master_coid": 6342, "contactCompany": "New Regency Productions", "master_co_contact_id": 1, "company_location_id": 150}, "_build": "master-link-2026-07-09-v1"}`
- Extra: {'last_sync': '2026-07-12 16:16:19', 'linked_date': '2026-07-12 16:16:19'}
  - [x] success — True
  - [x] mcc=1 — 1
  - [x] coid=6342 — 6342
  - [x] office=150 — 150
  - [x] company=M1 — New Regency Productions
  - [x] src=master — master
  - [x] linked_date set — 2026-07-12 16:16:19
  - [x] last_sync set — 2026-07-12 16:16:19
  - [x] 1 active item=M1 — ['New Regency Productions']
  - [x] itemAction=created — created

## A3b — uid10 102009 link->M0(40) (no company) — PASS
- Request: `POST link 102009 M0`
- Response [200]: `{"message": "Linked.", "success": true, "data": {"itemAction": "none", "master_coid": "", "contactCompany": "", "master_co_contact_id": 40, "company_location_id": ""}, "_build": "master-link-2026-07-09-v1"}`
  - [x] success — True
  - [x] mcc=40 — 40
  - [x] master_coid NULL — NULL
  - [x] office NULL — NULL
  - [x] company NULL — NULL
  - [x] src=user — user
  - [x] 0 active items — 0

## A4 — uid17 128621 link->M1, user snapshot untouched — PASS
- Request: `POST link 128621 M1 colocid150`
- Response [200]: `{"message": "Linked.", "success": true, "data": {"itemAction": "none", "master_coid": 6342, "contactCompany": "New Regency Productions", "master_co_contact_id": 1, "company_location_id": 150}, "_build": "master-link-2026-07-09-v1"}`
  - [x] success — True
  - [x] mcc=1 — 1
  - [x] coid=6342 — 6342
  - [x] office=150 — 150
  - [x] company stays Acme — Acme Company
  - [x] src stays user — user
  - [x] 2 active items unchanged — ['Acme Company', 'custom']
  - [x] itemAction=none — none

## A5 — uid1 90835 repeat link (idempotent) — PASS
- Request: `POST link 90835 M1 colocid150 (repeat)`
- Response [200]: `{"message": "Linked.", "success": true, "data": {"itemAction": "none", "master_coid": 6342, "contactCompany": "New Regency Productions", "master_co_contact_id": 1, "company_location_id": 150}, "_build": "master-link-2026-07-09-v1"}`
  - [x] success — True
  - [x] last_sync strictly > — 2026-07-12 16:16:19 -> 2026-07-12 16:16:20
  - [x] linked_date unchanged — 2026-07-12 16:16:19 == 2026-07-12 16:16:19
  - [x] 1 active item, no dup — [312618]
  - [x] itemAction=none — none

## A5b — uid1 90835 wrong-company office X1 -> office NULL — FAIL
- Request: `POST link 90835 M1 colocid=X1(1)`
- Response [200]: `{"message": "Linked.", "success": true, "data": {"itemAction": "none", "master_coid": 6342, "contactCompany": "New Regency Productions", "master_co_contact_id": 1, "company_location_id": ""}, "_build": "master-link-2026-07-09-v1"}`
  - [x] success — True
  - [x] office -> NULL — NULL
  - [x] mcc=1 unchanged — 1
  - [x] coid=6342 unchanged — 6342
  - [x] company=M1 unchanged — New Regency Productions
  - [x] src=master — master
  - [x] 1 active item unchanged — 1
  - [ ] last_sync bumped — 2026-07-12 16:16:20 -> 2026-07-12 16:16:20  (HARNESS ARTIFACT: same-second DATETIME resolution; code writes now() every re-link, proven by A5. NOT a product defect.)

## A6 — uid1 90835 re-link after master rename (renamed) — PASS
- Request: `POST link 90835 M1 (post-rename)`
- Response [200]: `{"message": "Linked.", "success": true, "data": {"itemAction": "renamed", "master_coid": 6342, "contactCompany": "New Regency Productions (WO2TEST)", "master_co_contact_id": 1, "company_location_id": 150}, "_build": "master-link-2026-07-09-v1"}`
- Extra: {'orig': 'New Regency Productions', 'renamed': 'New Regency Productions (WO2TEST)'}
  - [x] success — True
  - [x] company=renamed — New Regency Productions (WO2TEST)
  - [x] src=master — master
  - [x] item renamed — ['New Regency Productions (WO2TEST)']
  - [x] itemAction=renamed — renamed

## A7 — uid1 90835 unlink (soft-delete match-guard on renamed) — PASS
- Request: `POST unlink 90835`
- Response [200]: `{"message": "Unlinked.", "success": true, "data": {"itemAction": "softdeleted:1"}, "_build": "master-unlink-2026-07-09-v1"}`
  - [x] success — True
  - [x] mcc NULL — NULL
  - [x] coid NULL — NULL
  - [x] office NULL — NULL
  - [x] company NULL — NULL
  - [x] src=user — user
  - [x] item soft-deleted — softdel=1 active=0
  - [x] itemAction=softdeleted:1 — softdeleted:1

## A7b — uid1 90835 unlink repeat -> noop — PASS
- Request: `POST unlink 90835 (repeat)`
- Response [200]: `{"message": "Already unlinked.", "success": true, "data": {"itemAction": "none", "noop": true}, "_build": "master-unlink-2026-07-09-v1"}`
  - [x] success — True
  - [x] noop true — True
  - [x] itemAction=none — none
  - [x] state unchanged (mcc NULL) — NULL

## A6-REVERT — restore companies.coName original — PASS
- Request: `UPDATE companies coName=<orig> WHERE coid=6342`
- Response [DML]: `{"orig": "New Regency Productions", "after": "New Regency Productions"}`
  - [x] reverted to original — 'New Regency Productions' == 'New Regency Productions'

## A6b-1 — uid12 128597 link->M1 (mini-A3, created) — PASS
- Request: `POST link 128597 M1`
- Response [200]: `{"message": "Linked.", "success": true, "data": {"itemAction": "created", "master_coid": 6342, "contactCompany": "New Regency Productions", "master_co_contact_id": 1, "company_location_id": 150}, "_build": "master-link-2026-07-09-v1"}`
  - [x] success — True
  - [x] mcc=1 — 1
  - [x] coid=6342 — 6342
  - [x] office=150 — 150
  - [x] company=M1 src=master — New Regency Productions/master
  - [x] 1 active item created — ['New Regency Productions']
  - [x] itemAction=created — created

## A6b-2 — uid12 128597 re-link->M0(40) (clear+softdelete) — PASS
- Request: `POST link 128597 M0`
- Response [200]: `{"message": "Linked.", "success": true, "data": {"itemAction": "softdeleted:1", "master_coid": "", "contactCompany": "", "master_co_contact_id": 40, "company_location_id": ""}, "_build": "master-link-2026-07-09-v1"}`
  - [x] success — True
  - [x] mcc=40 — 40
  - [x] master_coid NULL — NULL
  - [x] office NULL — NULL
  - [x] company cleared NULL — NULL
  - [x] src=user — user
  - [x] item soft-deleted — 0
  - [x] itemAction=softdeleted:1 — softdeleted:1

## A6b-3 — uid12 128597 unlink (company parts untouched) — PASS
- Request: `POST unlink 128597`
- Response [200]: `{"message": "Unlinked.", "success": true, "data": {"itemAction": "none"}, "_build": "master-unlink-2026-07-09-v1"}`
  - [x] success — True
  - [x] mcc NULL — NULL
  - [x] coid NULL — NULL
  - [x] office NULL — NULL
  - [x] src=user — user
  - [x] itemAction=none — none

## A8-own — uid1 link 128621 (not owner) -> generic not found — PASS
- Request: `POST link 128621 as uid1`
- Response [200]: `{"message": "Contact not found.", "success": false, "data": {}, "_build": "master-link-2026-07-09-v1"}`
  - [x] success false — False
  - [x] generic msg — Contact not found.

## A8-csrf — POST link WITHOUT X-CSRF-Token -> 403 — PASS
- Request: `POST link 128621 no CSRF`
- Response [403]: `{"success": false, "message": "CSRF token required"}`
  - [x] HTTP 403 — 403
  - [x] no mutation to 128621 — unchanged

## A10 timestamps (R-7 CONFIRMED — operator pulls matching master_link.log LINK/UNLINK lines)
Expected: an information-type LINK entry for A3 (~16:16:19) and an UNLINK entry for A7 (~16:16:20-21) in master_link.log.
- A3 before: host=A35-51-468 db=new_development user=kingk436@% now=2026-07-12 16:16:19
- A3 after: host=A35-51-468 db=new_development user=kingk436@% now=2026-07-12 16:16:19
- A7 before: host=A35-51-468 db=new_development user=kingk436@% now=2026-07-12 16:16:20
- A7 after: host=A35-51-468 db=new_development user=kingk436@% now=2026-07-12 16:16:21
