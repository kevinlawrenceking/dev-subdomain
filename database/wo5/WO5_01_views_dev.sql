-- ============================================================================
-- DIR-LNK-WO-5 -- DEV VIEW READ CUTOVER (new_development ONLY). Operator-executed (HeidiSQL).
-- Repoints single-value Company/Phone/Email display from contactitems subqueries
-- to the contactdetails primary columns. SQL SECURITY INVOKER (RQ-6a/PC-4), no
-- schema qualifiers (bleed doctrine), CREATE OR REPLACE (idempotent).
-- PRECONDITION: run WO4_30 addendum FIRST (nulls the 64 exception-class residue),
-- else contacts_ss shows the V3_10 residue value for those 64 post-cutover.
-- Family views (contacts_ss_target/_followup/_maint) select FROM contacts_ss and
-- inherit col3/4/5 -- they are intentionally NOT redefined here. Prod = WO-12.
-- Bodies below are the P1 live capture with ONLY the p/e/c source swapped;
-- everything else (tags/col2*, joins, ordering) is byte-preserved from the capture.
-- ============================================================================
USE new_development;

-- ---- contacts_ss ----
CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY INVOKER VIEW `contacts_ss` AS select `d`.`contactID` AS `contactid`,concat('<input type="checkbox" class="form-check-input" id="C',`d`.`contactID`,'" name="batchlist" value="',`d`.`contactID`,'">') AS `contactcheck`,concat('<img src="/mediaroot/users/',`d`.`userID`,'/contacts/',`d`.`contactID`,'/avatar.jpg?ver=',`d`.`contactID`,'" class="mr-3  rounded-circle gambar img-responsive img-thumbnail"  alt="profile-image" id="item-img-output">') AS `avatar`,concat('<a href="/app/contact/?contactid=',`d`.`contactID`,'" >',`d`.`contactFullName`,'</a>') AS `hlink`,`d`.`contactFullName` AS `col1`,`d`.`contactID` AS `recid`,(select group_concat(concat('<span class=\'badge badge-blue\'>',`contactitems`.`valueText`,'</span>') order by `contactitems`.`valueText` ASC separator ' ') from `contactitems` where ((`contactitems`.`valueCategory` = 'Tag') and (`contactitems`.`contactID` = `d`.`contactID`) and (`contactitems`.`itemStatus` = 'Active')) limit 1) AS `col2`,concat(substring_index((select group_concat(concat('<span class=\'badge badge-blue\'>',`contactitems`.`valueText`,'</span>') order by `contactitems`.`valueText` ASC separator '&nbsp; ') from `contactitems` where ((`contactitems`.`valueCategory` = 'Tag') and (`contactitems`.`contactID` = `d`.`contactID`) and (`contactitems`.`itemStatus` = 'Active'))),'&nbsp;',2),convert(convert((case when (((select count(0) from `contactitems` where ((`contactitems`.`valueCategory` = 'Tag') and (`contactitems`.`contactID` = `d`.`contactID`) and (`contactitems`.`itemStatus` = 'Active'))) - 2) > 0) then concat(' +',((select count(0) from `contactitems` where ((`contactitems`.`valueCategory` = 'Tag') and (`contactitems`.`contactID` = `d`.`contactID`) and (`contactitems`.`itemStatus` = 'Active'))) - 2)) else NULL end) using utf8mb3) using utf8mb4)) AS `col2e`,concat(coalesce(substring_index((select group_concat(concat('<span class=\'badge badge-blue\'>',`contactitems`.`valueText`,'</span>') order by `contactitems`.`valueText` ASC separator '&nbsp; ') from `contactitems` where ((`contactitems`.`valueCategory` = 'Tag') and (`contactitems`.`contactID` = `d`.`contactID`) and (`contactitems`.`itemStatus` = 'Active'))),'&nbsp;',2),''),convert(convert(coalesce((case when (((select count(0) from `contactitems` where ((`contactitems`.`valueCategory` = 'Tag') and (`contactitems`.`contactID` = `d`.`contactID`) and (`contactitems`.`itemStatus` = 'Active'))) - 2) > 0) then concat(' +',((select count(0) from `contactitems` where ((`contactitems`.`valueCategory` = 'Tag') and (`contactitems`.`contactID` = `d`.`contactID`) and (`contactitems`.`itemStatus` = 'Active'))) - 2)) else NULL end),'') using utf8mb3) using utf8mb4)) AS `col2b`,`d`.`contactPhone` AS `col3`,`d`.`contactEmail` AS `col4`,`d`.`contactCompany` AS `col5`,`d`.`userID` AS `userid` from `contactdetails` `d` where (`d`.`contactStatus` = 'Active');

-- ---- sharez ----
CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY INVOKER VIEW `sharez` AS select `cd`.`contactID` AS `contactid`,`cd`.`recordname` AS `NAME`,`cd`.`contactMeetingLoc` AS `WhereMet`,`cd`.`contactMeetingDate` AS `WhenMet`,`cd`.`userID` AS `userid`,left(`tu`.`passwordHash`,10) AS `userHash`,`cd`.`contactCompany` AS `Company`,(select `ci`.`valuetext` from `contactitems_tbl` `ci` where ((`ci`.`contactID` = `cd`.`contactID`) and (`ci`.`valueCategory` = 'Tag') and (`ci`.`itemStatus` = 'Active') and (`ci`.`IsDeleted` = 0)) limit 1) AS `Title`,(select `s`.`audstep` from ((`audcontacts_auditions_xref` `x` join `events_tbl` `e` on(((`e`.`audRoleID` is not null) and (`e`.`IsDeleted` = 0)))) join `audsteps` `s` on((`s`.`audstepid` = `e`.`audStepID`))) where (`x`.`contactid` = `cd`.`contactID`) order by `s`.`audstepid` desc limit 1) AS `Audition`,(select count(0) from `eventcontactsxref_tbl` `ecx` where ((`ecx`.`contactID` = `cd`.`contactID`) and (`ecx`.`IsDeleted` = 0))) AS `no_mtgs`,(select `e`.`eventStart` from (`eventcontactsxref_tbl` `ecx` join `events_tbl` `e` on(((`e`.`eventID` = `ecx`.`eventID`) and (`e`.`IsDeleted` = 0)))) where ((`ecx`.`contactID` = `cd`.`contactID`) and (`ecx`.`IsDeleted` = 0)) order by `e`.`eventStart` desc limit 1) AS `last_met`,(select `e`.`eventTypeName` from (`eventcontactsxref_tbl` `ecx` join `events_tbl` `e` on(((`e`.`eventID` = `ecx`.`eventID`) and (`e`.`IsDeleted` = 0)))) where ((`ecx`.`contactID` = `cd`.`contactID`) and (`ecx`.`IsDeleted` = 0)) order by `e`.`eventStart` desc limit 1) AS `lasteventtype`,NULL AS `NotesLog` from ((`contactdetails_tbl` `cd` join `taousers_tbl` `tu` on(((`tu`.`userID` = `cd`.`userID`) and (`tu`.`IsDeleted` = 0)))) join `fusystemusers_tbl` `fsu` on(((`fsu`.`contactID` = `cd`.`contactID`) and (`fsu`.`userid` = `cd`.`userID`) and (`fsu`.`sustatus` = 'Active') and (`fsu`.`systemID` in (1,2,3,4)) and (`fsu`.`IsDeleted` = 0)))) where (`cd`.`IsDeleted` = 0);

-- ---- sharezz ----
CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY INVOKER VIEW `sharezz` AS select `cd`.`contactID` AS `contactid`,`cd`.`recordname` AS `NAME`,`cd`.`contactMeetingLoc` AS `WhereMet`,`cd`.`contactMeetingDate` AS `WhenMet`,`cd`.`userID` AS `userid`,left(`tu`.`passwordHash`,10) AS `userHash`,`cd`.`contactCompany` AS `Company`,(select `ci`.`valuetext` from (`contactitems_tbl` `ci` left join `tags` `t` on((`t`.`tagname` = `ci`.`valuetext`))) where ((`ci`.`contactID` = `cd`.`contactID`) and (`ci`.`valueCategory` = 'Tag') and (`ci`.`itemStatus` = 'Active') and (`ci`.`IsDeleted` = 0)) order by (case when ((`t`.`tagPriority` is null) or (`t`.`tagPriority` = 999)) then 1 else 0 end),`t`.`tagPriority`,`ci`.`valuetext` limit 1) AS `Title`,(select `s`.`audstep` from ((`audcontacts_auditions_xref` `x` join `events_tbl` `e` on(((`e`.`audRoleID` is not null) and (`e`.`IsDeleted` = 0)))) join `audsteps` `s` on((`s`.`audstepid` = `e`.`audStepID`))) where (`x`.`contactid` = `cd`.`contactID`) order by `s`.`audstepid` desc limit 1) AS `Audition`,(select count(0) from `eventcontactsxref_tbl` `ecx` where ((`ecx`.`contactID` = `cd`.`contactID`) and (`ecx`.`IsDeleted` = 0))) AS `no_mtgs`,(select `e`.`eventStart` from (`eventcontactsxref_tbl` `ecx` join `events_tbl` `e` on(((`e`.`eventID` = `ecx`.`eventID`) and (`e`.`IsDeleted` = 0)))) where ((`ecx`.`contactID` = `cd`.`contactID`) and (`ecx`.`IsDeleted` = 0)) order by `e`.`eventStart` desc limit 1) AS `last_met`,(select `e`.`eventTypeName` from (`eventcontactsxref_tbl` `ecx` join `events_tbl` `e` on(((`e`.`eventID` = `ecx`.`eventID`) and (`e`.`IsDeleted` = 0)))) where ((`ecx`.`contactID` = `cd`.`contactID`) and (`ecx`.`IsDeleted` = 0)) order by `e`.`eventStart` desc limit 1) AS `lasteventtype`,NULL AS `NotesLog` from ((`contactdetails_tbl` `cd` join `taousers_tbl` `tu` on(((`tu`.`userID` = `cd`.`userID`) and (`tu`.`IsDeleted` = 0)))) join `fusystemusers_tbl` `fsu` on(((`fsu`.`contactID` = `cd`.`contactID`) and (`fsu`.`userid` = `cd`.`userID`) and (`fsu`.`sustatus` = 'Active') and (`fsu`.`systemID` in (1,2,3,4)) and (`fsu`.`IsDeleted` = 0)))) where (`cd`.`IsDeleted` = 0);

-- ---- sharez_optimized ----
CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY INVOKER VIEW `sharez_optimized` AS
select `d`.`contactID` AS `contactid`,`d`.`recordname` AS `NAME`,`d`.`contactCompany` AS `Company`,
`ci_tag`.`valueText` AS `Title`,`mx`.`audstep` AS `Audition`,`d`.`contactMeetingLoc` AS `WhereMet`,
`d`.`contactMeetingDate` AS `WhenMet`,NULL AS `NotesLog`,`u`.`userID` AS `userid`,
left(`u`.`passwordHash`,10) AS `userHash`,`le`.`eventStart` AS `last_met`,ifnull(`mc`.`no_mtgs`,0) AS `no_mtgs`,
`le`.`eventTypeName` AS `lasteventtype`
from ((((((`contactdetails` `d`
 join `taousers` `u` on((`u`.`userID` = `d`.`userID`)))
 join `fusystemusers` `su` on(((`su`.`contactID` = `d`.`contactID`) and (`su`.`userid` = `d`.`userID`) and (`su`.`suStatus` = 'Active') and (`su`.`systemID` in (1,2,3,4)))))
 left join `maxaudition` `mx` on((`mx`.`contactid` = `d`.`contactID`)))
 left join `contactitems` `ci_tag` on(((`ci_tag`.`contactID` = `d`.`contactID`) and (`ci_tag`.`valueCategory` = 'Tag') and (`ci_tag`.`itemStatus` = 'Active'))))
 left join `cache_contact_meeting_counts` `mc` on((`mc`.`contactID` = `d`.`contactID`)))
 left join `cache_contact_last_event` `le` on((`le`.`contactID` = `d`.`contactID`)));

-- ---- v_contacts_optimized ----
CREATE OR REPLACE ALGORITHM=UNDEFINED SQL SECURITY INVOKER VIEW `v_contacts_optimized` AS
with `base` as (select `cd`.`contactID` AS `contactID`,`cd`.`recordname` AS `NAME`,`cd`.`contactMeetingLoc` AS `WhereMet`,
  `cd`.`contactMeetingDate` AS `WhenMet`,`cd`.`userID` AS `userID`,`cd`.`contactCompany` AS `contactCompany`,
  `tu`.`passwordHash` AS `passwordHash`
  from (`contactdetails_tbl` `cd` join `taousers_tbl` `tu` on(((`tu`.`userID` = `cd`.`userID`) and (`tu`.`IsDeleted` = 0)))) where (`cd`.`IsDeleted` = 0)),
 `active_fsu` as (select distinct `fsu`.`contactID` AS `contactID`,`fsu`.`userid` AS `userID` from `fusystemusers_tbl` `fsu`
  where ((`fsu`.`sustatus` = 'Active') and (`fsu`.`systemID` in (1,2,3,4)) and (`fsu`.`IsDeleted` = 0))),
 `title_pick` as (select `ci`.`contactID` AS `contactID`,`ci`.`valuetext` AS `valueText`,
  row_number() OVER (PARTITION BY `ci`.`contactID` ORDER BY (case when ((`t`.`tagPriority` is null) or (`t`.`tagPriority` = 999)) then 1 else 0 end),`t`.`tagPriority`,`ci`.`valuetext` ) AS `rn`
  from (`contactitems_tbl` `ci` left join `tags` `t` on((`t`.`tagname` = `ci`.`valuetext`)))
  where ((`ci`.`valueCategory` = 'Tag') and (`ci`.`itemStatus` = 'Active') and (`ci`.`IsDeleted` = 0) and (`ci`.`valuetext` is not null))),
 `audition_pick` as (select `ecx`.`contactID` AS `contactID`,`s`.`audstep` AS `audstep`,
  row_number() OVER (PARTITION BY `ecx`.`contactID` ORDER BY `s`.`audstepid` desc,`e`.`eventStart` desc ) AS `rn`
  from ((`eventcontactsxref_tbl` `ecx` join `events_tbl` `e` on(((`e`.`eventID` = `ecx`.`eventID`) and (`e`.`IsDeleted` = 0) and (`e`.`audRoleID` is not null)))) join `audsteps` `s` on((`s`.`audstepid` = `e`.`audStepID`))) where (`ecx`.`IsDeleted` = 0)),
 `meet_counts` as (select `ecx`.`contactID` AS `contactID`,count(0) AS `no_mtgs` from `eventcontactsxref_tbl` `ecx` where (`ecx`.`IsDeleted` = 0) group by `ecx`.`contactID`),
 `last_event` as (select `ecx`.`contactID` AS `contactID`,`e`.`eventStart` AS `eventStart`,`e`.`eventTypeName` AS `eventTypeName`,
  row_number() OVER (PARTITION BY `ecx`.`contactID` ORDER BY `e`.`eventStart` desc ) AS `rn`
  from (`eventcontactsxref_tbl` `ecx` join `events_tbl` `e` on(((`e`.`eventID` = `ecx`.`eventID`) and (`e`.`IsDeleted` = 0)))) where (`ecx`.`IsDeleted` = 0))
select `b`.`contactID` AS `contactid`,`b`.`NAME` AS `NAME`,`b`.`WhereMet` AS `WhereMet`,`b`.`WhenMet` AS `WhenMet`,
 `b`.`userID` AS `userid`,left(`b`.`passwordHash`,10) AS `userHash`,`b`.`contactCompany` AS `Company`,`t`.`valueText` AS `Title`,
 `a`.`audstep` AS `Audition`,coalesce(`m`.`no_mtgs`,0) AS `no_mtgs`,`le`.`eventStart` AS `last_met`,`le`.`eventTypeName` AS `lasteventtype`,NULL AS `NotesLog`
from (((((`base` `b`
 join `active_fsu` `f` on(((`f`.`contactID` = `b`.`contactID`) and (`f`.`userID` = `b`.`userID`))))
 left join `title_pick` `t` on(((`t`.`contactID` = `b`.`contactID`) and (`t`.`rn` = 1))))
 left join `audition_pick` `a` on(((`a`.`contactID` = `b`.`contactID`) and (`a`.`rn` = 1))))
 left join `meet_counts` `m` on((`m`.`contactID` = `b`.`contactID`)))
 left join `last_event` `le` on(((`le`.`contactID` = `b`.`contactID`) and (`le`.`rn` = 1))));

