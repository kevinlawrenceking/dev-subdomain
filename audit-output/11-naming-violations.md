# Phase 1A: Service CFC Naming Violations Report

**Generated:** 2026-03-16
**Total Service CFCs Scanned:** 138 (excluding Application.cfm, FunctionMigrationReference.md)
**Total Functions Found:** 1159
**Total Naming Violations:** 798

## Legend
- :x: = critical violation
- :warning: = needs review
- :white_check_mark: = clean
- :repeat: = merge candidate
- :lock: = security issue
- :skull: = dead code

## 1. Banned Verb Violations

| # | CFC File | Function Name | Access | Return Type | Violation | Suggested Name |
|---|----------|---------------|--------|-------------|-----------|----------------|
| 1 | AuditionImportService.cfc | `processRowForImport` | private | struct | :x: Banned verb 'process' -> rename to what it actually does | `` |
| 2 | ContactImportV2Service.cfc | `processRows` | public | struct | :x: Banned verb 'process' -> rename to what it actually does | `` |
| 3 | ContactImportV3Service.cfc | `processRowForImport` | private | struct | :x: Banned verb 'process' -> rename to what it actually does | `` |

## 2. Legacy CRUD Prefix Functions with Page-ID Suffixes

These functions use the legacy `SEL/INS/UPD/DEL/DET/RES` prefix pattern AND have
numeric suffixes that embed page context (e.g., `_24553`). They should be renamed to
standard verbs with descriptive names.

**Total functions with page-ID numeric suffixes:** 523

| CFC File | Count | Example Functions |
|----------|-------|-------------------|
| ActionUserService.cfc | 1 | `INSactionusers_24455` |
| AuditionAgeRangeService.cfc | 1 | `SELaudageranges_24552` |
| AuditionAgeRangeXRefService.cfc | 1 | `INSaudageranges_audtion_xref_24502` |
| AuditionAnswerService.cfc | 2 | `INSaudanswers_24506`, `UPDaudanswers_24507` |
| AuditionCallbackTypeService.cfc | 1 | `SELaudcallbacktypes_24509` |
| AuditionCategoryService.cfc | 9 | `SELaudcategories_23908`, `SELaudcategories_24033`, `SELaudcategories_24357` ... (+6 more) |
| AuditionGenreUserService.cfc | 4 | `SELaudgenres_user_24272`, `SELaudgenres_user_24273`, `SELaudgenres_user_24285` ... (+1 more) |
| AuditionImportErrorService.cfc | 4 | `INSauditionsimport_error_24355`, `INSauditionsimport_error_24356`, `INSauditionsimport_error_24358` ... (+1 more) |
| AuditionMediaService.cfc | 13 | `SELaudmedia_23799`, `DETaudmedia_24113`, `SELaudmedia_24249` ... (+10 more) |
| AuditionMediaTypeService.cfc | 2 | `SELaudmediatypes_23753`, `SELaudmediatypes_24198` |
| AuditionMediaXRefService.cfc | 2 | `INSaudmedia_auditions_xref_24153`, `INSaudmedia_auditions_xref_24568` |
| AuditionOpenCallOptionUserService.cfc | 2 | `SELaudopencalloptions_user_24262`, `SELaudopencalloptions_user_24280` |
| AuditionPayCycleService.cfc | 1 | `SELaudpaycycles_24579` |
| AuditionPlatformUserService.cfc | 3 | `SELaudPlatforms_user_23778`, `INSaudPlatforms_user_23779`, `SELaudplatforms_user_24582` |
| AuditionProjectService.cfc | 40 | `UPDaudprojects_24586`, `SELaudprojects_23795`, `DETaudprojects_23811` ... (+37 more) |
| AuditionQuestionUserService.cfc | 2 | `SELaudquestions_user_24078`, `SELaudquestions_user_24501` |
| AuditionRoleService.cfc | 17 | `SELaudroles_23809`, `UPDaudroles_23810`, `UPDaudroles_23813` ... (+14 more) |
| AuditionSourceService.cfc | 4 | `SELaudsources_24222`, `SELaudsources_24359`, `SELaudsources_24371` ... (+1 more) |
| AuditionStepService.cfc | 3 | `SELaudsteps_23784`, `SELaudsteps_23792`, `SELaudsteps_24083` |
| AuditionSubmitSiteUserService.cfc | 6 | `UPDaudsubmitsites_user_24167`, `SELaudsubmitsites_user_24034`, `SELaudsubmitsites_user_24265` ... (+3 more) |
| AuditionTypeService.cfc | 6 | `SELaudtypes_23793`, `SELaudtypes_24082`, `SELaudtypes_24231` ... (+3 more) |
| AuditionVocalTypeXRefService.cfc | 1 | `INSaudvocaltypes_audition_xref_24613` |
| ContactAuditionService.cfc | 7 | `INSaudcontacts_auditions_xref_23780`, `INSaudcontacts_auditions_xref_24059`, `DELaudcontacts_auditions_xref_24127` ... (+4 more) |
| ContactImportService.cfc | 2 | `SELcontactsimport_24409`, `SELcontactsimport_24668` |
| ContactItemService.cfc | 67 | `SELfindscope_24712`, `SELcontactitems_23758`, `SELcontactitems_23759` ... (+64 more) |
| ContactSSService.cfc | 1 | `SELcontacts_ss_23946` |
| ContactService.cfc | 36 | `SELcontactdetails_23722`, `SELcontactdetails_23727`, `INScontactdetails_23769` ... (+33 more) |
| ContactService_Consolidated.cfc | 2 | `INScontactdetails_23839`, `SELcontactdetails_23843` |
| CountryService.cfc | 3 | `SELcountries_24169`, `SELcountries_24637`, `SELcountries_24720` |
| EssenceService.cfc | 5 | `UPDessences_24181`, `SELessences_24270`, `SELessences_24282` ... (+2 more) |
| EventContactsXRefService.cfc | 9 | `INSeventcontactsxref_23737`, `SELeventcontactsxref_23738`, `INSeventcontactsxref_24020` ... (+6 more) |
| EventService.cfc | 44 | `SELevents_24105`, `UPDevents_24104`, `UPDevents_23725` ... (+41 more) |
| EventTypesUserService.cfc | 4 | `SELeventtypes_user_24484`, `SELeventtypes_user_24486`, `SELeventtypes_user_24619` ... (+1 more) |
| FUActionService.cfc | 1 | `SELfuactions_24453` |
| GenderPronounUserService.cfc | 4 | `SELgenderpronouns_users_24203`, `SELgenderpronouns_users_24444`, `INSgenderpronouns_users_24445` ... (+1 more) |
| GenreAuditionService.cfc | 2 | `SELaudgenres_audition_xref_24274`, `INSaudgenres_audition_xref_24521` |
| ItemCategoryService.cfc | 4 | `SELitemcategory_24039`, `SELitemcategory_24465`, `SELitemcategory_24621` ... (+1 more) |
| ItemCategoryXRefUserService.cfc | 1 | `INSitemcatxref_user_24468` |
| ItemTypeService.cfc | 1 | `SELitemtypes_24462` |
| ItemTypesUserService.cfc | 2 | `INSitemtypes_user_24464`, `SELitemtypes_user_24466` |
| LinkService.cfc | 1 | `SELlinks_23981` |
| MeetingDurationService.cfc | 3 | `SELmtgdurations_24493`, `SELmtgdurations_24655`, `SELmtgdurations_24656` |
| NoteService.cfc | 17 | `DELnoteslog_23709`, `INSnoteslog_23730`, `INSnoteslog_23966` ... (+14 more) |
| NotificationService.cfc | 15 | `INSfunotifications_23817`, `UPDfunotifications_23818`, `UPDfunotifications_24032` ... (+12 more) |
| PageAppLinkService.cfc | 2 | `SELpgapplinks_24006`, `SELpgapplinks_24007` |
| PageFieldService.cfc | 2 | `SELpgfields_24115`, `SELpgfields_24651` |
| PageService.cfc | 21 | `SELpgpages_24740`, `SELpgpages_23868`, `SELpgpages_23870` ... (+18 more) |
| PanelUserService.cfc | 10 | `UPDpgpanels_user_23858`, `UPDpgpanels_user_23886`, `SELpgpanels_user_24136` ... (+7 more) |
| RegionService.cfc | 4 | `SELregions_24170`, `SELregions_24177`, `SELregions_24717` ... (+1 more) |
| ReportItemService.cfc | 4 | `SELreportitems_24225`, `SELreportitems_24226`, `SELreportitems_24227` ... (+1 more) |
| ReportRangeService.cfc | 2 | `UPDreportranges_24221`, `SELreportranges_24229` |
| ReportUserService.cfc | 7 | `SELreports_user_24232`, `SELreports_user_24725`, `SELreports_user_24728` ... (+4 more) |
| SiteLinkUserService.cfc | 9 | `UPDsitelinks_user_23854`, `UPDsitelinks_user_23883`, `UPDsitelinks_user_23930` ... (+6 more) |
| SiteTypeMasterService.cfc | 1 | `SELsitetypes_master_24437` |
| SiteTypeUserService.cfc | 9 | `SELsitetypes_user_24133`, `UPDsitetypes_user_24134`, `SELsitetypes_user_24144` ... (+6 more) |
| SystemService.cfc | 15 | `SELfusystems_23821`, `SELfusystems_23933`, `SELfusystems_23938` ... (+12 more) |
| SystemUserService.cfc | 12 | `SELfusystemusers_23864`, `UPDfusystemusers_23865`, `INSfusystemusers_23934` ... (+9 more) |
| TagsUserService.cfc | 12 | `SELtags_user_23804`, `SELtags_user_23844`, `SELtags_user_24047` ... (+9 more) |
| TaoVersionService.cfc | 5 | `SELtaoversions_24215`, `SELtaoversions_24331`, `SELtaoversions_24386` ... (+2 more) |
| TicketService.cfc | 25 | `SELtickets_23720`, `UPDtickets_23866`, `SELtickets_23997` ... (+22 more) |
| TicketStatusService.cfc | 2 | `SELticketstatuses_24766`, `SELticketstatuses_24781` |
| TicketTestUserService.cfc | 2 | `SELtickettestusers_24474`, `SELtickettestusers_24475` |
| TimeZoneService.cfc | 1 | `SELtimezones_24770` |
| UserService.cfc | 22 | `SELtaousers_23718`, `SELtaousers_23721`, `SELtaousers_23842` ... (+19 more) |

## 3. Legacy CRUD Prefix Functions (Base Names, No Numeric Suffix)

These use legacy prefixes but without page-context numbers. They are the base
versions and should be renamed first as part of standardization.

**Total:** 272

| CFC File | Count | Example Functions |
|----------|-------|-------------------|
| AttachmentService.cfc | 4 | `INSattachments`, `DETattachments`, `UPDattachments` ... (+1 more) |
| AuditionAgeRangeService.cfc | 3 | `SELaudageranges`, `INSaudageranges`, `UPDaudageranges` |
| AuditionAgeRangeXRefService.cfc | 4 | `SELaudageranges_audtion_xref`, `DELaudageranges_audtion_xref`, `INSaudageranges_audtion_xref` ... (+1 more) |
| AuditionAnswerService.cfc | 3 | `DELaudanswers`, `INSaudanswers`, `UPDaudanswers` |
| AuditionBookTypeService.cfc | 1 | `SELaudbooktypes` |
| AuditionCallbackTypeService.cfc | 1 | `SELaudcallbacktypes` |
| AuditionCategoryService.cfc | 3 | `SELaudcategories`, `INSaudcategories`, `UPDaudcategories` |
| AuditionContractTypeService.cfc | 2 | `INSaudcontracttypes`, `UPDaudcontracttypes` |
| AuditionDialectService.cfc | 2 | `INSauddialects`, `UPDauddialects` |
| AuditionDialectsUserService.cfc | 2 | `INSauddialects_user`, `SELauddialects_user` |
| AuditionEssenceXRefService.cfc | 3 | `SELaudessences_audtion_xref`, `DELaudessences_audtion_xref`, `INSaudessences_audtion_xref` |
| AuditionGenreService.cfc | 2 | `INSaudgenres`, `UPDaudgenres` |
| AuditionGenreService_standardized.cfc | 2 | `INSaudgenres`, `UPDaudgenres` |
| AuditionGenreUserService.cfc | 2 | `SELaudgenres_user`, `INSaudgenres_user` |
| AuditionImportErrorService.cfc | 2 | `SELauditionsimport_error`, `INSauditionsimport_error` |
| AuditionLinkService.cfc | 4 | `SELaudlinks`, `INSaudlinks`, `DETaudlinks` ... (+1 more) |
| AuditionLocationService.cfc | 3 | `UPDaudlocations`, `INSaudlocations`, `SELaudlocations` |
| AuditionMediaAudRolesXRefService.cfc | 2 | `INSaudmedia_audroles_xref`, `UPDaudmedia_audroles_xref` |
| AuditionMediaService.cfc | 4 | `SELaudmedia`, `UPDaudmedia`, `DETaudmedia` ... (+1 more) |
| AuditionMediaTypeService.cfc | 4 | `SELaudmediatypes`, `SEL_Media_types_material`, `INSaudmediatypes` ... (+1 more) |
| AuditionMediaXRefService.cfc | 3 | `INSaudmedia_auditions_xref`, `DELaudmedia_auditions_xref`, `SELaudmedia_auditions_xref` |
| AuditionNetworkService.cfc | 2 | `INSaudnetworks`, `UPDaudnetworks` |
| AuditionNetworkUserService.cfc | 1 | `INSaudnetworks_user` |
| AuditionOpenCallOptionUserService.cfc | 2 | `SELaudopencalloptions_user`, `INSaudopencalloptions_user` |
| AuditionPayCycleService.cfc | 1 | `SELaudpaycycles` |
| AuditionPlatformsService.cfc | 2 | `INSaudplatforms`, `UPDaudplatforms` |
| AuditionProjectService.cfc | 4 | `DETaudprojects`, `SELaudprojects`, `UPDaudprojects` ... (+1 more) |
| AuditionProjectsCastingAboutService.cfc | 2 | `INSaudprojects_castingabout`, `UPDaudprojects_castingabout` |
| AuditionQuestionTypeService.cfc | 2 | `INSaudqtypes`, `UPDaudqtypes` |
| AuditionQuestionUserService.cfc | 3 | `SELaudquestions_user`, `INSaudquestions_user`, `UPDaudquestions_user` |
| AuditionQuestionsDefaultService.cfc | 2 | `INSaudquestions_default`, `UPDaudquestions_default` |
| AuditionRoleService.cfc | 4 | `SELaudroles`, `INSaudroles`, `UPDaudroles` ... (+1 more) |
| AuditionRoleTypeService.cfc | 3 | `SELaudroletypes`, `INSaudroletypes`, `UPDaudroletypes` |
| AuditionSourceService.cfc | 3 | `SELaudsources`, `INSaudsources`, `UPDaudsources` |
| AuditionStepService.cfc | 3 | `SELaudsteps`, `INSaudsteps`, `UPDaudsteps` |
| AuditionSubcategorieService.cfc | 3 | `SELaudsubcategories`, `INSaudsubcategories`, `UPDaudsubcategories` |
| AuditionSubmitSiteUserService.cfc | 4 | `SELaudsubmitsites_user`, `UPDaudsubmitsites_user`, `INSaudsubmitsites_user` ... (+1 more) |
| AuditionToneUserService.cfc | 2 | `INSaudtones_user`, `SELaudtones_user` |
| AuditionTonesService.cfc | 2 | `INSaudtones`, `UPDaudtones` |
| AuditionTypeService.cfc | 3 | `SELaudtypes`, `INSaudtypes`, `UPDaudtypes` |
| AuditionUnionService.cfc | 3 | `SELaudunions`, `INSaudunions`, `UPDaudunions` |
| AuditionVocalTypeService.cfc | 3 | `SELaudvocaltypes`, `INSaudvocaltypes`, `UPDaudvocaltypes` |
| AuditionVocalTypeXRefService.cfc | 4 | `SELaudvocaltypes_audition_xref`, `DELaudvocaltypes_audition_xref`, `INSaudvocaltypes_audition_xref` ... (+1 more) |
| BigBrotherService.cfc | 2 | `INSbigbrother`, `RESbigbrother` |
| CityService.cfc | 1 | `SELcities` |
| ComponentService.cfc | 1 | `SELpgcomps` |
| ContactAuditionService.cfc | 4 | `INSaudcontacts_auditions_xref`, `INSaudcontacts_auditions_xref_2`, `DELaudcontacts_auditions_xref` ... (+1 more) |
| ContactImportService.cfc | 11 | `UPDCONTACTSIMPORT`, `DETcontactsimport`, `SELcontactsimport_f` ... (+8 more) |
| ContactItemService.cfc | 6 | `SELcontactitems`, `INScontactitems`, `DETcontactitems` ... (+3 more) |
| ContactSSService.cfc | 1 | `SELcontacts_ss` |
| ContactService.cfc | 5 | `SELcontactdetails`, `INScontactdetails`, `UPDcontactdetails` ... (+2 more) |
| CountryService.cfc | 1 | `SELcountries` |
| DateFormatService.cfc | 1 | `SELdateformats` |
| EssenceService.cfc | 4 | `SELessences`, `UPDessences`, `INSessences` ... (+1 more) |
| EventContactsXRefService.cfc | 4 | `INSeventcontactsxref`, `SELeventcontactsxref`, `UPDeventcontactsxref` ... (+1 more) |
| EventService.cfc | 5 | `INSevents`, `UPDevents`, `RESevents` ... (+2 more) |
| EventTypesService.cfc | 1 | `SELeventtypes` |
| EventTypesUserService.cfc | 4 | `DETeventtypes_user`, `UPDeventtypes_user`, `SELeventtypes_user` ... (+1 more) |
| ExportItemService.cfc | 2 | `INSexportitems`, `SELexportitems` |
| ExportService.cfc | 2 | `INSexports`, `UPDexports` |
| FTypeXRefService.cfc | 1 | `SELftypexref` |
| FUActionService.cfc | 1 | `SELfuactions` |
| FUSystemTypeService.cfc | 1 | `SELfusystemtypes` |
| FilteredQueryService.cfc | 1 | `SELqFiltered` |
| GenderPronounService.cfc | 1 | `SELgenderpronouns` |
| GenderPronounUserService.cfc | 2 | `SELgenderpronouns_users`, `INSgenderpronouns_users` |
| GenreAuditionService.cfc | 4 | `SELaudgenres_audition_xref`, `DELaudgenres_audition_xref`, `INSaudgenres_audition_xref` ... (+1 more) |
| IncomeTypeService.cfc | 1 | `SELincometypes` |
| InformationSchemaTableService.cfc | 1 | `SELinformation_schema` |
| ItemCategoryService.cfc | 2 | `SELitemcategory`, `DETitemcategory` |
| ItemCategoryXRefUserService.cfc | 2 | `INSitemcatxref_user`, `SELitemcatxref_user` |
| ItemTypeService.cfc | 3 | `SELitemTypesByCategoryAndUser`, `SELitemTypesByCategory_4`, `SELitemtypes` |
| ItemTypesUserService.cfc | 2 | `INSitemtypes_user`, `SELitemtypes_user` |
| LinkService.cfc | 3 | `INSlinks`, `SELlinks`, `UPDlinks` |
| MeetingDurationService.cfc | 2 | `SELmtgdurations`, `SELdurations` |
| NoteService.cfc | 5 | `INSnoteslog`, `DELnoteslog`, `SELnoteslog` ... (+2 more) |
| NotificationService.cfc | 6 | `UPDfunotifications`, `INSfunotifications`, `SELfunotifications` ... (+3 more) |
| NotificationStatusService.cfc | 1 | `SELnotstatuses` |
| PageAppLinkService.cfc | 1 | `SELpgapplinks` |
| PageFieldService.cfc | 1 | `SELpgfields` |
| PageService.cfc | 2 | `SELpgpages`, `DETpgpages` |
| PanelService.cfc | 1 | `SELpgpanels` |
| PanelUserService.cfc | 3 | `SELpgpanels_user`, `UPDpgpanels_user`, `INSpgpanels_user` |
| PanelsMasterService.cfc | 1 | `SELpgpanels_master` |
| PanelsUserXRefService.cfc | 2 | `DELpgpanels_user_xref`, `INSpgpanels_user_xref` |
| RegionService.cfc | 1 | `SELregions` |
| ReportColorService.cfc | 1 | `SELreportcolors` |
| ReportItemService.cfc | 5 | `INSreportitems`, `SELreportitems`, `DELreportitems` ... (+2 more) |
| ReportRangeService.cfc | 2 | `SELreportranges`, `UPDreportranges` |
| ReportUserService.cfc | 2 | `SELreports_user`, `INSreports_user` |
| ReportsMasterService.cfc | 1 | `SELreports_master` |
| ShareService.cfc | 1 | `SELshares` |
| SiteLinkUserService.cfc | 3 | `UPDsitelinks_user`, `SELsitelinks_user`, `INSsitelinks_user` |
| SiteLinksMasterService.cfc | 1 | `SELsitelinks_master` |
| SiteTypeMasterService.cfc | 1 | `SELsitetypes_master` |
| SiteTypeUserService.cfc | 3 | `SELsitetypes_user`, `UPDsitetypes_user`, `INSsitetypes_user` |
| SystemService.cfc | 3 | `SELfusystemtypes`, `DETfusystems`, `SELfusystems` |
| SystemUserService.cfc | 2 | `INSfusystemusers_batch`, `SELfusystemusers` |
| TagService.cfc | 1 | `SELtags` |
| TagsUserService.cfc | 3 | `SELtags_user`, `INStags_user`, `UPDtags_user` |
| TaoVersionService.cfc | 3 | `SELtaoversions`, `INStaoversions`, `UPDtaoversions` |
| TicketPriorityService.cfc | 1 | `SELticketpriority` |
| TicketService.cfc | 5 | `UPDtickets`, `SELtickets`, `DETtickets` ... (+2 more) |
| TicketStatusService.cfc | 1 | `SELticketstatuses` |
| TicketTestUserService.cfc | 3 | `SELtickettestusers`, `INStickettestusers`, `UPDtickettestusers` |
| TicketTypeService.cfc | 1 | `SELtickettypes` |
| TicketsLogTableService.cfc | 1 | `INSticketslog` |
| TimeZoneService.cfc | 1 | `SELtimezones` |
| UpdateLogService.cfc | 2 | `INSupdatelog`, `RESupdatelog` |
| UploadService.cfc | 2 | `INSuploads`, `DETuploads` |
| UserService.cfc | 3 | `SELtaousers`, `UPDtaousers`, `DETtaousers` |

## 4. TECH-DEBT: Presentation Logic in Service Layer

Service CFC files containing HTML output tags. This violates separation of concerns.

| CFC File | HTML Pattern Found | Severity |
|----------|--------------------|----------|
| ContactItemService.cfc | SQL CONCAT with <span> badge HTML (lines 192, 493, 528, 658, 1591) | :x: TECH-DEBT |
| NoteService.cfc | HTML <input> tag in sanitization query (line 100) | :x: TECH-DEBT |
| PageTitleService.cfc | Generates <a> and <span> HTML tags (lines 44, 171, 178) | :x: TECH-DEBT |
| PaginationService.cfc | Full pagination HTML with <ul>, <li>, <a>, <span> (lines 114-194) | :x: TECH-DEBT |

## 5. Conforming Functions Summary

**Functions conforming to naming standard:** 361 of 1159 (31%)
**Functions with violations:** 798 of 1159 (68%)

### Top 15 CFCs by Violation Count

| CFC File | Total Functions | Violations | Violation % |
|----------|-----------------|------------|-------------|
| ContactItemService.cfc | 83 | 73 | 87% |
| EventService.cfc | 51 | 49 | 96% |
| AuditionProjectService.cfc | 47 | 44 | 93% |
| ContactService.cfc | 61 | 41 | 67% |
| TicketService.cfc | 30 | 30 | 100% |
| UserService.cfc | 38 | 25 | 65% |
| PageService.cfc | 34 | 23 | 67% |
| NoteService.cfc | 22 | 22 | 100% |
| AuditionRoleService.cfc | 22 | 21 | 95% |
| NotificationService.cfc | 30 | 21 | 70% |
| SystemService.cfc | 20 | 18 | 90% |
| AuditionMediaService.cfc | 19 | 17 | 89% |
| TagsUserService.cfc | 15 | 15 | 100% |
| SystemUserService.cfc | 21 | 14 | 66% |
| ContactImportService.cfc | 16 | 13 | 81% |

### Function Name Prefix Distribution

| Prefix | Count | Standard? |
|--------|-------|-----------|
| `SEL` | 410 | :warning: Legacy |
| `INS` | 155 | :warning: Legacy |
| `UPD` | 142 | :warning: Legacy |
| `get` | 112 | :white_check_mark: Yes |
| `DET` | 57 | :warning: Legacy |
| `update` | 23 | :white_check_mark: Yes |
| `DEL` | 16 | :warning: Legacy |
| `find` | 15 | :x: Non-standard |
| `RES` | 15 | :warning: Legacy |
| `report` | 14 | :x: Non-standard |
| `add` | 12 | :x: Non-standard |
| `Other` | 12 | :x: Non-standard |
| `set` | 12 | :x: Non-standard |
| `validate` | 12 | :x: Non-standard |
| `normalize` | 9 | :x: Non-standard |
| `create` | 8 | :white_check_mark: Yes |
| `delete` | 8 | :white_check_mark: Yes |
| `log` | 7 | :x: Non-standard |
| `is` | 7 | :x: Non-standard |
| `build` | 7 | :x: Non-standard |
| `init` | 7 | :x: Non-standard |
| `parse` | 6 | :x: Non-standard |
| `list` | 4 | :white_check_mark: Yes |
| `read` | 3 | :x: Non-standard |
| `bulk` | 3 | :x: Non-standard |
| `process` | 3 | :x: Non-standard |
| `detect` | 3 | :x: Non-standard |
| `render` | 3 | :x: Non-standard |
| `ok` | 2 | :x: Non-standard |
| `fail` | 2 | :x: Non-standard |
| `assert` | 2 | :x: Non-standard |
| `acquire` | 2 | :x: Non-standard |
| `release` | 2 | :x: Non-standard |
| `finalize` | 2 | :x: Non-standard |
| `record` | 2 | :x: Non-standard |
| `menu` | 2 | :x: Non-standard |
| `insert` | 2 | :x: Non-standard |
| `recompute` | 2 | :x: Non-standard |
| `debug` | 2 | :x: Non-standard |
| `info` | 2 | :x: Non-standard |
| `warn` | 2 | :x: Non-standard |
| `error` | 2 | :x: Non-standard |
| `fatal` | 2 | :x: Non-standard |
| `extract` | 2 | :x: Non-standard |
| `generate` | 2 | :x: Non-standard |
| `start` | 2 | :x: Non-standard |
| `restore` | 1 | :x: Non-standard |
| `audition` | 1 | :x: Non-standard |
| `audvocaltypes` | 1 | :x: Non-standard |
| `merge` | 1 | :x: Non-standard |
| `getcontacts` | 1 | :x: Non-standard |
| `safe` | 1 | :x: Non-standard |
| `compute` | 1 | :x: Non-standard |
| `try` | 1 | :x: Non-standard |
| `store` | 1 | :x: Non-standard |
| `auto` | 1 | :x: Non-standard |
| `confirm` | 1 | :x: Non-standard |
| `execute` | 1 | :x: Non-standard |
| `item` | 1 | :x: Non-standard |
| `enroll` | 1 | :x: Non-standard |
| `cleanup` | 1 | :x: Non-standard |
| `remove` | 1 | :x: Non-standard |
| `contact` | 1 | :x: Non-standard |
| `items` | 1 | :x: Non-standard |
| `updatebad` | 1 | :x: Non-standard |
| `updatse` | 1 | :x: Non-standard |
| `ru` | 1 | :x: Non-standard |
| `eventaudsync` | 1 | :x: Non-standard |
| `eventresults` | 1 | :x: Non-standard |
| `convert` | 1 | :x: Non-standard |
| `decode` | 1 | :x: Non-standard |
| `removenotdups` | 1 | :x: Non-standard |
| `del` | 1 | :x: Non-standard |
| `pages` | 1 | :x: Non-standard |
| `calculate` | 1 | :x: Non-standard |
| `pg` | 1 | :x: Non-standard |
| `complete` | 1 | :x: Non-standard |
| `shares` | 1 | :x: Non-standard |
| `close` | 1 | :x: Non-standard |
| `addfu` | 1 | :x: Non-standard |
| `versions` | 1 | :x: Non-standard |
| `dateformatpref` | 1 | :x: Non-standard |
| `users` | 1 | :x: Non-standard |
| `toggle` | 1 | :x: Non-standard |
