# SETUP-DIAG: Katie Sweeney (prod, read-only) - 2026-09-03

Binding: TAO / PROD actorsbusinessoffice / READ ONLY (SELECT, SHOW, DESCRIBE only; pymysql channel as kingk436).
Probe scripts + raw outputs retained in session scratchpad (katie_probe.py / katie_probe2.py / katie_probe3.py).

## Verdict

Account is fully provisioned and active. None of H1-H4 hold. The only fault attributable to her is a
pre-existing app bug on the auditions Export button when the user has zero auditions.

## Matched rows

thrivecart_tbl id 3905
- CustomerEmail = actorkatiesweeney@gmail.com (literal gmail.com, NOT gmaio.com) -> H1 refuted
- status = Completed, BaseProductLabel = "The Actor's Office", BaseProductID 24201, InvoiceID PK-PE7KZMNVRW
  -> real ThriveCart order, not Manual -> H2/H4 refuted
- customerid = NULL, userid = NULL (normal for real webhook rows since 2026-04; see setup regression memory)
- timestamp 2026-09-01 17:36:19; IsDeleted 0; no thrivecart_cancel row; no duplicate rows for the email

taousers_tbl / taousers (identical row in both -> present in the view, IsDeleted=0)
- userID 1108, userEmail actorkatiesweeney@gmail.com, userstatus Active, customerid 3905 (= thrivecart PK, correct convention)
- setup_step 7, setup_completed_at 2026-09-03 11:28:49, contactid 156388 (own contact created 11:20:27)
- passwordHash set, userPassword NULL (new-flow norm), is_setup_test 0
- isSetup 0 and tzid '0' match every other new-flow account (104/105 of userID>=1000 have isSetup=0; all Sept real buyers have tzid '0')
- viewtypeid 2 (gallery view; 5 of 105 recent users)

## Provisioning (H3) - COMPLETE

16 lookup tables: 479 user rows total, matches expected 479 exactly. All 16 status OK
(exact tables equal master; derived tables itemcatxref_user 41, pgpanels_user 10, sitelinks_user_tbl 62 non-zero).
Master expected: dialects 32, genres 95, networks 108, opencall 2, platforms 3, tones 6, eventtypes 8,
pronouns 3, itemtypes 59, tags 29, sitetypes 6, audquestions 5, submitsites 10 (+ derived).
Other footprint: contactdetails 2 (self + "Ofelia Habelt" added 11:26:06), audprojects 0, fusystemusers 0, actionusers 0
(actionusers 0 is the norm for every account since 1094 except 1093/1103).

## Actual error she hit

error_tickets id 489 ERR-157571C8 at 2026-09-03 11:33:06, user_id 1108, iPhone Safari, GET /include/export_auditions.cfm,
referer /app/auditions/?...&view=glry. tag_context: GenreAuditionService.cfc:7 CFTHROW <- include/qry/export_ac_31_6.cfm:3
<- include/export_auditions.cfm:2. The throw is "Project list cannot be empty": include/auditions.cfm:41-44 copies
projectlist into session.projectlist and redirects to the export; with zero auditions the list is empty and the service
throws unconditionally. Same ticket signature for Isabella Miranda (userid 1102, 3x on 2026-08-27, also a brand-new
account) and Bill Gunnin (930, 2026-08-10). Not a setup defect; a pre-existing export-with-no-rows bug.

## Side findings (register, no action taken)

1. tzid written as literal '0' by the current setup flow (22 users total, every real buyer since ~Aug 26). Legacy accounts
   hold IANA ids (America/Los_Angeles 939). Any timezone-dependent rendering for these users is suspect.
2. Table `loggins` (id,u,p,logged,REMOTE_ADDR,HTTP_USER_AGENT) stores what appear to be plaintext login attempts incl.
   password strings; last row 2026-07-11 (bingbot). Retire/purge candidate (WO-12 security backlog). Values not reproduced here.
3. Other Sept-1..3 tickets unrelated: importv3 parse.cfm POI NoSuchMethodError (ERR-2035FF82, user 142, contacts-import-v3 job 54),
   NoteService.cfc:115 x3 (user 1054), sched/events_completed.cfm:287 CFQUERY nightly x3 (CFSCHEDULE, unattributed).
