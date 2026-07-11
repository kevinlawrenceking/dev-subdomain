# DIR-WO-2 — CANONICAL ACCEPTANCE RUNBOOK v2 (architect-ratified) + GO

Your blocker report is accepted. D-16 registered: acceptance artifacts were
never persisted; this document is the canonical runbook, reconstructed and
ratified by the architect. Supersedes all prior chat-relayed versions.
Ordering fix vs prior version: A7 runs BEFORE the A6 revert (match-guard
depends on the renamed value).

STEP 0 — PERSIST FIRST
Save this entire relay verbatim to
docs/plans/evidence/2026-07-11-dir-wo2-acceptance-runbook-v2.md
and make ONE local docs-only commit ("docs: DIR-WO-2 acceptance runbook v2
(closes D-16 for this artifact)"). NO push — it rides close-out under the
standing docs-class authorization.

BINDING
Base URL: https://dev.theactorsoffice.com   Deployed pin: 5946ea4f
(WO-2 files verified identical at HEAD c7ccad22 — your diff evidence rides
the bundle). DB: new_development via the ratified pymysql read channel;
the ONLY authorized DML is the A6 rename + revert on companies.
PROHIBITIONS: no prod requests or writes; no code edits; no pushes; touch
only fixtures 90835/102009/128597/128621 + the A6 company row; A6 revert is
MANDATORY even on failure; credentials runtime-only, never persisted.

R-6 CREDENTIALS (Kevin fills — dev-only, rotated after acceptance):
  userid 1:  [login / password]
  userid 10: [login / password]
  userid 12: [login / password]
  userid 17: [login / password]

R-7 (Kevin fills): [CONFIRMED -> run A10 line-capture; operator pulls log]
                   [UNCONFIRMED -> execute all cases, HOLD A10 evidence]

SESSION + CSRF MECHANICS
Read include/core.cfm and loginform.cfm first to extract the exact login
POST target/fields and the CSRF token embed. One cookie jar per userid.
POSTs carry X-CSRF-Token exactly as core.cfm injects it. If the token
cannot be obtained programmatically: STOP and report — do not bypass the
gate. (ajax/Application.cfc enforces auth :57-63, CSRF :81-127.)

MASTER SELECTION (record all ids in the bundle)
M1 = any co_contacts row with coid > 0, companies row existing, coName
non-empty, and >= 2 co_locations offices (search or SQL; record id, coid,
coName, chosen colocid). M0 = co_contacts id=40 (coid=0, "Waters Circle").
X1 = any colocid whose co_locations.coid <> M1.coid (wrong-company probe).

SQL VERIFICATION TEMPLATES (run per mutating case, before + after)
S1: SELECT contactid, master_co_contact_id, master_coid,
    company_location_id, contactCompany, contactCompany_src,
    master_linked_date, master_last_sync
    FROM new_development.contactdetails WHERE contactid = ?;
S2: SELECT itemID, valueCompany, itemStatus, IsDeleted
    FROM new_development.contactitems_tbl
    WHERE contactID = ? AND valueCategory='Company';

EXECUTION ORDER + ASSERTIONS
A1 (any session) GET /ajax/master/search.cfm
   term=x -> success:true, data=[] (len<2 server-side)
   term=Sam&limit=10 -> <=10 rows, keys {master_co_contact_id, fullname,
     jobtitle_type, coid, coName}
   term=Sam&limit=999 -> <=25 rows (clamp)
   term=Waters -> id=40 row present with empty/0 coid, empty coName
A2 (any session) GET /ajax/master/locations.cfm
   coid=7 -> data=[] ; coid=1 -> 1 row ; coid=980 -> 15 rows
   coid=abc and coid= -> data=[] (no error)
A3 (uid1, 90835) POST link.cfm {contactid=90835,
   masterCoContactId=M1, coid=0, colocid=M1.colocid}
   S1: person/coid/office pointers set; contactCompany=M1.coName,
   _src='master'; master_linked_date set; master_last_sync set.
   S2: exactly 1 active Company item = M1.coName. Response
   itemAction='created'.
A3b (uid10, 102009) POST link {masterCoContactId=M0(40)}
   person pointer=40; master_coid NULL; company_location_id NULL;
   contactCompany still NULL, _src='user'; S2: zero items; success:true.
A4 (uid17, 128621) POST link {masterCoContactId=M1, colocid=M1.colocid}
   pointers set; contactCompany stays 'Acme Company', _src='user';
   S2: still exactly 2 active items, both values unchanged.
A5 (uid1, 90835) repeat A3 POST verbatim
   master_last_sync strictly increases; master_linked_date UNCHANGED;
   S2 unchanged (1 item, no dup); itemAction='none'.
A5b (uid1, 90835) same POST but colocid=X1   [architect addition:
   live regression for F-2/Q-3.3 wrong-company office]
   company_location_id -> NULL; person/coid pointers + snapshot + item
   unchanged; sync bumps.
A6 (operator-authorized fixture DML, ratified channel)
   Capture: SELECT coid, coName FROM new_development.companies
            WHERE coid=M1.coid;
   UPDATE new_development.companies
     SET coName = CONCAT(coName,' (WO2TEST)') WHERE coid = M1.coid;
   Re-capture. Then (uid1, 90835) repeat link POST ->
   snapshot = renamed value, _src='master'; S2: item renamed;
   itemAction='renamed'.  DO NOT REVERT YET.
A7 (uid1, 90835) POST unlink.cfm {contactid=90835}
   all 3 pointers NULL; contactCompany NULL, _src='user';
   S2: the item soft-deleted (IsDeleted=1); response
   itemAction='softdeleted:1'.
   Second identical POST -> success:true, noop:true, no state change.
A6-REVERT (mandatory): UPDATE new_development.companies
   SET coName = '<captured original literal>' WHERE coid = M1.coid;
   capture after-state. Runs even if any prior case failed.
A6b (uid12, 128597) mini-A3: link to M1 (assert item created,
   snapshot _src='master'), then re-link {masterCoContactId=M0(40)} ->
   person pointer=40; master_coid NULL; office NULL; snapshot cleared,
   _src='user'; item soft-deleted (itemAction='softdeleted:1'); success.
   Then unlink -> pointers cleared; company parts untouched
   (preSrc='user'); itemAction='none'.
A8 (uid1 session) POST link {contactid=128621, masterCoContactId=M1}
   -> success:false, generic "Contact not found." — no info leak.
   POST link WITHOUT X-CSRF-Token -> HTTP 403.
   (Unauthenticated case already smoke-proven by operator; cite.)
A9 Static — cite pre-push grep transcripts + your deploy-pin diff
   (5946ea4f..HEAD empty over WO-2 files) as deployed=reviewed proof.
A10 Per R-7 bracket. Expected lines: information-type LINK entry for A3,
   UNLINK entry for A7 in master_link.log. Record precise timestamps of
   A3/A7 for the operator's excerpt pull.

FINAL BUNDLE
Raw request/response per case; S1/S2 before/after per mutating case;
A6 capture/rename/revert trio; master-selection record (M1/M0/X1);
connection fingerprints per SQL block; R-6 non-persistence + zero-prod
confirmation; defect register additions; the Step-0 commit SHA.
Then STOP. Deploy gate (DG-1 prod aggregate, DG-3 Jodie, DG-4 prod
authorization) follows architect acceptance review.
