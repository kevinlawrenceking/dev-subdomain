# Phase 2: Call Graph Analysis -- Raw Data

Generated: 2026-03-16
Scope: All .cfm and .cfc files, excluding dev_backup/

---

## 2A -- Service Function Callers

### 2A.1 -- variables.{Service}.{method}() calls (122 matches)

These are direct method calls on service objects stored in the `variables` scope.
Found in import subsystems (v3, audition) and ContactImportV2Service internal wiring.

| Calling File | Service Name | Function Called |
|---|---|---|
| ajax/import-auditions/columns.cfm:89 | auditionService | getJobForUser |
| ajax/import-auditions/columns.cfm:389 | auditionService | setJobStatus |
| ajax/import-auditions/columns.cfm:395 | auditionService | logEvent |
| ajax/import-auditions/columns.cfm:492 | auditionService | getJobForUser |
| ajax/import-auditions/columns.cfm:524 | auditionService | logEvent |
| ajax/import-auditions/fact_update.cfm:189 | auditionService | getJobForUser |
| ajax/import-auditions/fact_update.cfm:216 | auditionService | updateRowFacts |
| ajax/import-auditions/fact_update.cfm:249 | auditionService | logEvent |
| ajax/import-auditions/finalize.cfm:202 | auditionService | getJobForUser |
| ajax/import-auditions/finalize.cfm:230 | auditionService | finalizeJob |
| ajax/import-auditions/finalize.cfm:265 | auditionService | logEvent |
| ajax/import-auditions/parse.cfm:106 | importService | getJobForUser |
| ajax/import-auditions/parse.cfm:157 | importService | logEvent |
| ajax/import-auditions/parse.cfm:183 | importService | acquireJobLock |
| ajax/import-auditions/parse.cfm:196 | importService | setJobStatus |
| ajax/import-auditions/parse.cfm:197 | importService | logEvent |
| ajax/import-auditions/parse.cfm:209 | importService | setJobStatus |
| ajax/import-auditions/parse.cfm:210 | importService | logEvent |
| ajax/import-auditions/parse.cfm:291 | importService | setJobStatus |
| ajax/import-auditions/parse.cfm:292 | importService | logEvent |
| ajax/import-auditions/parse.cfm:448 | importService | setJobStatus |
| ajax/import-auditions/parse.cfm:451 | importService | logEvent |
| ajax/import-auditions/parse.cfm:500 | importService | setJobStatus |
| ajax/import-auditions/parse.cfm:501 | importService | logEvent |
| ajax/import-auditions/recompute.cfm:315 | dupeService | isDupeDetectionAvailable |
| ajax/import-auditions/recompute.cfm:334 | dupeService | buildUserDupeIndex |
| ajax/import-auditions/recompute.cfm:379 | audService | getJobForUser |
| ajax/import-auditions/recompute.cfm:446 | audService | logEvent |
| ajax/import-auditions/recompute.cfm:459 | audService | logEvent |
| ajax/import-auditions/recompute.cfm:475 | audService | logEvent |
| ajax/import-auditions/recompute.cfm:862 | dupeService | findDuplicates |
| ajax/import-auditions/recompute.cfm:1002 | audService | setJobStatus |
| ajax/import-auditions/recompute.cfm:1005 | audService | logEvent |
| ajax/import-auditions/recompute.cfm:1021 | audService | logEvent |
| ajax/import-auditions/recompute.cfm:1038 | audService | getJobForUser |
| ajax/import-auditions/recompute.cfm:1098 | audService | logEvent |
| ajax/import-auditions/row.cfm:88 | auditionService | getJobForUser |
| ajax/import-auditions/row.cfm:114 | auditionService | getRowDetail |
| ajax/import-auditions/row.cfm:144 | auditionService | logEvent |
| ajax/import-auditions/rows.cfm:107 | auditionService | getJobForUser |
| ajax/import-auditions/rows.cfm:134 | auditionService | getJobStats |
| ajax/import-auditions/rows.cfm:149 | auditionService | getRows |
| ajax/import-auditions/rows.cfm:178 | auditionService | logEvent |
| ajax/import-auditions/row_action.cfm:242 | auditionService | getJobForUser |
| ajax/import-auditions/row_action.cfm:273 | auditionService | bulkRowAction |
| ajax/import-auditions/row_action.cfm:281 | auditionService | setRowAction |
| ajax/import-auditions/row_action.cfm:317 | auditionService | logEvent |
| ajax/import-auditions/status.cfm:190 | auditionService | getJobForUser |
| ajax/import-auditions/status.cfm:257 | auditionService | logEvent |
| ajax/import-auditions/status.cfm:272 | auditionService | logEvent |
| ajax/import-auditions/status.cfm:301 | auditionService | logEvent |
| ajax/import-auditions/upload.cfm:144 | importService | logEvent |
| ajax/import-auditions/upload.cfm:194 | importService | logEvent |
| ajax/importv3/columns.cfm:89 | v3Service | getJobForUser |
| ajax/importv3/columns.cfm:401 | v3Service | setJobStatus |
| ajax/importv3/columns.cfm:407 | v3Service | logEvent |
| ajax/importv3/columns.cfm:504 | v3Service | getJobForUser |
| ajax/importv3/columns.cfm:536 | v3Service | logEvent |
| ajax/importv3/fact_update.cfm:194 | v3Service | getJobForUser |
| ajax/importv3/fact_update.cfm:221 | v3Service | updateRowFacts |
| ajax/importv3/fact_update.cfm:255 | v3Service | logEvent |
| ajax/importv3/finalize.cfm:222 | v3Service | getJobForUser |
| ajax/importv3/finalize.cfm:250 | v3Service | finalizeJob |
| ajax/importv3/finalize.cfm:285 | v3Service | logEvent |
| ajax/importv3/parse.cfm:106 | v3Service | getJobForUser |
| ajax/importv3/parse.cfm:149 | v3Service | logEvent |
| ajax/importv3/parse.cfm:177 | v3Service | acquireJobLock |
| ajax/importv3/parse.cfm:190 | v3Service | setJobStatus |
| ajax/importv3/parse.cfm:191 | v3Service | logEvent |
| ajax/importv3/parse.cfm:203 | v3Service | setJobStatus |
| ajax/importv3/parse.cfm:204 | v3Service | logEvent |
| ajax/importv3/parse.cfm:413 | v3Service | setJobStatus |
| ajax/importv3/parse.cfm:414 | v3Service | logEvent |
| ajax/importv3/parse.cfm:573 | v3Service | logEvent |
| ajax/importv3/parse.cfm:599 | v3Service | setJobStatus |
| ajax/importv3/parse.cfm:602 | v3Service | logEvent |
| ajax/importv3/parse.cfm:652 | v3Service | setJobStatus |
| ajax/importv3/parse.cfm:653 | v3Service | logEvent |
| ajax/importv3/recompute.cfm:328 | dupeService | isDupeDetectionAvailable |
| ajax/importv3/recompute.cfm:352 | dupeService | buildUserDupeIndex |
| ajax/importv3/recompute.cfm:402 | v3Service | getJobForUser |
| ajax/importv3/recompute.cfm:499 | v3Service | logEvent |
| ajax/importv3/recompute.cfm:512 | v3Service | logEvent |
| ajax/importv3/recompute.cfm:528 | v3Service | logEvent |
| ajax/importv3/recompute.cfm:716 | validationService | validateEmail |
| ajax/importv3/recompute.cfm:730 | validationService | validatePhone |
| ajax/importv3/recompute.cfm:741 | validationService | validateDate |
| ajax/importv3/recompute.cfm:752 | validationService | validateURL |
| ajax/importv3/recompute.cfm:766 | validationService | validateString |
| ajax/importv3/recompute.cfm:774 | validationService | validateString |
| ajax/importv3/recompute.cfm:905 | dupeService | findDuplicatesWithIndex |
| ajax/importv3/recompute.cfm:1037 | dupeService | getCandidateDetailsBatch |
| ajax/importv3/recompute.cfm:1063 | dupeService | findDuplicatesWithIndex |
| ajax/importv3/recompute.cfm:1150 | v3Service | setJobStatus |
| ajax/importv3/recompute.cfm:1153 | v3Service | logEvent |
| ajax/importv3/recompute.cfm:1169 | v3Service | logEvent |
| ajax/importv3/recompute.cfm:1186 | v3Service | getJobForUser |
| ajax/importv3/recompute.cfm:1252 | v3Service | logEvent |
| ajax/importv3/row.cfm:88 | v3Service | getJobForUser |
| ajax/importv3/row.cfm:114 | v3Service | getRowDetail |
| ajax/importv3/row.cfm:144 | v3Service | logEvent |
| ajax/importv3/rows.cfm:106 | v3Service | getJobForUser |
| ajax/importv3/rows.cfm:133 | v3Service | getJobStats |
| ajax/importv3/rows.cfm:148 | v3Service | getRows |
| ajax/importv3/rows.cfm:177 | v3Service | logEvent |
| ajax/importv3/row_action.cfm:242 | v3Service | getJobForUser |
| ajax/importv3/row_action.cfm:273 | v3Service | bulkRowAction |
| ajax/importv3/row_action.cfm:281 | v3Service | setRowAction |
| ajax/importv3/row_action.cfm:317 | v3Service | logEvent |
| ajax/importv3/status.cfm:194 | v3Service | getJobForUser |
| ajax/importv3/status.cfm:268 | v3Service | logEvent |
| ajax/importv3/status.cfm:283 | v3Service | logEvent |
| ajax/importv3/status.cfm:314 | v3Service | logEvent |
| ajax/importv3/upload.cfm:152 | v3Service | logEvent |
| ajax/importv3/upload.cfm:203 | v3Service | logEvent |
| services/ContactImportV2Service.cfc:394 | fileParserService | parseFile |
| services/ContactImportV2Service.cfc:630 | validationService | validateRow |
| services/ContactImportV2Service.cfc:633 | duplicateMatcherService | findDuplicates |
| services/ContactImportV2Service.cfc:813 | validationService | validateRow |
| services/ContactImportV2Service.cfc:816 | duplicateMatcherService | findDuplicates |
| services/ContactImportV2Service.cfc:1152 | contactService | create |
| services/ContactImportV2Service.cfc:1243 | contactService | update |

### 2A.2 -- createObject("component", "services.{Service}") instantiations (935 matches)

These lines instantiate a service CFC. Found in 139 distinct service classes.
The overwhelming majority (~800+) are inside /include/qry/ files.

| Calling File | Line | Service Instantiated |
|---|---|---|
| app/admin-relationship/index.cfm | 20 | RelationshipService |
| app/autolookup.cfm | 4 | LookupService |
| app/autolookup2.cfm | 4 | LookupService |
| app/contact-duplicates/contact-duplicates.cfm | 13 | ContactDuplicateService |
| include/auditions.cfm | 514 | PaginationService |
| include/birthdays.cfm | 85 | BirthdayService |
| include/contacts_check.cfm | 3 | SystemService |
| include/contacts_check.cfm | 10 | SystemService |
| include/contacts_table_attendees.cfm | 1 | ContactService |
| include/core_title.cfm | 12 | PageTitleService |
| include/customicon_single.cfm | 3 | SiteLinksService |
| include/dashboard_new.cfm | 22 | NotificationService |
| include/debugLog.cfm | 5 | DebugService |
| include/delete_audcontact.cfm | 7 | contactItemService |
| include/delete_team.cfm | 4 | contactItemService |
| include/fetchPageService.cfm | 2 | PageService |
| include/mantra.cfm | 2 | QuotesService |
| include/merge_contacts_interface.cfm | 14 | ContactDuplicateService |
| include/mylinks_user.cfm | 6 | SiteLinksService |
| include/qry/actiondetails_194_1.cfm | 1 | SystemService |
| include/qry/actions_159_2.cfm | 1 | SystemService |
| include/qry/action_user_295_2.cfm | 1 | SystemService |
| include/qry/action_user_del_295_3.cfm | 1 | SystemService |
| include/qry/activate_222_3.cfm | 1 | EventService |
| include/qry/addActionUsers.cfm | 1 | ActionUserService |
| include/qry/addDaysNo_157_7.cfm | 1 | SystemService |
| include/qry/addDaysNo_315_35.cfm | 1 | SystemService |
| include/qry/addDaysNo_5_2.cfm | 1 | SystemService |
| include/qry/AddExport_115_1.cfm | 1 | ExportService |
| include/qry/addfuSystemUsers.cfm | 6 | SystemUserService |
| include/qry/addMembers.cfm | 1 | ContactService |
| include/qry/addmissing_33_3.cfm | 1 | ContactAuditionService |
| include/qry/addNotification.cfm | 1 | NotificationService |
| include/qry/addNotifications.cfm | 1 | NotificationsService |
| include/qry/addNotification_157_10.cfm | 1 | NotificationService |
| include/qry/addNotification_157_9.cfm | 1 | NotificationService |
| include/qry/addNotification_315_37.cfm | 1 | NotificationService |
| include/qry/addNotification_315_38.cfm | 1 | NotificationService |
| include/qry/addNotification_326_1.cfm | 1 | NotificationService |
| include/qry/addNotification_5_4.cfm | 1 | NotificationService |
| include/qry/addNotification_71_1.cfm | 1 | NotificationService |
| include/qry/addNotification_71_3.cfm | 1 | NotificationService |
| include/qry/addNotification_72_1.cfm | 1 | NotificationService |
| include/qry/address_315_30.cfm | 1 | ContactImportService |
| include/qry/address_insert_315_31.cfm | 1 | ContactItemService |
| include/qry/addSystem.cfm | 1 | SystemUserService |
| include/qry/addSystem_157_3.cfm | 1 | SystemUserService |
| include/qry/addSystem_315_34.cfm | 1 | SystemUserService |
| include/qry/addSystem_327_1.cfm | 1 | SystemUserService |
| include/qry/addTeam.cfm | 1 | contactService |
| include/qry/add_149_1.cfm | 1 | LinkService |
| include/qry/add_14_1.cfm | 1 | EventService |
| include/qry/add_14_6.cfm | 1 | ContactService |
| include/qry/add_197_3.cfm | 1 | AuditionSubmitSiteUserService |
| include/qry/add_199_3.cfm | 1 | ContactItemService |
| include/qry/add_201_1.cfm | 1 | ContactService |
| include/qry/add_202_1.cfm | 1 | ContactService |
| include/qry/add_211_1.cfm | 1 | ContactService |
| include/qry/add_240_1.cfm | 1 | SiteTypeUserService |
| include/qry/add_242_2.cfm | 1 | SiteLinkUserService |
| include/qry/add_249_5.cfm | 1 | PanelUserService |
| include/qry/add_249_6.cfm | 1 | SiteTypeUserService |
| include/qry/add_257_1.cfm | 1 | TicketService |
| include/qry/add_270_3.cfm | 1 | GenderPronounUserService |
| include/qry/add_287_20.cfm | 1 | ContactService |
| include/qry/add_287_23.cfm | 1 | AuditionSubmitSiteUserService |
| include/qry/add_28_4.cfm | 3 | ContactService |
| include/qry/add_315_6.cfm | 1 | ContactService |
| include/qry/add_318_10.cfm | 1 | PanelUserService |
| include/qry/add_365_3.cfm | 3 | EventService |
| include/qry/add_367_4.cfm | 1 | ContactService |
| include/qry/add_82_1.cfm | 1 | ContactService |
| include/qry/add_aud_contact.cfm | 1 | ContactAuditionService |
| include/qry/add_cd_202_7.cfm | 1 | ContactAuditionService |
| include/qry/add_cd_28_12.cfm | 1 | ContactAuditionService |
| include/qry/add_cd_368_10.cfm | 1 | ContactAuditionService |
| include/qry/add_sitetype_205_1.cfm | 1 | EssenceService |
| include/qry/add_sitetype_249_2.cfm | 1 | SiteTypeUserService |
| include/qry/admin-support-details.cfm | 2 | TicketService |
| include/qry/admin-support-update.cfm | 4 | TicketService |
| include/qry/admin-support-update.cfm | 8 | ticketStatusService |
| include/qry/admin-support-update.cfm | 12 | ticketTypeService |
| include/qry/admin-support-update.cfm | 16 | ticketPriorityService |
| include/qry/admin-support-update.cfm | 20 | PageService |
| include/qry/admin-support-update.cfm | 25 | UserService |
| include/qry/admin-support-update.cfm | 29 | taoVersionService |
| include/qry/allfields_536_2.cfm | 1 | ComponentService |
| include/qry/attachdetails_109_1.cfm | 1 | AuditionMediaService |
| include/qry/attachdetails_25_1.cfm | 1 | AttachmentService |
| include/qry/attachments_181_2.cfm | 1 | AttachmentService |
| include/qry/attendees_334_5.cfm | 1 | EventContactsXRefService |
| include/qry/attendees_336_5.cfm | 1 | EventContactsXRefService |
| include/qry/audageranges_audtion_xref_368_11.cfm | 1 | AuditionAgeRangeService |
| include/qry/audageranges_audtion_xref_ins_337_1.cfm | 1 | AuditionAgeRangeXRefService |
| include/qry/audageranges_audtion_xref_ins_338_1.cfm | 1 | AuditionAgeRangeXRefService |
| include/qry/audageranges_ins_339_1.cfm | 1 | AuditionAgeRangeService |
| include/qry/audageranges_ins_341_1.cfm | 1 | AuditionAgeRangeService |
| include/qry/audbooktypes_sel_221_13.cfm | 1 | AuditionBookTypeService |
| include/qry/audcallbacktypes_sel_344_1.cfm | 1 | AuditionCallbackTypeService |
| include/qry/audcallbacktypes_sel_def_344_2.cfm | 1 | AuditionCallbackTypeService |
| include/qry/audcategories_ins_345_1.cfm | 1 | AuditionCategoryService |
| include/qry/audcategories_ins_347_1.cfm | 1 | AuditionCategoryService |
| include/qry/audcontacts_auditions_xref_ins_350_1.cfm | 1 | ContactAuditionService |
| include/qry/audcontacts_auditions_xref_ins_351_1.cfm | 1 | ContactAuditionService |
| include/qry/audcontacts_sel_349_2.cfm | 1 | ContactService |
| include/qry/auddialects_ins_355_1.cfm | 1 | AuditionDialectService |
| include/qry/auddialects_user_sel_358_1.cfm | 3 | AuditionDialectsUserService |
| include/qry/audessences_audtion_xref_49_1.cfm | 1 | EssenceService |
| include/qry/audgenres_audition_xref_359_1.cfm | 1 | AuditionGenreUserService |
| include/qry/audgenres_audition_xref_ins_360_1.cfm | 1 | GenreAuditionService |
| include/qry/audgenres_audition_xref_ins_361_1.cfm | 1 | GenreAuditionService |
| include/qry/audgenres_ins_362_1.cfm | 1 | AuditionGenreService |
| include/qry/audition.cfm | 81 | EventContactsXRefService |
| include/qry/auditionDetails_222_5.cfm | 1 | AuditionProjectService |
| include/qry/auditionDetails_29_3.cfm | 1 | AuditionProjectService |
| include/qry/auditionDetails_369_1.cfm | 1 | AuditionProjectService |
| include/qry/auditionprojectDetails_370_1.cfm | 1 | AuditionProjectService |
| include/qry/auditionprojectDetails_66_1.cfm | 1 | AuditionProjectService |
| include/qry/auditions_import.cfm | 1 | AuditionImportService |
| include/qry/auditions_ins_221_8.cfm | 1 | EventService |
| include/qry/auditions_ins_32_1.cfm | 1 | EventService |
| include/qry/auditions_ins_373_1.cfm | 1 | EventService |
| include/qry/auditions_ins_374_1.cfm | 1 | EventService |
| include/qry/audlink_details_237_1.cfm | 1 | AuditionLinkService |
| include/qry/audlocations_ins_218_1.cfm | 1 | AuditionLocationService |
| include/qry/audlocations_sel_376_1.cfm | 1 | AuditionLocationService |
| include/qry/audmediatypes_ins_378_1.cfm | 1 | AuditionMediaTypeService |
| include/qry/audmediatypes_ins_380_1.cfm | 1 | AuditionMediaTypeService |
| include/qry/audmedia_377_1.cfm | 1 | AuditionMediaService |
| include/qry/audmedia_384_1.cfm | 1 | AuditionMediaService |
| include/qry/audmedia_38_1.cfm | 1 | AuditionMediaService |
| include/qry/audmedia_audroles_xref_ins_382_1.cfm | 1 | AuditionMediaAudRolesXRefService |
| include/qry/audmedia_details_226_1.cfm | 1 | AuditionMediaService |
| include/qry/audmedia_details_238_1.cfm | 1 | AuditionLinkService |
| include/qry/audmedia_headshots_delete.cfm | 1 | AuditionMediaXRefService |
| include/qry/audmedia_ins_383_1.cfm | 1 | AuditionMediaService |
| include/qry/audmedia_picklist_385_1.cfm | 1 | AuditionMediaService |
| include/qry/audmedia_upd_386_1.cfm | 1 | AuditionMediaService |
| include/qry/audnetworks_ins_387_1.cfm | 1 | AuditionNetworkService |
| include/qry/audnetworks_ins_389_1.cfm | 1 | AuditionNetworkService |
| include/qry/audpaycycles_sel_391_1.cfm | 1 | AuditionPayCycleService |
| include/qry/audpaycyles_sel_392_1.cfm | 1 | AuditionPayCycleService |
| include/qry/audplatforms_ins_393_1.cfm | 1 | AuditionPlatformsService |
| include/qry/audplatforms_ins_395_1.cfm | 1 | AuditionPlatformsService |
| include/qry/Audplatforms_user_sel_396_1.cfm | 1 | AuditionPlatformUserService |
| include/qry/audprojects_castingabout_ins_397_1.cfm | 1 | AuditionProjectsCastingAboutService |
| include/qry/audprojects_ins_308_19.cfm | 1 | AuditionProjectService |
| include/qry/audprojects_ins_399_1.cfm | 1 | AuditionProjectService |
| include/qry/audprojects_ins_401_1.cfm | 1 | AuditionProjectService |
| include/qry/audprojects_ins_67_1.cfm | 1 | AuditionProjectService |
| include/qry/audqtypes_ins_402_1.cfm | 1 | AuditionQuestionTypeService |
| include/qry/audqtypes_ins_404_1.cfm | 1 | AuditionQuestionTypeService |
| include/qry/audquestions_default_ins_406_1.cfm | 1 | AuditionQuestionsDefaultService |
| include/qry/audquestions_user_ins_407_1.cfm | 1 | AuditionQuestionUserService |
| include/qry/audquestions_user_ins_408_1.cfm | 1 | AuditionQuestionUserService |
| include/qry/audroles_ins_308_21.cfm | 1 | AuditionRoleService |
| include/qry/audroles_ins_39_1.cfm | 1 | AuditionRoleService |
| include/qry/audroles_ins_409_1.cfm | 1 | AuditionRoleService |
| include/qry/audroles_upd_287_25.cfm | 1 | AuditionRoleService |
| include/qry/audroletypes_ins_412_1.cfm | 1 | AuditionRoleTypeService |
| include/qry/audroletypes_ins_414_1.cfm | 1 | AuditionRoleTypeService |
| include/qry/audroletypes_sel_27_2.cfm | 1 | AuditionRoleTypeService |
| include/qry/audsources_281_1.cfm | 1 | AuditionSourceService |
| include/qry/audsources_ins_415_1.cfm | 1 | AuditionSourceService |
| include/qry/audsources_ins_417_1.cfm | 1 | AuditionSourceService |
| include/qry/audsources_sel_499_2.cfm | 1 | AuditionSourceService |
| include/qry/audsteps_ins_418_1.cfm | 1 | AuditionStepService |
| include/qry/audsteps_ins_420_1.cfm | 1 | AuditionStepService |
| include/qry/audsteps_sel_217_3.cfm | 1 | AuditionStepService |
| include/qry/audsteps_sel_31_2.cfm | 1 | AuditionStepService |
| include/qry/audsubcategories_ins_423_1.cfm | 1 | AuditionSubcategorieService |
| include/qry/audtones_ins_425_1.cfm | 1 | AuditionTonesService |
| include/qry/audtones_ins_427_1.cfm | 1 | AuditionTonesService |
| include/qry/audtones_user_sel_428_1.cfm | 1 | AuditionToneUserService |
| include/qry/audtypes_ins_429_1.cfm | 1 | AuditionTypeService |
| include/qry/audtypes_ins_431_1.cfm | 1 | AuditionTypeService |
| include/qry/audtypes_sel_217_2.cfm | 1 | AuditionTypeService |
| include/qry/audtypes_sel_221_11.cfm | 1 | AuditionTypeService |
| include/qry/audtypes_sel_27_3.cfm | 1 | AuditionTypeService |
| include/qry/audtypes_sel_31_3.cfm | 1 | AuditionTypeService |
| include/qry/audtypes_sel_430_1.cfm | 1 | AuditionTypeService |
| include/qry/audunions_ins_432_1.cfm | 1 | AuditionUnionService |
| include/qry/audunions_ins_434_1.cfm | 1 | AuditionUnionService |
| include/qry/audunions_sel_40_1.cfm | 1 | AuditionUnionService |
| include/qry/audvocaltypes_audition_xref.cfm | 2 | AuditionVocalTypeXrefService |
| include/qry/audvocaltypes_audition_xref_ins_436_1.cfm | 1 | AuditionVocalTypeXRefService |
| include/qry/audvocaltypes_ins_437_1.cfm | 1 | AuditionVocalTypeService |
| include/qry/audvocaltypes_ins_439_1.cfm | 1 | AuditionVocalTypeService |
| include/qry/aud_details_217_1.cfm | 1 | AuditionRoleService |
| include/qry/aud_details_219_1.cfm | 1 | AuditionRoleService |
| include/qry/aud_det_221_9.cfm | 1 | AuditionProjectService |
| include/qry/aud_det_440_1.cfm | 1 | AuditionProjectService |
| include/qry/BatchDetails_304_1.cfm | 1 | ContactService |
| include/qry/birthdays_442_1.cfm | 1 | ContactService |
| include/qry/Booked_check_29_8.cfm | 1 | EventService |
| include/qry/book_det_57_1.cfm | 1 | AuditionRoleService |
| include/qry/bro_add_53_1.cfm | 1 | BigBrotherService |
| include/qry/callback_check_29_5.cfm | 1 | EventService |
| include/qry/castingdirectors_sel_445_1.cfm | 1 | ContactItemService |
| include/qry/casting_types_27_4.cfm | 1 | TagsUserService |
| include/qry/categories_446_1.cfm | 1 | ItemCategoryService |
| include/qry/categories_524_11.cfm | 1 | AuditionCategoryService |
| include/qry/cats_529_2.cfm | 1 | AuditionCategoryService |
| include/qry/cat_27_1.cfm | 1 | AuditionCategoryService |
| include/qry/cdcheck_368_9.cfm | 1 | AuditionProjectService |
| include/qry/cds_31_4.cfm | 1 | AuditionProjectService |
| include/qry/checkformaint_71_6.cfm | 1 | SystemUserService |
| include/qry/checkUnique_157_8.cfm | 1 | ContactService |
| include/qry/checkUnique_315_36.cfm | 1 | NotificationService |
| include/qry/checkUnique_5_3.cfm | 3 | ContactService |
| include/qry/check_318_36.cfm | 1 | ItemCategoryXRefUserService |
| include/qry/cities_448_1.cfm | 1 | CityService |
| include/qry/CLEAN_169_2.cfm | 1 | NoteService |
| include/qry/close2_294_5.cfm | 1 | NotificationService |
| include/qry/close_294_4.cfm | 1 | SystemUserService |
| include/qry/companies_198_4.cfm | 1 | ContactItemService |
| include/qry/companies_203_3.cfm | 1 | ContactItemService |
| include/qry/CompleteTargetSystems_157_4.cfm | 1 | SystemUserService |
| include/qry/contacts_333_1.cfm | 1 | ContactService |
| include/qry/correct_191_10.cfm | 1 | EventContactsXRefService |
| include/qry/coss_371_1.cfm | 1 | AuditionProjectService |
| include/qry/cos_31_5.cfm | 1 | AuditionProjectService |
| include/qry/cu_83_1.cfm | 1 | ContactItemService |
| include/qry/C_318_2.cfm | 1 | ContactService |
| include/qry/C_73_2.cfm | 1 | ContactService |
| include/qry/c_83_2.cfm | 1 | ItemCategoryService |
| include/qry/dashboards_458_1.cfm | 1 | PanelUserService |
| include/qry/dashboards_459_1.cfm | 1 | PanelUserService |
| include/qry/dashboardzz_93_1.cfm | 1 | PanelUserService |
| include/qry/dataset_x_281_4.cfm | 1 | ReportItemService |
| include/qry/dd_14_4.cfm | 1 | EventService |
| include/qry/del2_230_2.cfm | 1 | EventService |
| include/qry/del2_232_5.cfm | 1 | AuditionProjectService |
| include/qry/del4_232_7.cfm | 1 | ContactAuditionService |
| include/qry/delete2_368_8.cfm | 1 | EventContactsXRefService |
| include/qry/deletelink_150_2.cfm | 1 | LinkService |
| include/qry/deletenote_103_1.cfm | 1 | NoteService |
| include/qry/DeleteNote_4_2.cfm | 1 | NoteService |
| include/qry/DeleteNote_4_4.cfm | 1 | NoteService |
| include/qry/deleteNotificationBySystem.cfm | 1 | NotificationService |
| include/qry/deletesystem_104_2.cfm | 1 | SystemUserService |
| include/qry/deleteTeam.cfm | 1 | contactItemService |
| include/qry/deleteticket_100_1.cfm | 1 | EventService |
| include/qry/deleteticket_105_1.cfm | 1 | TicketService |
| include/qry/delete_102_1.cfm | 1 | EssenceService |
| include/qry/delete_15_1.cfm | 1 | EventService |
| include/qry/delete_191_8.cfm | 1 | EventService |
| include/qry/delete_287_2.cfm | 1 | AuditionEssenceXRefService |
| include/qry/delete_287_3.cfm | 1 | GenreAuditionService |
| include/qry/delete_287_4.cfm | 1 | AuditionAgeRangeXRefService |
| include/qry/delete_298_1.cfm | 1 | ContactItemService |
| include/qry/delete_304_6.cfm | 1 | SystemUserService |
| include/qry/delete_368_7.cfm | 1 | ContactAuditionService |
| include/qry/delete_all_282_1.cfm | 1 | ReportItemService |
| include/qry/delete_ref_368_4.cfm | 1 | ContactAuditionService |
| include/qry/delete_ref_368_4.cfm | 17 | DebugService |
| include/qry/delete_team.cfm | 4 | contactItemService |
| include/qry/delSystemNotifications.cfm | 1 | NotificationService |
| include/qry/del_159_10.cfm | 1 | ContactItemService |
| include/qry/del_159_11.cfm | 1 | ContactItemService |
| include/qry/del_191_1.cfm | 1 | AuditionProjectService |
| include/qry/del_230_1.cfm | 1 | EventService |
| include/qry/del_232_4.cfm | 1 | EventService |
| include/qry/del_233_2.cfm | 3 | NotificationService |
| include/qry/del_25_2.cfm | 1 | AttachmentService |
| include/qry/del_277_4.cfm | 1 | ContactAuditionService |
| include/qry/del_460_1.cfm | 1 | PanelsUserXRefService |
| include/qry/del_465_1.cfm | 2 | NotificationService |
| include/qry/del_99_1.cfm | 1 | AuditionMediaService |
| include/qry/details_106_1.cfm | 1 | ContactItemService |
| include/qry/details_198_1.cfm | 1 | ItemCategoryService |
| include/qry/details_212_1.cfm | 1 | TicketService |
| include/qry/details_223_1.cfm | 1 | TicketService |
| include/qry/details_229_1.cfm | 1 | EventService |
| include/qry/details_257_3.cfm | 1 | TicketService |
| include/qry/details_259_1.cfm | 1 | AuditionSubmitSiteUserService |
| include/qry/details_261_1.cfm | 1 | ContactItemService |
| include/qry/details_263_1.cfm | 1 | EssenceService |
| include/qry/details_269_3.cfm | 1 | ContactService |
| include/qry/details_274_1.cfm | 1 | TicketService |
| include/qry/details_275_2.cfm | 1 | TicketService |
| include/qry/details_303_3.cfm | 1 | TicketService |
| include/qry/details_312_2.cfm | 1 | TicketService |
| include/qry/details_456_1.cfm | 1 | ContactService |
| include/qry/details_484_1.cfm | 1 | UploadService |
| include/qry/details_500_1.cfm | 1 | ContactService |
| include/qry/details_521_1.cfm | 1 | ContactItemService |
| include/qry/details_543_2.cfm | 1 | TicketService |
| include/qry/details_555_1.cfm | 1 | TicketService |
| include/qry/details_556_1.cfm | 1 | TicketService |
| include/qry/de_283_3.cfm | 1 | ActionUserService |
| include/qry/durations.cfm | 2 | MeetingDurationService |
| include/qry/durations_468_1.cfm | 1 | MeetingDurationService |
| include/qry/duration_467_1.cfm | 1 | MeetingDurationService |
| include/qry/d_18_2.cfm | 1 | EventContactsXRefService |
| include/qry/d_298_8.cfm | 1 | TagsUserService |
| include/qry/emailcheck_469_1.cfm | 1 | ContactItemService |
| include/qry/err_308_4.cfm | 1 | AuditionImportErrorService |
| include/qry/err_308_5.cfm | 1 | AuditionImportErrorService |
| include/qry/err_308_7.cfm | 1 | AuditionImportErrorService |
| include/qry/essences_286_10.cfm | 1 | EssenceService |
| include/qry/essence_sel_470_1.cfm | 1 | EssenceService |
| include/qry/eventdetails_334_3.cfm | 1 | EventService |
| include/qry/eventdetails_335_3.cfm | 1 | EventService |
| include/qry/eventresults.cfm | 1 | eventservice |
| include/qry/eventresults_471_1.cfm | 1 | EventService |
| include/qry/eventss_443_1.cfm | 1 | EventService |
| include/qry/events_166_1.cfm | 1 | AuditionProjectService |
| include/qry/events_203_1.cfm | 1 | AuditionProjectService |
| include/qry/events_232_3.cfm | 1 | EventService |
| include/qry/events_368_5.cfm | 1 | EventService |
| include/qry/events_424_1.cfm | 1 | EventService |
| include/qry/events_472_1.cfm | 3 | EventService |
| include/qry/events_472_1.cfm | 7 | EventService |
| include/qry/events_501_1.cfm | 1 | EventService |
| include/qry/events_505_1.cfm | 1 | EventService |
| include/qry/events_nobooking_368_6.cfm | 1 | EventService |
| include/qry/eventtypes_user_443_2.cfm | 1 | EventTypesUserService |
| include/qry/eventtypes_user_473_1.cfm | 1 | EventTypesUserService |
| include/qry/export_ac_115_15.cfm | 1 | ExportItemService |
| include/qry/export_ac_31_6.cfm | 1 | GenreAuditionService |
| include/qry/e_315_16.cfm | 1 | ContactImportService |
| include/qry/e_insert_315_17.cfm | 1 | ContactItemService |
| include/qry/fetchContactItems.cfm | 2 | ContactItemService |
| include/qry/fetchLocationService.cfm | 2 | LocationService |
| include/qry/fetchUsers.cfm | 1 | UserService |
| include/qry/fetch_folowup.cfm | 1 | ContactService |
| include/qry/finall_20_1.cfm | 1 | EventContactsXRefService |
| include/qry/find2_318_17.cfm | 1 | SiteLinkUserService |
| include/qry/FindActive_304_4.cfm | 1 | SystemUserService |
| include/qry/findcat_308_6.cfm | 1 | AuditionCategoryService |
| include/qry/findcd_308_13.cfm | 1 | ContactService |
| include/qry/Findchild_107_1.cfm | 1 | PageService |
| include/qry/findcompany_476_1.cfm | 1 | ContactItemService |
| include/qry/findcountry_199_4.cfm | 1 | CountryService |
| include/qry/findcountry_261_2.cfm | 1 | CountryService |
| include/qry/findcountry_521_2.cfm | 1 | CountryService |
| include/qry/findc_286_2.cfm | 1 | AuditionOpenCallOptionUserService |
| include/qry/findc_286_4.cfm | 1 | ContactService |
| include/qry/FindDetails_107_2.cfm | 1 | PageService |
| include/qry/Finddetails_185_1.cfm | 1 | PageService |
| include/qry/Finddetails_266_4.cfm | 1 | PageService |
| include/qry/FindDetails_284_1.cfm | 1 | PageService |
| include/qry/findd_221_10.cfm | 2 | MeetingDurationService |
| include/qry/findd_335_4.cfm | 1 | MeetingDurationService |
| include/qry/Findemail_167_3.cfm | 1 | ContactItemService |
| include/qry/Findemail_48_3.cfm | 1 | ContactItemService |
| include/qry/FindEvent_222_4.cfm | 3 | EventService |
| include/qry/finde_17_1.cfm | 1 | EventContactsXRefService |
| include/qry/FindFields_188_7.cfm | 1 | PageService |
| include/qry/findge_286_14.cfm | 1 | GenreAuditionService |
| include/qry/findg_286_11.cfm | 1 | AuditionEssenceXRefService |
| include/qry/findg_287_19.cfm | 1 | ContactService |
| include/qry/findid_146_1.cfm | 1 | ReportUserService |
| include/qry/findid_282_5.cfm | 1 | ReportUserService |
| include/qry/findit2_287_6.cfm | 1 | AuditionOpenCallOptionUserService |
| include/qry/finditems_524_6.cfm | 1 | ReportItemService |
| include/qry/findit_249_3.cfm | 1 | SiteTypeUserService |
| include/qry/findit_278_1.cfm | 1 | TaoVersionService |
| include/qry/Findit_282_7.cfm | 1 | AuditionTypeService |
| include/qry/findit_286_12.cfm | 1 | AuditionGenreUserService |
| include/qry/findit_287_11.cfm | 1 | AuditionGenreUserService |
| include/qry/findit_287_8.cfm | 1 | EssenceService |
| include/qry/findit_49_2.cfm | 1 | AuditionGenreUserService |
| include/qry/FindJoins_466_3.cfm | 1 | PageService |
| include/qry/FindJoins_526_3.cfm | 1 | PageService |
| include/qry/FindJoins_550_3.cfm | 1 | PageService |
| include/qry/FindKey_185_3.cfm | 1 | PageFieldService |
| include/qry/FindKey_228_1.cfm | 1 | PageFieldService |
| include/qry/FindKey_466_1.cfm | 1 | PageFieldService |
| include/qry/FINDK_159_4.cfm | 1 | ContactSSService |
| include/qry/FindLinksB.cfm | 3 | PageAppLinks |
| include/qry/FindLinksB_188_9.cfm | 1 | PageAppLinkService |
| include/qry/FindLinksExtra_188_10.cfm | 1 | PageAppLinkService |
| include/qry/findLinksT.cfm | 3 | PageAppLinks |
| include/qry/FindLinksT_188_8.cfm | 1 | PageAppLinkService |
| include/qry/findloc_365_2.cfm | 1 | EventService |
| include/qry/FindModalTitle_107_3.cfm | 1 | PageService |
| include/qry/findnumber_202_8.cfm | 1 | EventContactsXRefService |
| include/qry/FindPage_188_6.cfm | 1 | PageService |
| include/qry/Findphone_167_2.cfm | 1 | ContactItemService |
| include/qry/Findphone_48_2.cfm | 1 | ContactItemService |
| include/qry/findproject_218_2.cfm | 1 | AuditionProjectService |
| include/qry/findp_292_4.cfm | 1 | AllFieldsService |
| include/qry/FindRefcontacts_135_2.cfm | 1 | ContactService |
| include/qry/FindRefPage_135_1.cfm | 1 | PageService |
| include/qry/findregion_199_5.cfm | 1 | RegionService |
| include/qry/findregion_261_3.cfm | 1 | RegionService |
| include/qry/findregion_262_4.cfm | 1 | RegionService |
| include/qry/findregion_521_3.cfm | 1 | RegionService |
| include/qry/FindResults_185_2.cfm | 1 | PageService |
| include/qry/FindResults_466_2.cfm | 1 | PageService |
| include/qry/FindResults_526_2.cfm | 1 | PageService |
| include/qry/FindResults_550_2.cfm | 1 | PageService |
| include/qry/findsame_304_5.cfm | 1 | SystemUserService |
| include/qry/findsame_305_2.cfm | 1 | ContactItemService |
| include/qry/findscope.cfm | 1 | ContactItemService |
| include/qry/FindScope_304_2.cfm | 1 | TagsUserService |
| include/qry/findscope_539_2.cfm | 1 | ContactItemService |
| include/qry/findscope_old_294_2.cfm | 1 | ContactItemService |
| include/qry/findsource_308_8.cfm | 1 | AuditionSourceService |
| include/qry/findstep_29_4.cfm | 1 | AuditionStepService |
| include/qry/findSubCatId_316_2.cfm | 1 | AuditionCategoryService |
| include/qry/findsubs_259_3.cfm | 1 | AuditionRoleService |
| include/qry/findSystemByScope.cfm | 1 | SystemService |
| include/qry/FindSystemOld_294_7.cfm | 1 | SystemService |
| include/qry/FindSystem_294_6.cfm | 1 | SystemService |
| include/qry/FindSystem_304_3.cfm | 1 | SystemService |
| include/qry/findsystem_315_33.cfm | 1 | SystemUserService |
| include/qry/findSystem_71_7.cfm | 1 | SystemService |
| include/qry/findtag_97_1.cfm | 1 | ContactItemService |
| include/qry/Findtotal_249_4.cfm | 1 | PanelUserService |
| include/qry/Findtotal_318_9.cfm | 1 | PanelUserService |
| include/qry/findtype_365_1.cfm | 1 | AuditionTypeService |
| include/qry/findt_272_2.cfm | 1 | ContactItemService |
| include/qry/findt_286_7.cfm | 1 | AuditionAgeRangeXRefService |
| include/qry/findt_286_9.cfm | 1 | AuditionVocalTypeXRefService |
| include/qry/findUserById.cfm | 3 | UserService |
| include/qry/FindUser_188_1.cfm | 1 | UserService |
| include/qry/FindUser_188_5.cfm | 1 | UserService |
| include/qry/FindUser_538_1.cfm | 1 | UserService |
| include/qry/FindUser_539_1.cfm | 1 | UserService |
| include/qry/FINDz_159_6.cfm | 1 | ContactItemService |
| include/qry/Find_114_1.cfm | 1 | SiteTypeUserService |
| include/qry/FIND_14_5.cfm | 1 | ContactService |
| include/qry/find_150_1.cfm | 1 | LinkService |
| include/qry/Find_159_12.cfm | 1 | ContactItemService |
| include/qry/FIND_18_3.cfm | 1 | ContactService |
| include/qry/find_197_1.cfm | 1 | AuditionSubmitSiteUserService |
| include/qry/find_212_3.cfm | 1 | TicketTestUserService |
| include/qry/find_242_1.cfm | 1 | SiteLinkUserService |
| include/qry/find_246_1.cfm | 1 | UserService |
| include/qry/find_249_1.cfm | 1 | SiteTypeUserService |
| include/qry/find_270_2.cfm | 1 | GenderPronounUserService |
| include/qry/find_283_6.cfm | 1 | ActionUserService |
| include/qry/FIND_28_10.cfm | 1 | AuditionPlatformUserService |
| include/qry/find_292_5.cfm | 1 | FTypeXRefService |
| include/qry/find_298_2.cfm | 1 | TagsUserService |
| include/qry/find_303_1.cfm | 1 | TaoVersionService |
| include/qry/find_308_2.cfm | 1 | AuditionProjectService |
| include/qry/find_313_1.cfm | 1 | AuditionCategoryService |
| include/qry/find_315_2.cfm | 1 | ContactImportService |
| include/qry/find_315_4.cfm | 1 | ContactService |
| include/qry/find_316_3.cfm | 1 | AuditionImportService |
| include/qry/find_318_13.cfm | 1 | GenderPronounUserService |
| include/qry/find_318_16.cfm | 1 | SiteTypeUserService |
| include/qry/find_318_20.cfm | 1 | EventTypesUserService |
| include/qry/find_318_26.cfm | 1 | TagsUserService |
| include/qry/find_318_32.cfm | 1 | ItemTypesUserService |
| include/qry/find_318_35.cfm | 1 | ItemTypesUserService |
| include/qry/FIND_318_4.cfm | 1 | PanelUserService |
| include/qry/find_318_7.cfm | 1 | SiteTypeUserService |
| include/qry/find_320_1.cfm | 1 | TaoVersionService |
| include/qry/FInd_374_2.cfm | 1 | EventService |
| include/qry/find_383_2.cfm | 1 | AuditionMediaXRefService |
| include/qry/find_524_4.cfm | 1 | ReportUserService |
| include/qry/find_cat_308_17.cfm | 1 | AuditionCategoryService |
| include/qry/find_d_104_1.cfm | 1 | SystemUserService |
| include/qry/find_events_309_2.cfm | 1 | EventService |
| include/qry/find_fu_157_2.cfm | 1 | SystemService |
| include/qry/find_new_277_3.cfm | 1 | ContactAuditionService |
| include/qry/find_new_address_115_10.cfm | 1 | ContactItemService |
| include/qry/find_new_address_other_115_11.cfm | 1 | ContactItemService |
| include/qry/find_new_BusinessEmail_115_4.cfm | 1 | ContactItemService |
| include/qry/find_new_Company_115_6.cfm | 1 | ContactItemService |
| include/qry/find_new_homePhone_115_9.cfm | 1 | ContactItemService |
| include/qry/find_new_mobilePhone_115_8.cfm | 1 | ContactItemService |
| include/qry/find_new_PersonalEmail_115_5.cfm | 1 | ContactItemService |
| include/qry/find_new_tag_115_12.cfm | 1 | ContactItemService |
| include/qry/find_new_Website_115_3.cfm | 1 | ContactItemService |
| include/qry/find_new_WorkPhone_115_7.cfm | 1 | ContactItemService |
| include/qry/find_note_315_7.cfm | 1 | NoteService |
| include/qry/find_orphan_298_7.cfm | 1 | ContactItemService |
| include/qry/find_source_308_20.cfm | 1 | AuditionSourceService |
| include/qry/find_subcat_308_16.cfm | 1 | AuditionCategoryService |
| include/qry/find_subcat_308_18.cfm | 1 | AuditionSubcategorieService |
| include/qry/find_subsite_287_21.cfm | 1 | AuditionSubmitSiteUserService |
| include/qry/find_typesmediatypeid_42_2.cfm | 1 | AuditionMediaService |
| include/qry/fin_recordname_157_1.cfm | 1 | ContactService |
| include/qry/fix_191_9.cfm | 1 | AuditionProjectService |
| include/qry/followups_33_2.cfm | 1 | EventService |
| include/qry/folowup_body.cfm | 1 | EventService |
| include/qry/f_315_18.cfm | 1 | ContactImportService |
| include/qry/f_insert_315_19.cfm | 1 | ContactItemService |
| include/qry/genres_286_13.cfm | 1 | AuditionGenreUserService |
| include/qry/getActionUsers.cfm | 1 | ActionUserService |
| include/qry/getActiveTaoVersions.cfm | 1 | taoVersionService |
| include/qry/getActiveVersions.cfm | 1 | TicketService |
| include/qry/getAllCountries.cfm | 1 | CountryService |
| include/qry/getAllDateFormats.cfm | 1 | DateFormatService |
| include/qry/getAllRegions.cfm | 1 | RegionService |
| include/qry/getAllTimezones.cfm | 1 | TimeZoneService |
| include/qry/getAuditionImportErrors.cfm | 1 | AuditionImportErrorService |
| include/qry/getAuditionImportResults.cfm | 1 | AuditionImportService |
| include/qry/getAuditionLinks.cfm | 3 | AuditionLinkService |
| include/qry/getAuditionMediaTypes.cfm | 1 | AuditionMediaTypeService |
| include/qry/getAuditions.cfm | 1 | AuditionProjectService |
| include/qry/getAuditionUploadDetails.cfm | 1 | AuditionImportService |
| include/qry/getCategories_132_2.cfm | 1 | AuditionCategoryService |
| include/qry/getCategories_196_1.cfm | 1 | AuditionCategoryService |
| include/qry/getContactsByAudProject.cfm | 1 | ContactService |
| include/qry/getContactsImportByUploadID.cfm | 1 | ContactImportService |
| include/qry/getContactTagStatus.cfm | 1 | ContactItemService |
| include/qry/getFuSystemUsersBySystemID.cfm | 1 | SystemService |
| include/qry/getLinksByNoteId.cfm | 1 | LinkService |
| include/qry/getMinimalTimezones.cfm | 1 | TimeZoneService |
| include/qry/getMyTeam.cfm | 1 | ContactService |
| include/qry/getNoteDetails.cfm | 1 | NoteService |
| include/qry/getNotificationByID.cfm | 1 | NotificationService |
| include/qry/getNotificationsBySystem.cfm | 1 | NotificationService |
| include/qry/getOldSystemDetails.cfm | 1 | SystemUserService |
| include/qry/getRecord_132_1.cfm | 1 | AuditionImportService |
| include/qry/getRemindersByRelationship.cfm | 1 | SystemUserService |
| include/qry/getSocialIcons.cfm | 1 | ContactItemService |
| include/qry/getSources_132_3.cfm | 1 | AuditionSourceService |
| include/qry/getSystemIdBasedOnTag.cfm | 2 | ContactService |
| include/qry/getSystemUserByID.cfm | 1 | SystemUserService |
| include/qry/getUserDetails.cfm | 1 | UserService |
| include/qry/getUsers.cfm | 1 | userService |
| include/qry/g_315_20.cfm | 1 | ContactImportService |
| include/qry/g_insert_315_21.cfm | 1 | ContactItemService |
| include/qry/headshots_377_2.cfm | 1 | AuditionMediaService |
| include/qry/headshots_sel_478_1.cfm | 1 | AuditionMediaService |
| include/qry/headshots_sel_479_1.cfm | 1 | AuditionMediaService |
| include/qry/headshots_sel_494_1.cfm | 3 | AuditionMediaService |
| include/qry/headshots_sel_495_1.cfm | 4 | AuditionMediaService |
| include/qry/h_315_22.cfm | 1 | ContactImportService |
| include/qry/h_insert_315_23.cfm | 1 | ContactItemService |
| include/qry/imports.cfm | 1 | ContactImportService |
| include/qry/imports_140_4.cfm | 1 | AuditionImportService |
| include/qry/imports_372_1.cfm | 1 | AuditionImportService |
| include/qry/imports_485_1.cfm | 1 | ContactImportService |
| include/qry/incometypes_sel_486_1.cfm | 1 | IncomeTypeService |
| include/qry/INScontactdetails.cfm | 3 | ContactService |
| include/qry/InsertContact_188_2.cfm | 1 | UserService |
| include/qry/InsertContact_188_3.cfm | 1 | ContactService |
| include/qry/InsertContact_188_4.cfm | 1 | UserService |
| include/qry/InsertNote_14_8.cfm | 1 | NoteService |
| include/qry/InsertNote_169_1.cfm | 1 | NoteService |
| include/qry/InsertNote_171_1.cfm | 1 | NoteService |
| include/qry/InsertNote_173_1.cfm | 1 | NoteService |
| include/qry/InsertNote_294_8.cfm | 1 | NoteService |
| include/qry/InsertNote_308_22.cfm | 1 | NoteService |
| include/qry/InsertNote_315_8.cfm | 1 | NoteService |
| include/qry/InsertNote_4_1.cfm | 1 | NoteService |
| include/qry/inserts_14_7.cfm | 1 | EventContactsXRefService |
| include/qry/inserts_18_5.cfm | 1 | EventContactsXRefService |
| include/qry/inserts_202_9.cfm | 1 | EventContactsXRefService |
| include/qry/inserts_365_7.cfm | 1 | EventContactsXRefService |
| include/qry/inserttlog_487_1.cfm | 1 | TicketsLogTableService |
| include/qry/insertx_199_2.cfm | 1 | ItemCategoryXRefUserService |
| include/qry/Insert_157_6.cfm | 1 | NotificationService |
| include/qry/Insert_159_13.cfm | 1 | ContactItemService |
| include/qry/insert_159_5.cfm | 1 | ContactItemService |
| include/qry/insert_199_1.cfm | 1 | ItemTypesUserService |
| include/qry/insert_201_2.cfm | 1 | ContactItemService |
| include/qry/insert_201_3.cfm | 1 | ContactItemService |
| include/qry/insert_201_4.cfm | 1 | ContactItemService |
| include/qry/insert_201_5.cfm | 1 | ContactItemService |
| include/qry/insert_202_5.cfm | 1 | ContactItemService |
| include/qry/insert_202_6.cfm | 1 | ContactItemService |
| include/qry/Insert_213_1.cfm | 1 | TicketTestUserService |
| include/qry/INSERT_22_1.cfm | 1 | AttachmentService |
| include/qry/INSERT_266_3.cfm | 1 | UpdateLogService |
| include/qry/insert_277_1.cfm | 1 | AuditionToneUserService |
| include/qry/insert_277_2.cfm | 1 | AuditionNetworkUserService |
| include/qry/insert_287_10.cfm | 1 | AuditionEssenceXRefService |
| include/qry/insert_287_12.cfm | 1 | GenreAuditionService |
| include/qry/insert_287_13.cfm | 1 | AuditionGenreUserService |
| include/qry/insert_287_16.cfm | 1 | AuditionVocalTypeXRefService |
| include/qry/insert_287_18.cfm | 1 | AuditionAgeRangeXRefService |
| include/qry/insert_287_24.cfm | 1 | AuditionDialectsUserService |
| include/qry/insert_287_9.cfm | 1 | EssenceService |
| include/qry/insert_28_11.cfm | 1 | AuditionPlatformUserService |
| include/qry/insert_28_2.cfm | 1 | ContactItemService |
| include/qry/insert_28_3.cfm | 1 | ContactItemService |
| include/qry/insert_298_5.cfm | 1 | ContactItemService |
| include/qry/insert_305_3.cfm | 1 | ContactItemService |
| include/qry/insert_305_4.cfm | 1 | ContactItemService |
| include/qry/INSERT_316_1.cfm | 1 | UploadService |
| include/qry/insert_318_14.cfm | 1 | GenderPronounUserService |
| include/qry/insert_318_18.cfm | 1 | SiteLinkUserService |
| include/qry/insert_318_21.cfm | 1 | EventTypesUserService |
| include/qry/insert_318_24.cfm | 1 | ActionUserService |
| include/qry/insert_318_27.cfm | 1 | TagsUserService |
| include/qry/insert_318_33.cfm | 1 | ItemTypesUserService |
| include/qry/insert_318_37.cfm | 1 | ItemCategoryXRefUserService |
| include/qry/insert_318_5.cfm | 1 | PanelUserService |
| include/qry/insert_318_8.cfm | 1 | SiteTypeUserService |
| include/qry/insert_320_2.cfm | 1 | TaoVersionService |
| include/qry/insert_460_3.cfm | 1 | PanelsUserXRefService |
| include/qry/insert_524_5.cfm | 1 | ReportUserService |
| include/qry/Insert_71_8.cfm | 1 | NotificationService |
| include/qry/Insert_72_8.cfm | 1 | NotificationService |
| include/qry/Insert_ReportItems_146_2.cfm | 1 | ReportItemService |
| include/qry/Insert_ReportItems_282_6.cfm | 1 | ReportItemService |
| include/qry/insert_tag_298_3.cfm | 1 | TagsUserService |
| include/qry/ins_252_1.cfm | 1 | AuditionMediaXRefService |
| include/qry/ins_252_2.cfm | 1 | AuditionMediaXRefService |
| include/qry/itemDetails_130_1.cfm | 1 | ContactItemService |
| include/qry/itemsAll_489_1.cfm | 1 | ContactItemService |
| include/qry/itemsbycatActive.cfm | 1 | contactItemService |
| include/qry/itemsbycatActive_490_1.cfm | 1 | ContactItemService |
| include/qry/items_488_1.cfm | 1 | ContactItemService |
| include/qry/i_315_24.cfm | 1 | ContactImportService |
| include/qry/i_insert_315_25.cfm | 1 | ContactItemService |
| include/qry/jsons_50_1.cfm | 1 | ContactSSService |
| include/qry/jsons_myteam_50_2.cfm | 1 | EventService |
| include/qry/jtags_50_3.cfm | 1 | TagsUserService |
| include/qry/j_315_26.cfm | 1 | ContactImportService |
| include/qry/j_insert_315_27.cfm | 1 | ContactItemService |
| include/qry/k_195_2.cfm | 1 | SystemUserService |
| include/qry/labels_x_281_5.cfm | 1 | ReportItemService |
| include/qry/lastupdates.cfm | 1 | ContactService |
| include/qry/linkdetails_309_1.cfm | 1 | EventTypesUserService |
| include/qry/links_181_1.cfm | 1 | LinkService |
| include/qry/links_182_1.cfm | 1 | AuditionLinkService |
| include/qry/links_183_1.cfm | 1 | linkService |
| include/qry/locationDetails_492_1.cfm | 1 | EventService |
| include/qry/lookup_contacts.cfm | 3 | LookupService |
| include/qry/maints_315_32.cfm | 1 | ContactImportService |
| include/qry/master_164_4.cfm | 1 | SiteTypeMasterService |
| include/qry/materials_details_493_1.cfm | 1 | AuditionMediaService |
| include/qry/materials_sel.cfm | 1 | AuditionMediaService |
| include/qry/menuitems.cfm | 1 | ComponentService |
| include/qry/menuItemsAud_496_3.cfm | 1 | ComponentService |
| include/qry/menuItemsA_496_2.cfm | 1 | ComponentService |
| include/qry/menuItemsU_496_1.cfm | 1 | ComponentService |
| include/qry/mylinks_159_1.cfm | 1 | SiteLinkUserService |
| include/qry/mylinks_498_1.cfm | 1 | ContactItemService |
| include/qry/mylinks_user_164_2.cfm | 1 | SiteLinkUserService |
| include/qry/mylinks_user_del_164_3.cfm | 1 | SiteLinkUserService |
| include/qry/mysystems_295_1.cfm | 1 | SystemService |
| include/qry/mytags_167_1.cfm | 1 | ContactItemService |
| include/qry/mytags_48_1.cfm | 1 | ContactItemService |
| include/qry/myteam_499_1.cfm | 1 | ContactService |
| include/qry/m_318_3.cfm | 1 | PanelsMasterService |
| include/qry/new_312_4.cfm | 1 | TaoVersionService |
| include/qry/notesaud_506_1.cfm | 1 | NoteService |
| include/qry/notesContactDetails_180_2.cfm | 1 | NoteService |
| include/qry/notesContact_507_1.cfm | 1 | NoteService |
| include/qry/notesEvent_180_1.cfm | 1 | NoteService |
| include/qry/notesEvent_508_1.cfm | 1 | NoteService |
| include/qry/notesRelationship_509_1.cfm | 1 | NoteService |
| include/qry/notes_186_1.cfm | 1 | TicketService |
| include/qry/notsActives_458_2.cfm | 1 | NotificationService |
| include/qry/notsActives_461_1.cfm | 1 | NotificationService |
| include/qry/notsActive_510_1.cfm | 1 | NotificationService |
| include/qry/notsActive_511_2.cfm | 1 | NotificationService |
| include/qry/notsall_512_1.cfm | 1 | NotificationService |
| include/qry/notsInactive_510_2.cfm | 1 | NotificationStatusService |
| include/qry/notsnext.cfm | 1 | NotificationService |
| include/qry/notsNext_514_1.cfm | 1 | NotificationService |
| include/qry/old_312_3.cfm | 1 | TaoVersionService |
| include/qry/opencalls_286_1.cfm | 1 | AuditionOpenCallOptionUserService |
| include/qry/pages_10_4.cfm | 1 | PageService |
| include/qry/pages_274_3.cfm | 1 | PageService |
| include/qry/pgPanelsFix.cfm | 1 | PanelUserService |
| include/qry/pgpanels_460_2.cfm | 1 | PanelService |
| include/qry/pgpanels_94_2.cfm | 3 | PanelUserService |
| include/qry/phonecheck_515_1.cfm | 1 | ContactItemService |
| include/qry/Pin_check_29_7.cfm | 1 | EventService |
| include/qry/priorities_274_7.cfm | 1 | TicketPriorityService |
| include/qry/profiles_516_1.cfm | 1 | ContactItemService |
| include/qry/projectDetails_221_1.cfm | 1 | AuditionProjectService |
| include/qry/projectDetails_222_6.cfm | 1 | AuditionProjectService |
| include/qry/projectDetails_368_2.cfm | 1 | AuditionProjectService |
| include/qry/projectDetails_517_1.cfm | 1 | AuditionProjectService |
| include/qry/pronouns_210_1.cfm | 1 | GenderPronounUserService |
| include/qry/pronouns_456_4.cfm | 1 | GenderPronounUserService |
| include/qry/qCount_77_2.cfm | 1 | FilteredQueryService |
| include/qry/qFiltered_77_1.cfm | 22 | ContactService |
| include/qry/qFiltered_79_1.cfm | 26 | ContactService |
| include/qry/qry_block_1_1.cfm | 1 | ActionUserService |
| include/qry/qry_block_1_2.cfm | 1 | UserService |
| include/qry/queryFullNames_129_1.cfm | 1 | ContactService |
| include/qry/questions_441_1.cfm | 1 | AuditionQuestionUserService |
| include/qry/questions_check_29_9.cfm | 1 | EventService |
| include/qry/rangeselected_282_2.cfm | 1 | ReportRangeService |
| include/qry/ranges_286_6.cfm | 1 | AuditionAgeRangeService |
| include/qry/ranges_524_7.cfm | 1 | ReportRangeService |
| include/qry/ratio_13_524_12.cfm | 1 | ReportUserService |
| include/qry/ratio_17_524_13.cfm | 1 | ReportUserService |
| include/qry/Redirect_check_29_6.cfm | 1 | EventService |
| include/qry/referrals_286_3.cfm | 1 | ContactService |
| include/qry/refers_210_2.cfm | 1 | ContactService |
| include/qry/refer_details_451_2.cfm | 1 | ContactService |
| include/qry/refer_details_456_2.cfm | 1 | ContactService |
| include/qry/regions.cfm | 1 | RegionService |
| include/qry/relationships_13_1.cfm | 1 | ContactService |
| include/qry/reldetails_271_1.cfm | 1 | SystemUserService |
| include/qry/reminders_511_1.cfm | 2 | NotificationService |
| include/qry/remove2_191_12.cfm | 1 | EventContactsXRefService |
| include/qry/removenotdups.cfm | 1 | NotificationService |
| include/qry/remove_191_11.cfm | 1 | EventContactsXRefService |
| include/qry/reportcheck_524_1.cfm | 1 | ReportUserService |
| include/qry/reportcolors_523_1.cfm | 1 | ReportColorService |
| include/qry/reportitems_x_281_3.cfm | 1 | ReportItemService |
| include/qry/reportrefresh.cfm | 1 | ReportsRefreshService |
| include/qry/reports_524_9.cfm | 1 | ReportUserService |
| include/qry/report_10_282_3.cfm | 1 | AuditionProjectService |
| include/qry/report_11_282_9.cfm | 1 | AuditionProjectService |
| include/qry/report_12_282_10.cfm | 1 | AuditionProjectService |
| include/qry/report_13_282_12.cfm | 1 | AuditionProjectService |
| include/qry/report_17_282_11.cfm | 1 | AuditionProjectService |
| include/qry/report_18_282_21.cfm | 1 | AuditionProjectService |
| include/qry/report_2_282_24.cfm | 1 | AuditionProjectService |
| include/qry/report_3_282_13.cfm | 1 | AuditionProjectService |
| include/qry/report_4_loop_282_4.cfm | 1 | AuditionTypeService |
| include/qry/report_5_282_14.cfm | 1 | AuditionProjectService |
| include/qry/report_6_282_15.cfm | 1 | AuditionProjectService |
| include/qry/report_6_282_16.cfm | 1 | AuditionProjectService |
| include/qry/report_6_282_17.cfm | 1 | AuditionProjectService |
| include/qry/report_6_282_18.cfm | 1 | AuditionProjectService |
| include/qry/report_6_282_19.cfm | 1 | AuditionProjectService |
| include/qry/report_7_282_20.cfm | 1 | AuditionProjectService |
| include/qry/report_8_282_22.cfm | 1 | AuditionMediaService |
| include/qry/report_9_282_23.cfm | 1 | AuditionProjectService |
| include/qry/restoreActionUsers.cfm | 1 | ActionUserService |
| include/qry/restorenotdups.cfm | 1 | notificationService |
| include/qry/results_125_1.cfm | 1 | AuditionImportService |
| include/qry/results_141_2.cfm | 1 | ContactItemService |
| include/qry/results_142_1.cfm | 1 | ContactItemService |
| include/qry/results_330_1.cfm | 1 | TicketService |
| include/qry/results_331_1.cfm | 1 | UpdateLogService |
| include/qry/results_371_2.cfm | 1 | AuditionProjectService |
| include/qry/results_375_1.cfm | 1 | BigBrotherService |
| include/qry/results_43_1.cfm | 1 | EventService |
| include/qry/results_456_3.cfm | 1 | ContactService |
| include/qry/results_544_1.cfm | 1 | TicketService |
| include/qry/results_556_2.cfm | 1 | TicketService |
| include/qry/results_557_1.cfm | 1 | TicketService |
| include/qry/rolecheck_29_2.cfm | 1 | AuditionRoleService |
| include/qry/rolecheck_90_1.cfm | 1 | AuditionRoleService |
| include/qry/roleDetails_221_2.cfm | 1 | AuditionRoleService |
| include/qry/roleDetails_232_2.cfm | 1 | AuditionRoleService |
| include/qry/roleDetails_368_3.cfm | 1 | AuditionRoleService |
| include/qry/RPGAdd_288_5.cfm | 1 | PageService |
| include/qry/RPGFields_288_2.cfm | 1 | PageService |
| include/qry/RPGkey_288_4.cfm | 1 | PageService |
| include/qry/RPGResults_288_3.cfm | 1 | PageService |
| include/qry/RPGUpdate_288_6.cfm | 1 | PageService |
| include/qry/RPG_288_1.cfm | 1 | PageService |
| include/qry/rr_283_2.cfm | 1 | NotificationService |
| include/qry/ru.cfm | 1 | ContactService |
| include/qry/r_462_1.cfm | 1 | NotificationService |
| include/qry/SELaudnoteslog.cfm | 1 | NoteService |
| include/qry/SELnoteslog.cfm | 1 | ContactService |
| include/qry/SEL_Media_types_material.cfm | 1 | AuditionMediaTypeService |
| include/qry/set_missing.cfm | 1 | AuditionRoleService |
| include/qry/shares_534_1.cfm | 1 | ShareService |
| include/qry/sitetypes_535_1.cfm | 1 | SiteTypeUserService |
| include/qry/stats_524_10.cfm | 1 | ReportUserService |
| include/qry/statuses_10_2.cfm | 1 | TicketService |
| include/qry/statuses_274_5.cfm | 1 | TicketStatusService |
| include/qry/statuses_543_1.cfm | 1 | TicketStatusService |
| include/qry/statuses_554_1.cfm | 1 | TicketStatusService |
| include/qry/steps_29_1.cfm | 1 | AuditionStepService |
| include/qry/submitsitefix_368_1.cfm | 2 | AuditionRoleService |
| include/qry/submitsitefix_368_1.cfm | 6 | DebugService |
| include/qry/subsites_189_1.cfm | 1 | AuditionSubmitSiteUserService |
| include/qry/subsites_286_5.cfm | 1 | AuditionSubmitSiteUserService |
| include/qry/sudetails_157_5.cfm | 1 | SystemService |
| include/qry/sysActive_537_1.cfm | 1 | SystemUserService |
| include/qry/sysAvail_539_3.cfm | 1 | SystemService |
| include/qry/systemnames_453_2.cfm | 1 | SystemService |
| include/qry/systems_454_1.cfm | 1 | FUSystemTypeService |
| include/qry/Systems_540_1.cfm | 1 | SystemService |
| include/qry/TagsContact_541_1.cfm | 1 | ContactItemService |
| include/qry/tagsvalid_542_1.cfm | 1 | TagsUserService |
| include/qry/tags_200_1.cfm | 1 | TagsUserService |
| include/qry/tags_203_2.cfm | 1 | TagsUserService |
| include/qry/tags_76_1.cfm | 1 | TagsUserService |
| include/qry/tag_315_10.cfm | 1 | ContactImportService |
| include/qry/tag_315_12.cfm | 1 | ContactImportService |
| include/qry/tag_315_14.cfm | 1 | contactImportService |
| include/qry/tag_insert_315_11.cfm | 1 | ContactItemService |
| include/qry/tag_insert_315_13.cfm | 1 | ContactItemService |
| include/qry/tag_insert_315_15.cfm | 1 | ContactItemService |
| include/qry/ticketme_323_4.cfm | 1 | TicketTestUserService |
| include/qry/ticketusers_10_6.cfm | 1 | UserService |
| include/qry/ticketusers_323_3.cfm | 1 | TicketTestUserService |
| include/qry/toastmenu_306_2.cfm | 1 | NotificationService |
| include/qry/toasts_306_1.cfm | 1 | NotificationService |
| include/qry/tt_14_3.cfm | 1 | EventService |
| include/qry/tt_365_5.cfm | 1 | EventService |
| include/qry/types.cfm | 1 | itemTypeService |
| include/qry/types_10_3.cfm | 1 | UserService |
| include/qry/types_198_2.cfm | 1 | ItemTypeService |
| include/qry/types_198_3.cfm | 1 | ItemCategoryService |
| include/qry/types_256_2.cfm | 1 | TicketTypeService |
| include/qry/types_261_4.cfm | 1 | itemTypeService |
| include/qry/types_261_5.cfm | 1 | itemTypeService |
| include/qry/types_333_2.cfm | 1 | EventTypesUserService |
| include/qry/types_334_2.cfm | 1 | EventTypesUserService |
| include/qry/types_42_1.cfm | 1 | AuditionMediaTypeService |
| include/qry/types_44_1.cfm | 2 | AuditionMediaTypeService |
| include/qry/types_521_4.cfm | 1 | ItemCategoryService |
| include/qry/Type_208_1.cfm | 1 | AuditionMediaTypeService |
| include/qry/t_14_2.cfm | 1 | EventService |
| include/qry/update2_262_6.cfm | 1 | ContactItemService |
| include/qry/update2_280_2.cfm | 1 | ReportRangeService |
| include/qry/update2_280_3.cfm | 2 | ReportRangeService |
| include/qry/updateActionUsers.cfm | 1 | ActionUserService |
| include/qry/updateActionUsersByActionUpdate.cfm | 2 | ActionUserService |
| include/qry/updateActionUsersByExcludeAction.cfm | 1 | ActionUserService |
| include/qry/updateContactUnique.cfm | 1 | ContactService |
| include/qry/updatecontact_270_1.cfm | 1 | ContactService |
| include/qry/updateContact_71_2.cfm | 1 | ContactService |
| include/qry/updateEventData.cfm | 1 | EventService |
| include/qry/updateEvent_222_7.cfm | 1 | EventService |
| include/qry/updateExport_115_14.cfm | 1 | ExportService |
| include/qry/updatenote_175_1.cfm | 1 | NoteService |
| include/qry/updatenote_179_1.cfm | 1 | NoteService |
| include/qry/updateNotificationCompleted.cfm | 1 | NotificationService |
| include/qry/updateNotificationNext.cfm | 1 | NotificationService |
| include/qry/updateSystemUserCompleted.cfm | 1 | SystemUserService |
| include/qry/updatesystem_71_4.cfm | 1 | NotificationService |
| include/qry/updatesystem_71_5.cfm | 1 | SystemUserService |
| include/qry/updates_239_1.cfm | 1 | SiteTypeUserService |
| include/qry/updates_491_1.cfm | 1 | ContactService |
| include/qry/updateticket_213_3.cfm | 1 | TicketService |
| include/qry/updateticket_213_4.cfm | 1 | TicketService |
| include/qry/updateUserToken_133_1.cfm | 1 | UserService |
| include/qry/updateUserToken_184_1.cfm | 1 | UserService |
| include/qry/updateUserToken_184_2.cfm | 1 | UserService |
| include/qry/update_101_1.cfm | 1 | ContactService |
| include/qry/update_113_1.cfm | 1 | SiteLinkUserService |
| include/qry/update_114_2.cfm | 1 | SiteTypeUserService |
| include/qry/update_114_3.cfm | 1 | PanelUserService |
| include/qry/update_145_1.cfm | 1 | ActionUserService |
| include/qry/update_151_1.cfm | 1 | SiteLinkUserService |
| include/qry/update_159_3.cfm | 1 | UserService |
| include/qry/update_159_7.cfm | 1 | ContactItemService |
| include/qry/update_159_8.cfm | 1 | UserService |
| include/qry/update_159_9.cfm | 1 | UserService |
| include/qry/update_187_1.cfm | 1 | NotificationService |
| include/qry/update_187_2.cfm | 1 | NotificationService |
| include/qry/update_18_1.cfm | 1 | EventService |
| include/qry/update_191_5.cfm | 1 | AuditionProjectService |
| include/qry/update_191_7.cfm | 1 | AuditionProjectService |
| include/qry/update_199_6.cfm | 1 | ContactItemService |
| include/qry/update_213_2.cfm | 1 | TicketTestUserService |
| include/qry/update_260_2.cfm | 1 | AuditionSubmitSiteUserService |
| include/qry/update_262_5.cfm | 1 | ContactItemService |
| include/qry/update_264_1.cfm | 1 | EssenceService |
| include/qry/update_275_1.cfm | 1 | TicketService |
| include/qry/update_282_8.cfm | 1 | ReportItemService |
| include/qry/update_287_22.cfm | 1 | AuditionSubmitSiteUserService |
| include/qry/update_299_2.cfm | 1 | TicketService |
| include/qry/update_300_2.cfm | 1 | TicketService |
| include/qry/update_302_1.cfm | 1 | TicketService |
| include/qry/update_303_2.cfm | 1 | TicketService |
| include/qry/update_310_1.cfm | 1 | EventTypesUserService |
| include/qry/update_312_1.cfm | 1 | TicketService |
| include/qry/update_315_5.cfm | 1 | ContactImportService |
| include/qry/update_322_1.cfm | 1 | TaoVersionService |
| include/qry/update_367_7.cfm | 1 | EventService |
| include/qry/update_373_2.cfm | 1 | EventService |
| include/qry/update_551_1.cfm | 1 | NotificationService |
| include/qry/update_55_2.cfm | 1 | ContactService |
| include/qry/update_56_1.cfm | 1 | AuditionRoleService |
| include/qry/update_68_1.cfm | 1 | AuditionRoleService |
| include/qry/update_68_2.cfm | 1 | AuditionRoleService |
| include/qry/update_91_2.cfm | 1 | SiteLinkUserService |
| include/qry/update_92_1.cfm | 1 | SiteLinkUserService |
| include/qry/update_9_1.cfm | 17 | TicketService |
| include/qry/update_cal.cfm | 1 | userService |
| include/qry/update_Iscasting_318_29.cfm | 1 | TagsUserService |
| include/qry/update_record_313_2.cfm | 1 | AuditionImportService |
| include/qry/update_tags_318_28.cfm | 1 | TagsUserService |
| include/qry/upload_details_141_1.cfm | 1 | ContactImportService |
| include/qry/up_195_3.cfm | 1 | NotificationService |
| include/qry/up_31_1.cfm | 1 | UserService |
| include/qry/usercontact_159_14.cfm | 1 | UserService |
| include/qry/users_10_1.cfm | 1 | UserService |
| include/qry/users_212_2.cfm | 1 | UserService |
| include/qry/users_256_1.cfm | 1 | UserService |
| include/qry/users_318_1.cfm | 1 | UserService |
| include/qry/uu_223_2.cfm | 1 | UserService |
| include/qry/uu_33_1.cfm | 1 | EventService |
| include/qry/u_315_28.cfm | 1 | ContactImportService |
| include/qry/u_318_30.cfm | 1 | UserService |
| include/qry/U_73_1.cfm | 1 | UserService |
| include/qry/u_insert_315_29.cfm | 1 | ContactItemService |
| include/qry/values_x_281_6.cfm | 1 | ReportItemService |
| include/qry/versions_10_5.cfm | 1 | TicketService |
| include/qry/versions_323_2.cfm | 1 | TicketService |
| include/qry/vers_274_8.cfm | 1 | TaoVersionService |
| include/qry/vers_323_1.cfm | 1 | TicketService |
| include/qry/vers_330_3.cfm | 1 | TicketService |
| include/qry/vocals_286_8.cfm | 1 | AuditionVocalTypeService |
| include/qry/xs_283_5.cfm | 1 | FUActionService |
| include/qry/xs_318_19.cfm | 1 | EventTypesService |
| include/qry/xs_318_22.cfm | 1 | FUActionService |
| include/qry/xx_55_1.cfm | 1 | ContactService |
| include/qry/x_115_2.cfm | 1 | ContactService |
| include/qry/x_191_2.cfm | 1 | EventService |
| include/qry/x_214_1.cfm | 1 | AuditionQuestionUserService |
| include/qry/x_240_3.cfm | 1 | PanelUserService |
| include/qry/x_280_1.cfm | 2 | ReportRangeService |
| include/qry/x_283_1.cfm | 1 | NotificationService |
| include/qry/x_291_1.cfm | 1 | UserService |
| include/qry/x_292_3.cfm | 1 | AllFieldsService |
| include/qry/x_308_11.cfm | 1 | AuditionImportService |
| include/qry/x_308_12.cfm | 1 | AuditionImportService |
| include/qry/x_315_3.cfm | 1 | ContactImportService |
| include/qry/x_318_12.cfm | 1 | GenderPronounService |
| include/qry/x_318_15.cfm | 1 | SiteLinksMasterService |
| include/qry/x_318_25.cfm | 1 | TagService |
| include/qry/x_318_31.cfm | 1 | ItemTypeService |
| include/qry/x_318_34.cfm | 1 | ItemCategoryService |
| include/qry/x_318_6.cfm | 1 | SiteTypeMasterService |
| include/qry/x_41_2.cfm | 1 | AuditionQuestionUserService |
| include/qry/x_524_3.cfm | 1 | ReportsMasterService |
| include/qry/x_91_1.cfm | 1 | SiteLinkUserService |
| include/qry/x_94_1.cfm | 1 | PanelUserService |
| include/qry/y_191_4.cfm | 1 | EventService |
| include/qry/y_292_1.cfm | 1 | InformationSchemaTableService |
| include/qry/y_298_6.cfm | 1 | TagsUserService |
| include/qry/y_308_1.cfm | 1 | AuditionImportService |
| include/qry/z_191_6.cfm | 1 | AuditionProjectService |
| include/remoteDeleteFormLink.cfm | 2 | SiteLinksService |
| include/remotelinkUpdate.cfm | 3 | SiteLinksService |
| include/remotelinkUpdateUpdate.cfm | 6 | SiteLinksService |
| include/systemchange.cfm | 2 | SystemUserService |
| include/systemchange.cfm | 9 | ContactItemService |
| include/systemchange.cfm | 18 | notificationService |
| include/test_auditions_pagination.cfm | 37 | PaginationService |
| include/transfer_audition.cfm | 36 | AuditionImportErrorService |
| include/update_cal.cfm | 11 | UserService |
| include/update_selected_headshot.cfm | 7 | AuditionMediaXRefService |
| services/RelationshipService.cfc | 14 | RelationshipService |
| share/calendar_shared.cfm | 66 | ReminderService |
| share/relationships_shared.cfm | 62 | ContactItemService |

### 2A.3 -- application.{Service}.{method}() calls

> **Result: NONE found.** No files use `application.{Service}.method()` pattern.

### 2A.4 -- request.{Service}.{method}() calls

> **Result: NONE found.** No files use `request.{Service}.method()` pattern.

### 2A.5 -- cfinvoke component="services.*" calls

> **Result: NONE found.** No files use `cfinvoke component="services.*"` pattern.

---

## 2B -- /qry/ cfinclude Callers (1,301 matches, 1,018 unique /qry/ files)

**TECH-DEBT: scope-leaking cfinclude** -- Every entry below uses cfinclude to pull in a /qry/ file.
These query files execute in the caller's variable scope, meaning any variable set inside leaks
into the calling page. This is a significant maintainability and security concern.

Top 10 most-included /qry/ files:
- /qry/select_query.cfm (8 callers)
- /qry/relationships_13_1.cfm (8 callers)
- /qry/fetchUsers.cfm (7 callers)
- /qry/fetchLocationService.cfm (6 callers)
- /qry/audcategories_sel.cfm (6 callers)
- /qry/InsertNote_294_8.cfm (6 callers)
- /qry/lastupdates.cfm (5 callers)
- /qry/getRemindersByRelationship.cfm (5 callers)
- /qry/getNotificationByID.cfm (5 callers)
- /qry/getAuditionMediaTypes.cfm (5 callers)

| Calling File | Line | Included /qry/ File | Flag |
|---|---|---|---|
| include/qry/insert_460_3.cfm | 1 | PanelsUserXRefService |
| app/admin-users/setup-verification.cfm | 8 | /qry/core.cfm | TECH-DEBT: scope-leaking cfinclude |
| app/Application.cfc | 267 | /qry/fetchUsers.cfm | TECH-DEBT: scope-leaking cfinclude |
| app/Application.cfc | 314 | /qry/fetchUsers.cfm | TECH-DEBT: scope-leaking cfinclude |
| app/assets/js/eventtypes_user.cfm | 2 | /qry/eventtypes_user.cfm | TECH-DEBT: scope-leaking cfinclude |
| calendar-appoint.cfm | 4 | /qry/eventtypes_user.cfm | TECH-DEBT: scope-leaking cfinclude |
| calendar-appoint.cfm | 7 | /qry/events_byuser.cfm | TECH-DEBT: scope-leaking cfinclude |
| debug-calendar-events.cfm | 13 | /qry/eventtypes_user.cfm | TECH-DEBT: scope-leaking cfinclude |
| debug-calendar-events.cfm | 14 | /qry/events_byuser.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/account_info.cfm | 77 | /qry/getAllCountries.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/account_info.cfm | 78 | /qry/getAllRegions.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/account_info.cfm | 79 | /qry/getAllTimezones.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/account_info.cfm | 80 | /qry/getMinimalTimezones.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/account_info.cfm | 81 | /qry/getAllDateFormats.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/account_info.cfm | 82 | /qry/getUserDetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/account_info.cfm | 97 | /qry/deleteTeam.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/account_info.cfm | 104 | /qry/addTeam.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/addeventtypeadd.cfm | 3 | /qry/insert_564_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/addnote.cfm | 8 | /qry/InsertNote_4_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/addnote.cfm | 12 | /qry/DeleteNote_4_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/addnote.cfm | 16 | /qry/InsertNote_4_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/addnote.cfm | 17 | /qry/DeleteNote_4_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/AddSystemToContact.cfm | 2 | /qry/addfuSystemUsers.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/AddSystemToContact.cfm | 16 | /qry/addDaysNo_5_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/AddSystemToContact.cfm | 31 | /qry/checkUnique_5_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/AddSystemToContact.cfm | 50 | /qry/addNotification_5_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/AddSystemToContact.cfm | 55 | /qry/addNotification_5_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/add_system.cfm | 9 | /qry/delSystemNotifications.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/add_system.cfm | 12 | /qry/addfuSystemUsers.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/add_system.cfm | 15 | /qry/getFuSystemUsersBySystemID.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/add_system.cfm | 25 | /qry/checkUnique_157_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/add_system.cfm | 43 | /qry/addNotification_326_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/admin-support-update2.cfm | 16 | /qry/update_9_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/admin-support_backup.cfm | 522 | /qry/results_330_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/admin-support_backup.cfm | 525 | /qry/priorities_330_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/admin-support_backup.cfm | 528 | /qry/vers_330_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/Applicationx.cfm | 13 | /qry/fetchUsers.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add.cfm | 6 | /qry/relationships_13_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add.cfm | 7 | /qry/durations.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add.cfm | 8 | /qry/eventtypes_user_443_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add2.cfm | 56 | /qry/duration_467_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add2.cfm | 69 | /qry/add_14_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add2.cfm | 70 | /qry/t_14_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add2.cfm | 71 | /qry/tt_14_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add2.cfm | 72 | /qry/dd_14_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add2.cfm | 77 | /qry/FIND_14_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add2.cfm | 84 | /qry/add_14_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add2.cfm | 95 | /qry/inserts_14_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add2.cfm | 101 | /qry/InsertNote_14_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add2.cfm | 121 | /qry/audprojects_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add2.cfm | 122 | /qry/audroles_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add2.cfm | 123 | /qry/auditions_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-delete.cfm | 3 | /qry/delete_15_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-info.cfm | 6 | /qry/eventdetails_334_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-info.cfm | 7 | /qry/notesEvent_508_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-info.cfm | 9 | /qry/attendees_336_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-info.cfm | 10 | /qry/notesContactDetails_180_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-update.cfm | 12 | /qry/eventdetails_334_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-update.cfm | 13 | /qry/durations.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-update.cfm | 14 | /qry/relationships_13_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-update.cfm | 15 | /qry/eventtypes_user_443_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-update.cfm | 76 | /qry/finde_17_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-update2.cfm | 43 | /qry/durations.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-update2.cfm | 44 | /qry/duration_467_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-update2.cfm | 58 | /qry/update_18_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-update2.cfm | 59 | /qry/d_18_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-update2.cfm | 66 | /qry/FIND_18_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-update2.cfm | 76 | /qry/add_14_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-update2.cfm | 91 | /qry/inserts_18_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint.cfm | 3 | /qry/notesevent.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appointments_pane.cfm | 46 | /qry/finall_20_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/attachmentadd.cfm | 12 | /qry/getNoteDetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/attachmentadd2.cfm | 71 | /qry/INSERT_22_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/attachmentadd2aud.cfm | 18 | /qry/fetchusers.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/attachmentadd2aud.cfm | 44 | /qry/INSERT_22_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/attachmentaddaud.cfm | 13 | /qry/getNoteDetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/attachmentdel.cfm | 11 | /qry/attachdetails_25_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/attachmentdel.cfm | 26 | /qry/del_25_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/attachmentdelaud.cfm | 10 | /qry/attachdetails_25_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/attachmentdelaud.cfm | 21 | /qry/del_25_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add.cfm | 25 | /qry/fetchLocationService.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add.cfm | 27 | /qry/audplatforms_user_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add.cfm | 30 | /qry/cities_448_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add.cfm | 32 | /qry/cat_27_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add.cfm | 37 | /qry/audroletypes_sel_27_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add.cfm | 38 | /qry/audtypes_sel_27_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add.cfm | 39 | /qry/casting_types_27_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add.cfm | 40 | /qry/castingdirectors_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add.cfm | 469 | /qry/getAllCountries.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add.cfm | 470 | /qry/regions.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add.cfm | 471 | /qry/cities.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 76 | /qry/inscontactdetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 80 | /qry/insert_28_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 84 | /qry/insert_28_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 99 | /qry/insContactDetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 100 | /qry/insert_28_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 104 | /qry/insert_28_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 114 | /qry/insContactDetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 116 | /qry/insert_28_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 117 | /qry/insert_28_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 120 | /qry/FIND_28_10.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 124 | /qry/insert_28_11.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 132 | /qry/audprojects_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 133 | /qry/audroles_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 137 | /qry/auditions_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 142 | /qry/add_cd_28_12.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-update.cfm | 21 | /qry/fetchLocationService.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-update.cfm | 23 | /qry/audplatforms_user_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-update.cfm | 26 | /qry/cities_448_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-update.cfm | 28 | /qry/cat_27_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-update.cfm | 33 | /qry/audroletypes_sel_27_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-update.cfm | 34 | /qry/audtypes_sel_27_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-update.cfm | 35 | /qry/casting_types_27_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-update.cfm | 36 | /qry/castingdirectors_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition.cfm | 63 | /qry/steps_29_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition.cfm | 138 | /qry/rolecheck_29_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition.cfm | 170 | /qry/audunions_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition.cfm | 171 | /qry/audnetworks_user_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition.cfm | 172 | /qry/audtones_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition.cfm | 173 | /qry/audcontracttypes_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition.cfm | 174 | /qry/notesaud.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition.cfm | 178 | /qry/auditionDetails_29_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition.cfm | 302 | /qry/findstep_29_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition.cfm | 424 | /qry/callback_check_29_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition.cfm | 442 | /qry/Redirect_check_29_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition.cfm | 460 | /qry/Pin_check_29_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition.cfm | 474 | /qry/Booked_check_29_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/auditions.cfm | 48 | /qry/audcategories_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/auditions.cfm | 351 | /qry/up_31_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/auditions.cfm | 352 | /qry/audsteps_sel_31_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/auditions.cfm | 353 | /qry/audtypes_sel_31_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/auditions.cfm | 354 | /qry/auditions.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/auditions.cfm | 440 | /qry/cds_31_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/auditions.cfm | 441 | /qry/cos_31_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/auditions_ins.cfm | 23 | /qry/auditions_ins_32_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/auditions_new.cfm | 8 | /qry/audcategories_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/auditions_new.cfm | 84 | /qry/up_31_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/auditions_new.cfm | 85 | /qry/audsteps_sel_31_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/auditions_new.cfm | 86 | /qry/audtypes_sel_31_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/auditions_new.cfm | 175 | /qry/cds_31_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/auditions_new.cfm | 176 | /qry/cos_31_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition_check.cfm | 16 | /qry/uu_33_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition_check.cfm | 22 | /qry/folowup_body.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition_check.cfm | 60 | /qry/addmissing_33_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audlocupdate2.cfm | 13 | /qry/audlocations_upd_37_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audmedia.cfm | 6 | /qry/audmedia_38_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audroles_ins.cfm | 14 | /qry/audroles_ins_39_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audunions_sel.cfm | 6 | /qry/audunions_sel_40_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_assessment_add.cfm | 3 | /qry/insert_41_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_assessment_add.cfm | 5 | /qry/x_41_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_assessment_add.cfm | 9 | /qry/insert_41_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_book_pane.cfm | 6 | /qry/SEL_Media_types_material.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_call_pane.cfm | 2 | /qry/results_43_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_head_pane.cfm | 3 | /qry/audmedia.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_head_pane.cfm | 4 | /qry/types_44_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_head_pane.cfm | 5 | /qry/getAuditionLinks.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_mat_pane.cfm | 3 | /qry/getAuditionMaterials.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_mat_pane.cfm | 4 | /qry/getAuditionMediaPicklist.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_mat_pane.cfm | 5 | /qry/getAuditionMediaTypes.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_mat_pane.cfm | 6 | /qry/getAuditionLinks.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_ques_pane.cfm | 2 | /qry/auds_byrole.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_ques_pane.cfm | 36 | /qry/aud_questions.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_rel_pane.cfm | 20 | /qry/getContactsByAudProject.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_rel_pane.cfm | 22 | /qry/audcontacts_sel_349_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_rel_pane.cfm | 91 | /qry/mytags_48_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_rel_pane.cfm | 92 | /qry/Findphone_48_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_rel_pane.cfm | 94 | /qry/Findemail_48_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_rel_pane.cfm | 153 | /qry/getSocialIcons.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_rel_pane.cfm | 154 | /qry/getRemindersByRelationship.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_role_pane.cfm | 31 | /qry/audessences_audtion_xref_49_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_role_pane.cfm | 106 | /qry/findit_49_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_role_pane.cfm | 110 | /qry/audgenres_audition_xref.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_role_pane.cfm | 126 | /qry/audgenres_audition_xref.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_role_pane.cfm | 163 | /qry/audvocaltypes_audition_xref.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/bigbrotherinclude.cfm | 7 | /qry/bro_add_53_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/birthday_fix.cfm | 3 | /qry/xx_55_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/birthday_fix.cfm | 35 | /qry/update_55_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/booked.cfm | 2 | /qry/update_56_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/bookupdateform.cfm | 3 | /qry/audplatforms_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/bookupdateform.cfm | 4 | /qry/incometypes_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/bookupdateform.cfm | 5 | /qry/audpaycyles_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/bookupdateform.cfm | 6 | /qry/book_det_57_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/bookupdateform2.cfm | 16 | /qry/audlocations_ins_58_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/calendar-appoint.cfm | 4 | /qry/eventtypes_user.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/calendar-appoint.cfm | 7 | /qry/events_byuser.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/catupdateform.cfm | 5 | /qry/audcategories_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/catupdateform.cfm | 6 | /qry/audsubcategories_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/catupdateform.cfm | 7 | /qry/auditionprojectDetails_66_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/catupdateform2.cfm | 2 | /qry/audprojects_ins_67_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/changestatus.cfm | 10 | /qry/update_68_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/changestatus.cfm | 13 | /qry/update_68_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not.cfm | 22 | /qry/getNotificationByID.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not.cfm | 83 | /qry/updateNotificationCompleted.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not.cfm | 110 | /qry/updateContactUnique.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not.cfm | 143 | /qry/addNotification.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not.cfm | 162 | /qry/getNotificationsBySystem.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not.cfm | 206 | /qry/updateNotificationNext.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not.cfm | 236 | /qry/updateSystemUserCompleted.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not.cfm | 268 | /qry/addNotifications.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not.cfm | 277 | /qry/findSystemByScope.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_ajax.cfm | 57 | /qry/getNotificationByID.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_ajax.cfm | 116 | /qry/updateNotificationCompleted.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_ajax.cfm | 142 | /qry/updateContactUnique.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_ajax.cfm | 164 | /qry/addNotification.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_ajax.cfm | 182 | /qry/getNotificationsBySystem.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_ajax.cfm | 253 | /qry/updateNotificationNext.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_ajax.cfm | 275 | /qry/updateSystemUserCompleted.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_ajax.cfm | 284 | /qry/checkformaint_71_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_ajax.cfm | 309 | /qry/addNotifications.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_ajax.cfm | 310 | /qry/findSystemByScope.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch.cfm | 61 | /qry/getNotificationByID.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch.cfm | 85 | /qry/updateNotificationCompleted.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch.cfm | 89 | /qry/updateContactUnique.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch.cfm | 95 | /qry/addNotification.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch.cfm | 99 | /qry/getNotificationsBySystem.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch.cfm | 104 | /qry/updateNotificationNext.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch.cfm | 108 | /qry/updateSystemUserCompleted.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch.cfm | 111 | /qry/checkformaint_71_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch.cfm | 117 | /qry/addNotifications.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch.cfm | 118 | /qry/findSystemByScope.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_backup_20251211.cfm | 61 | /qry/getNotificationByID.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_backup_20251211.cfm | 85 | /qry/updateNotificationCompleted.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_backup_20251211.cfm | 89 | /qry/updateContactUnique.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_backup_20251211.cfm | 95 | /qry/addNotification.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_backup_20251211.cfm | 99 | /qry/getNotificationsBySystem.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_backup_20251211.cfm | 104 | /qry/updateNotificationNext.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_backup_20251211.cfm | 108 | /qry/updateSystemUserCompleted.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_backup_20251211.cfm | 111 | /qry/checkformaint_71_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_backup_20251211.cfm | 117 | /qry/addNotifications.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_backup_20251211.cfm | 118 | /qry/findSystemByScope.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_old.cfm | 16 | /qry/getNotificationByID.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_old.cfm | 45 | /qry/addNotification_71_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_old.cfm | 49 | /qry/updateContact_71_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_old.cfm | 55 | /qry/addNotification_71_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_old.cfm | 59 | /qry/notsnext.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_old.cfm | 68 | /qry/updatesystem_71_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_old.cfm | 74 | /qry/updatesystem_71_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_old.cfm | 75 | /qry/checkformaint_71_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_old.cfm | 79 | /qry/findSystem_71_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_old.cfm | 82 | /qry/Insert_71_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_skip.cfm | 13 | /qry/getNotificationById.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_skip.cfm | 38 | /qry/addNotification_72_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_skip.cfm | 42 | /qry/updateContact_72_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_skip.cfm | 48 | /qry/addNotification_71_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_skip.cfm | 51 | /qry/notsnext.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_skip.cfm | 61 | /qry/updatesystem_72_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_skip.cfm | 67 | /qry/updatesystem_72_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_skip.cfm | 68 | /qry/checkformaint_72_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_skip.cfm | 72 | /qry/findSystem_71_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_skip.cfm | 76 | /qry/Insert_72_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contactfolder_setup.cfm | 18 | /qry/U_73_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contactfolder_setup.cfm | 93 | /qry/C_73_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contacts.cfm | 33 | /qry/lastupdates.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contacts.cfm | 313 | /qry/imports.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contacts_all.cfm | 21 | /qry/lastupdates.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contacts_all.cfm | 167 | /qry/tags_76_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contacts_all_tabs.cfm | 53 | /qry/lastupdates.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contacts_all_tabs.cfm | 236 | /qry/tags_76_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contacts_attendees.cfm | 20 | /qry/qFiltered_77_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contacts_attendees.cfm | 23 | /qry/qCount_77_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contacts_table.cfm | 44 | /qry/imports.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_add.cfm | 2 | /qry/add_82_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 3 | /qry/fetchLocationService.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 141 | /qry/details_456_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 142 | /qry/eventresults.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 143 | /qry/ru.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 145 | /qry/contacts_333_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 146 | /qry/categories_446_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 147 | /qry/items_488_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 148 | /qry/notesContact_507_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 149 | /qry/Systems_540_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 150 | /qry/TagsContact_541_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 151 | /qry/profiles_516_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 152 | /qry/sysActive_537_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 153 | /qry/notsall_512_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 154 | /qry/eventss_443_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 155 | /qry/systemNotificationsActive.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 156 | /qry/findscope.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 157 | /qry/sysAvail_539_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 158 | /qry/getRemindersByRelationship.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 159 | /qry/emailcheck_469_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 160 | /qry/phonecheck_515_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 161 | /qry/rels.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 162 | /qry/fetchcontactitems.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 163 | /qry/findcompany_476_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 164 | /qry/notesRelationship_509_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 239 | /qry/cu_83_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 324 | /qry/c_83_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 454 | /qry/notsactive_510_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 455 | /qry/notsInactive_510_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_pane.cfm | 10 | /qry/itemsbycatActive.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/core.cfm | 1 | /qry/menuitems.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/core.cfm | 2 | /qry/menuItemsa_496_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/core.cfm | 3 | /qry/menuItemsAud_496_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/core.cfm | 29 | /qry/FindLinksT.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/core.cfm | 30 | /qry/FindLinksB.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/core_title_175.cfm | 3 | /qry/rolecheck_90_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/customicon.cfm | 2 | /qry/x_91_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/customicon.cfm | 39 | /qry/update_91_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/customicon_single.cfm | 101 | /qry/update_92_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/dashboardupdate.cfm | 2 | /qry/dashboardzz_93_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/dashboardupdate2.cfm | 6 | /qry/x_94_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/dashboardupdate2.cfm | 9 | /qry/pgpanels_94_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/dashboard_pane.cfm | 2 | /qry/dashboardoptions.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/dash_repteam.cfm | 84 | /qry/myteam_499_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/dash_repteam.cfm | 109 | /qry/findtag_97_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/dash_rr.cfm | 11 | /qry/reminders_511_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/delaudmedia.cfm | 7 | /qry/del_99_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/deleteappointment.cfm | 3 | /qry/deleteticket_100_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/deleteContacts.cfm | 6 | /qry/update_101_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/deleteessence.cfm | 2 | /qry/delete_102_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/deletenote.cfm | 2 | /qry/deletenote_103_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/deletesystemfromrel.cfm | 21 | /qry/find_d_104_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/deletesystemfromrel.cfm | 24 | /qry/deletesystem_104_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/deleteticket.cfm | 3 | /qry/deleteticket_105_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/DetailPage.cfm | 16 | /qry/details_106_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/details.cfm | 6 | /qry/Findchild_107_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/details.cfm | 26 | /qry/FindDetails_107_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/details.cfm | 127 | /qry/FindModalTitle_107_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/details.cfm | 128 | /qry/update.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/details.cfm | 134 | /qry/find_107_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/details.cfm | 169 | /qry/FindValue_107_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/details.cfm | 255 | /qry/FindValue_107_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/details.cfm | 256 | /qry/selects_107_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/details.cfm | 276 | /qry/FindValue_107_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/details.cfm | 278 | /qry/selects_107_9.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/details.cfm | 308 | /qry/FindValue_107_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/details.cfm | 309 | /qry/selects_107_11.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/details.cfm | 340 | /qry/selects_107_12.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/download.cfm | 7 | /qry/attachdetails_25_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/download_aud.cfm | 7 | /qry/attachdetails_25_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/download_media.cfm | 4 | /qry/attachdetails_109_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/excludeaction.cfm | 2 | /qry/updateActionUsersByExcludeAction.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/excludelink.cfm | 5 | /qry/update_113_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/excludesitetype.cfm | 3 | /qry/Find_114_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/excludesitetype.cfm | 5 | /qry/update_114_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/excludesitetype.cfm | 11 | /qry/update_114_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 47 | /qry/AddExport_115_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 48 | /qry/x_115_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 79 | /qry/find_new_Website_115_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 86 | /qry/find_new_BusinessEmail_115_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 93 | /qry/find_new_PersonalEmail_115_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 100 | /qry/find_new_Company_115_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 107 | /qry/find_new_WorkPhone_115_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 114 | /qry/find_new_mobilePhone_115_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 121 | /qry/find_new_homePhone_115_9.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 128 | /qry/find_new_address_115_10.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 141 | /qry/find_new_address_other_115_11.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 154 | /qry/find_new_tag_115_12.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 177 | /qry/insert_115_13.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 181 | /qry/updateExport_115_14.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 183 | /qry/export_ac_115_15.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/export_auditions.cfm | 2 | /qry/export_ac_31_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/fetch_updated_row.cfm | 6 | /qry/results_125_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/fetch_updated_row.cfm | 7 | /qry/getAuditionImportErrors.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/folder_setup.cfm | 45 | /qry/C_73_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/folowup_body.cfm | 2 | /qry/fetch_folowup.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/FullNameLookup.cfc | 11 | /qry/queryFullNames_129_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/getmodalcontent.cfm | 5 | /qry/itemDetails_130_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/get_record_data.cfm | 9 | /qry/getRecord_132_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/get_record_data.cfm | 12 | /qry/getCategories_132_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/get_record_data.cfm | 15 | /qry/getSources_132_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/google_auth.cfm | 13 | /qry/updateUserToken_133_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/image-upload-contact.cfm | 9 | /qry/FindRefPage_135_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/image-upload-contact.cfm | 10 | /qry/FindRefcontacts_135_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/image-upload.cfm | 8 | /qry/FindRefPage_136_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/image-upload.cfm | 11 | /qry/FindRefcontacts_135_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/import-auditions.cfm | 224 | /qry/getAuditionUploadDetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/import-auditions.cfm | 226 | /qry/getAuditionImportResults.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/import-auditions.cfm | 277 | /qry/getAuditionImportErrors.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/import-auditions.cfm | 336 | /qry/auditions_import.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/import-contacts_old.cfm | 9 | /qry/imports.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/import-contacts_old.cfm | 15 | /qry/upload_details_141_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/import-contacts_old.cfm | 18 | /qry/results_141_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/import.cfm | 71 | /qry/results_142_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/includeaction.cfm | 3 | /qry/update_145_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/Insert_ReportItem.cfm | 3 | /qry/findid_146_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/Insert_ReportItem.cfm | 25 | /qry/Insert_ReportItems_146_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/linkadd.cfm | 7 | /qry/getNoteDetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/linkadd2.cfm | 8 | /qry/add_149_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/linkdel.cfm | 7 | /qry/find_150_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/linkdel.cfm | 12 | /qry/deletelink_150_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/linkinclude.cfm | 3 | /qry/update_151_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/linkmedia.cfm | 3 | /qry/linkmedia_152_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/load_headshot.cfm | 4 | /qry/headshots_377_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/load_headshot_gallery.cfm | 4 | /qry/headshots_sel_479_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/modalansweryes.cfm | 5 | /qry/fin_recordname_157_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/modalansweryes.cfm | 12 | /qry/find_fu_157_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/modalansweryes.cfm | 22 | /qry/addSystem_157_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/modalansweryes.cfm | 24 | /qry/CompleteTargetSystems_157_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/modalansweryes.cfm | 25 | /qry/sudetails_157_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/modalansweryes.cfm | 26 | /qry/Insert_157_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/modalansweryes.cfm | 27 | /qry/addDaysNo_157_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/modalansweryes.cfm | 35 | /qry/checkUnique_157_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/modalansweryes.cfm | 54 | /qry/addNotification_157_9.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/modalansweryes.cfm | 56 | /qry/addNotification_157_10.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/ModalRemoteNewForm.cfm | 3 | /qry/FindModalTitle_107_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/mybrand_pane.cfm | 51 | /qry/essence_sel_470_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/myheadshots_pane.cfm | 23 | /qry/headshots_sel_478_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/mylinks_pane.cfm | 40 | /qry/sitetypes_535_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/mylinks_pane.cfm | 41 | /qry/mylinks_159_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/mylinks_pane.cfm | 173 | /qry/mylinks_user_164_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/mylinks_pane.cfm | 174 | /qry/mylinks_user_del_164_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/mylinks_pane.cfm | 175 | /qry/master_164_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/mymaterials_pane.cfm | 55 | /qry/materials_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/mymaterials_pane.cfm | 149 | /qry/events_166_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/myteam_pane.cfm | 2 | /qry/getMyTeam.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/myteam_pane.cfm | 123 | /qry/getSocialIcons.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/myteam_pane.cfm | 124 | /qry/getRemindersByRelationship.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/myteam_pane_backup.cfm | 23 | /qry/getMyTeam.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/myteam_pane_backup.cfm | 138 | /qry/getSocialIcons.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/myteam_pane_backup.cfm | 139 | /qry/getRemindersByRelationship.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/myteam_pane_fixed.cfm | 2 | /qry/getMyTeam.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/myteam_pane_fixed.cfm | 123 | /qry/getSocialIcons.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/myteam_pane_fixed.cfm | 124 | /qry/getRemindersByRelationship.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-add-aud.cfm | 4 | /qry/relationships_13_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-add-aud2.cfm | 11 | /qry/InsertNote_169_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-add-aud2.cfm | 14 | /qry/CLEAN_169_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-add-event.cfm | 6 | /qry/relationships_13_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-add-event2.cfm | 11 | /qry/InsertNote_171_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-add-event2.cfm | 14 | /qry/CLEAN_169_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-add.cfm | 6 | /qry/relationships_13_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-add2.cfm | 5 | /qry/InsertNote_173_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-update-aud.cfm | 6 | /qry/relationships_13_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-update-aud2.cfm | 11 | /qry/updatenote_175_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-update-aud2.cfm | 14 | /qry/CLEAN_169_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-update-event.cfm | 6 | /qry/relationships_13_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-update-event2.cfm | 11 | /qry/updatenote_177_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-update-event2.cfm | 14 | /qry/CLEAN_169_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-update.cfm | 6 | /qry/relationships_13_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-update2.cfm | 5 | /qry/updatenote_179_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/notesEvent.cfm | 6 | /qry/notesEvent_180_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/notesEvent.cfm | 8 | /qry/notesContactDetails_180_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/notes_aud_pane.cfm | 67 | /qry/links_181_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/notes_aud_pane.cfm | 68 | /qry/attachments_181_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/notes_event_pane.cfm | 66 | /qry/getLinksByNoteId.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/notes_event_pane.cfm | 67 | /qry/attachments_181_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/notes_relationship_pane.cfm | 55 | /qry/links_183_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/notes_relationship_pane.cfm | 56 | /qry/attachments_181_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/order.cfm | 3 | /qry/Finddetails_185_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/order.cfm | 4 | /qry/FindResults_185_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/order.cfm | 5 | /qry/FindKey_185_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/order.cfm | 37 | /qry/find_185_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/order.cfm | 48 | /qry/sql1_185_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/order.cfm | 49 | /qry/sq2_185_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/patchnotes.cfm | 2 | /qry/notes_186_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/pgload.cfm | 27 | /qry/update_187_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/pgload.cfm | 32 | /qry/update_187_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/pgload.cfm | 41 | /qry/fetchusers.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/pgload.cfm | 52 | /qry/#pgFilename# | TECH-DEBT: scope-leaking cfinclude |
| include/pgload_setup.cfm | 11 | /qry/FindUser_188_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/pgload_setup.cfm | 41 | /qry/InsertContact_188_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/pgload_setup.cfm | 46 | /qry/InsertContact_188_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/pgload_setup.cfm | 47 | /qry/InsertContact_188_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/pgload_setup.cfm | 48 | /qry/FindUser_188_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/pgload_setup.cfm | 52 | /qry/FindPage_188_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/pgload_setup.cfm | 58 | /qry/FindFields_188_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/pgload_setup.cfm | 66 | /qry/FindLinksT_188_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/pgload_setup.cfm | 70 | /qry/FindLinksB_188_9.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/pgload_setup.cfm | 74 | /qry/FindLinksExtra_188_10.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/prefs_pane.cfm | 172 | /qry/subsites_189_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/projdate_fix_user.cfm | 9 | /qry/pupdate_191_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/projdate_fix_user.cfm | 13 | /qry/z_191_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/projdate_fix_user.cfm | 25 | /qry/update_191_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/projdate_fix_user.cfm | 29 | /qry/delete_191_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/projdate_fix_user.cfm | 40 | /qry/fix_191_9.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/projdate_fix_user.cfm | 43 | /qry/correct_191_10.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/projdate_fix_user.cfm | 46 | /qry/remove_191_11.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/projdate_fix_user.cfm | 49 | /qry/remove2_191_12.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/addNotification_placeholder.cfm | 1 | /qry/addNotification_326_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/admin-update-log.cfm | 1 | /qry/results_331_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/ageranges_sel.cfm | 3 | /qry/ranges_332_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint-add.cfm | 1 | /qry/contacts_333_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint-add.cfm | 2 | /qry/types_333_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint-info.cfm | 1 | /qry/relationships_334_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint-info.cfm | 2 | /qry/types_334_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint-info.cfm | 3 | /qry/eventdetails_334_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint-info.cfm | 6 | /qry/contacts_334_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint-info.cfm | 8 | /qry/attendees_334_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint-update.cfm | 3 | /qry/relationships_335_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint-update.cfm | 5 | /qry/types_335_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint-update.cfm | 6 | /qry/eventdetails_335_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint-update.cfm | 8 | /qry/findd_335_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint-update.cfm | 16 | /qry/contacts_335_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint.cfm | 1 | /qry/relationships_336_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint.cfm | 2 | /qry/types_336_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint.cfm | 3 | /qry/eventdetails_336_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint.cfm | 6 | /qry/contacts_336_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint.cfm | 8 | /qry/attendees_336_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audageranges_audtion_xref_ins.cfm | 7 | /qry/audageranges_audtion_xref_ins_337_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audageranges_audtion_xref_upd.cfm | 7 | /qry/audageranges_audtion_xref_ins_338_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audageranges_ins.cfm | 13 | /qry/audageranges_ins_339_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audageranges_sel.cfm | 11 | /qry/select_query.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audageranges_upd.cfm | 13 | /qry/audageranges_ins_341_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audanswers_ins.cfm | 15 | /qry/audanswers_ins_342_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audanswers_upd.cfm | 15 | /qry/audanswers_ins_343_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audcallbacktypes_sel.cfm | 3 | /qry/audcallbacktypes_sel_344_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audcallbacktypes_sel.cfm | 5 | /qry/audcallbacktypes_sel_def_344_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audcategories_ins.cfm | 7 | /qry/audcategories_ins_345_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audcategories_sel.cfm | 9 | /qry/select_query.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audcategories_upd.cfm | 7 | /qry/audcategories_ins_347_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audcategory_sel.cfm | 11 | /qry/select_query.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audcontacts.cfm | 4 | /qry/getContactsbyAudProject.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audcontacts.cfm | 6 | /qry/audcontacts_sel_349_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audcontacts_auditions_xref_ins.cfm | 7 | /qry/audcontacts_auditions_xref_ins_350_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audcontacts_auditions_xref_upd.cfm | 7 | /qry/audcontacts_auditions_xref_ins_351_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audcontracttypes_ins.cfm | 9 | /qry/audcontracttypes_ins_352_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audcontracttypes_sel.cfm | 11 | /qry/select_cat_query.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audcontracttypes_upd.cfm | 9 | /qry/audcontracttypes_ins_354_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auddialects_ins.cfm | 9 | /qry/auddialects_ins_355_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auddialects_sel.cfm | 10 | /qry/select_cat_query.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auddialects_upd.cfm | 9 | /qry/auddialects_ins_357_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audgenres_audition_xref.cfm | 3 | /qry/audgenres_audition_xref_359_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audgenres_audition_xref_ins.cfm | 7 | /qry/audgenres_audition_xref_ins_360_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audgenres_audition_xref_upd.cfm | 7 | /qry/audgenres_audition_xref_ins_361_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audgenres_ins.cfm | 9 | /qry/audgenres_ins_362_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audgenres_sel.cfm | 11 | /qry/select_cat_user_query.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audgenres_upd.cfm | 9 | /qry/audgenres_update.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/AUDintoEVENTS.cfm | 17 | /qry/findtype_365_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/AUDintoEVENTS.cfm | 45 | /qry/findloc_365_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/AUDintoEVENTS.cfm | 73 | /qry/add_365_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/AUDintoEVENTS.cfm | 75 | /qry/t_365_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/AUDintoEVENTS.cfm | 77 | /qry/tt_365_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/AUDintoEVENTS.cfm | 79 | /qry/dd_365_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/AUDintoEVENTS.cfm | 81 | /qry/inserts_365_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition-add.cfm | 2 | /qry/relationships_366_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition-add.cfm | 4 | /qry/durations.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition-add2.cfm | 8 | /qry/INScontactdetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition-add2.cfm | 12 | /qry/insert_367_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition-add2.cfm | 16 | /qry/insert_367_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition-add2.cfm | 24 | /qry/add_367_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition-add2.cfm | 26 | /qry/insert_367_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition-add2.cfm | 28 | /qry/insert_367_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition-add2.cfm | 32 | /qry/audprojects_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition-add2.cfm | 33 | /qry/audroles_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition-add2.cfm | 36 | /qry/auditions_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition-add2.cfm | 38 | /qry/update_367_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition-add2.cfm | 42 | /qry/add_cd_28_12.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition.cfm | 17 | /qry/submitsitefix_368_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition.cfm | 20 | /qry/projectDetails_368_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition.cfm | 30 | /qry/roleDetails_368_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition.cfm | 34 | /qry/delete_ref_368_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition.cfm | 37 | /qry/events_368_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition.cfm | 40 | /qry/events_nobooking_368_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition.cfm | 44 | /qry/delete_368_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition.cfm | 46 | /qry/delete2_368_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition.cfm | 53 | /qry/add_aud_contact.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition.cfm | 57 | /qry/getSystemIdBasedOnTag.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition.cfm | 71 | /qry/cdcheck_368_9.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition.cfm | 75 | /qry/add_cd_368_10.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition.cfm | 85 | /qry/audageranges_audtion_xref_368_11.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auditiondetails.cfm | 3 | /qry/auditionDetails_369_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auditionprojectdetails.cfm | 3 | /qry/auditionprojectDetails_370_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auditions.cfm | 2 | /qry/updateEventData.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auditions.cfm | 26 | /qry/coss_371_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auditions.cfm | 30 | /qry/getAuditions.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auditionsimport.cfm | 3 | /qry/imports_372_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auditions_ins.cfm | 33 | /qry/duration.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auditions_ins.cfm | 54 | /qry/auditions_ins_373_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auditions_ins.cfm | 56 | /qry/update_373_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auditions_upd.cfm | 51 | /qry/duration.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auditions_upd.cfm | 73 | /qry/auditions_ins_374_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auditlog.cfm | 3 | /qry/results_375_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audlocations_sel.cfm | 3 | /qry/audlocations_sel_376_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audmedia.cfm | 3 | /qry/audmedia_377_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audmedia.cfm | 5 | /qry/headshots_377_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audmediatypes_ins.cfm | 7 | /qry/audmediatypes_ins_378_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audmediatypes_sel.cfm | 10 | /qry/select_query.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audmediatypes_upd.cfm | 7 | /qry/audmediatypes_ins_380_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audmedia_audroles_xref_ins.cfm | 11 | /qry/audmedia_audroles_xref_ins_381_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audmedia_audroles_xref_upd.cfm | 11 | /qry/audmedia_audroles_xref_ins_382_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audmedia_ins.cfm | 25 | /qry/audmedia_ins_383_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audmedia_ins.cfm | 29 | /qry/find_383_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audmedia_ins.cfm | 33 | /qry/add_383_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audmedia_upd.cfm | 19 | /qry/audmedia_upd_386_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audnetworks_ins.cfm | 9 | /qry/audnetworks_ins_387_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audnetworks_sel.cfm | 12 | /qry/select_cat_user_query.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audnetworks_upd.cfm | 9 | /qry/audnetworks_ins_389_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audnetworks_user_sel.cfm | 11 | /qry/select_cat_user_query.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audpaycycles_sel.cfm | 3 | /qry/audpaycycles_sel_391_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audpaycyles_sel.cfm | 3 | /qry/audpaycyles_sel_392_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audplatforms_ins.cfm | 6 | /qry/audplatforms_ins_393_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audplatforms_sel.cfm | 10 | /qry/select_query.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audplatforms_upd.cfm | 6 | /qry/audplatforms_ins_395_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audplatforms_user_sel.cfm | 11 | /qry/Audplatforms_user_sel_396_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audprojects_castingabout_ins.cfm | 42 | /qry/audprojects_castingabout_ins_397_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audprojects_castingabout_upd.cfm | 17 | /qry/audprojects_castingabout_ins_398_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audprojects_ins.cfm | 26 | /qry/audprojects_ins_399_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audprojects_sel.cfm | 11 | /qry/select_user_query.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audprojects_upd.cfm | 52 | /qry/audprojects_ins_401_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audqtypes_ins.cfm | 7 | /qry/audqtypes_ins_402_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audqtypes_sel.cfm | 11 | /qry/select_query.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audqtypes_upd.cfm | 9 | /qry/audqtypes_ins_404_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audquestions_default_ins.cfm | 8 | /qry/audquestions_default_ins_405_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audquestions_default_upd.cfm | 11 | /qry/audquestions_default_ins_406_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audquestions_user_ins.cfm | 18 | /qry/audquestions_user_ins_407_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audquestions_user_upd.cfm | 18 | /qry/audquestions_user_ins_408_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audroles_ins.cfm | 35 | /qry/audroles_ins_409_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audroles_sel.cfm | 11 | /qry/select_user_query.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audroles_upd.cfm | 33 | /qry/audroles_ins_411_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audroletypes_ins.cfm | 7 | /qry/audroletypes_ins_412_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audroletypes_sel.cfm | 10 | /qry/select_cat_query.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audroletypes_upd.cfm | 12 | /qry/audroletypes_ins_414_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audsources_ins.cfm | 7 | /qry/audsources_ins_415_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audsources_sel.cfm | 10 | /qry/select_user_query_noisdelete.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audsources_upd.cfm | 7 | /qry/audsources_ins_417_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audsteps_ins.cfm | 6 | /qry/audsteps_ins_418_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audsteps_sel.cfm | 9 | /qry/select_query.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audsteps_upd.cfm | 7 | /qry/audsteps_ins_420_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audsubcategories_ins.cfm | 8 | /qry/audsubcategories_ins_421_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audsubcategories_sel.cfm | 11 | /qry/select_cat_query.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audsubcategories_upd.cfm | 8 | /qry/audsubcategories_ins_423_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auds_byrole.cfm | 6 | /qry/events_424_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audtones_ins.cfm | 8 | /qry/audtones_ins_425_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audtones_sel.cfm | 14 | /qry/select_cat_user_query.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audtones_upd.cfm | 8 | /qry/audtones_ins_427_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audtones_user_sel.cfm | 2 | /qry/audtones_user_sel_428_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audtypes_ins.cfm | 7 | /qry/audtypes_ins_429_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audtypes_sel.cfm | 5 | /qry/audtypes_sel_430_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audtypes_upd.cfm | 7 | /qry/audtypes_ins_431_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audunions_ins.cfm | 8 | /qry/audunions_ins_432_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audunions_sel.cfm | 7 | /qry/audunions_sel_433_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audunions_upd.cfm | 8 | /qry/audunions_ins_434_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audvocaltypes_audition_xref_ins.cfm | 7 | /qry/audvocaltypes_audition_xref_ins_435_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audvocaltypes_audition_xref_upd.cfm | 7 | /qry/audvocaltypes_audition_xref_ins_436_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audvocaltypes_ins.cfm | 7 | /qry/audvocaltypes_ins_437_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audvocaltypes_sel.cfm | 9 | /qry/select_query.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audvocaltypes_upd.cfm | 7 | /qry/audvocaltypes_ins_439_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/aud_det.cfm | 3 | /qry/aud_det_440_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/aud_questions.cfm | 2 | /qry/questions_441_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/birthdays.cfm | 2 | /qry/birthdays_442_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/calendar-appoint.cfm | 3 | /qry/eventss_443_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/calendar-appoint.cfm | 5 | /qry/updateEventData.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/castingdirectors_sel.cfm | 6 | /qry/castingdirectors_sel_445_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/categories.cfm | 2 | /qry/categories_446_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/checkUniqueContact.cfm | 3 | /qry/checkUnique_447_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/cities.cfm | 3 | /qry/cities_448_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contact.cfm | 3 | /qry/details_451_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contact.cfm | 7 | /qry/refer_details_451_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contact.cfm | 11 | /qry/results_451_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contact.cfm | 14 | /qry/pronouns_451_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contacts.cfm | 3 | /qry/systems_452_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contacts.cfm | 5 | /qry/systemnames_452_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contacts_all.cfm | 3 | /qry/systems_453_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contacts_all.cfm | 5 | /qry/systemnames_453_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contacts_all_tabs.cfm | 3 | /qry/systems_454_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contacts_check.cfm | 6 | /qry/contacts_all.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contacts_check.cfm | 9 | /qry/contacts.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contact_info.cfm | 5 | /qry/details_456_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contact_info.cfm | 9 | /qry/refer_details_456_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contact_info.cfm | 13 | /qry/results_456_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contact_info.cfm | 16 | /qry/pronouns_456_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/dashboard.cfm | 3 | /qry/dashboards_458_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/dashboard.cfm | 5 | /qry/notsActives_458_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/dashboardoptions.cfm | 3 | /qry/dashboards_459_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/dashboardupdate2.cfm | 6 | /qry/del_460_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/dashboardupdate2.cfm | 14 | /qry/pgpanels_460_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/dashboardupdate2.cfm | 21 | /qry/insert_460_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/dashboard_new.cfm | 1 | /qry/dashboards_458_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/dash_rr.cfm | 3 | /qry/r_462_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/dateformats.cfm | 6 | /qry/getAllDateFormats.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/default_table_ins.cfm | 13 | /qry/allfields_536_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/default_table_ins.cfm | 16 | /qry/x_464_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/default_table_ins.cfm | 51 | /qry/tname_ins_464_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/details.cfm | 2 | /qry/FindFields_188_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/details.cfm | 8 | /qry/FindKey_466_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/details.cfm | 64 | /qry/FindResults_466_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/details.cfm | 67 | /qry/FindJoins_466_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/details.cfm | 117 | /qry/details_466_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/duration.cfm | 3 | /qry/duration_467_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/emailcheck.cfm | 3 | /qry/emailcheck_469_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/essence_sel.cfm | 6 | /qry/essence_sel_470_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/events.cfm | 10 | /qry/eventresults_471_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/events_byuser.cfm | 3 | /qry/events_472_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/eventtypes_user.cfm | 10 | /qry/eventtypes_user_473_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/findcompany.cfm | 3 | /qry/findcompany_476_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/fu_actions.cfm | 3 | /qry/actions_159_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/getAuditionMaterials.cfm | 3 | /qry/audmedia_384_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/getAuditionMediaPicklist.cfm | 3 | /qry/audmedia_picklist_385_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/headshots_sel.cfm | 6 | /qry/headshots_sel_478_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/headshots_sel_unused.cfm | 6 | /qry/headshots_sel_479_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/import.cfm | 3 | /qry/details_484_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/incometypes_sel.cfm | 6 | /qry/incometypes_sel_486_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/inserttlog.cfm | 13 | /qry/inserttlog_487_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/items.cfm | 5 | /qry/items_488_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/itemsAll.cfm | 6 | /qry/itemsAll_489_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/locationDetails.cfm | 2 | /qry/locationDetails_492_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/materials_details.cfm | 6 | /qry/materials_details_493_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/materials_sel_unused.cfm | 5 | /qry/headshots_sel_495_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/mylinks.cfm | 3 | /qry/mylinks_498_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/myteam.cfm | 3 | /qry/myteam_499_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/myteam.cfm | 5 | /qry/audsources_sel_499_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/note-add-aud.cfm | 3 | /qry/details_500_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/note-add-event.cfm | 3 | /qry/events_501_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/note-add-event.cfm | 5 | /qry/details_501_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/note-add.cfm | 3 | /qry/events_502_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/note-add.cfm | 5 | /qry/details_502_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/note-update-aud.cfm | 3 | /qry/note_503_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/note-update-aud.cfm | 5 | /qry/details_503_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/note-update-event.cfm | 3 | /qry/events_504_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/note-update-event.cfm | 5 | /qry/note_504_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/note-update-event.cfm | 7 | /qry/details_504_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/note-update.cfm | 3 | /qry/events_505_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/note-update.cfm | 5 | /qry/note_505_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/note-update.cfm | 7 | /qry/details_505_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/NotesAud.cfm | 7 | /qry/notesaud_506_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/NotesAud.cfm | 10 | /qry/notesContactDetails_506_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/notesContact.cfm | 7 | /qry/notesContact_507_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/notesContact.cfm | 10 | /qry/notesContactDetails_507_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/notesEvent.cfm | 7 | /qry/notesEvent_508_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/notesEvent.cfm | 10 | /qry/notesContactDetails_508_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/notesrelationship.cfm | 7 | /qry/notesRelationship_509_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/notesrelationship.cfm | 10 | /qry/notesContactDetails_509_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/notsactive.cfm | 8 | /qry/notsActive_510_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/notsactive.cfm | 11 | /qry/notsInactive_510_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/notsactivedash.cfm | 6 | /qry/reminders_511_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/notsactivedash.cfm | 9 | /qry/notsActive_511_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/notsactivedash.cfm | 12 | /qry/notsActives_511_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/notsall.cfm | 3 | /qry/notsall_512_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/phonecheck.cfm | 3 | /qry/phonecheck_515_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/profiles.cfm | 3 | /qry/profiles_516_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/projectDetails.cfm | 3 | /qry/projectDetails_517_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/rels.cfm | 3 | /qry/rels_519_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/remoteaudadd.cfm | 12 | /qry/audcategories_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/remoteaudadd.cfm | 15 | /qry/audsubcategories_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/remoteUpdateC.cfm | 3 | /qry/details_521_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/remoteUpdateC.cfm | 8 | /qry/findcountry_521_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/remoteUpdateC.cfm | 14 | /qry/findregion_521_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/remoteUpdateC.cfm | 22 | /qry/types_521_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/remoteUpdateC.cfm | 145 | /qry/companies_521_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/remote_aud_project_update.cfm | 2 | /qry/audunions_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/remote_aud_project_update.cfm | 3 | /qry/audnetworks_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/remote_aud_project_update.cfm | 4 | /qry/auditionrojectDetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/reportcolors.cfm | 3 | /qry/reportcolors_523_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/reports.cfm | 20 | /qry/reportcheck_524_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/reports.cfm | 24 | /qry/u_524_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/reports.cfm | 27 | /qry/x_524_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/reports.cfm | 30 | /qry/find_524_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/reports.cfm | 34 | /qry/insert_524_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/reports.cfm | 41 | /qry/finditems_524_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/reports.cfm | 51 | /qry/ranges_524_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/reports.cfm | 53 | /qry/rangeselected_524_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/reports.cfm | 74 | /qry/reports_524_9.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/reports.cfm | 77 | /qry/stats_524_10.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/reports.cfm | 80 | /qry/categories_524_11.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/reports.cfm | 83 | /qry/ratio_13_524_12.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/reports.cfm | 85 | /qry/ratio_17_524_13.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/results.cfm | 3 | /qry/FindFields_188_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/results.cfm | 19 | /qry/FindKey_526_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/results.cfm | 24 | /qry/FindResults_526_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/results.cfm | 27 | /qry/FindJoins_526_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/results.cfm | 50 | /qry/results_526_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/selectActions.cfm | 2 | /qry/getFuSystemUsersBySystemID.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/select_cat_query.cfm | 6 | /qry/tname_sel_529_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/select_cat_query.cfm | 21 | /qry/cats_529_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/select_cat_query.cfm | 28 | /qry/bycat_529_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/select_cat_user_query.cfm | 7 | /qry/tname_sel_530_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/select_query.cfm | 5 | /qry/tname_sel_531_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/select_user_query.cfm | 5 | /qry/tname_sel_532_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/select_user_query_noisdelete.cfm | 6 | /qry/tname_sel_533_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/share.cfm | 3 | /qry/shares_534_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/sitetypes.cfm | 2 | /qry/sitetypes_535_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/sql.cfm | 3 | /qry/y_536_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/sql.cfm | 10 | /qry/allfields_536_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/sql.cfm | 12 | /qry/x_536_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/sql.cfm | 14 | /qry/findp_536_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/sql.cfm | 48 | /qry/find_536_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/sysActive.cfm | 6 | /qry/sysActive_537_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/systemNotificationsActive.cfm | 12 | /qry/FindUser_538_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/SystemsActiveContact.cfm | 3 | /qry/FindUser_539_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/SystemsActiveContact.cfm | 5 | /qry/findscope_539_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/SystemsActiveContact.cfm | 15 | /qry/sysAvail_539_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/SystemsContact.cfm | 3 | /qry/Systems_540_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/tagsContact.cfm | 3 | /qry/TagsContact_541_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/tagsvalid.cfm | 3 | /qry/tagsvalid_542_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/testing.cfm | 10 | /qry/statuses_543_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/testing.cfm | 13 | /qry/details_543_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/testings.cfm | 3 | /qry/results_544_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/timezones.cfm | 3 | /qry/getAllTimezones.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/timezones.cfm | 5 | /qry/getMinimalTimezones.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/tmpcontactgroups.cfm | 6 | /qry/BatchDetails_548_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/toasts.cfm | 3 | /qry/toasts_549_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/toasts.cfm | 5 | /qry/toastmenu_549_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/update.cfm | 8 | /qry/FindKey_550_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/update.cfm | 27 | /qry/FindResults_550_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/update.cfm | 30 | /qry/FindJoins_550_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/update.cfm | 80 | /qry/update_550_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/updateNotification.cfm | 2 | /qry/update_551_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/update_action_users.cfm | 2 | /qry/update_552_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/update_action_users2.cfm | 2 | /qry/update_553_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/version-add.cfm | 2 | /qry/statuses_554_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/version-update.cfm | 3 | /qry/details_555_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/version-update.cfm | 5 | /qry/statuses_555_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/version.cfm | 9 | /qry/details_556_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/version.cfm | 11 | /qry/results_556_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/version.cfm | 13 | /qry/priorities_556_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/versions.cfm | 3 | /qry/results_557_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reminder_pane_fucked.cfm | 24 | /qry/notsactive_510_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remotaudmatadd.cfm | 12 | /qry/getAuditionMediaTypes.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteactionUpdate.cfm | 3 | /qry/actiondetails_194_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteactionUpdateUpdate.cfm | 11 | /qry/updateActionUsersByActionUpdate.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteactionUpdateUpdate.cfm | 14 | /qry/k_195_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteactionUpdateUpdate.cfm | 20 | /qry/up_195_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaddaudsubmitsite.cfm | 27 | /qry/getCategories_196_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaddaudsubmitsite2.cfm | 9 | /qry/find_197_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaddaudsubmitsite2.cfm | 13 | /qry/update_197_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaddaudsubmitsite2.cfm | 18 | /qry/add_197_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaddC.cfm | 16 | /qry/fetchLocationService.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaddC.cfm | 18 | /qry/details_198_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaddC.cfm | 22 | /qry/types_198_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaddC.cfm | 24 | /qry/types_198_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaddC.cfm | 194 | /qry/companies_198_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddCAdd.cfm | 12 | /qry/insert_199_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddCAdd.cfm | 17 | /qry/insertx_199_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddCAdd.cfm | 20 | /qry/add_199_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddCAdd.cfm | 27 | /qry/findcountry_199_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddCAdd.cfm | 35 | /qry/findregion_199_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddCAdd.cfm | 76 | /qry/update_199_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContact.cfm | 5 | /qry/tags_200_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAdd.cfm | 15 | /qry/add_201_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAdd.cfm | 21 | /qry/insert_201_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAdd.cfm | 27 | /qry/insert_201_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAdd.cfm | 32 | /qry/insert_201_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAdd.cfm | 37 | /qry/insert_201_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAddaud.cfm | 16 | /qry/add_202_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAddaud.cfm | 23 | /qry/insert_202_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAddaud.cfm | 29 | /qry/insert_202_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAddaud.cfm | 34 | /qry/insert_201_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAddaud.cfm | 39 | /qry/insert_202_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAddaud.cfm | 44 | /qry/insert_202_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAddaud.cfm | 52 | /qry/add_cd_202_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAddaud.cfm | 62 | /qry/findnumber_202_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAddaud.cfm | 66 | /qry/inserts_202_9.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAud.cfm | 16 | /qry/events_203_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAud.cfm | 19 | /qry/tags_203_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAud.cfm | 22 | /qry/companies_203_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddEssenceContact2.cfm | 3 | /qry/add_sitetype_205_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaddHeadshot.cfm | 23 | /qry/getAuditionMediaTypes.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaddHeadshot2.cfm | 38 | /qry/audmedia_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaddMaterial.cfm | 25 | /qry/SEL_Media_types_material.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaddMaterial2.cfm | 36 | /qry/audmedia_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddName.cfm | 10 | /qry/pronouns_210_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddName.cfm | 11 | /qry/refers_210_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddNameAdd.cfm | 5 | /qry/add_211_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteapprove.cfm | 3 | /qry/details_212_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteapprove.cfm | 4 | /qry/users_212_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteapprove.cfm | 5 | /qry/find_212_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteapprove2.cfm | 5 | /qry/Insert_213_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteapprove2.cfm | 8 | /qry/update_213_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteapprove2.cfm | 15 | /qry/updateticket_213_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteapprove2.cfm | 18 | /qry/updateticket_213_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteassForm.cfm | 3 | /qry/aud_questions.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteassForm.cfm | 8 | /qry/x_214_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteassForm.cfm | 12 | /qry/insert_41_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteassForm.cfm | 15 | /qry/aud_questions.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteassFormUpdate.cfm | 3 | /qry/aud_questions.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteassFormUpdate.cfm | 21 | /qry/audanswers_ins_215_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudadd.cfm | 12 | /qry/audcategories_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudadd.cfm | 15 | /qry/audsubcategories_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudaddform.cfm | 7 | /qry/aud_details_217_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudaddform.cfm | 8 | /qry/audlocations_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudaddform.cfm | 12 | /qry/audtypes_sel_217_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudaddform.cfm | 13 | /qry/audsteps_sel_217_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudaddform.cfm | 14 | /qry/audplatforms_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudaddform2.cfm | 5 | /qry/audlocations_ins_218_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudaddform2.cfm | 9 | /qry/findproject_218_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudaddform2.cfm | 16 | /qry/auditions_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudmatadd2.cfm | 33 | /qry/audmedia_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 10 | /qry/durations.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 11 | /qry/fetchLocationService.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 12 | /qry/fetchusers.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 13 | /qry/audplatforms_user_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 14 | /qry/projectDetails_221_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 17 | /qry/roleDetails_221_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 18 | /qry/locationDetails_492_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 20 | /qry/cat_221_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 21 | /qry/cat_221_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 22 | /qry/audroletypes_sel_27_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 23 | /qry/audtypes_sel_221_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 24 | /qry/casting_types_221_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 25 | /qry/castingdirectors_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 49 | /qry/auditions_ins_221_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 59 | /qry/aud_det_221_9.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 61 | /qry/audtypes_sel_221_11.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 62 | /qry/audsteps_sel_217_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 63 | /qry/audplatforms_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 79 | /qry/findd_221_10.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 199 | /qry/audcallbacktypes_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 256 | /qry/audbooktypes_sel_221_13.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform2.cfm | 7 | /qry/FIND_222_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform2.cfm | 11 | /qry/insert_28_11.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform2.cfm | 20 | /qry/auditions_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform2.cfm | 21 | /qry/activate_222_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform2.cfm | 23 | /qry/auditionDetails_222_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform2.cfm | 24 | /qry/projectDetails_222_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform2.cfm | 37 | /qry/FindEvent_222_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remotecontent.cfm | 3 | /qry/details_223_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remotecontent.cfm | 4 | /qry/uu_223_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDelete.cfm | 9 | /qry/attachdetails_109_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDelete2.cfm | 2 | /qry/audmedia_details_225_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteaudmedia.cfm | 7 | /qry/audmedia_details_226_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteaudmedia2.cfm | 2 | /qry/audmedia_details_225_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteForm.cfm | 14 | /qry/FindKey_228_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteForm.cfm | 15 | /qry/Findrec_228_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteFormAud.cfm | 3 | /qry/details_229_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteFormAudDelete.cfm | 2 | /qry/del_230_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteFormAudDelete.cfm | 4 | /qry/del2_230_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteFormAudDelete.cfm | 6 | /qry/remove_191_11.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteFormAudprojectDelete.cfm | 3 | /qry/projectDetails_232_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteFormAudprojectDelete.cfm | 7 | /qry/roleDetails_232_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteFormAudprojectDelete.cfm | 9 | /qry/events_232_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteFormAudprojectDelete.cfm | 15 | /qry/del_232_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteFormAudprojectDelete.cfm | 19 | /qry/del2_232_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteFormAudprojectDelete.cfm | 20 | /qry/del3_232_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteFormAudprojectDelete.cfm | 21 | /qry/del4_232_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteFormAudprojectDelete.cfm | 22 | /qry/remove_191_11.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteFormDelete.cfm | 26 | /qry/delete_233_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteFormDelete.cfm | 39 | /qry/del_233_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteheadshots_auditions_xref.cfm | 3 | /qry/audmedia_details_226_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteheadshots_auditions_xref2.cfm | 3 | /qry/audmedia_headshots_delete.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeletelink.cfm | 3 | /qry/audlink_details_237_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteLink2.cfm | 3 | /qry/audmedia_details_238_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteheadingupdate.cfm | 4 | /qry/updates_239_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteheadingupdate2.cfm | 6 | /qry/add_240_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteheadingupdate2.cfm | 8 | /qry/pgPanelsFix.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remotelinkadd2.cfm | 10 | /qry/find_242_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remotelinkadd2.cfm | 30 | /qry/add_242_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteNewForm.cfm | 117 | /qry/selects_245_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteNewForm.cfm | 147 | /qry/selects_245_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteNewFormAdd.cfm | 32 | /qry/find_246_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remotenotedetails.cfm | 12 | /qry/getNoteDetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remotepaneladd2.cfm | 7 | /qry/find_249_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remotepaneladd2.cfm | 15 | /qry/add_sitetype_249_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remotepaneladd2.cfm | 20 | /qry/findit_249_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remotepaneladd2.cfm | 26 | /qry/Findtotal_249_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remotepaneladd2.cfm | 29 | /qry/add_249_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remotepaneladd2.cfm | 32 | /qry/add_249_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteRemoveaudmedia.cfm | 8 | /qry/audmedia_details_226_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteRemoveaudmedia2.cfm | 3 | /qry/audmedia_details_225_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteselectedheadshot2.cfm | 5 | /qry/ins_252_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteselectedheadshot2.cfm | 8 | /qry/ins_252_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteselectedmaterial2.cfm | 5 | /qry/ins_253_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteselectedmaterial2.cfm | 8 | /qry/ins_252_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteselectheadshot.cfm | 3 | /qry/headshots_sel_unused.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteselectheadshot.cfm | 5 | /qry/getAuditionMediaTypes.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteselectmaterial.cfm | 2 | /qry/materials_sel_unused.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteselectmaterial.cfm | 4 | /qry/getAuditionMediaTypes.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteSupportFormAdd.cfm | 48 | /qry/inserttlog.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateaudsubmitsite.cfm | 3 | /qry/details_259_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateaudsubmitsite.cfm | 29 | /qry/getCategories_196_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateaudsubmitsite.cfm | 50 | /qry/findsubs_259_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateaudsubmitsite2.cfm | 6 | /qry/subsites_189_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateaudsubmitsite2.cfm | 15 | /qry/update_260_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateC.cfm | 3 | /qry/fetchLocationService.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateC.cfm | 4 | /qry/details_261_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateC.cfm | 9 | /qry/findcountry_261_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateC.cfm | 16 | /qry/findregion_261_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateC.cfm | 27 | /qry/types.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateC.cfm | 178 | /qry/companies_198_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateCUpdate.cfm | 15 | /qry/insert_262_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateCUpdate.cfm | 20 | /qry/insertx_262_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateCUpdate.cfm | 24 | /qry/findcountry_199_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateCUpdate.cfm | 31 | /qry/findregion_262_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateCUpdate.cfm | 58 | /qry/update_262_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateCUpdate.cfm | 59 | /qry/update2_262_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateEssenceContact.cfm | 3 | /qry/details_263_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateEssenceContact2.cfm | 5 | /qry/update_264_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateForm.cfm | 13 | /qry/FindModalTitle_265_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateForm.cfm | 14 | /qry/update.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateForm.cfm | 20 | /qry/find_265_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateForm.cfm | 55 | /qry/FindValue_265_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateForm.cfm | 135 | /qry/FindValue_265_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateForm.cfm | 136 | /qry/selects_265_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateForm.cfm | 155 | /qry/FindValue_265_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateForm.cfm | 156 | /qry/selects_265_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateForm.cfm | 175 | /qry/FindValue_265_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateForm.cfm | 177 | /qry/selects_265_9.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateForm.cfm | 219 | /qry/FindValue_265_10.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateForm.cfm | 220 | /qry/selects_265_11.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateForm.cfm | 250 | /qry/selects_107_12.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateFormUpdate.cfm | 76 | /qry/FindOld_266_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateFormUpdate.cfm | 124 | /qry/update_266_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateFormUpdate.cfm | 125 | /qry/INSERT_266_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateFormUpdate.cfm | 149 | /qry/Finddetails_266_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateMaterial.cfm | 25 | /qry/materials_details.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateMaterial.cfm | 26 | /qry/SEL_Media_types_material.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateMaterial2.cfm | 10 | /qry/audmedia_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateName.cfm | 53 | /qry/pronouns_210_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateName.cfm | 54 | /qry/refers_210_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateName.cfm | 55 | /qry/details_269_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateNameUpdate.cfm | 24 | /qry/updatecontact_270_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateNameUpdate.cfm | 33 | /qry/find_270_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateNameUpdate.cfm | 37 | /qry/add_270_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateSUID.cfm | 2 | /qry/reldetails_271_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateTag.cfm | 3 | /qry/tagsContact.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateTag.cfm | 26 | /qry/tags_203_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateTag.cfm | 49 | /qry/findt_272_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUserUpdate.cfm | 1 | /qry/getUserDetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUserUpdate.cfm | 3 | /qry/getAllCountries.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUserUpdate.cfm | 5 | /qry/getAllRegions.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUserUpdated.cfm | 1 | /qry/qry_block_1_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteverticketupdate.cfm | 3 | /qry/details_274_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteverticketupdate.cfm | 4 | /qry/uu_274_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteverticketupdate.cfm | 5 | /qry/pages_274_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteverticketupdate.cfm | 6 | /qry/users_274_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteverticketupdate.cfm | 7 | /qry/statuses_274_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteverticketupdate.cfm | 8 | /qry/types_256_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteverticketupdate.cfm | 9 | /qry/priorities_274_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteverticketupdate.cfm | 10 | /qry/vers_274_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteverticketupdate2.cfm | 3 | /qry/update_275_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteverticketupdate2.cfm | 4 | /qry/details_275_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update.cfm | 6 | /qry/auditionprojectDetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update.cfm | 7 | /qry/audcategories_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update.cfm | 8 | /qry/audsubcategories_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update.cfm | 9 | /qry/audunions_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update.cfm | 10 | /qry/audnetworks_user_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update.cfm | 11 | /qry/audtones_user_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update.cfm | 12 | /qry/audcontracttypes_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update.cfm | 13 | /qry/castingdirectors_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update.cfm | 15 | /qry/audplatforms_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update.cfm | 16 | /qry/incometypes_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update.cfm | 17 | /qry/audpaycyles_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update2.cfm | 6 | /qry/insert_277_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update2.cfm | 15 | /qry/insert_277_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update2.cfm | 22 | /qry/find_new_277_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update2.cfm | 26 | /qry/audcontacts_auditions_xref_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update2.cfm | 31 | /qry/del_277_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update2.cfm | 34 | /qry/audprojects_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_load.cfm | 3 | /qry/findit_278_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/removestatus.cfm | 8 | /qry/update_68_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reportrangegenerator.cfm | 3 | /qry/x_280_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reportrangegenerator.cfm | 96 | /qry/update2_280_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reportrangegenerator.cfm | 100 | /qry/update2_280_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reports.cfm | 97 | /qry/dataset_x_281_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reports.cfm | 150 | /qry/reportitems_x_281_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reports.cfm | 151 | /qry/dataset_x_281_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reports.cfm | 152 | /qry/labels_x_281_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reports.cfm | 158 | /qry/values_x_281_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reportsRefresh.cfm | 18 | /qry/delete_all_282_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reportsRefresh.cfm | 19 | /qry/rangeselected_282_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reportsRefresh.cfm | 21 | /qry/reportRefresh.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reports_backup.cfm | 97 | /qry/dataset_x_281_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reports_backup.cfm | 150 | /qry/reportitems_x_281_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reports_backup.cfm | 151 | /qry/dataset_x_281_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reports_backup.cfm | 152 | /qry/labels_x_281_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reports_backup.cfm | 159 | /qry/values_x_281_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/restoreaction.cfm | 3 | /qry/removenotdups.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/restoreaction.cfm | 5 | /qry/restoreActionUsers.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/results.cfm | 86 | /qry/FindDetails_284_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/rolecheck.cfm | 28 | /qry/update_285_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 7 | /qry/audition.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 9 | /qry/essence_sel_470_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 10 | /qry/audroletypes_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 11 | /qry/myteam_499_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 12 | /qry/auddialects_user_sel_358_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 13 | /qry/audsources_sel_499_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 210 | /qry/opencalls_286_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 221 | /qry/findc_286_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 266 | /qry/referrals_286_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 277 | /qry/findc_286_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 312 | /qry/subsites_286_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 351 | /qry/ranges_286_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 358 | /qry/findt_286_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 422 | /qry/vocals_286_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 429 | /qry/findt_286_9.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 455 | /qry/essences_286_10.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 461 | /qry/findg_286_11.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 491 | /qry/findit_286_12.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 497 | /qry/genres_286_13.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 503 | /qry/findge_286_14.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 83 | /qry/delete_287_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 84 | /qry/delete_287_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 85 | /qry/delete_287_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 86 | /qry/delete_287_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 87 | /qry/delete_287_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 91 | /qry/findit2_287_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 96 | /qry/insert_287_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 104 | /qry/findit_287_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 109 | /qry/insert_287_9.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 113 | /qry/insert_287_10.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 122 | /qry/findit_287_11.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 126 | /qry/insert_287_12.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 128 | /qry/insert_287_13.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 130 | /qry/insert_287_14.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 137 | /qry/delete_287_15.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 140 | /qry/insert_287_16.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 146 | /qry/delete_287_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 149 | /qry/insert_287_18.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 171 | /qry/findg_287_19.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 190 | /qry/add_287_20.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 204 | /qry/find_subsite_287_21.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 232 | /qry/update_287_22.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 242 | /qry/add_287_23.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 271 | /qry/insert_287_24.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 278 | /qry/audroles_upd_287_25.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/rpg_load.cfm | 2 | /qry/RPG_288_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/rpg_load.cfm | 3 | /qry/RPGFields_288_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/rpg_load.cfm | 4 | /qry/RPGResults_288_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/rpg_load.cfm | 5 | /qry/RPGkey_288_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/rpg_load.cfm | 6 | /qry/RPGAdd_288_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/rpg_load.cfm | 7 | /qry/RPGUpdate_288_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/share.cfm | 21 | /qry/x_291_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/sql.cfm | 2 | /qry/y_292_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/sql.cfm | 8 | /qry/allfields_536_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/sql.cfm | 9 | /qry/x_292_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/sql.cfm | 10 | /qry/findp_292_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/sql.cfm | 44 | /qry/find_292_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/systemchange.cfm | 24 | /qry/FindSystem_294_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/systemchange.cfm | 25 | /qry/FindSystemOld_294_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/systemchange.cfm | 52 | /qry/InsertNote_294_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/systemchange.cfm | 57 | /qry/InsertNote_294_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/systemchange.cfm | 62 | /qry/InsertNote_294_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/systemchange.cfm | 67 | /qry/InsertNote_294_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/systemchange.cfm | 72 | /qry/InsertNote_294_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/systemchange.cfm | 77 | /qry/InsertNote_294_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/systemprefs_pane.cfm | 3 | /qry/mysystems_295_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/systemprefs_pane.cfm | 20 | /qry/action_user_295_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/systemprefs_pane.cfm | 21 | /qry/action_user_del_295_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/TagChange.cfm | 12 | /qry/delete_298_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/TagChange.cfm | 19 | /qry/find_298_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/TagChange.cfm | 23 | /qry/insert_tag_298_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/TagChange.cfm | 24 | /qry/find_298_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/TagChange.cfm | 27 | /qry/insert_298_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/TagChange.cfm | 32 | /qry/y_298_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/TagChange.cfm | 36 | /qry/find_orphan_298_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/TagChange.cfm | 40 | /qry/d_298_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/thrivecart_results.cfm | 14 | /qry/thrivecart_results.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/ticketclose.cfm | 2 | /qry/uu_223_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/ticketclose.cfm | 3 | /qry/update_299_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/ticketcomplete.cfm | 4 | /qry/find_300_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/ticketcomplete.cfm | 6 | /qry/update_300_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/ticketcomplete.cfm | 7 | /qry/details_303_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/ticketpass.cfm | 2 | /qry/update_302_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/ticket_email_client.cfm | 6 | /qry/find_303_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/ticket_email_client.cfm | 13 | /qry/update_303_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/ticket_email_client.cfm | 16 | /qry/details_303_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/tmpcontactgroups.cfm | 17 | /qry/BatchDetails_304_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/tmpcontactgroups.cfm | 34 | /qry/lastupdates.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/tmpcontactgroups.cfm | 61 | /qry/FindScope_304_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/tmpcontactgroups.cfm | 85 | /qry/FindSystem_304_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/tmpcontactgroups.cfm | 99 | /qry/FindActive_304_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/tmpcontactgroups.cfm | 138 | /qry/findsame_304_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/tmpcontactgroups.cfm | 156 | /qry/delete_304_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/tmpcontacttags.cfm | 30 | /qry/lastupdates.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/tmpcontacttags.cfm | 42 | /qry/BatchDetails_304_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/tmpcontacttags.cfm | 60 | /qry/findsame_305_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/tmpcontacttags.cfm | 67 | /qry/insert_305_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/tmpcontacttags.cfm | 94 | /qry/insert_305_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/toast.cfm | 2 | /qry/toasts_306_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/toast.cfm | 3 | /qry/toastmenu_306_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 18 | /qry/y_308_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 30 | /qry/find_308_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 37 | /qry/err_308_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 44 | /qry/err_308_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 51 | /qry/err_308_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 56 | /qry/findcat_308_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 62 | /qry/err_308_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 66 | /qry/findsource_308_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 71 | /qry/err_308_9.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 74 | /qry/update_308_10.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 79 | /qry/x_308_11.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 81 | /qry/x_308_12.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 96 | /qry/findcd_308_13.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 101 | /qry/INScontactDetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 109 | /qry/insert_28_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 131 | /qry/find_subcat_308_16.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 170 | /qry/find_cat_308_17.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 174 | /qry/find_subcat_308_18.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 185 | /qry/audprojects_ins_308_19.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 190 | /qry/find_source_308_20.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 200 | /qry/audroles_ins_308_21.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 203 | /qry/InsertNote_308_22.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 206 | /qry/update_contact_308_23.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/updateeventtype.cfm | 3 | /qry/linkdetails_309_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/updateeventtype.cfm | 4 | /qry/find_events_309_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/updateeventtypeupdate.cfm | 6 | /qry/update_310_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/UpdateFormUpdate.cfm | 76 | /qry/FindOld_311_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/UpdateFormUpdate.cfm | 122 | /qry/update_311_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/UpdateFormUpdate.cfm | 123 | /qry/INSERT_266_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/updatetickver2.cfm | 3 | /qry/update_312_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/updatetickver2.cfm | 4 | /qry/details_312_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/updatetickver2.cfm | 18 | /qry/inserttlog.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/updatetickver2.cfm | 23 | /qry/old_312_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/updatetickver2.cfm | 24 | /qry/new_312_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/updatetickver2.cfm | 46 | /qry/inserttlog.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/update_cal.cfm | 9 | /qry/update_cal.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/update_import_auditions.cfm | 27 | /qry/find_313_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/update_import_auditions.cfm | 32 | /qry/update_record_313_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/update_order.cfm | 7 | /qry/query_0_314_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 6 | /qry/INSERT_315_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 27 | /qry/find_315_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 29 | /qry/getContactsImportByUploadID.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 33 | /qry/add_315_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 41 | /qry/find_note_315_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 44 | /qry/InsertNote_315_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 52 | /qry/tag_315_10.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 55 | /qry/tag_insert_315_11.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 58 | /qry/tag_315_12.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 62 | /qry/tag_insert_315_13.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 65 | /qry/tag_315_14.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 68 | /qry/tag_insert_315_15.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 71 | /qry/e_315_16.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 73 | /qry/e_insert_315_17.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 76 | /qry/f_315_18.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 78 | /qry/f_insert_315_19.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 81 | /qry/g_315_20.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 83 | /qry/g_insert_315_21.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 86 | /qry/h_315_22.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 88 | /qry/h_insert_315_23.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 91 | /qry/i_315_24.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 93 | /qry/i_insert_315_25.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 96 | /qry/j_315_26.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 98 | /qry/j_insert_315_27.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 101 | /qry/u_315_28.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 103 | /qry/u_insert_315_29.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 106 | /qry/address_315_30.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 110 | /qry/address_insert_315_31.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 117 | /qry/maints_315_32.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 129 | /qry/findsystem_315_33.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 136 | /qry/addSystem_315_34.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 139 | /qry/addDaysNo_315_35.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 141 | /qry/checkUnique_315_36.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 145 | /qry/addNotification_315_37.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 147 | /qry/addNotification_315_38.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload_update_audition.cfm | 20 | /qry/find_317_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload_update_audition.cfm | 26 | /qry/fix_191_9.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 57 | /qry/users_318_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 201 | /qry/C_318_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 293 | /qry/m_318_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 296 | /qry/FIND_318_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 300 | /qry/insert_318_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 304 | /qry/x_318_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 308 | /qry/find_318_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 321 | /qry/insert_318_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 328 | /qry/Findtotal_318_9.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 329 | /qry/add_318_10.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 331 | /qry/add_249_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 342 | /qry/x_318_12.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 346 | /qry/find_318_13.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 359 | /qry/insert_318_14.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 370 | /qry/x_318_15.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 374 | /qry/find_318_16.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 379 | /qry/find2_318_17.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 392 | /qry/insert_318_18.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 408 | /qry/xs_318_19.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 412 | /qry/find_318_20.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 425 | /qry/insert_318_21.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 437 | /qry/xs_318_22.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 441 | /qry/getActionUsers.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 454 | /qry/insert_318_24.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 467 | /qry/x_318_25.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 471 | /qry/find_318_26.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 484 | /qry/insert_318_27.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 496 | /qry/update_tags_318_28.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 497 | /qry/update_Iscasting_318_29.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 498 | /qry/u_318_30.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 499 | /qry/x_318_31.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 503 | /qry/find_318_32.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 516 | /qry/insert_318_33.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 529 | /qry/x_318_34.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 534 | /qry/find_318_35.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 536 | /qry/check_318_36.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 546 | /qry/insert_318_37.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/version-add2.cfm | 33 | /qry/find_320_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/version-add2.cfm | 40 | /qry/insert_320_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/version-update2.cfm | 3 | /qry/update_322_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/version.cfm | 11 | /qry/vers_323_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/version.cfm | 251 | /qry/versions_323_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/version.cfm | 340 | /qry/ticketusers_323_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/version.cfm | 341 | /qry/ticketme_323_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| sched/Application_back.cfc | 98 | /qry/fetchUsers.cfm | TECH-DEBT: scope-leaking cfinclude |
| sched/Application_back.cfc | 135 | /qry/fetchUsers.cfm | TECH-DEBT: scope-leaking cfinclude |
| sched/Application_last.cfc | 41 | /qry/fetchUsers.cfm | TECH-DEBT: scope-leaking cfinclude |
| sched/Application_last.cfc | 72 | /qry/fetchUsers.cfm | TECH-DEBT: scope-leaking cfinclude |
| sched/appoint-update2.cfm | 7 | /qry/duration.cfm | TECH-DEBT: scope-leaking cfinclude |
| sched/appoint-update2.cfm | 31 | /qry/update_618_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| sched/appoint-update2.cfm | 85 | /qry/inserts_619_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| sched/extracts_for_multiple.cfm | 68 | /qry/#newQueryFilename# | TECH-DEBT: scope-leaking cfinclude |
| sched/extract_queries.cfm | 52 | /qry/#newQueryFilename# | TECH-DEBT: scope-leaking cfinclude |
| sched/extract_queries_overwrite.cfm | 51 | /qry/#newQueryFilename# | TECH-DEBT: scope-leaking cfinclude |
| sched/extract_queries_overwrite_qry.cfm | 45 | /qry/#newQueryFilename# | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 79 | /qry/friendfamilycheck.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 81 | /qry/contacts.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 83 | /qry/categories.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 85 | /qry/items.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 87 | /qry/notesContact.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 89 | /qry/SystemsContact.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 91 | /qry/tagsContact.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 93 | /qry/profiles.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 95 | /qry/sysactive.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 97 | /qry/notsall.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 99 | /qry/events.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 101 | /qry/systemNotificationsActive.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 103 | /qry/SystemsActiveContact.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 105 | /qry/ru.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 107 | /qry/emailcheck.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 109 | /qry/phonecheck.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 111 | /qry/rels.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 113 | /qry/fetchcontactitems.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 115 | /qry/tagFriendCheck.cfm | TECH-DEBT: scope-leaking cfinclude |
| share/assets/eventtypes_user.cfm | 2 | /qry/eventtypes_user.cfm | TECH-DEBT: scope-leaking cfinclude |
| share/remoteUpdateForm.cfm | 30 | /qry/update.cfm | TECH-DEBT: scope-leaking cfinclude |

---

## 2C -- Dynamic Includes (Highest Risk) (24 matches)

**Every match below is flagged: TECH-DEBT: dynamic cfinclude -- cannot statically verify -- MANUAL REVIEW REQUIRED**

These cfinclude tags contain ColdFusion expressions (#...#) in the template path,
making it impossible to determine at build time which file will be included.
This is a security risk (potential path traversal) and a dead-code-analysis blocker.

| Calling File | Line | Include Expression | Flag |
|---|---|---|---|
| app/ajax/Application.cfc | 25 | `template="#arguments.targetPage#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| app/Application.cfc | 353 | `template="#arguments.targetPage#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| include/account_info.cfm | 173 | `template="#modalData.include#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| include/audition.cfm | 871 | `template="#includeTemplates[secid]#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| include/core.cfm | 41 | `template="#findlinkst.linkurl#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| include/core.cfm | 82 | `template="/include/#pgFilename#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| include/core.cfm | 193 | `template="#findlinksb.linkurl#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| include/coreb.cfm | 31 | `template="#findlinkst.linkurl#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| include/coreb.cfm | 181 | `template="/include/#pgFilename#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| include/coreb.cfm | 228 | `template="#findlinksb.linkurl#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| include/core_nomenu.cfm | 93 | `template="/include/#pgFilename#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| include/dashboard_new.cfm | 72 | `template="/include/#dashboards.pnFilename#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| include/pgload.cfm | 52 | `template="/include/qry/#pgFilename#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| include/qry/sql.cfm | 21 | `template="/include/remote_load.cfm"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| include/sql.cfm | 16 | `template="/include/remote_load.cfm"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| sched/Application_back.cfc | 178 | `template="#arguments.targetPage#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| sched/extracts.cfm | 88 | `template="#qry_path#/#newQueryFilename#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| sched/extracts_for_multiple.cfm | 68 | `template="/include/qry/#newQueryFilename#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| sched/extracts_new.cfm | 97 | `template="#qry_path#/#newQueryFilename#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| sched/extracts_newest.cfm | 97 | `template="#qry_path#/#newQueryFilename#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| sched/extracts_newest_qry.cfm | 97 | `template="#qry_path#/#newQueryFilename#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| sched/extract_queries.cfm | 52 | `template="/extracted/qry/#newQueryFilename#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| sched/extract_queries_overwrite.cfm | 51 | `template="/optimized/qry/#newQueryFilename#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| sched/extract_queries_overwrite_qry.cfm | 45 | `template="/optimized/qry/#newQueryFilename#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |

---

## Summary Statistics

| Category | Count (excl. dev_backup/) |
|---|---|
| variables.Service.method() calls | 122 |
| createObject("component","services.*") instantiations | 935 |
| Unique service classes instantiated | 139 |
| /qry/ cfinclude callers | 1,301 |
| Unique /qry/ files included | 1,018 |
| Dynamic cfinclude (highest risk) | 24 |
| application.Service.method() calls | 0 |
| request.Service.method() calls | 0 |
| cfinvoke component="services.*" calls | 0 |

### Service Call Patterns (variables scope)

These 9 services are called via `variables.{service}.method()` -- all within the import subsystems:

| Service Variable | Used In | Description |
|---|---|---|
| v3Service | ajax/importv3/*.cfm | ContactImportV3 AJAX endpoints |
| auditionService | ajax/import-auditions/*.cfm | Audition import AJAX endpoints |
| audService | ajax/import-auditions/recompute.cfm | Audition import recompute |
| importService | ajax/import-auditions/{upload,parse}.cfm | Audition import upload/parse |
| dupeService | ajax/importv3/recompute.cfm, ajax/import-auditions/recompute.cfm | Duplicate detection |
| validationService | ajax/importv3/recompute.cfm | Field validation |
| fileParserService | services/ContactImportV2Service.cfc | File parsing (internal) |
| duplicateMatcherService | services/ContactImportV2Service.cfc | Dupe matching (internal) |
| contactService | services/ContactImportV2Service.cfc | Contact CRUD (internal) |

### Key Observations

1. **No application-scoped or request-scoped service singletons.** All services are instantiated
   per-request via `createObject()`. This means every page/AJAX hit creates fresh CFC instances --
   potential performance concern for high-traffic pages.

2. **935 createObject instantiations** spread across ~900+ files in /include/qry/ alone. The vast
   majority of service usage is inside /qry/ files that are themselves cfincluded, creating a
   two-level indirection: page -> cfinclude /qry/file.cfm -> createObject -> service.method().

3. **1,301 /qry/ cfinclude calls referencing 1,018 unique /qry/ files** -- all scope-leaking.
   Every query result variable bleeds into the caller's scope. This makes variable collision bugs
   likely and refactoring dangerous.

4. **24 dynamic cfincludes** that cannot be statically traced. These are the highest-risk items
   for security review and dead-code detection. Key examples:
   - `include/core.cfm` line 41/82/193: includes based on query results (`findlinkst.linkurl`, `pgFilename`)
   - `include/coreb.cfm` line 31/181/228: same pattern
   - `include/dashboard_new.cfm` line 72: includes based on `dashboards.pnFilename`
   - `include/audition.cfm` line 871: includes from `includeTemplates[secid]` struct
   - `include/account_info.cfm` line 173: includes from `modalData.include`
   - `app/Application.cfc` line 353: includes `arguments.targetPage` (framework dispatch)

5. **The /qry/ include pattern dominates the codebase architecture.** Nearly all database access
   goes through cfinclude'd /qry/ files, each of which instantiates its own service object.
   This is the primary call graph pattern for downstream dead-code analysis.

---

*This file is consumed by later audit phases for dead-code detection. Every service function call
and /qry/ include has been captured with file paths.*
| include/qry/insert_524_5.cfm | 1 | ReportUserService |
| include/qry/Insert_71_8.cfm | 1 | NotificationService |
| include/qry/Insert_72_8.cfm | 1 | NotificationService |
| include/qry/Insert_ReportItems_146_2.cfm | 1 | ReportItemService |
| include/qry/Insert_ReportItems_282_6.cfm | 1 | ReportItemService |
| include/qry/insert_tag_298_3.cfm | 1 | TagsUserService |
| include/qry/ins_252_1.cfm | 1 | AuditionMediaXRefService |
| include/qry/ins_252_2.cfm | 1 | AuditionMediaXRefService |
| include/qry/itemDetails_130_1.cfm | 1 | ContactItemService |
| include/qry/itemsAll_489_1.cfm | 1 | ContactItemService |
| include/qry/itemsbycatActive.cfm | 1 | contactItemService |
| include/qry/itemsbycatActive_490_1.cfm | 1 | ContactItemService |
| include/qry/items_488_1.cfm | 1 | ContactItemService |
| include/qry/i_315_24.cfm | 1 | ContactImportService |
| include/qry/i_insert_315_25.cfm | 1 | ContactItemService |
| include/qry/jsons_50_1.cfm | 1 | ContactSSService |
| include/qry/jsons_myteam_50_2.cfm | 1 | EventService |
| include/qry/jtags_50_3.cfm | 1 | TagsUserService |
| include/qry/j_315_26.cfm | 1 | ContactImportService |
| include/qry/j_insert_315_27.cfm | 1 | ContactItemService |
| include/qry/k_195_2.cfm | 1 | SystemUserService |
| include/qry/labels_x_281_5.cfm | 1 | ReportItemService |
| include/qry/lastupdates.cfm | 1 | ContactService |
| include/qry/linkdetails_309_1.cfm | 1 | EventTypesUserService |
| include/qry/links_181_1.cfm | 1 | LinkService |
| include/qry/links_182_1.cfm | 1 | AuditionLinkService |
| include/qry/links_183_1.cfm | 1 | linkService |
| include/qry/locationDetails_492_1.cfm | 1 | EventService |
| include/qry/lookup_contacts.cfm | 3 | LookupService |
| include/qry/maints_315_32.cfm | 1 | ContactImportService |
| include/qry/master_164_4.cfm | 1 | SiteTypeMasterService |
| include/qry/materials_details_493_1.cfm | 1 | AuditionMediaService |
| include/qry/materials_sel.cfm | 1 | AuditionMediaService |
| include/qry/menuitems.cfm | 1 | ComponentService |
| include/qry/menuItemsAud_496_3.cfm | 1 | ComponentService |
| include/qry/menuItemsA_496_2.cfm | 1 | ComponentService |
| include/qry/menuItemsU_496_1.cfm | 1 | ComponentService |
| include/qry/mylinks_159_1.cfm | 1 | SiteLinkUserService |
| include/qry/mylinks_498_1.cfm | 1 | ContactItemService |
| include/qry/mylinks_user_164_2.cfm | 1 | SiteLinkUserService |
| include/qry/mylinks_user_del_164_3.cfm | 1 | SiteLinkUserService |
| include/qry/mysystems_295_1.cfm | 1 | SystemService |
| include/qry/mytags_167_1.cfm | 1 | ContactItemService |
| include/qry/mytags_48_1.cfm | 1 | ContactItemService |
| include/qry/myteam_499_1.cfm | 1 | ContactService |
| include/qry/m_318_3.cfm | 1 | PanelsMasterService |
| include/qry/new_312_4.cfm | 1 | TaoVersionService |
| include/qry/notesaud_506_1.cfm | 1 | NoteService |
| include/qry/notesContactDetails_180_2.cfm | 1 | NoteService |
| include/qry/notesContact_507_1.cfm | 1 | NoteService |
| include/qry/notesEvent_180_1.cfm | 1 | NoteService |
| include/qry/notesEvent_508_1.cfm | 1 | NoteService |
| include/qry/notesRelationship_509_1.cfm | 1 | NoteService |
| include/qry/notes_186_1.cfm | 1 | TicketService |
| include/qry/notsActives_458_2.cfm | 1 | NotificationService |
| include/qry/notsActives_461_1.cfm | 1 | NotificationService |
| include/qry/notsActive_510_1.cfm | 1 | NotificationService |
| include/qry/notsActive_511_2.cfm | 1 | NotificationService |
| include/qry/notsall_512_1.cfm | 1 | NotificationService |
| include/qry/notsInactive_510_2.cfm | 1 | NotificationStatusService |
| include/qry/notsnext.cfm | 1 | NotificationService |
| include/qry/notsNext_514_1.cfm | 1 | NotificationService |
| include/qry/old_312_3.cfm | 1 | TaoVersionService |
| include/qry/opencalls_286_1.cfm | 1 | AuditionOpenCallOptionUserService |
| include/qry/pages_10_4.cfm | 1 | PageService |
| include/qry/pages_274_3.cfm | 1 | PageService |
| include/qry/pgPanelsFix.cfm | 1 | PanelUserService |
| include/qry/pgpanels_460_2.cfm | 1 | PanelService |
| include/qry/pgpanels_94_2.cfm | 3 | PanelUserService |
| include/qry/phonecheck_515_1.cfm | 1 | ContactItemService |
| include/qry/Pin_check_29_7.cfm | 1 | EventService |
| include/qry/priorities_274_7.cfm | 1 | TicketPriorityService |
| include/qry/profiles_516_1.cfm | 1 | ContactItemService |
| include/qry/projectDetails_221_1.cfm | 1 | AuditionProjectService |
| include/qry/projectDetails_222_6.cfm | 1 | AuditionProjectService |
| include/qry/projectDetails_368_2.cfm | 1 | AuditionProjectService |
| include/qry/projectDetails_517_1.cfm | 1 | AuditionProjectService |
| include/qry/pronouns_210_1.cfm | 1 | GenderPronounUserService |
| include/qry/pronouns_456_4.cfm | 1 | GenderPronounUserService |
| include/qry/qCount_77_2.cfm | 1 | FilteredQueryService |
| include/qry/qFiltered_77_1.cfm | 22 | ContactService |
| include/qry/qFiltered_79_1.cfm | 26 | ContactService |
| include/qry/qry_block_1_1.cfm | 1 | ActionUserService |
| include/qry/qry_block_1_2.cfm | 1 | UserService |
| include/qry/queryFullNames_129_1.cfm | 1 | ContactService |
| include/qry/questions_441_1.cfm | 1 | AuditionQuestionUserService |
| include/qry/questions_check_29_9.cfm | 1 | EventService |
| include/qry/rangeselected_282_2.cfm | 1 | ReportRangeService |
| include/qry/ranges_286_6.cfm | 1 | AuditionAgeRangeService |
| include/qry/ranges_524_7.cfm | 1 | ReportRangeService |
| include/qry/ratio_13_524_12.cfm | 1 | ReportUserService |
| include/qry/ratio_17_524_13.cfm | 1 | ReportUserService |
| include/qry/Redirect_check_29_6.cfm | 1 | EventService |
| include/qry/referrals_286_3.cfm | 1 | ContactService |
| include/qry/refers_210_2.cfm | 1 | ContactService |
| include/qry/refer_details_451_2.cfm | 1 | ContactService |
| include/qry/refer_details_456_2.cfm | 1 | ContactService |
| include/qry/regions.cfm | 1 | RegionService |
| include/qry/relationships_13_1.cfm | 1 | ContactService |
| include/qry/reldetails_271_1.cfm | 1 | SystemUserService |
| include/qry/reminders_511_1.cfm | 2 | NotificationService |
| include/qry/remove2_191_12.cfm | 1 | EventContactsXRefService |
| include/qry/removenotdups.cfm | 1 | NotificationService |
| include/qry/remove_191_11.cfm | 1 | EventContactsXRefService |
| include/qry/reportcheck_524_1.cfm | 1 | ReportUserService |
| include/qry/reportcolors_523_1.cfm | 1 | ReportColorService |
| include/qry/reportitems_x_281_3.cfm | 1 | ReportItemService |
| include/qry/reportrefresh.cfm | 1 | ReportsRefreshService |
| include/qry/reports_524_9.cfm | 1 | ReportUserService |
| include/qry/report_10_282_3.cfm | 1 | AuditionProjectService |
| include/qry/report_11_282_9.cfm | 1 | AuditionProjectService |
| include/qry/report_12_282_10.cfm | 1 | AuditionProjectService |
| include/qry/report_13_282_12.cfm | 1 | AuditionProjectService |
| include/qry/report_17_282_11.cfm | 1 | AuditionProjectService |
| include/qry/report_18_282_21.cfm | 1 | AuditionProjectService |
| include/qry/report_2_282_24.cfm | 1 | AuditionProjectService |
| include/qry/report_3_282_13.cfm | 1 | AuditionProjectService |
| include/qry/report_4_loop_282_4.cfm | 1 | AuditionTypeService |
| include/qry/report_5_282_14.cfm | 1 | AuditionProjectService |
| include/qry/report_6_282_15.cfm | 1 | AuditionProjectService |
| include/qry/report_6_282_16.cfm | 1 | AuditionProjectService |
| include/qry/report_6_282_17.cfm | 1 | AuditionProjectService |
| include/qry/report_6_282_18.cfm | 1 | AuditionProjectService |
| include/qry/report_6_282_19.cfm | 1 | AuditionProjectService |
| include/qry/report_7_282_20.cfm | 1 | AuditionProjectService |
| include/qry/report_8_282_22.cfm | 1 | AuditionMediaService |
| include/qry/report_9_282_23.cfm | 1 | AuditionProjectService |
| include/qry/restoreActionUsers.cfm | 1 | ActionUserService |
| include/qry/restorenotdups.cfm | 1 | notificationService |
| include/qry/results_125_1.cfm | 1 | AuditionImportService |
| include/qry/results_141_2.cfm | 1 | ContactItemService |
| include/qry/results_142_1.cfm | 1 | ContactItemService |
| include/qry/results_330_1.cfm | 1 | TicketService |
| include/qry/results_331_1.cfm | 1 | UpdateLogService |
| include/qry/results_371_2.cfm | 1 | AuditionProjectService |
| include/qry/results_375_1.cfm | 1 | BigBrotherService |
| include/qry/results_43_1.cfm | 1 | EventService |
| include/qry/results_456_3.cfm | 1 | ContactService |
| include/qry/results_544_1.cfm | 1 | TicketService |
| include/qry/results_556_2.cfm | 1 | TicketService |
| include/qry/results_557_1.cfm | 1 | TicketService |
| include/qry/rolecheck_29_2.cfm | 1 | AuditionRoleService |
| include/qry/rolecheck_90_1.cfm | 1 | AuditionRoleService |
| include/qry/roleDetails_221_2.cfm | 1 | AuditionRoleService |
| include/qry/roleDetails_232_2.cfm | 1 | AuditionRoleService |
| include/qry/roleDetails_368_3.cfm | 1 | AuditionRoleService |
| include/qry/RPGAdd_288_5.cfm | 1 | PageService |
| include/qry/RPGFields_288_2.cfm | 1 | PageService |
| include/qry/RPGkey_288_4.cfm | 1 | PageService |
| include/qry/RPGResults_288_3.cfm | 1 | PageService |
| include/qry/RPGUpdate_288_6.cfm | 1 | PageService |
| include/qry/RPG_288_1.cfm | 1 | PageService |
| include/qry/rr_283_2.cfm | 1 | NotificationService |
| include/qry/ru.cfm | 1 | ContactService |
| include/qry/r_462_1.cfm | 1 | NotificationService |
| include/qry/SELaudnoteslog.cfm | 1 | NoteService |
| include/qry/SELnoteslog.cfm | 1 | ContactService |
| include/qry/SEL_Media_types_material.cfm | 1 | AuditionMediaTypeService |
| include/qry/set_missing.cfm | 1 | AuditionRoleService |
| include/qry/shares_534_1.cfm | 1 | ShareService |
| include/qry/sitetypes_535_1.cfm | 1 | SiteTypeUserService |
| include/qry/stats_524_10.cfm | 1 | ReportUserService |
| include/qry/statuses_10_2.cfm | 1 | TicketService |
| include/qry/statuses_274_5.cfm | 1 | TicketStatusService |
| include/qry/statuses_543_1.cfm | 1 | TicketStatusService |
| include/qry/statuses_554_1.cfm | 1 | TicketStatusService |
| include/qry/steps_29_1.cfm | 1 | AuditionStepService |
| include/qry/submitsitefix_368_1.cfm | 2 | AuditionRoleService |
| include/qry/submitsitefix_368_1.cfm | 6 | DebugService |
| include/qry/subsites_189_1.cfm | 1 | AuditionSubmitSiteUserService |
| include/qry/subsites_286_5.cfm | 1 | AuditionSubmitSiteUserService |
| include/qry/sudetails_157_5.cfm | 1 | SystemService |
| include/qry/sysActive_537_1.cfm | 1 | SystemUserService |
| include/qry/sysAvail_539_3.cfm | 1 | SystemService |
| include/qry/systemnames_453_2.cfm | 1 | SystemService |
| include/qry/systems_454_1.cfm | 1 | FUSystemTypeService |
| include/qry/Systems_540_1.cfm | 1 | SystemService |
| include/qry/TagsContact_541_1.cfm | 1 | ContactItemService |
| include/qry/tagsvalid_542_1.cfm | 1 | TagsUserService |
| include/qry/tags_200_1.cfm | 1 | TagsUserService |
| include/qry/tags_203_2.cfm | 1 | TagsUserService |
| include/qry/tags_76_1.cfm | 1 | TagsUserService |
| include/qry/tag_315_10.cfm | 1 | ContactImportService |
| include/qry/tag_315_12.cfm | 1 | ContactImportService |
| include/qry/tag_315_14.cfm | 1 | contactImportService |
| include/qry/tag_insert_315_11.cfm | 1 | ContactItemService |
| include/qry/tag_insert_315_13.cfm | 1 | ContactItemService |
| include/qry/tag_insert_315_15.cfm | 1 | ContactItemService |
| include/qry/ticketme_323_4.cfm | 1 | TicketTestUserService |
| include/qry/ticketusers_10_6.cfm | 1 | UserService |
| include/qry/ticketusers_323_3.cfm | 1 | TicketTestUserService |
| include/qry/toastmenu_306_2.cfm | 1 | NotificationService |
| include/qry/toasts_306_1.cfm | 1 | NotificationService |
| include/qry/tt_14_3.cfm | 1 | EventService |
| include/qry/tt_365_5.cfm | 1 | EventService |
| include/qry/types.cfm | 1 | itemTypeService |
| include/qry/types_10_3.cfm | 1 | UserService |
| include/qry/types_198_2.cfm | 1 | ItemTypeService |
| include/qry/types_198_3.cfm | 1 | ItemCategoryService |
| include/qry/types_256_2.cfm | 1 | TicketTypeService |
| include/qry/types_261_4.cfm | 1 | itemTypeService |
| include/qry/types_261_5.cfm | 1 | itemTypeService |
| include/qry/types_333_2.cfm | 1 | EventTypesUserService |
| include/qry/types_334_2.cfm | 1 | EventTypesUserService |
| include/qry/types_42_1.cfm | 1 | AuditionMediaTypeService |
| include/qry/types_44_1.cfm | 2 | AuditionMediaTypeService |
| include/qry/types_521_4.cfm | 1 | ItemCategoryService |
| include/qry/Type_208_1.cfm | 1 | AuditionMediaTypeService |
| include/qry/t_14_2.cfm | 1 | EventService |
| include/qry/update2_262_6.cfm | 1 | ContactItemService |
| include/qry/update2_280_2.cfm | 1 | ReportRangeService |
| include/qry/update2_280_3.cfm | 2 | ReportRangeService |
| include/qry/updateActionUsers.cfm | 1 | ActionUserService |
| include/qry/updateActionUsersByActionUpdate.cfm | 2 | ActionUserService |
| include/qry/updateActionUsersByExcludeAction.cfm | 1 | ActionUserService |
| include/qry/updateContactUnique.cfm | 1 | ContactService |
| include/qry/updatecontact_270_1.cfm | 1 | ContactService |
| include/qry/updateContact_71_2.cfm | 1 | ContactService |
| include/qry/updateEventData.cfm | 1 | EventService |
| include/qry/updateEvent_222_7.cfm | 1 | EventService |
| include/qry/updateExport_115_14.cfm | 1 | ExportService |
| include/qry/updatenote_175_1.cfm | 1 | NoteService |
| include/qry/updatenote_179_1.cfm | 1 | NoteService |
| include/qry/updateNotificationCompleted.cfm | 1 | NotificationService |
| include/qry/updateNotificationNext.cfm | 1 | NotificationService |
| include/qry/updateSystemUserCompleted.cfm | 1 | SystemUserService |
| include/qry/updatesystem_71_4.cfm | 1 | NotificationService |
| include/qry/updatesystem_71_5.cfm | 1 | SystemUserService |
| include/qry/updates_239_1.cfm | 1 | SiteTypeUserService |
| include/qry/updates_491_1.cfm | 1 | ContactService |
| include/qry/updateticket_213_3.cfm | 1 | TicketService |
| include/qry/updateticket_213_4.cfm | 1 | TicketService |
| include/qry/updateUserToken_133_1.cfm | 1 | UserService |
| include/qry/updateUserToken_184_1.cfm | 1 | UserService |
| include/qry/updateUserToken_184_2.cfm | 1 | UserService |
| include/qry/update_101_1.cfm | 1 | ContactService |
| include/qry/update_113_1.cfm | 1 | SiteLinkUserService |
| include/qry/update_114_2.cfm | 1 | SiteTypeUserService |
| include/qry/update_114_3.cfm | 1 | PanelUserService |
| include/qry/update_145_1.cfm | 1 | ActionUserService |
| include/qry/update_151_1.cfm | 1 | SiteLinkUserService |
| include/qry/update_159_3.cfm | 1 | UserService |
| include/qry/update_159_7.cfm | 1 | ContactItemService |
| include/qry/update_159_8.cfm | 1 | UserService |
| include/qry/update_159_9.cfm | 1 | UserService |
| include/qry/update_187_1.cfm | 1 | NotificationService |
| include/qry/update_187_2.cfm | 1 | NotificationService |
| include/qry/update_18_1.cfm | 1 | EventService |
| include/qry/update_191_5.cfm | 1 | AuditionProjectService |
| include/qry/update_191_7.cfm | 1 | AuditionProjectService |
| include/qry/update_199_6.cfm | 1 | ContactItemService |
| include/qry/update_213_2.cfm | 1 | TicketTestUserService |
| include/qry/update_260_2.cfm | 1 | AuditionSubmitSiteUserService |
| include/qry/update_262_5.cfm | 1 | ContactItemService |
| include/qry/update_264_1.cfm | 1 | EssenceService |
| include/qry/update_275_1.cfm | 1 | TicketService |
| include/qry/update_282_8.cfm | 1 | ReportItemService |
| include/qry/update_287_22.cfm | 1 | AuditionSubmitSiteUserService |
| include/qry/update_299_2.cfm | 1 | TicketService |
| include/qry/update_300_2.cfm | 1 | TicketService |
| include/qry/update_302_1.cfm | 1 | TicketService |
| include/qry/update_303_2.cfm | 1 | TicketService |
| include/qry/update_310_1.cfm | 1 | EventTypesUserService |
| include/qry/update_312_1.cfm | 1 | TicketService |
| include/qry/update_315_5.cfm | 1 | ContactImportService |
| include/qry/update_322_1.cfm | 1 | TaoVersionService |
| include/qry/update_367_7.cfm | 1 | EventService |
| include/qry/update_373_2.cfm | 1 | EventService |
| include/qry/update_551_1.cfm | 1 | NotificationService |
| include/qry/update_55_2.cfm | 1 | ContactService |
| include/qry/update_56_1.cfm | 1 | AuditionRoleService |
| include/qry/update_68_1.cfm | 1 | AuditionRoleService |
| include/qry/update_68_2.cfm | 1 | AuditionRoleService |
| include/qry/update_91_2.cfm | 1 | SiteLinkUserService |
| include/qry/update_92_1.cfm | 1 | SiteLinkUserService |
| include/qry/update_9_1.cfm | 17 | TicketService |
| include/qry/update_cal.cfm | 1 | userService |
| include/qry/update_Iscasting_318_29.cfm | 1 | TagsUserService |
| include/qry/update_record_313_2.cfm | 1 | AuditionImportService |
| include/qry/update_tags_318_28.cfm | 1 | TagsUserService |
| include/qry/upload_details_141_1.cfm | 1 | ContactImportService |
| include/qry/up_195_3.cfm | 1 | NotificationService |
| include/qry/up_31_1.cfm | 1 | UserService |
| include/qry/usercontact_159_14.cfm | 1 | UserService |
| include/qry/users_10_1.cfm | 1 | UserService |
| include/qry/users_212_2.cfm | 1 | UserService |
| include/qry/users_256_1.cfm | 1 | UserService |
| include/qry/users_318_1.cfm | 1 | UserService |
| include/qry/uu_223_2.cfm | 1 | UserService |
| include/qry/uu_33_1.cfm | 1 | EventService |
| include/qry/u_315_28.cfm | 1 | ContactImportService |
| include/qry/u_318_30.cfm | 1 | UserService |
| include/qry/U_73_1.cfm | 1 | UserService |
| include/qry/u_insert_315_29.cfm | 1 | ContactItemService |
| include/qry/values_x_281_6.cfm | 1 | ReportItemService |
| include/qry/versions_10_5.cfm | 1 | TicketService |
| include/qry/versions_323_2.cfm | 1 | TicketService |
| include/qry/vers_274_8.cfm | 1 | TaoVersionService |
| include/qry/vers_323_1.cfm | 1 | TicketService |
| include/qry/vers_330_3.cfm | 1 | TicketService |
| include/qry/vocals_286_8.cfm | 1 | AuditionVocalTypeService |
| include/qry/xs_283_5.cfm | 1 | FUActionService |
| include/qry/xs_318_19.cfm | 1 | EventTypesService |
| include/qry/xs_318_22.cfm | 1 | FUActionService |
| include/qry/xx_55_1.cfm | 1 | ContactService |
| include/qry/x_115_2.cfm | 1 | ContactService |
| include/qry/x_191_2.cfm | 1 | EventService |
| include/qry/x_214_1.cfm | 1 | AuditionQuestionUserService |
| include/qry/x_240_3.cfm | 1 | PanelUserService |
| include/qry/x_280_1.cfm | 2 | ReportRangeService |
| include/qry/x_283_1.cfm | 1 | NotificationService |
| include/qry/x_291_1.cfm | 1 | UserService |
| include/qry/x_292_3.cfm | 1 | AllFieldsService |
| include/qry/x_308_11.cfm | 1 | AuditionImportService |
| include/qry/x_308_12.cfm | 1 | AuditionImportService |
| include/qry/x_315_3.cfm | 1 | ContactImportService |
| include/qry/x_318_12.cfm | 1 | GenderPronounService |
| include/qry/x_318_15.cfm | 1 | SiteLinksMasterService |
| include/qry/x_318_25.cfm | 1 | TagService |
| include/qry/x_318_31.cfm | 1 | ItemTypeService |
| include/qry/x_318_34.cfm | 1 | ItemCategoryService |
| include/qry/x_318_6.cfm | 1 | SiteTypeMasterService |
| include/qry/x_41_2.cfm | 1 | AuditionQuestionUserService |
| include/qry/x_524_3.cfm | 1 | ReportsMasterService |
| include/qry/x_91_1.cfm | 1 | SiteLinkUserService |
| include/qry/x_94_1.cfm | 1 | PanelUserService |
| include/qry/y_191_4.cfm | 1 | EventService |
| include/qry/y_292_1.cfm | 1 | InformationSchemaTableService |
| include/qry/y_298_6.cfm | 1 | TagsUserService |
| include/qry/y_308_1.cfm | 1 | AuditionImportService |
| include/qry/z_191_6.cfm | 1 | AuditionProjectService |
| include/remoteDeleteFormLink.cfm | 2 | SiteLinksService |
| include/remotelinkUpdate.cfm | 3 | SiteLinksService |
| include/remotelinkUpdateUpdate.cfm | 6 | SiteLinksService |
| include/systemchange.cfm | 2 | SystemUserService |
| include/systemchange.cfm | 9 | ContactItemService |
| include/systemchange.cfm | 18 | notificationService |
| include/test_auditions_pagination.cfm | 37 | PaginationService |
| include/transfer_audition.cfm | 36 | AuditionImportErrorService |
| include/update_cal.cfm | 11 | UserService |
| include/update_selected_headshot.cfm | 7 | AuditionMediaXRefService |
| services/RelationshipService.cfc | 14 | RelationshipService |
| share/calendar_shared.cfm | 66 | ReminderService |
| share/relationships_shared.cfm | 62 | ContactItemService |

### 2A.3 — application.{Service}.{method}() calls

> **Result: NONE found.** No files use `application.{Service}.method()` pattern.

### 2A.4 — request.{Service}.{method}() calls

> **Result: NONE found.** No files use `request.{Service}.method()` pattern.

### 2A.5 — cfinvoke component="services.*" calls

> **Result: NONE found.** No files use `cfinvoke component="services.*"` pattern.

---

## 2B — /qry/ cfinclude Callers

**TECH-DEBT: scope-leaking cfinclude** -- Every entry below uses cfinclude to pull in a /qry/ file.
These query files execute in the caller's variable scope, meaning any variable set inside leaks
into the calling page. This is a significant maintainability and security concern.

| Calling File | Line | Included /qry/ File | Flag |
|---|---|---|---|
| app/admin-users/setup-verification.cfm | 8 | /qry/core.cfm | TECH-DEBT: scope-leaking cfinclude |
| app/Application.cfc | 267 | /qry/fetchUsers.cfm | TECH-DEBT: scope-leaking cfinclude |
| app/Application.cfc | 314 | /qry/fetchUsers.cfm | TECH-DEBT: scope-leaking cfinclude |
| app/assets/js/eventtypes_user.cfm | 2 | /qry/eventtypes_user.cfm | TECH-DEBT: scope-leaking cfinclude |
| calendar-appoint.cfm | 4 | /qry/eventtypes_user.cfm | TECH-DEBT: scope-leaking cfinclude |
| calendar-appoint.cfm | 7 | /qry/events_byuser.cfm | TECH-DEBT: scope-leaking cfinclude |
| debug-calendar-events.cfm | 13 | /qry/eventtypes_user.cfm | TECH-DEBT: scope-leaking cfinclude |
| debug-calendar-events.cfm | 14 | /qry/events_byuser.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/account_info.cfm | 77 | /qry/getAllCountries.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/account_info.cfm | 78 | /qry/getAllRegions.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/account_info.cfm | 79 | /qry/getAllTimezones.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/account_info.cfm | 80 | /qry/getMinimalTimezones.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/account_info.cfm | 81 | /qry/getAllDateFormats.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/account_info.cfm | 82 | /qry/getUserDetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/account_info.cfm | 97 | /qry/deleteTeam.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/account_info.cfm | 104 | /qry/addTeam.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/addeventtypeadd.cfm | 3 | /qry/insert_564_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/addnote.cfm | 8 | /qry/InsertNote_4_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/addnote.cfm | 12 | /qry/DeleteNote_4_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/addnote.cfm | 16 | /qry/InsertNote_4_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/addnote.cfm | 17 | /qry/DeleteNote_4_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/AddSystemToContact.cfm | 2 | /qry/addfuSystemUsers.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/AddSystemToContact.cfm | 16 | /qry/addDaysNo_5_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/AddSystemToContact.cfm | 31 | /qry/checkUnique_5_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/AddSystemToContact.cfm | 50 | /qry/addNotification_5_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/AddSystemToContact.cfm | 55 | /qry/addNotification_5_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/add_system.cfm | 9 | /qry/delSystemNotifications.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/add_system.cfm | 12 | /qry/addfuSystemUsers.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/add_system.cfm | 15 | /qry/getFuSystemUsersBySystemID.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/add_system.cfm | 25 | /qry/checkUnique_157_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/add_system.cfm | 43 | /qry/addNotification_326_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/admin-support-update2.cfm | 16 | /qry/update_9_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/admin-support_backup.cfm | 522 | /qry/results_330_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/admin-support_backup.cfm | 525 | /qry/priorities_330_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/admin-support_backup.cfm | 528 | /qry/vers_330_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/Applicationx.cfm | 13 | /qry/fetchUsers.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add.cfm | 6 | /qry/relationships_13_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add.cfm | 7 | /qry/durations.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add.cfm | 8 | /qry/eventtypes_user_443_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add2.cfm | 56 | /qry/duration_467_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add2.cfm | 69 | /qry/add_14_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add2.cfm | 70 | /qry/t_14_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add2.cfm | 71 | /qry/tt_14_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add2.cfm | 72 | /qry/dd_14_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add2.cfm | 77 | /qry/FIND_14_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add2.cfm | 84 | /qry/add_14_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add2.cfm | 95 | /qry/inserts_14_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add2.cfm | 101 | /qry/InsertNote_14_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add2.cfm | 121 | /qry/audprojects_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add2.cfm | 122 | /qry/audroles_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-add2.cfm | 123 | /qry/auditions_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-delete.cfm | 3 | /qry/delete_15_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-info.cfm | 6 | /qry/eventdetails_334_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-info.cfm | 7 | /qry/notesEvent_508_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-info.cfm | 9 | /qry/attendees_336_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-info.cfm | 10 | /qry/notesContactDetails_180_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-update.cfm | 12 | /qry/eventdetails_334_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-update.cfm | 13 | /qry/durations.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-update.cfm | 14 | /qry/relationships_13_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-update.cfm | 15 | /qry/eventtypes_user_443_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-update.cfm | 76 | /qry/finde_17_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-update2.cfm | 43 | /qry/durations.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-update2.cfm | 44 | /qry/duration_467_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-update2.cfm | 58 | /qry/update_18_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-update2.cfm | 59 | /qry/d_18_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-update2.cfm | 66 | /qry/FIND_18_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-update2.cfm | 76 | /qry/add_14_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint-update2.cfm | 91 | /qry/inserts_18_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appoint.cfm | 3 | /qry/notesevent.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/appointments_pane.cfm | 46 | /qry/finall_20_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/attachmentadd.cfm | 12 | /qry/getNoteDetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/attachmentadd2.cfm | 71 | /qry/INSERT_22_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/attachmentadd2aud.cfm | 18 | /qry/fetchusers.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/attachmentadd2aud.cfm | 44 | /qry/INSERT_22_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/attachmentaddaud.cfm | 13 | /qry/getNoteDetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/attachmentdel.cfm | 11 | /qry/attachdetails_25_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/attachmentdel.cfm | 26 | /qry/del_25_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/attachmentdelaud.cfm | 10 | /qry/attachdetails_25_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/attachmentdelaud.cfm | 21 | /qry/del_25_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add.cfm | 25 | /qry/fetchLocationService.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add.cfm | 27 | /qry/audplatforms_user_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add.cfm | 30 | /qry/cities_448_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add.cfm | 32 | /qry/cat_27_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add.cfm | 37 | /qry/audroletypes_sel_27_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add.cfm | 38 | /qry/audtypes_sel_27_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add.cfm | 39 | /qry/casting_types_27_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add.cfm | 40 | /qry/castingdirectors_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add.cfm | 469 | /qry/getAllCountries.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add.cfm | 470 | /qry/regions.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add.cfm | 471 | /qry/cities.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 76 | /qry/inscontactdetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 80 | /qry/insert_28_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 84 | /qry/insert_28_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 99 | /qry/insContactDetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 100 | /qry/insert_28_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 104 | /qry/insert_28_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 114 | /qry/insContactDetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 116 | /qry/insert_28_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 117 | /qry/insert_28_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 120 | /qry/FIND_28_10.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 124 | /qry/insert_28_11.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 132 | /qry/audprojects_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 133 | /qry/audroles_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 137 | /qry/auditions_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-add2.cfm | 142 | /qry/add_cd_28_12.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-update.cfm | 21 | /qry/fetchLocationService.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-update.cfm | 23 | /qry/audplatforms_user_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-update.cfm | 26 | /qry/cities_448_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-update.cfm | 28 | /qry/cat_27_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-update.cfm | 33 | /qry/audroletypes_sel_27_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-update.cfm | 34 | /qry/audtypes_sel_27_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-update.cfm | 35 | /qry/casting_types_27_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition-update.cfm | 36 | /qry/castingdirectors_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition.cfm | 63 | /qry/steps_29_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition.cfm | 138 | /qry/rolecheck_29_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition.cfm | 170 | /qry/audunions_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition.cfm | 171 | /qry/audnetworks_user_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition.cfm | 172 | /qry/audtones_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition.cfm | 173 | /qry/audcontracttypes_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition.cfm | 174 | /qry/notesaud.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition.cfm | 178 | /qry/auditionDetails_29_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition.cfm | 302 | /qry/findstep_29_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition.cfm | 424 | /qry/callback_check_29_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition.cfm | 442 | /qry/Redirect_check_29_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition.cfm | 460 | /qry/Pin_check_29_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition.cfm | 474 | /qry/Booked_check_29_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/auditions.cfm | 48 | /qry/audcategories_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/auditions.cfm | 351 | /qry/up_31_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/auditions.cfm | 352 | /qry/audsteps_sel_31_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/auditions.cfm | 353 | /qry/audtypes_sel_31_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/auditions.cfm | 354 | /qry/auditions.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/auditions.cfm | 440 | /qry/cds_31_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/auditions.cfm | 441 | /qry/cos_31_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/auditions_ins.cfm | 23 | /qry/auditions_ins_32_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/auditions_new.cfm | 8 | /qry/audcategories_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/auditions_new.cfm | 84 | /qry/up_31_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/auditions_new.cfm | 85 | /qry/audsteps_sel_31_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/auditions_new.cfm | 86 | /qry/audtypes_sel_31_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/auditions_new.cfm | 175 | /qry/cds_31_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/auditions_new.cfm | 176 | /qry/cos_31_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition_check.cfm | 16 | /qry/uu_33_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition_check.cfm | 22 | /qry/folowup_body.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audition_check.cfm | 60 | /qry/addmissing_33_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audlocupdate2.cfm | 13 | /qry/audlocations_upd_37_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audmedia.cfm | 6 | /qry/audmedia_38_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audroles_ins.cfm | 14 | /qry/audroles_ins_39_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/audunions_sel.cfm | 6 | /qry/audunions_sel_40_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_assessment_add.cfm | 3 | /qry/insert_41_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_assessment_add.cfm | 5 | /qry/x_41_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_assessment_add.cfm | 9 | /qry/insert_41_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_book_pane.cfm | 6 | /qry/SEL_Media_types_material.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_call_pane.cfm | 2 | /qry/results_43_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_head_pane.cfm | 3 | /qry/audmedia.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_head_pane.cfm | 4 | /qry/types_44_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_head_pane.cfm | 5 | /qry/getAuditionLinks.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_mat_pane.cfm | 3 | /qry/getAuditionMaterials.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_mat_pane.cfm | 4 | /qry/getAuditionMediaPicklist.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_mat_pane.cfm | 5 | /qry/getAuditionMediaTypes.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_mat_pane.cfm | 6 | /qry/getAuditionLinks.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_ques_pane.cfm | 2 | /qry/auds_byrole.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_ques_pane.cfm | 36 | /qry/aud_questions.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_rel_pane.cfm | 20 | /qry/getContactsByAudProject.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_rel_pane.cfm | 22 | /qry/audcontacts_sel_349_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_rel_pane.cfm | 91 | /qry/mytags_48_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_rel_pane.cfm | 92 | /qry/Findphone_48_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_rel_pane.cfm | 94 | /qry/Findemail_48_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_rel_pane.cfm | 153 | /qry/getSocialIcons.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_rel_pane.cfm | 154 | /qry/getRemindersByRelationship.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_role_pane.cfm | 31 | /qry/audessences_audtion_xref_49_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_role_pane.cfm | 106 | /qry/findit_49_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_role_pane.cfm | 110 | /qry/audgenres_audition_xref.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_role_pane.cfm | 126 | /qry/audgenres_audition_xref.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/aud_role_pane.cfm | 163 | /qry/audvocaltypes_audition_xref.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/bigbrotherinclude.cfm | 7 | /qry/bro_add_53_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/birthday_fix.cfm | 3 | /qry/xx_55_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/birthday_fix.cfm | 35 | /qry/update_55_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/booked.cfm | 2 | /qry/update_56_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/bookupdateform.cfm | 3 | /qry/audplatforms_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/bookupdateform.cfm | 4 | /qry/incometypes_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/bookupdateform.cfm | 5 | /qry/audpaycyles_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/bookupdateform.cfm | 6 | /qry/book_det_57_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/bookupdateform2.cfm | 16 | /qry/audlocations_ins_58_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/calendar-appoint.cfm | 4 | /qry/eventtypes_user.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/calendar-appoint.cfm | 7 | /qry/events_byuser.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/catupdateform.cfm | 5 | /qry/audcategories_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/catupdateform.cfm | 6 | /qry/audsubcategories_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/catupdateform.cfm | 7 | /qry/auditionprojectDetails_66_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/catupdateform2.cfm | 2 | /qry/audprojects_ins_67_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/changestatus.cfm | 10 | /qry/update_68_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/changestatus.cfm | 13 | /qry/update_68_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not.cfm | 22 | /qry/getNotificationByID.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not.cfm | 83 | /qry/updateNotificationCompleted.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not.cfm | 110 | /qry/updateContactUnique.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not.cfm | 143 | /qry/addNotification.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not.cfm | 162 | /qry/getNotificationsBySystem.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not.cfm | 206 | /qry/updateNotificationNext.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not.cfm | 236 | /qry/updateSystemUserCompleted.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not.cfm | 268 | /qry/addNotifications.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not.cfm | 277 | /qry/findSystemByScope.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_ajax.cfm | 57 | /qry/getNotificationByID.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_ajax.cfm | 116 | /qry/updateNotificationCompleted.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_ajax.cfm | 142 | /qry/updateContactUnique.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_ajax.cfm | 164 | /qry/addNotification.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_ajax.cfm | 182 | /qry/getNotificationsBySystem.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_ajax.cfm | 253 | /qry/updateNotificationNext.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_ajax.cfm | 275 | /qry/updateSystemUserCompleted.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_ajax.cfm | 284 | /qry/checkformaint_71_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_ajax.cfm | 309 | /qry/addNotifications.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_ajax.cfm | 310 | /qry/findSystemByScope.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch.cfm | 61 | /qry/getNotificationByID.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch.cfm | 85 | /qry/updateNotificationCompleted.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch.cfm | 89 | /qry/updateContactUnique.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch.cfm | 95 | /qry/addNotification.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch.cfm | 99 | /qry/getNotificationsBySystem.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch.cfm | 104 | /qry/updateNotificationNext.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch.cfm | 108 | /qry/updateSystemUserCompleted.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch.cfm | 111 | /qry/checkformaint_71_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch.cfm | 117 | /qry/addNotifications.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch.cfm | 118 | /qry/findSystemByScope.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_backup_20251211.cfm | 61 | /qry/getNotificationByID.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_backup_20251211.cfm | 85 | /qry/updateNotificationCompleted.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_backup_20251211.cfm | 89 | /qry/updateContactUnique.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_backup_20251211.cfm | 95 | /qry/addNotification.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_backup_20251211.cfm | 99 | /qry/getNotificationsBySystem.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_backup_20251211.cfm | 104 | /qry/updateNotificationNext.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_backup_20251211.cfm | 108 | /qry/updateSystemUserCompleted.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_backup_20251211.cfm | 111 | /qry/checkformaint_71_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_backup_20251211.cfm | 117 | /qry/addNotifications.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_backup_20251211.cfm | 118 | /qry/findSystemByScope.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_old.cfm | 16 | /qry/getNotificationByID.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_old.cfm | 45 | /qry/addNotification_71_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_old.cfm | 49 | /qry/updateContact_71_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_old.cfm | 55 | /qry/addNotification_71_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_old.cfm | 59 | /qry/notsnext.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_old.cfm | 68 | /qry/updatesystem_71_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_old.cfm | 74 | /qry/updatesystem_71_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_old.cfm | 75 | /qry/checkformaint_71_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_old.cfm | 79 | /qry/findSystem_71_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_batch_old.cfm | 82 | /qry/Insert_71_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_skip.cfm | 13 | /qry/getNotificationById.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_skip.cfm | 38 | /qry/addNotification_72_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_skip.cfm | 42 | /qry/updateContact_72_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_skip.cfm | 48 | /qry/addNotification_71_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_skip.cfm | 51 | /qry/notsnext.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_skip.cfm | 61 | /qry/updatesystem_72_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_skip.cfm | 67 | /qry/updatesystem_72_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_skip.cfm | 68 | /qry/checkformaint_72_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_skip.cfm | 72 | /qry/findSystem_71_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/complete_not_skip.cfm | 76 | /qry/Insert_72_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contactfolder_setup.cfm | 18 | /qry/U_73_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contactfolder_setup.cfm | 93 | /qry/C_73_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contacts.cfm | 33 | /qry/lastupdates.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contacts.cfm | 313 | /qry/imports.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contacts_all.cfm | 21 | /qry/lastupdates.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contacts_all.cfm | 167 | /qry/tags_76_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contacts_all_tabs.cfm | 53 | /qry/lastupdates.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contacts_all_tabs.cfm | 236 | /qry/tags_76_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contacts_attendees.cfm | 20 | /qry/qFiltered_77_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contacts_attendees.cfm | 23 | /qry/qCount_77_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contacts_table.cfm | 44 | /qry/imports.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_add.cfm | 2 | /qry/add_82_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 3 | /qry/fetchLocationService.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 141 | /qry/details_456_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 142 | /qry/eventresults.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 143 | /qry/ru.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 145 | /qry/contacts_333_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 146 | /qry/categories_446_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 147 | /qry/items_488_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 148 | /qry/notesContact_507_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 149 | /qry/Systems_540_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 150 | /qry/TagsContact_541_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 151 | /qry/profiles_516_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 152 | /qry/sysActive_537_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 153 | /qry/notsall_512_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 154 | /qry/eventss_443_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 155 | /qry/systemNotificationsActive.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 156 | /qry/findscope.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 157 | /qry/sysAvail_539_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 158 | /qry/getRemindersByRelationship.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 159 | /qry/emailcheck_469_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 160 | /qry/phonecheck_515_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 161 | /qry/rels.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 162 | /qry/fetchcontactitems.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 163 | /qry/findcompany_476_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 164 | /qry/notesRelationship_509_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 239 | /qry/cu_83_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 324 | /qry/c_83_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 454 | /qry/notsactive_510_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_info.cfm | 455 | /qry/notsInactive_510_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/contact_pane.cfm | 10 | /qry/itemsbycatActive.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/core.cfm | 1 | /qry/menuitems.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/core.cfm | 2 | /qry/menuItemsa_496_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/core.cfm | 3 | /qry/menuItemsAud_496_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/core.cfm | 29 | /qry/FindLinksT.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/core.cfm | 30 | /qry/FindLinksB.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/core_title_175.cfm | 3 | /qry/rolecheck_90_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/customicon.cfm | 2 | /qry/x_91_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/customicon.cfm | 39 | /qry/update_91_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/customicon_single.cfm | 101 | /qry/update_92_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/dashboardupdate.cfm | 2 | /qry/dashboardzz_93_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/dashboardupdate2.cfm | 6 | /qry/x_94_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/dashboardupdate2.cfm | 9 | /qry/pgpanels_94_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/dashboard_pane.cfm | 2 | /qry/dashboardoptions.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/dash_repteam.cfm | 84 | /qry/myteam_499_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/dash_repteam.cfm | 109 | /qry/findtag_97_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/dash_rr.cfm | 11 | /qry/reminders_511_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/delaudmedia.cfm | 7 | /qry/del_99_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/deleteappointment.cfm | 3 | /qry/deleteticket_100_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/deleteContacts.cfm | 6 | /qry/update_101_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/deleteessence.cfm | 2 | /qry/delete_102_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/deletenote.cfm | 2 | /qry/deletenote_103_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/deletesystemfromrel.cfm | 21 | /qry/find_d_104_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/deletesystemfromrel.cfm | 24 | /qry/deletesystem_104_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/deleteticket.cfm | 3 | /qry/deleteticket_105_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/DetailPage.cfm | 16 | /qry/details_106_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/details.cfm | 6 | /qry/Findchild_107_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/details.cfm | 26 | /qry/FindDetails_107_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/details.cfm | 127 | /qry/FindModalTitle_107_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/details.cfm | 128 | /qry/update.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/details.cfm | 134 | /qry/find_107_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/details.cfm | 169 | /qry/FindValue_107_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/details.cfm | 255 | /qry/FindValue_107_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/details.cfm | 256 | /qry/selects_107_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/details.cfm | 276 | /qry/FindValue_107_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/details.cfm | 278 | /qry/selects_107_9.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/details.cfm | 308 | /qry/FindValue_107_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/details.cfm | 309 | /qry/selects_107_11.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/details.cfm | 340 | /qry/selects_107_12.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/download.cfm | 7 | /qry/attachdetails_25_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/download_aud.cfm | 7 | /qry/attachdetails_25_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/download_media.cfm | 4 | /qry/attachdetails_109_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/excludeaction.cfm | 2 | /qry/updateActionUsersByExcludeAction.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/excludelink.cfm | 5 | /qry/update_113_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/excludesitetype.cfm | 3 | /qry/Find_114_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/excludesitetype.cfm | 5 | /qry/update_114_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/excludesitetype.cfm | 11 | /qry/update_114_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 47 | /qry/AddExport_115_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 48 | /qry/x_115_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 79 | /qry/find_new_Website_115_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 86 | /qry/find_new_BusinessEmail_115_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 93 | /qry/find_new_PersonalEmail_115_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 100 | /qry/find_new_Company_115_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 107 | /qry/find_new_WorkPhone_115_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 114 | /qry/find_new_mobilePhone_115_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 121 | /qry/find_new_homePhone_115_9.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 128 | /qry/find_new_address_115_10.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 141 | /qry/find_new_address_other_115_11.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 154 | /qry/find_new_tag_115_12.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 177 | /qry/insert_115_13.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 181 | /qry/updateExport_115_14.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/exportContacts.cfm | 183 | /qry/export_ac_115_15.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/export_auditions.cfm | 2 | /qry/export_ac_31_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/fetch_updated_row.cfm | 6 | /qry/results_125_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/fetch_updated_row.cfm | 7 | /qry/getAuditionImportErrors.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/folder_setup.cfm | 45 | /qry/C_73_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/folowup_body.cfm | 2 | /qry/fetch_folowup.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/FullNameLookup.cfc | 11 | /qry/queryFullNames_129_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/getmodalcontent.cfm | 5 | /qry/itemDetails_130_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/get_record_data.cfm | 9 | /qry/getRecord_132_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/get_record_data.cfm | 12 | /qry/getCategories_132_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/get_record_data.cfm | 15 | /qry/getSources_132_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/google_auth.cfm | 13 | /qry/updateUserToken_133_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/image-upload-contact.cfm | 9 | /qry/FindRefPage_135_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/image-upload-contact.cfm | 10 | /qry/FindRefcontacts_135_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/image-upload.cfm | 8 | /qry/FindRefPage_136_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/image-upload.cfm | 11 | /qry/FindRefcontacts_135_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/import-auditions.cfm | 224 | /qry/getAuditionUploadDetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/import-auditions.cfm | 226 | /qry/getAuditionImportResults.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/import-auditions.cfm | 277 | /qry/getAuditionImportErrors.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/import-auditions.cfm | 336 | /qry/auditions_import.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/import-contacts_old.cfm | 9 | /qry/imports.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/import-contacts_old.cfm | 15 | /qry/upload_details_141_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/import-contacts_old.cfm | 18 | /qry/results_141_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/import.cfm | 71 | /qry/results_142_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/includeaction.cfm | 3 | /qry/update_145_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/Insert_ReportItem.cfm | 3 | /qry/findid_146_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/Insert_ReportItem.cfm | 25 | /qry/Insert_ReportItems_146_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/linkadd.cfm | 7 | /qry/getNoteDetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/linkadd2.cfm | 8 | /qry/add_149_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/linkdel.cfm | 7 | /qry/find_150_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/linkdel.cfm | 12 | /qry/deletelink_150_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/linkinclude.cfm | 3 | /qry/update_151_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/linkmedia.cfm | 3 | /qry/linkmedia_152_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/load_headshot.cfm | 4 | /qry/headshots_377_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/load_headshot_gallery.cfm | 4 | /qry/headshots_sel_479_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/modalansweryes.cfm | 5 | /qry/fin_recordname_157_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/modalansweryes.cfm | 12 | /qry/find_fu_157_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/modalansweryes.cfm | 22 | /qry/addSystem_157_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/modalansweryes.cfm | 24 | /qry/CompleteTargetSystems_157_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/modalansweryes.cfm | 25 | /qry/sudetails_157_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/modalansweryes.cfm | 26 | /qry/Insert_157_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/modalansweryes.cfm | 27 | /qry/addDaysNo_157_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/modalansweryes.cfm | 35 | /qry/checkUnique_157_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/modalansweryes.cfm | 54 | /qry/addNotification_157_9.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/modalansweryes.cfm | 56 | /qry/addNotification_157_10.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/ModalRemoteNewForm.cfm | 3 | /qry/FindModalTitle_107_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/mybrand_pane.cfm | 51 | /qry/essence_sel_470_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/myheadshots_pane.cfm | 23 | /qry/headshots_sel_478_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/mylinks_pane.cfm | 40 | /qry/sitetypes_535_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/mylinks_pane.cfm | 41 | /qry/mylinks_159_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/mylinks_pane.cfm | 173 | /qry/mylinks_user_164_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/mylinks_pane.cfm | 174 | /qry/mylinks_user_del_164_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/mylinks_pane.cfm | 175 | /qry/master_164_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/mymaterials_pane.cfm | 55 | /qry/materials_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/mymaterials_pane.cfm | 149 | /qry/events_166_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/myteam_pane.cfm | 2 | /qry/getMyTeam.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/myteam_pane.cfm | 123 | /qry/getSocialIcons.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/myteam_pane.cfm | 124 | /qry/getRemindersByRelationship.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/myteam_pane_backup.cfm | 23 | /qry/getMyTeam.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/myteam_pane_backup.cfm | 138 | /qry/getSocialIcons.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/myteam_pane_backup.cfm | 139 | /qry/getRemindersByRelationship.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/myteam_pane_fixed.cfm | 2 | /qry/getMyTeam.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/myteam_pane_fixed.cfm | 123 | /qry/getSocialIcons.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/myteam_pane_fixed.cfm | 124 | /qry/getRemindersByRelationship.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-add-aud.cfm | 4 | /qry/relationships_13_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-add-aud2.cfm | 11 | /qry/InsertNote_169_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-add-aud2.cfm | 14 | /qry/CLEAN_169_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-add-event.cfm | 6 | /qry/relationships_13_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-add-event2.cfm | 11 | /qry/InsertNote_171_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-add-event2.cfm | 14 | /qry/CLEAN_169_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-add.cfm | 6 | /qry/relationships_13_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-add2.cfm | 5 | /qry/InsertNote_173_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-update-aud.cfm | 6 | /qry/relationships_13_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-update-aud2.cfm | 11 | /qry/updatenote_175_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-update-aud2.cfm | 14 | /qry/CLEAN_169_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-update-event.cfm | 6 | /qry/relationships_13_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-update-event2.cfm | 11 | /qry/updatenote_177_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-update-event2.cfm | 14 | /qry/CLEAN_169_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-update.cfm | 6 | /qry/relationships_13_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/note-update2.cfm | 5 | /qry/updatenote_179_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/notesEvent.cfm | 6 | /qry/notesEvent_180_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/notesEvent.cfm | 8 | /qry/notesContactDetails_180_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/notes_aud_pane.cfm | 67 | /qry/links_181_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/notes_aud_pane.cfm | 68 | /qry/attachments_181_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/notes_event_pane.cfm | 66 | /qry/getLinksByNoteId.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/notes_event_pane.cfm | 67 | /qry/attachments_181_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/notes_relationship_pane.cfm | 55 | /qry/links_183_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/notes_relationship_pane.cfm | 56 | /qry/attachments_181_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/order.cfm | 3 | /qry/Finddetails_185_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/order.cfm | 4 | /qry/FindResults_185_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/order.cfm | 5 | /qry/FindKey_185_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/order.cfm | 37 | /qry/find_185_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/order.cfm | 48 | /qry/sql1_185_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/order.cfm | 49 | /qry/sq2_185_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/patchnotes.cfm | 2 | /qry/notes_186_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/pgload.cfm | 27 | /qry/update_187_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/pgload.cfm | 32 | /qry/update_187_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/pgload.cfm | 41 | /qry/fetchusers.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/pgload.cfm | 52 | /qry/#pgFilename# | TECH-DEBT: scope-leaking cfinclude |
| include/pgload_setup.cfm | 11 | /qry/FindUser_188_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/pgload_setup.cfm | 41 | /qry/InsertContact_188_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/pgload_setup.cfm | 46 | /qry/InsertContact_188_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/pgload_setup.cfm | 47 | /qry/InsertContact_188_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/pgload_setup.cfm | 48 | /qry/FindUser_188_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/pgload_setup.cfm | 52 | /qry/FindPage_188_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/pgload_setup.cfm | 58 | /qry/FindFields_188_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/pgload_setup.cfm | 66 | /qry/FindLinksT_188_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/pgload_setup.cfm | 70 | /qry/FindLinksB_188_9.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/pgload_setup.cfm | 74 | /qry/FindLinksExtra_188_10.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/prefs_pane.cfm | 172 | /qry/subsites_189_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/projdate_fix_user.cfm | 9 | /qry/pupdate_191_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/projdate_fix_user.cfm | 13 | /qry/z_191_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/projdate_fix_user.cfm | 25 | /qry/update_191_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/projdate_fix_user.cfm | 29 | /qry/delete_191_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/projdate_fix_user.cfm | 40 | /qry/fix_191_9.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/projdate_fix_user.cfm | 43 | /qry/correct_191_10.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/projdate_fix_user.cfm | 46 | /qry/remove_191_11.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/projdate_fix_user.cfm | 49 | /qry/remove2_191_12.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/addNotification_placeholder.cfm | 1 | /qry/addNotification_placeholder.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/admin-update-log.cfm | 1 | /qry/admin-update-log.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/ageranges_sel.cfm | 3 | /qry/ageranges_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint-add.cfm | 1 | /qry/appoint-add.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint-add.cfm | 2 | /qry/appoint-add.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint-info.cfm | 1 | /qry/appoint-info.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint-info.cfm | 2 | /qry/appoint-info.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint-info.cfm | 3 | /qry/appoint-info.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint-info.cfm | 6 | /qry/appoint-info.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint-info.cfm | 8 | /qry/appoint-info.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint-update.cfm | 3 | /qry/appoint-update.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint-update.cfm | 5 | /qry/appoint-update.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint-update.cfm | 6 | /qry/appoint-update.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint-update.cfm | 8 | /qry/appoint-update.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint-update.cfm | 16 | /qry/appoint-update.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint.cfm | 1 | /qry/appoint.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint.cfm | 2 | /qry/appoint.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint.cfm | 3 | /qry/appoint.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint.cfm | 6 | /qry/appoint.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/appoint.cfm | 8 | /qry/appoint.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audageranges_audtion_xref_ins.cfm | 7 | /qry/audageranges_audtion_xref_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audageranges_audtion_xref_upd.cfm | 7 | /qry/audageranges_audtion_xref_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audageranges_ins.cfm | 13 | /qry/audageranges_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audageranges_sel.cfm | 11 | /qry/audageranges_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audageranges_upd.cfm | 13 | /qry/audageranges_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audanswers_ins.cfm | 15 | /qry/audanswers_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audanswers_upd.cfm | 15 | /qry/audanswers_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audcallbacktypes_sel.cfm | 3 | /qry/audcallbacktypes_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audcallbacktypes_sel.cfm | 5 | /qry/audcallbacktypes_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audcategories_ins.cfm | 7 | /qry/audcategories_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audcategories_sel.cfm | 9 | /qry/audcategories_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audcategories_upd.cfm | 7 | /qry/audcategories_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audcategory_sel.cfm | 11 | /qry/audcategory_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audcontacts.cfm | 4 | /qry/audcontacts.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audcontacts.cfm | 6 | /qry/audcontacts.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audcontacts_auditions_xref_ins.cfm | 7 | /qry/audcontacts_auditions_xref_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audcontacts_auditions_xref_upd.cfm | 7 | /qry/audcontacts_auditions_xref_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audcontracttypes_ins.cfm | 9 | /qry/audcontracttypes_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audcontracttypes_sel.cfm | 11 | /qry/audcontracttypes_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audcontracttypes_upd.cfm | 9 | /qry/audcontracttypes_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auddialects_ins.cfm | 9 | /qry/auddialects_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auddialects_sel.cfm | 10 | /qry/auddialects_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auddialects_upd.cfm | 9 | /qry/auddialects_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audgenres_audition_xref.cfm | 3 | /qry/audgenres_audition_xref.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audgenres_audition_xref_ins.cfm | 7 | /qry/audgenres_audition_xref_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audgenres_audition_xref_upd.cfm | 7 | /qry/audgenres_audition_xref_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audgenres_ins.cfm | 9 | /qry/audgenres_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audgenres_sel.cfm | 11 | /qry/audgenres_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audgenres_upd.cfm | 9 | /qry/audgenres_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/AUDintoEVENTS.cfm | 17 | /qry/AUDintoEVENTS.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/AUDintoEVENTS.cfm | 45 | /qry/AUDintoEVENTS.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/AUDintoEVENTS.cfm | 73 | /qry/AUDintoEVENTS.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/AUDintoEVENTS.cfm | 75 | /qry/AUDintoEVENTS.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/AUDintoEVENTS.cfm | 77 | /qry/AUDintoEVENTS.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/AUDintoEVENTS.cfm | 79 | /qry/AUDintoEVENTS.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/AUDintoEVENTS.cfm | 81 | /qry/AUDintoEVENTS.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition-add.cfm | 2 | /qry/audition-add.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition-add.cfm | 4 | /qry/audition-add.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition-add2.cfm | 8 | /qry/audition-add2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition-add2.cfm | 12 | /qry/audition-add2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition-add2.cfm | 16 | /qry/audition-add2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition-add2.cfm | 24 | /qry/audition-add2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition-add2.cfm | 26 | /qry/audition-add2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition-add2.cfm | 28 | /qry/audition-add2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition-add2.cfm | 32 | /qry/audition-add2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition-add2.cfm | 33 | /qry/audition-add2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition-add2.cfm | 36 | /qry/audition-add2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition-add2.cfm | 38 | /qry/audition-add2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition-add2.cfm | 42 | /qry/audition-add2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition.cfm | 17 | /qry/audition.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition.cfm | 20 | /qry/audition.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition.cfm | 30 | /qry/audition.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition.cfm | 34 | /qry/audition.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition.cfm | 37 | /qry/audition.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition.cfm | 40 | /qry/audition.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition.cfm | 44 | /qry/audition.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition.cfm | 46 | /qry/audition.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition.cfm | 53 | /qry/audition.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition.cfm | 57 | /qry/audition.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition.cfm | 71 | /qry/audition.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition.cfm | 75 | /qry/audition.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audition.cfm | 85 | /qry/audition.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auditiondetails.cfm | 3 | /qry/auditiondetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auditionprojectdetails.cfm | 3 | /qry/auditionprojectdetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auditions.cfm | 2 | /qry/auditions.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auditions.cfm | 26 | /qry/auditions.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auditions.cfm | 30 | /qry/auditions.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auditionsimport.cfm | 3 | /qry/auditionsimport.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auditions_ins.cfm | 33 | /qry/auditions_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auditions_ins.cfm | 54 | /qry/auditions_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auditions_ins.cfm | 56 | /qry/auditions_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auditions_upd.cfm | 51 | /qry/auditions_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auditions_upd.cfm | 73 | /qry/auditions_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auditlog.cfm | 3 | /qry/auditlog.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audlocations_sel.cfm | 3 | /qry/audlocations_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audmedia.cfm | 3 | /qry/audmedia.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audmedia.cfm | 5 | /qry/audmedia.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audmediatypes_ins.cfm | 7 | /qry/audmediatypes_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audmediatypes_sel.cfm | 10 | /qry/audmediatypes_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audmediatypes_upd.cfm | 7 | /qry/audmediatypes_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audmedia_audroles_xref_ins.cfm | 11 | /qry/audmedia_audroles_xref_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audmedia_audroles_xref_upd.cfm | 11 | /qry/audmedia_audroles_xref_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audmedia_ins.cfm | 25 | /qry/audmedia_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audmedia_ins.cfm | 29 | /qry/audmedia_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audmedia_ins.cfm | 33 | /qry/audmedia_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audmedia_upd.cfm | 19 | /qry/audmedia_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audnetworks_ins.cfm | 9 | /qry/audnetworks_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audnetworks_sel.cfm | 12 | /qry/audnetworks_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audnetworks_upd.cfm | 9 | /qry/audnetworks_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audnetworks_user_sel.cfm | 11 | /qry/audnetworks_user_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audpaycycles_sel.cfm | 3 | /qry/audpaycycles_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audpaycyles_sel.cfm | 3 | /qry/audpaycyles_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audplatforms_ins.cfm | 6 | /qry/audplatforms_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audplatforms_sel.cfm | 10 | /qry/audplatforms_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audplatforms_upd.cfm | 6 | /qry/audplatforms_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audplatforms_user_sel.cfm | 11 | /qry/audplatforms_user_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audprojects_castingabout_ins.cfm | 42 | /qry/audprojects_castingabout_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audprojects_castingabout_upd.cfm | 17 | /qry/audprojects_castingabout_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audprojects_ins.cfm | 26 | /qry/audprojects_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audprojects_sel.cfm | 11 | /qry/audprojects_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audprojects_upd.cfm | 52 | /qry/audprojects_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audqtypes_ins.cfm | 7 | /qry/audqtypes_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audqtypes_sel.cfm | 11 | /qry/audqtypes_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audqtypes_upd.cfm | 9 | /qry/audqtypes_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audquestions_default_ins.cfm | 8 | /qry/audquestions_default_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audquestions_default_upd.cfm | 11 | /qry/audquestions_default_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audquestions_user_ins.cfm | 18 | /qry/audquestions_user_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audquestions_user_upd.cfm | 18 | /qry/audquestions_user_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audroles_ins.cfm | 35 | /qry/audroles_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audroles_sel.cfm | 11 | /qry/audroles_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audroles_upd.cfm | 33 | /qry/audroles_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audroletypes_ins.cfm | 7 | /qry/audroletypes_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audroletypes_sel.cfm | 10 | /qry/audroletypes_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audroletypes_upd.cfm | 12 | /qry/audroletypes_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audsources_ins.cfm | 7 | /qry/audsources_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audsources_sel.cfm | 10 | /qry/audsources_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audsources_upd.cfm | 7 | /qry/audsources_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audsteps_ins.cfm | 6 | /qry/audsteps_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audsteps_sel.cfm | 9 | /qry/audsteps_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audsteps_upd.cfm | 7 | /qry/audsteps_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audsubcategories_ins.cfm | 8 | /qry/audsubcategories_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audsubcategories_sel.cfm | 11 | /qry/audsubcategories_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audsubcategories_upd.cfm | 8 | /qry/audsubcategories_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/auds_byrole.cfm | 6 | /qry/auds_byrole.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audtones_ins.cfm | 8 | /qry/audtones_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audtones_sel.cfm | 14 | /qry/audtones_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audtones_upd.cfm | 8 | /qry/audtones_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audtones_user_sel.cfm | 2 | /qry/audtones_user_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audtypes_ins.cfm | 7 | /qry/audtypes_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audtypes_sel.cfm | 5 | /qry/audtypes_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audtypes_upd.cfm | 7 | /qry/audtypes_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audunions_ins.cfm | 8 | /qry/audunions_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audunions_sel.cfm | 7 | /qry/audunions_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audunions_upd.cfm | 8 | /qry/audunions_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audvocaltypes_audition_xref_ins.cfm | 7 | /qry/audvocaltypes_audition_xref_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audvocaltypes_audition_xref_upd.cfm | 7 | /qry/audvocaltypes_audition_xref_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audvocaltypes_ins.cfm | 7 | /qry/audvocaltypes_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audvocaltypes_sel.cfm | 9 | /qry/audvocaltypes_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/audvocaltypes_upd.cfm | 7 | /qry/audvocaltypes_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/aud_det.cfm | 3 | /qry/aud_det.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/aud_questions.cfm | 2 | /qry/aud_questions.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/birthdays.cfm | 2 | /qry/birthdays.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/calendar-appoint.cfm | 3 | /qry/calendar-appoint.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/calendar-appoint.cfm | 5 | /qry/calendar-appoint.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/castingdirectors_sel.cfm | 6 | /qry/castingdirectors_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/categories.cfm | 2 | /qry/categories.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/checkUniqueContact.cfm | 3 | /qry/checkUniqueContact.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/cities.cfm | 3 | /qry/cities.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contact.cfm | 3 | /qry/contact.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contact.cfm | 7 | /qry/contact.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contact.cfm | 11 | /qry/contact.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contact.cfm | 14 | /qry/contact.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contacts.cfm | 3 | /qry/contacts.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contacts.cfm | 5 | /qry/contacts.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contacts_all.cfm | 3 | /qry/contacts_all.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contacts_all.cfm | 5 | /qry/contacts_all.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contacts_all_tabs.cfm | 3 | /qry/contacts_all_tabs.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contacts_check.cfm | 6 | /qry/contacts_check.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contacts_check.cfm | 9 | /qry/contacts_check.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contact_info.cfm | 5 | /qry/contact_info.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contact_info.cfm | 9 | /qry/contact_info.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contact_info.cfm | 13 | /qry/contact_info.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/contact_info.cfm | 16 | /qry/contact_info.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/dashboard.cfm | 3 | /qry/dashboard.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/dashboard.cfm | 5 | /qry/dashboard.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/dashboardoptions.cfm | 3 | /qry/dashboardoptions.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/dashboardupdate2.cfm | 6 | /qry/dashboardupdate2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/dashboardupdate2.cfm | 14 | /qry/dashboardupdate2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/dashboardupdate2.cfm | 21 | /qry/dashboardupdate2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/dashboard_new.cfm | 1 | /qry/dashboard_new.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/dash_rr.cfm | 3 | /qry/dash_rr.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/dateformats.cfm | 6 | /qry/dateformats.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/default_table_ins.cfm | 13 | /qry/default_table_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/default_table_ins.cfm | 16 | /qry/default_table_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/default_table_ins.cfm | 51 | /qry/default_table_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/details.cfm | 2 | /qry/details.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/details.cfm | 8 | /qry/details.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/details.cfm | 64 | /qry/details.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/details.cfm | 67 | /qry/details.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/details.cfm | 117 | /qry/details.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/duration.cfm | 3 | /qry/duration.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/emailcheck.cfm | 3 | /qry/emailcheck.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/essence_sel.cfm | 6 | /qry/essence_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/events.cfm | 10 | /qry/events.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/events_byuser.cfm | 3 | /qry/events_byuser.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/eventtypes_user.cfm | 10 | /qry/eventtypes_user.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/findcompany.cfm | 3 | /qry/findcompany.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/fu_actions.cfm | 3 | /qry/fu_actions.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/getAuditionMaterials.cfm | 3 | /qry/getAuditionMaterials.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/getAuditionMediaPicklist.cfm | 3 | /qry/getAuditionMediaPicklist.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/headshots_sel.cfm | 6 | /qry/headshots_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/headshots_sel_unused.cfm | 6 | /qry/headshots_sel_unused.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/import.cfm | 3 | /qry/import.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/incometypes_sel.cfm | 6 | /qry/incometypes_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/inserttlog.cfm | 13 | /qry/inserttlog.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/items.cfm | 5 | /qry/items.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/itemsAll.cfm | 6 | /qry/itemsAll.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/locationDetails.cfm | 2 | /qry/locationDetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/materials_details.cfm | 6 | /qry/materials_details.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/materials_sel_unused.cfm | 5 | /qry/materials_sel_unused.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/mylinks.cfm | 3 | /qry/mylinks.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/myteam.cfm | 3 | /qry/myteam.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/myteam.cfm | 5 | /qry/myteam.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/note-add-aud.cfm | 3 | /qry/note-add-aud.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/note-add-event.cfm | 3 | /qry/note-add-event.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/note-add-event.cfm | 5 | /qry/note-add-event.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/note-add.cfm | 3 | /qry/note-add.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/note-add.cfm | 5 | /qry/note-add.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/note-update-aud.cfm | 3 | /qry/note-update-aud.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/note-update-aud.cfm | 5 | /qry/note-update-aud.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/note-update-event.cfm | 3 | /qry/note-update-event.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/note-update-event.cfm | 5 | /qry/note-update-event.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/note-update-event.cfm | 7 | /qry/note-update-event.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/note-update.cfm | 3 | /qry/note-update.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/note-update.cfm | 5 | /qry/note-update.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/note-update.cfm | 7 | /qry/note-update.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/NotesAud.cfm | 7 | /qry/NotesAud.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/NotesAud.cfm | 10 | /qry/NotesAud.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/notesContact.cfm | 7 | /qry/notesContact.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/notesContact.cfm | 10 | /qry/notesContact.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/notesEvent.cfm | 7 | /qry/notesEvent.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/notesEvent.cfm | 10 | /qry/notesEvent.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/notesrelationship.cfm | 7 | /qry/notesrelationship.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/notesrelationship.cfm | 10 | /qry/notesrelationship.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/notsactive.cfm | 8 | /qry/notsactive.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/notsactive.cfm | 11 | /qry/notsactive.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/notsactivedash.cfm | 6 | /qry/notsactivedash.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/notsactivedash.cfm | 9 | /qry/notsactivedash.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/notsactivedash.cfm | 12 | /qry/notsactivedash.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/notsall.cfm | 3 | /qry/notsall.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/phonecheck.cfm | 3 | /qry/phonecheck.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/profiles.cfm | 3 | /qry/profiles.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/projectDetails.cfm | 3 | /qry/projectDetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/rels.cfm | 3 | /qry/rels.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/remoteaudadd.cfm | 12 | /qry/remoteaudadd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/remoteaudadd.cfm | 15 | /qry/remoteaudadd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/remoteUpdateC.cfm | 3 | /qry/remoteUpdateC.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/remoteUpdateC.cfm | 8 | /qry/remoteUpdateC.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/remoteUpdateC.cfm | 14 | /qry/remoteUpdateC.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/remoteUpdateC.cfm | 22 | /qry/remoteUpdateC.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/remoteUpdateC.cfm | 145 | /qry/remoteUpdateC.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/remote_aud_project_update.cfm | 2 | /qry/remote_aud_project_update.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/remote_aud_project_update.cfm | 3 | /qry/remote_aud_project_update.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/remote_aud_project_update.cfm | 4 | /qry/remote_aud_project_update.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/reportcolors.cfm | 3 | /qry/reportcolors.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/reports.cfm | 20 | /qry/reports.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/reports.cfm | 24 | /qry/reports.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/reports.cfm | 27 | /qry/reports.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/reports.cfm | 30 | /qry/reports.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/reports.cfm | 34 | /qry/reports.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/reports.cfm | 41 | /qry/reports.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/reports.cfm | 51 | /qry/reports.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/reports.cfm | 53 | /qry/reports.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/reports.cfm | 74 | /qry/reports.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/reports.cfm | 77 | /qry/reports.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/reports.cfm | 80 | /qry/reports.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/reports.cfm | 83 | /qry/reports.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/reports.cfm | 85 | /qry/reports.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/results.cfm | 3 | /qry/results.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/results.cfm | 19 | /qry/results.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/results.cfm | 24 | /qry/results.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/results.cfm | 27 | /qry/results.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/results.cfm | 50 | /qry/results.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/selectActions.cfm | 2 | /qry/selectActions.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/select_cat_query.cfm | 6 | /qry/select_cat_query.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/select_cat_query.cfm | 21 | /qry/select_cat_query.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/select_cat_query.cfm | 28 | /qry/select_cat_query.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/select_cat_user_query.cfm | 7 | /qry/select_cat_user_query.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/select_query.cfm | 5 | /qry/select_query.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/select_user_query.cfm | 5 | /qry/select_user_query.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/select_user_query_noisdelete.cfm | 6 | /qry/select_user_query_noisdelete.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/share.cfm | 3 | /qry/share.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/sitetypes.cfm | 2 | /qry/sitetypes.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/sql.cfm | 3 | /qry/sql.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/sql.cfm | 10 | /qry/sql.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/sql.cfm | 12 | /qry/sql.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/sql.cfm | 14 | /qry/sql.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/sql.cfm | 48 | /qry/sql.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/sysActive.cfm | 6 | /qry/sysActive.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/systemNotificationsActive.cfm | 12 | /qry/systemNotificationsActive.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/SystemsActiveContact.cfm | 3 | /qry/SystemsActiveContact.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/SystemsActiveContact.cfm | 5 | /qry/SystemsActiveContact.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/SystemsActiveContact.cfm | 15 | /qry/SystemsActiveContact.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/SystemsContact.cfm | 3 | /qry/SystemsContact.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/tagsContact.cfm | 3 | /qry/tagsContact.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/tagsvalid.cfm | 3 | /qry/tagsvalid.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/testing.cfm | 10 | /qry/testing.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/testing.cfm | 13 | /qry/testing.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/testings.cfm | 3 | /qry/testings.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/timezones.cfm | 3 | /qry/timezones.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/timezones.cfm | 5 | /qry/timezones.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/tmpcontactgroups.cfm | 6 | /qry/tmpcontactgroups.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/toasts.cfm | 3 | /qry/toasts.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/toasts.cfm | 5 | /qry/toasts.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/update.cfm | 8 | /qry/update.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/update.cfm | 27 | /qry/update.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/update.cfm | 30 | /qry/update.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/update.cfm | 80 | /qry/update.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/updateNotification.cfm | 2 | /qry/updateNotification.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/update_action_users.cfm | 2 | /qry/update_action_users.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/update_action_users2.cfm | 2 | /qry/update_action_users2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/version-add.cfm | 2 | /qry/version-add.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/version-update.cfm | 3 | /qry/version-update.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/version-update.cfm | 5 | /qry/version-update.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/version.cfm | 9 | /qry/version.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/version.cfm | 11 | /qry/version.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/version.cfm | 13 | /qry/version.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/qry/versions.cfm | 3 | /qry/versions.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reminder_pane_fucked.cfm | 24 | /qry/notsactive_510_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remotaudmatadd.cfm | 12 | /qry/getAuditionMediaTypes.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteactionUpdate.cfm | 3 | /qry/actiondetails_194_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteactionUpdateUpdate.cfm | 11 | /qry/updateActionUsersByActionUpdate.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteactionUpdateUpdate.cfm | 14 | /qry/k_195_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteactionUpdateUpdate.cfm | 20 | /qry/up_195_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaddaudsubmitsite.cfm | 27 | /qry/getCategories_196_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaddaudsubmitsite2.cfm | 9 | /qry/find_197_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaddaudsubmitsite2.cfm | 13 | /qry/update_197_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaddaudsubmitsite2.cfm | 18 | /qry/add_197_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaddC.cfm | 16 | /qry/fetchLocationService.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaddC.cfm | 18 | /qry/details_198_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaddC.cfm | 22 | /qry/types_198_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaddC.cfm | 24 | /qry/types_198_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaddC.cfm | 194 | /qry/companies_198_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddCAdd.cfm | 12 | /qry/insert_199_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddCAdd.cfm | 17 | /qry/insertx_199_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddCAdd.cfm | 20 | /qry/add_199_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddCAdd.cfm | 27 | /qry/findcountry_199_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddCAdd.cfm | 35 | /qry/findregion_199_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddCAdd.cfm | 76 | /qry/update_199_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContact.cfm | 5 | /qry/tags_200_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAdd.cfm | 15 | /qry/add_201_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAdd.cfm | 21 | /qry/insert_201_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAdd.cfm | 27 | /qry/insert_201_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAdd.cfm | 32 | /qry/insert_201_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAdd.cfm | 37 | /qry/insert_201_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAddaud.cfm | 16 | /qry/add_202_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAddaud.cfm | 23 | /qry/insert_202_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAddaud.cfm | 29 | /qry/insert_202_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAddaud.cfm | 34 | /qry/insert_201_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAddaud.cfm | 39 | /qry/insert_202_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAddaud.cfm | 44 | /qry/insert_202_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAddaud.cfm | 52 | /qry/add_cd_202_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAddaud.cfm | 62 | /qry/findnumber_202_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAddaud.cfm | 66 | /qry/inserts_202_9.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAud.cfm | 16 | /qry/events_203_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAud.cfm | 19 | /qry/tags_203_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddContactAud.cfm | 22 | /qry/companies_203_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddEssenceContact2.cfm | 3 | /qry/add_sitetype_205_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaddHeadshot.cfm | 23 | /qry/getAuditionMediaTypes.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaddHeadshot2.cfm | 38 | /qry/audmedia_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaddMaterial.cfm | 25 | /qry/SEL_Media_types_material.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaddMaterial2.cfm | 36 | /qry/audmedia_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddName.cfm | 10 | /qry/pronouns_210_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddName.cfm | 11 | /qry/refers_210_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteAddNameAdd.cfm | 5 | /qry/add_211_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteapprove.cfm | 3 | /qry/details_212_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteapprove.cfm | 4 | /qry/users_212_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteapprove.cfm | 5 | /qry/find_212_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteapprove2.cfm | 5 | /qry/Insert_213_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteapprove2.cfm | 8 | /qry/update_213_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteapprove2.cfm | 15 | /qry/updateticket_213_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteapprove2.cfm | 18 | /qry/updateticket_213_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteassForm.cfm | 3 | /qry/aud_questions.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteassForm.cfm | 8 | /qry/x_214_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteassForm.cfm | 12 | /qry/insert_41_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteassForm.cfm | 15 | /qry/aud_questions.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteassFormUpdate.cfm | 3 | /qry/aud_questions.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteassFormUpdate.cfm | 21 | /qry/audanswers_ins_215_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudadd.cfm | 12 | /qry/audcategories_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudadd.cfm | 15 | /qry/audsubcategories_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudaddform.cfm | 7 | /qry/aud_details_217_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudaddform.cfm | 8 | /qry/audlocations_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudaddform.cfm | 12 | /qry/audtypes_sel_217_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudaddform.cfm | 13 | /qry/audsteps_sel_217_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudaddform.cfm | 14 | /qry/audplatforms_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudaddform2.cfm | 5 | /qry/audlocations_ins_218_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudaddform2.cfm | 9 | /qry/findproject_218_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudaddform2.cfm | 16 | /qry/auditions_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudmatadd2.cfm | 33 | /qry/audmedia_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 10 | /qry/durations.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 11 | /qry/fetchLocationService.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 12 | /qry/fetchusers.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 13 | /qry/audplatforms_user_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 14 | /qry/projectDetails_221_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 17 | /qry/roleDetails_221_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 18 | /qry/locationDetails_492_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 20 | /qry/cat_221_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 21 | /qry/cat_221_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 22 | /qry/audroletypes_sel_27_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 23 | /qry/audtypes_sel_221_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 24 | /qry/casting_types_221_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 25 | /qry/castingdirectors_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 49 | /qry/auditions_ins_221_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 59 | /qry/aud_det_221_9.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 61 | /qry/audtypes_sel_221_11.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 62 | /qry/audsteps_sel_217_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 63 | /qry/audplatforms_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 79 | /qry/findd_221_10.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 199 | /qry/audcallbacktypes_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform.cfm | 256 | /qry/audbooktypes_sel_221_13.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform2.cfm | 7 | /qry/FIND_222_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform2.cfm | 11 | /qry/insert_28_11.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform2.cfm | 20 | /qry/auditions_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform2.cfm | 21 | /qry/activate_222_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform2.cfm | 23 | /qry/auditionDetails_222_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform2.cfm | 24 | /qry/projectDetails_222_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteaudupdateform2.cfm | 37 | /qry/FindEvent_222_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remotecontent.cfm | 3 | /qry/details_223_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remotecontent.cfm | 4 | /qry/uu_223_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDelete.cfm | 9 | /qry/attachdetails_109_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDelete2.cfm | 2 | /qry/audmedia_details_225_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteaudmedia.cfm | 7 | /qry/audmedia_details_226_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteaudmedia2.cfm | 2 | /qry/audmedia_details_225_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteForm.cfm | 14 | /qry/FindKey_228_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteForm.cfm | 15 | /qry/Findrec_228_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteFormAud.cfm | 3 | /qry/details_229_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteFormAudDelete.cfm | 2 | /qry/del_230_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteFormAudDelete.cfm | 4 | /qry/del2_230_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteFormAudDelete.cfm | 6 | /qry/remove_191_11.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteFormAudprojectDelete.cfm | 3 | /qry/projectDetails_232_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteFormAudprojectDelete.cfm | 7 | /qry/roleDetails_232_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteFormAudprojectDelete.cfm | 9 | /qry/events_232_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteFormAudprojectDelete.cfm | 15 | /qry/del_232_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteFormAudprojectDelete.cfm | 19 | /qry/del2_232_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteFormAudprojectDelete.cfm | 20 | /qry/del3_232_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteFormAudprojectDelete.cfm | 21 | /qry/del4_232_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteFormAudprojectDelete.cfm | 22 | /qry/remove_191_11.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteFormDelete.cfm | 26 | /qry/delete_233_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteFormDelete.cfm | 39 | /qry/del_233_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteheadshots_auditions_xref.cfm | 3 | /qry/audmedia_details_226_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteheadshots_auditions_xref2.cfm | 3 | /qry/audmedia_headshots_delete.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeletelink.cfm | 3 | /qry/audlink_details_237_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteDeleteLink2.cfm | 3 | /qry/audmedia_details_238_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteheadingupdate.cfm | 4 | /qry/updates_239_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteheadingupdate2.cfm | 6 | /qry/add_240_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteheadingupdate2.cfm | 8 | /qry/pgPanelsFix.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remotelinkadd2.cfm | 10 | /qry/find_242_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remotelinkadd2.cfm | 30 | /qry/add_242_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteNewForm.cfm | 117 | /qry/selects_245_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteNewForm.cfm | 147 | /qry/selects_245_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteNewFormAdd.cfm | 32 | /qry/find_246_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remotenotedetails.cfm | 12 | /qry/getNoteDetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remotepaneladd2.cfm | 7 | /qry/find_249_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remotepaneladd2.cfm | 15 | /qry/add_sitetype_249_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remotepaneladd2.cfm | 20 | /qry/findit_249_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remotepaneladd2.cfm | 26 | /qry/Findtotal_249_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remotepaneladd2.cfm | 29 | /qry/add_249_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remotepaneladd2.cfm | 32 | /qry/add_249_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteRemoveaudmedia.cfm | 8 | /qry/audmedia_details_226_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteRemoveaudmedia2.cfm | 3 | /qry/audmedia_details_225_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteselectedheadshot2.cfm | 5 | /qry/ins_252_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteselectedheadshot2.cfm | 8 | /qry/ins_252_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteselectedmaterial2.cfm | 5 | /qry/ins_253_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteselectedmaterial2.cfm | 8 | /qry/ins_252_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteselectheadshot.cfm | 3 | /qry/headshots_sel_unused.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteselectheadshot.cfm | 5 | /qry/getAuditionMediaTypes.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteselectmaterial.cfm | 2 | /qry/materials_sel_unused.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteselectmaterial.cfm | 4 | /qry/getAuditionMediaTypes.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteSupportFormAdd.cfm | 48 | /qry/inserttlog.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateaudsubmitsite.cfm | 3 | /qry/details_259_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateaudsubmitsite.cfm | 29 | /qry/getCategories_196_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateaudsubmitsite.cfm | 50 | /qry/findsubs_259_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateaudsubmitsite2.cfm | 6 | /qry/subsites_189_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateaudsubmitsite2.cfm | 15 | /qry/update_260_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateC.cfm | 3 | /qry/fetchLocationService.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateC.cfm | 4 | /qry/details_261_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateC.cfm | 9 | /qry/findcountry_261_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateC.cfm | 16 | /qry/findregion_261_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateC.cfm | 27 | /qry/types.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateC.cfm | 178 | /qry/companies_198_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateCUpdate.cfm | 15 | /qry/insert_262_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateCUpdate.cfm | 20 | /qry/insertx_262_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateCUpdate.cfm | 24 | /qry/findcountry_199_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateCUpdate.cfm | 31 | /qry/findregion_262_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateCUpdate.cfm | 58 | /qry/update_262_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateCUpdate.cfm | 59 | /qry/update2_262_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateEssenceContact.cfm | 3 | /qry/details_263_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateEssenceContact2.cfm | 5 | /qry/update_264_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateForm.cfm | 13 | /qry/FindModalTitle_265_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateForm.cfm | 14 | /qry/update.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateForm.cfm | 20 | /qry/find_265_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateForm.cfm | 55 | /qry/FindValue_265_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateForm.cfm | 135 | /qry/FindValue_265_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateForm.cfm | 136 | /qry/selects_265_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateForm.cfm | 155 | /qry/FindValue_265_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateForm.cfm | 156 | /qry/selects_265_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateForm.cfm | 175 | /qry/FindValue_265_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateForm.cfm | 177 | /qry/selects_265_9.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateForm.cfm | 219 | /qry/FindValue_265_10.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateForm.cfm | 220 | /qry/selects_265_11.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateForm.cfm | 250 | /qry/selects_107_12.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateFormUpdate.cfm | 76 | /qry/FindOld_266_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateFormUpdate.cfm | 124 | /qry/update_266_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateFormUpdate.cfm | 125 | /qry/INSERT_266_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateFormUpdate.cfm | 149 | /qry/Finddetails_266_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateMaterial.cfm | 25 | /qry/materials_details.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateMaterial.cfm | 26 | /qry/SEL_Media_types_material.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateMaterial2.cfm | 10 | /qry/audmedia_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateName.cfm | 53 | /qry/pronouns_210_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateName.cfm | 54 | /qry/refers_210_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateName.cfm | 55 | /qry/details_269_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateNameUpdate.cfm | 24 | /qry/updatecontact_270_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateNameUpdate.cfm | 33 | /qry/find_270_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateNameUpdate.cfm | 37 | /qry/add_270_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateSUID.cfm | 2 | /qry/reldetails_271_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateTag.cfm | 3 | /qry/tagsContact.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateTag.cfm | 26 | /qry/tags_203_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUpdateTag.cfm | 49 | /qry/findt_272_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUserUpdate.cfm | 1 | /qry/getUserDetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUserUpdate.cfm | 3 | /qry/getAllCountries.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUserUpdate.cfm | 5 | /qry/getAllRegions.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteUserUpdated.cfm | 1 | /qry/qry_block_1_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteverticketupdate.cfm | 3 | /qry/details_274_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteverticketupdate.cfm | 4 | /qry/uu_274_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteverticketupdate.cfm | 5 | /qry/pages_274_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteverticketupdate.cfm | 6 | /qry/users_274_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteverticketupdate.cfm | 7 | /qry/statuses_274_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteverticketupdate.cfm | 8 | /qry/types_256_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteverticketupdate.cfm | 9 | /qry/priorities_274_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteverticketupdate.cfm | 10 | /qry/vers_274_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteverticketupdate2.cfm | 3 | /qry/update_275_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remoteverticketupdate2.cfm | 4 | /qry/details_275_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update.cfm | 6 | /qry/auditionprojectDetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update.cfm | 7 | /qry/audcategories_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update.cfm | 8 | /qry/audsubcategories_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update.cfm | 9 | /qry/audunions_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update.cfm | 10 | /qry/audnetworks_user_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update.cfm | 11 | /qry/audtones_user_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update.cfm | 12 | /qry/audcontracttypes_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update.cfm | 13 | /qry/castingdirectors_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update.cfm | 15 | /qry/audplatforms_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update.cfm | 16 | /qry/incometypes_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update.cfm | 17 | /qry/audpaycyles_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update2.cfm | 6 | /qry/insert_277_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update2.cfm | 15 | /qry/insert_277_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update2.cfm | 22 | /qry/find_new_277_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update2.cfm | 26 | /qry/audcontacts_auditions_xref_ins.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update2.cfm | 31 | /qry/del_277_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_aud_project_update2.cfm | 34 | /qry/audprojects_upd.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/remote_load.cfm | 3 | /qry/findit_278_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/removestatus.cfm | 8 | /qry/update_68_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reportrangegenerator.cfm | 3 | /qry/x_280_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reportrangegenerator.cfm | 96 | /qry/update2_280_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reportrangegenerator.cfm | 100 | /qry/update2_280_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reports.cfm | 97 | /qry/dataset_x_281_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reports.cfm | 150 | /qry/reportitems_x_281_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reports.cfm | 151 | /qry/dataset_x_281_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reports.cfm | 152 | /qry/labels_x_281_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reports.cfm | 158 | /qry/values_x_281_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reportsRefresh.cfm | 18 | /qry/delete_all_282_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reportsRefresh.cfm | 19 | /qry/rangeselected_282_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reportsRefresh.cfm | 21 | /qry/reportRefresh.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reports_backup.cfm | 97 | /qry/dataset_x_281_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reports_backup.cfm | 150 | /qry/reportitems_x_281_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reports_backup.cfm | 151 | /qry/dataset_x_281_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reports_backup.cfm | 152 | /qry/labels_x_281_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/reports_backup.cfm | 159 | /qry/values_x_281_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/restoreaction.cfm | 3 | /qry/removenotdups.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/restoreaction.cfm | 5 | /qry/restoreActionUsers.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/results.cfm | 86 | /qry/FindDetails_284_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/rolecheck.cfm | 28 | /qry/update_285_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 7 | /qry/audition.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 9 | /qry/essence_sel_470_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 10 | /qry/audroletypes_sel.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 11 | /qry/myteam_499_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 12 | /qry/auddialects_user_sel_358_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 13 | /qry/audsources_sel_499_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 210 | /qry/opencalls_286_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 221 | /qry/findc_286_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 266 | /qry/referrals_286_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 277 | /qry/findc_286_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 312 | /qry/subsites_286_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 351 | /qry/ranges_286_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 358 | /qry/findt_286_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 422 | /qry/vocals_286_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 429 | /qry/findt_286_9.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 455 | /qry/essences_286_10.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 461 | /qry/findg_286_11.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 491 | /qry/findit_286_12.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 497 | /qry/genres_286_13.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform.cfm | 503 | /qry/findge_286_14.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 83 | /qry/delete_287_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 84 | /qry/delete_287_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 85 | /qry/delete_287_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 86 | /qry/delete_287_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 87 | /qry/delete_287_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 91 | /qry/findit2_287_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 96 | /qry/insert_287_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 104 | /qry/findit_287_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 109 | /qry/insert_287_9.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 113 | /qry/insert_287_10.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 122 | /qry/findit_287_11.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 126 | /qry/insert_287_12.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 128 | /qry/insert_287_13.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 130 | /qry/insert_287_14.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 137 | /qry/delete_287_15.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 140 | /qry/insert_287_16.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 146 | /qry/delete_287_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 149 | /qry/insert_287_18.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 171 | /qry/findg_287_19.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 190 | /qry/add_287_20.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 204 | /qry/find_subsite_287_21.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 232 | /qry/update_287_22.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 242 | /qry/add_287_23.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 271 | /qry/insert_287_24.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/roleupdateform2.cfm | 278 | /qry/audroles_upd_287_25.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/rpg_load.cfm | 2 | /qry/RPG_288_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/rpg_load.cfm | 3 | /qry/RPGFields_288_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/rpg_load.cfm | 4 | /qry/RPGResults_288_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/rpg_load.cfm | 5 | /qry/RPGkey_288_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/rpg_load.cfm | 6 | /qry/RPGAdd_288_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/rpg_load.cfm | 7 | /qry/RPGUpdate_288_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/share.cfm | 21 | /qry/x_291_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/sql.cfm | 2 | /qry/y_292_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/sql.cfm | 8 | /qry/allfields_536_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/sql.cfm | 9 | /qry/x_292_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/sql.cfm | 10 | /qry/findp_292_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/sql.cfm | 44 | /qry/find_292_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/systemchange.cfm | 24 | /qry/FindSystem_294_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/systemchange.cfm | 25 | /qry/FindSystemOld_294_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/systemchange.cfm | 52 | /qry/InsertNote_294_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/systemchange.cfm | 57 | /qry/InsertNote_294_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/systemchange.cfm | 62 | /qry/InsertNote_294_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/systemchange.cfm | 67 | /qry/InsertNote_294_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/systemchange.cfm | 72 | /qry/InsertNote_294_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/systemchange.cfm | 77 | /qry/InsertNote_294_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/systemprefs_pane.cfm | 3 | /qry/mysystems_295_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/systemprefs_pane.cfm | 20 | /qry/action_user_295_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/systemprefs_pane.cfm | 21 | /qry/action_user_del_295_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/TagChange.cfm | 12 | /qry/delete_298_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/TagChange.cfm | 19 | /qry/find_298_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/TagChange.cfm | 23 | /qry/insert_tag_298_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/TagChange.cfm | 24 | /qry/find_298_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/TagChange.cfm | 27 | /qry/insert_298_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/TagChange.cfm | 32 | /qry/y_298_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/TagChange.cfm | 36 | /qry/find_orphan_298_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/TagChange.cfm | 40 | /qry/d_298_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/thrivecart_results.cfm | 14 | /qry/thrivecart_results.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/ticketclose.cfm | 2 | /qry/uu_223_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/ticketclose.cfm | 3 | /qry/update_299_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/ticketcomplete.cfm | 4 | /qry/find_300_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/ticketcomplete.cfm | 6 | /qry/update_300_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/ticketcomplete.cfm | 7 | /qry/details_303_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/ticketpass.cfm | 2 | /qry/update_302_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/ticket_email_client.cfm | 6 | /qry/find_303_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/ticket_email_client.cfm | 13 | /qry/update_303_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/ticket_email_client.cfm | 16 | /qry/details_303_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/tmpcontactgroups.cfm | 17 | /qry/BatchDetails_304_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/tmpcontactgroups.cfm | 34 | /qry/lastupdates.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/tmpcontactgroups.cfm | 61 | /qry/FindScope_304_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/tmpcontactgroups.cfm | 85 | /qry/FindSystem_304_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/tmpcontactgroups.cfm | 99 | /qry/FindActive_304_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/tmpcontactgroups.cfm | 138 | /qry/findsame_304_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/tmpcontactgroups.cfm | 156 | /qry/delete_304_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/tmpcontacttags.cfm | 30 | /qry/lastupdates.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/tmpcontacttags.cfm | 42 | /qry/BatchDetails_304_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/tmpcontacttags.cfm | 60 | /qry/findsame_305_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/tmpcontacttags.cfm | 67 | /qry/insert_305_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/tmpcontacttags.cfm | 94 | /qry/insert_305_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/toast.cfm | 2 | /qry/toasts_306_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/toast.cfm | 3 | /qry/toastmenu_306_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 18 | /qry/y_308_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 30 | /qry/find_308_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 37 | /qry/err_308_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 44 | /qry/err_308_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 51 | /qry/err_308_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 56 | /qry/findcat_308_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 62 | /qry/err_308_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 66 | /qry/findsource_308_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 71 | /qry/err_308_9.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 74 | /qry/update_308_10.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 79 | /qry/x_308_11.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 81 | /qry/x_308_12.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 96 | /qry/findcd_308_13.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 101 | /qry/INScontactDetails.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 109 | /qry/insert_28_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 131 | /qry/find_subcat_308_16.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 170 | /qry/find_cat_308_17.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 174 | /qry/find_subcat_308_18.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 185 | /qry/audprojects_ins_308_19.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 190 | /qry/find_source_308_20.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 200 | /qry/audroles_ins_308_21.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 203 | /qry/InsertNote_308_22.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/transfer_audition_back .cfm | 206 | /qry/update_contact_308_23.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/updateeventtype.cfm | 3 | /qry/linkdetails_309_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/updateeventtype.cfm | 4 | /qry/find_events_309_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/updateeventtypeupdate.cfm | 6 | /qry/update_310_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/UpdateFormUpdate.cfm | 76 | /qry/FindOld_311_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/UpdateFormUpdate.cfm | 122 | /qry/update_311_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/UpdateFormUpdate.cfm | 123 | /qry/INSERT_266_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/updatetickver2.cfm | 3 | /qry/update_312_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/updatetickver2.cfm | 4 | /qry/details_312_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/updatetickver2.cfm | 18 | /qry/inserttlog.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/updatetickver2.cfm | 23 | /qry/old_312_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/updatetickver2.cfm | 24 | /qry/new_312_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/updatetickver2.cfm | 46 | /qry/inserttlog.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/update_cal.cfm | 9 | /qry/update_cal.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/update_import_auditions.cfm | 27 | /qry/find_313_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/update_import_auditions.cfm | 32 | /qry/update_record_313_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/update_order.cfm | 7 | /qry/query_0_314_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 6 | /qry/INSERT_315_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 27 | /qry/find_315_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 29 | /qry/getContactsImportByUploadID.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 33 | /qry/add_315_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 41 | /qry/find_note_315_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 44 | /qry/InsertNote_315_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 52 | /qry/tag_315_10.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 55 | /qry/tag_insert_315_11.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 58 | /qry/tag_315_12.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 62 | /qry/tag_insert_315_13.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 65 | /qry/tag_315_14.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 68 | /qry/tag_insert_315_15.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 71 | /qry/e_315_16.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 73 | /qry/e_insert_315_17.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 76 | /qry/f_315_18.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 78 | /qry/f_insert_315_19.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 81 | /qry/g_315_20.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 83 | /qry/g_insert_315_21.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 86 | /qry/h_315_22.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 88 | /qry/h_insert_315_23.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 91 | /qry/i_315_24.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 93 | /qry/i_insert_315_25.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 96 | /qry/j_315_26.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 98 | /qry/j_insert_315_27.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 101 | /qry/u_315_28.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 103 | /qry/u_insert_315_29.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 106 | /qry/address_315_30.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 110 | /qry/address_insert_315_31.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 117 | /qry/maints_315_32.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 129 | /qry/findsystem_315_33.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 136 | /qry/addSystem_315_34.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 139 | /qry/addDaysNo_315_35.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 141 | /qry/checkUnique_315_36.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 145 | /qry/addNotification_315_37.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload.cfm | 147 | /qry/addNotification_315_38.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload_update_audition.cfm | 20 | /qry/find_317_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/upload_update_audition.cfm | 26 | /qry/fix_191_9.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 57 | /qry/users_318_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 201 | /qry/C_318_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 293 | /qry/m_318_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 296 | /qry/FIND_318_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 300 | /qry/insert_318_5.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 304 | /qry/x_318_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 308 | /qry/find_318_7.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 321 | /qry/insert_318_8.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 328 | /qry/Findtotal_318_9.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 329 | /qry/add_318_10.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 331 | /qry/add_249_6.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 342 | /qry/x_318_12.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 346 | /qry/find_318_13.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 359 | /qry/insert_318_14.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 370 | /qry/x_318_15.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 374 | /qry/find_318_16.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 379 | /qry/find2_318_17.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 392 | /qry/insert_318_18.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 408 | /qry/xs_318_19.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 412 | /qry/find_318_20.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 425 | /qry/insert_318_21.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 437 | /qry/xs_318_22.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 441 | /qry/getActionUsers.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 454 | /qry/insert_318_24.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 467 | /qry/x_318_25.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 471 | /qry/find_318_26.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 484 | /qry/insert_318_27.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 496 | /qry/update_tags_318_28.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 497 | /qry/update_Iscasting_318_29.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 498 | /qry/u_318_30.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 499 | /qry/x_318_31.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 503 | /qry/find_318_32.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 516 | /qry/insert_318_33.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 529 | /qry/x_318_34.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 534 | /qry/find_318_35.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 536 | /qry/check_318_36.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/user_setup.cfm | 546 | /qry/insert_318_37.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/version-add2.cfm | 33 | /qry/find_320_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/version-add2.cfm | 40 | /qry/insert_320_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/version-update2.cfm | 3 | /qry/update_322_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/version.cfm | 11 | /qry/vers_323_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/version.cfm | 251 | /qry/versions_323_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/version.cfm | 340 | /qry/ticketusers_323_3.cfm | TECH-DEBT: scope-leaking cfinclude |
| include/version.cfm | 341 | /qry/ticketme_323_4.cfm | TECH-DEBT: scope-leaking cfinclude |
| sched/Application_back.cfc | 98 | /qry/fetchUsers.cfm | TECH-DEBT: scope-leaking cfinclude |
| sched/Application_back.cfc | 135 | /qry/fetchUsers.cfm | TECH-DEBT: scope-leaking cfinclude |
| sched/Application_last.cfc | 41 | /qry/fetchUsers.cfm | TECH-DEBT: scope-leaking cfinclude |
| sched/Application_last.cfc | 72 | /qry/fetchUsers.cfm | TECH-DEBT: scope-leaking cfinclude |
| sched/appoint-update2.cfm | 7 | /qry/duration.cfm | TECH-DEBT: scope-leaking cfinclude |
| sched/appoint-update2.cfm | 31 | /qry/update_618_1.cfm | TECH-DEBT: scope-leaking cfinclude |
| sched/appoint-update2.cfm | 85 | /qry/inserts_619_2.cfm | TECH-DEBT: scope-leaking cfinclude |
| sched/extracts_for_multiple.cfm | 68 | /qry/#newQueryFilename# | TECH-DEBT: scope-leaking cfinclude |
| sched/extract_queries.cfm | 52 | /qry/#newQueryFilename# | TECH-DEBT: scope-leaking cfinclude |
| sched/extract_queries_overwrite.cfm | 51 | /qry/#newQueryFilename# | TECH-DEBT: scope-leaking cfinclude |
| sched/extract_queries_overwrite_qry.cfm | 45 | /qry/#newQueryFilename# | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 79 | /qry/friendfamilycheck.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 81 | /qry/contacts.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 83 | /qry/categories.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 85 | /qry/items.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 87 | /qry/notesContact.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 89 | /qry/SystemsContact.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 91 | /qry/tagsContact.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 93 | /qry/profiles.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 95 | /qry/sysactive.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 97 | /qry/notsall.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 99 | /qry/events.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 101 | /qry/systemNotificationsActive.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 103 | /qry/SystemsActiveContact.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 105 | /qry/ru.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 107 | /qry/emailcheck.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 109 | /qry/phonecheck.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 111 | /qry/rels.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 113 | /qry/fetchcontactitems.cfm | TECH-DEBT: scope-leaking cfinclude |
| setup/contact_info.cfm | 115 | /qry/tagFriendCheck.cfm | TECH-DEBT: scope-leaking cfinclude |
| share/assets/eventtypes_user.cfm | 2 | /qry/eventtypes_user.cfm | TECH-DEBT: scope-leaking cfinclude |
| share/remoteUpdateForm.cfm | 30 | /qry/update.cfm | TECH-DEBT: scope-leaking cfinclude |

---

## 2C — Dynamic Includes (Highest Risk)

**Every match below is flagged: TECH-DEBT: dynamic cfinclude -- cannot statically verify -- MANUAL REVIEW REQUIRED**

These cfinclude tags contain ColdFusion expressions (#...#) in the template path,
making it impossible to determine at build time which file will be included.
This is a security risk (potential path traversal) and a dead-code-analysis blocker.

| Calling File | Line | Include Expression | Flag |
|---|---|---|---|
| app/ajax/Application.cfc | 25 | `template="#arguments.targetPage#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| app/Application.cfc | 353 | `template="#arguments.targetPage#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| include/account_info.cfm | 173 | `template="#modalData.include#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| include/audition.cfm | 871 | `template="#includeTemplates[secid]#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| include/core.cfm | 41 | `template="#findlinkst.linkurl#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| include/core.cfm | 82 | `template="/include/#pgFilename#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| include/core.cfm | 193 | `template="#findlinksb.linkurl#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| include/coreb.cfm | 31 | `template="#findlinkst.linkurl#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| include/coreb.cfm | 181 | `template="/include/#pgFilename#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| include/coreb.cfm | 228 | `template="#findlinksb.linkurl#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| include/core_nomenu.cfm | 93 | `template="/include/#pgFilename#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| include/dashboard_new.cfm | 72 | `template="/include/#dashboards.pnFilename#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| include/pgload.cfm | 52 | `template="/include/qry/#pgFilename#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| include/qry/sql.cfm | 21 | `template="/include/remote_load.cfm"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| include/sql.cfm | 16 | `template="/include/remote_load.cfm"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| sched/Application_back.cfc | 178 | `template="#arguments.targetPage#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| sched/extracts.cfm | 88 | `template="#qry_path#/#newQueryFilename#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| sched/extracts_for_multiple.cfm | 68 | `template="/include/qry/#newQueryFilename#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| sched/extracts_new.cfm | 97 | `template="#qry_path#/#newQueryFilename#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| sched/extracts_newest.cfm | 97 | `template="#qry_path#/#newQueryFilename#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| sched/extracts_newest_qry.cfm | 97 | `template="#qry_path#/#newQueryFilename#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| sched/extract_queries.cfm | 52 | `template="/extracted/qry/#newQueryFilename#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| sched/extract_queries_overwrite.cfm | 51 | `template="/optimized/qry/#newQueryFilename#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |
| sched/extract_queries_overwrite_qry.cfm | 45 | `template="/optimized/qry/#newQueryFilename#"` | TECH-DEBT: dynamic cfinclude -- MANUAL REVIEW REQUIRED |

---

## Summary Statistics

| Category | Count (excl. dev_backup/) |
|---|---|
| variables.Service.method() calls | 122 |
| createObject("component","services.*") instantiations | 935 |
| /qry/ cfinclude callers | 1,301 |
| Dynamic cfinclude (highest risk) | 24 |
| application.Service.method() calls | 0 |
| request.Service.method() calls | 0 |
| cfinvoke component="services.*" calls | 0 |

### Key Observations

1. **No application-scoped or request-scoped service singletons.** All services are instantiated
   per-request via `createObject()`. This means every page/AJAX hit creates fresh CFC instances --
   potential performance concern for high-traffic pages.

2. **935 createObject instantiations** spread across ~900+ files in /include/qry/ alone. The vast
   majority of service usage is inside /qry/ files that are themselves cfincluded, creating a
   two-level indirection: page -> cfinclude /qry/file.cfm -> createObject -> service.method().

3. **1,301 /qry/ cfinclude calls** -- all scope-leaking. Every query result variable bleeds into
   the caller's scope. This makes variable collision bugs likely and refactoring dangerous.

4. **24 dynamic cfincludes** that cannot be statically traced. These are the highest-risk items
   for security review and dead-code detection.

5. **Service call patterns found:**
   - `variables.v3Service.*` (ContactImportV3 subsystem)
   - `variables.auditionService.*` / `variables.audService.*` / `variables.importService.*` (audition import subsystem)
   - `variables.dupeService.*` (duplicate detection)
   - `variables.validationService.*` (field validation)
   - `variables.fileParserService.*`, `variables.duplicateMatcherService.*`, `variables.contactService.*` (ContactImportV2Service internal calls)

---

*This file is consumed by later audit phases for dead-code detection. Every service function call
and /qry/ include has been captured with file paths.*
