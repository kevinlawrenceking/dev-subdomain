# Phase 1: Full Codebase Inventory

**Generated:** 2026-03-16
**Purpose:** Comprehensive inventory of service functions, query files, and templates.
This file will be supplemented with dead code analysis in a later phase.

## Legend
- :x: = critical violation
- :warning: = needs review
- :white_check_mark: = clean
- :repeat: = merge candidate
- :lock: = security issue
- :skull: = dead code

---
# PHASE 1A: Service CFC Function Inventory

**Total Service CFCs:** 138
**Total Functions:** 1159

### AccessedService.cfc (1 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `logFile` | public | void | Logs accessed files | :white_check_mark: |

### ActionUserService.cfc (5 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `restoreActionUsers` | public | numeric |  | :white_check_mark: |
| `INSactionusers_24455` | public | numeric |  | :x: |
| `addActionUsers` | public | numeric |  | :white_check_mark: |
| `updateActionUsers` | public | void | Unified function to update actionusers_tbl with various upda... | :white_check_mark: |
| `GetActionUsers` | public | query | Retrieve user actions with optional filtering | :white_check_mark: |

### AttachmentService.cfc (4 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `INSattachments` | public | numeric |  | :x: |
| `DETattachments` | public | query |  | :x: |
| `UPDattachments` | public | void |  | :x: |
| `SELattachments` | public | query |  | :x: |

### AuditionAgeRangeService.cfc (4 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELaudageranges` | public | query |  | :x: |
| `INSaudageranges` | public | numeric |  | :x: |
| `UPDaudageranges` | public | void |  | :x: |
| `SELaudageranges_24552` | public | query |  | :x: |

### AuditionAgeRangeXRefService.cfc (5 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELaudageranges_audtion_xref` | public | query |  | :x: |
| `DELaudageranges_audtion_xref` | public | void |  | :x: |
| `INSaudageranges_audtion_xref` | public | numeric |  | :x: |
| `INSaudageranges_audtion_xref_24502` | public | numeric |  | :x: |
| `UPDaudageranges_audtion_xref` | public | void |  | :x: |

### AuditionAnswerService.cfc (5 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `DELaudanswers` | public | void |  | :x: |
| `INSaudanswers` | public | numeric |  | :x: |
| `UPDaudanswers` | public | void |  | :x: |
| `INSaudanswers_24506` | public | numeric |  | :x: |
| `UPDaudanswers_24507` | public | void |  | :x: |

### AuditionBookTypeService.cfc (1 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELaudbooktypes` | public | query |  | :x: |

### AuditionCallbackTypeService.cfc (2 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELaudcallbacktypes` | public | query |  | :x: |
| `SELaudcallbacktypes_24509` | public | query |  | :x: |

### AuditionCategoryService.cfc (12 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELaudcategories` | public | query |  | :x: |
| `SELaudcategories_23908` | public | query |  | :x: |
| `SELaudcategories_24033` | public | query |  | :x: |
| `SELaudcategories_24357` | public | query |  | :x: |
| `SELaudcategories_24367` | public | query |  | :x: |
| `SELaudcategories_24368` | public | query |  | :x: |
| `SELaudcategories_24375` | public | query |  | :x: |
| `SELaudcategories_24389` | public | query |  | :x: |
| `INSaudcategories` | public | void |  | :x: |
| `UPDaudcategories` | public | void |  | :x: |
| `SELaudcategories_24735` | public | query |  | :x: |
| `SELaudcategories_24744` | public | query |  | :x: |

### AuditionContractTypeService.cfc (2 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `INSaudcontracttypes` | public | numeric |  | :x: |
| `UPDaudcontracttypes` | public | void |  | :x: |

### AuditionDialectService.cfc (2 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `INSauddialects` | public | numeric |  | :x: |
| `UPDauddialects` | public | void |  | :x: |

### AuditionDialectsUserService.cfc (2 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `INSauddialects_user` | public | numeric |  | :x: |
| `SELauddialects_user` | public | query |  | :x: |

### AuditionDuplicateMatcherService.cfc (7 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `normalizeProjectName` | public | string |  | :white_check_mark: |
| `normalizeActorName` | public | string |  | :white_check_mark: |
| `normalizeDate` | public | string |  | :white_check_mark: |
| `isDupeDetectionAvailable` | public | struct |  | :white_check_mark: |
| `buildUserDupeIndex` | public | struct |  | :white_check_mark: |
| `findDuplicates` | public | struct |  | :white_check_mark: |
| `getCandidateDetails` | public | array |  | :white_check_mark: |

### AuditionEssenceXRefService.cfc (3 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELaudessences_audtion_xref` | public | query |  | :x: |
| `DELaudessences_audtion_xref` | public | void |  | :x: |
| `INSaudessences_audtion_xref` | public | numeric |  | :x: |

### AuditionGenreService.cfc (2 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `INSaudgenres` | public | numeric |  | :x: |
| `UPDaudgenres` | public | void |  | :x: |

### AuditionGenreService_standardized.cfc (7 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `create` | public | numeric |  | :white_check_mark: |
| `read` | public | query |  | :white_check_mark: |
| `update` | public | void |  | :white_check_mark: |
| `delete` | public | void |  | :white_check_mark: |
| `list` | public | query |  | :white_check_mark: |
| `INSaudgenres` | public | numeric |  | :x: |
| `UPDaudgenres` | public | void |  | :x: |

### AuditionGenreUserService.cfc (6 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELaudgenres_user` | public | query |  | :x: |
| `SELaudgenres_user_24272` | public | query |  | :x: |
| `SELaudgenres_user_24273` | public | query |  | :x: |
| `SELaudgenres_user_24285` | public | query |  | :x: |
| `INSaudgenres_user` | public | numeric |  | :x: |
| `SELaudgenres_user_24523` | public | query |  | :x: |

### AuditionImportErrorService.cfc (6 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELauditionsimport_error` | public | query |  | :x: |
| `INSauditionsimport_error` | public | numeric |  | :x: |
| `INSauditionsimport_error_24355` | public | numeric |  | :x: |
| `INSauditionsimport_error_24356` | public | numeric |  | :x: |
| `INSauditionsimport_error_24358` | public | numeric |  | :x: |
| `INSauditionsimport_error_24360` | public | numeric |  | :x: |

### AuditionImportService.cfc (26 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `init` | public | AuditionImportService |  | :white_check_mark: |
| `ok` | public | struct |  | :white_check_mark: |
| `fail` | public | struct |  | :white_check_mark: |
| `isAuditionImportEnabled` | public | boolean |  | :white_check_mark: |
| `getFeatureFlagStatus` | public | struct |  | :white_check_mark: |
| `getJob` | public | struct |  | :white_check_mark: |
| `assertJobOwnership` | public | struct |  | :white_check_mark: |
| `getJobForUser` | public | struct |  | :white_check_mark: |
| `logEvent` | public | boolean |  | :white_check_mark: |
| `acquireJobLock` | public | struct |  | :white_check_mark: |
| `releaseJobLock` | public | struct |  | :white_check_mark: |
| `setJobStatus` | public | struct |  | :white_check_mark: |
| `isValidTransition` | private | boolean |  | :white_check_mark: |
| `getJobStats` | public | struct |  | :white_check_mark: |
| `getRows` | public | struct |  | :white_check_mark: |
| `getRowDetail` | public | struct |  | :white_check_mark: |
| `setRowAction` | public | struct |  | :white_check_mark: |
| `bulkRowAction` | public | struct |  | :white_check_mark: |
| `updateJobRowCounts` | private | void |  | :white_check_mark: |
| `updateRowFacts` | public | struct |  | :white_check_mark: |
| `finalizeJob` | public | struct |  | :white_check_mark: |
| `processRowForImport` | private | struct |  | :x: |
| `recordRowResult` | private | void |  | :white_check_mark: |
| `updateFinalCounts` | private | void |  | :white_check_mark: |
| `auditionImports` | public | query |  | :white_check_mark: |
| `getUserJobHistory` | public | query |  | :white_check_mark: |

### AuditionLinkService.cfc (4 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELaudlinks` | public | query |  | :x: |
| `INSaudlinks` | public | numeric |  | :x: |
| `DETaudlinks` | public | query |  | :x: |
| `UPDaudlinks` | public | void |  | :x: |

### AuditionLocationService.cfc (3 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `UPDaudlocations` | public | void |  | :x: |
| `INSaudlocations` | public | numeric |  | :x: |
| `SELaudlocations` | public | query |  | :x: |

### AuditionMediaAudRolesXRefService.cfc (2 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `INSaudmedia_audroles_xref` | public | numeric |  | :x: |
| `UPDaudmedia_audroles_xref` | public | void |  | :x: |

### AuditionMediaService.cfc (19 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `GetHeadshots` | public | query | Retrieve headshots for a specific user ID. | :white_check_mark: |
| `GetMaterials` | public | query | Retrieve headshots for a specific user ID. | :white_check_mark: |
| `SELaudmedia` | public | query |  | :x: |
| `SELaudmedia_23799` | public | query |  | :x: |
| `UPDaudmedia` | public | void |  | :x: |
| `DETaudmedia` | public | query |  | :x: |
| `DETaudmedia_24113` | public | query |  | :x: |
| `SELaudmedia_24249` | public | query |  | :x: |
| `INSaudmedia` | public | numeric |  | :x: |
| `SELaudmedia_24569` | public | query |  | :x: |
| `SELaudmedia_24570` | public | query |  | :x: |
| `UPDaudmedia_24571` | public | void |  | :x: |
| `SELaudmedia_24572` | public | query |  | :x: |
| `SELaudmedia_24573` | public | query |  | :x: |
| `SELaudmedia_24665` | public | query |  | :x: |
| `SELaudmedia_24666` | public | query |  | :x: |
| `DETaudmedia_24676` | public | query |  | :x: |
| `SELaudmedia_24677` | public | query |  | :x: |
| `SELaudmedia_24678` | public | query |  | :x: |

### AuditionMediaTypeService.cfc (7 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELaudmediatypes` | public | query |  | :x: |
| `SELaudmediatypes_23753` | public | query |  | :x: |
| `getMediaTypes` | public | query |  | :white_check_mark: |
| `SEL_Media_types_material` | public | query |  | :x: |
| `SELaudmediatypes_24198` | public | query |  | :x: |
| `INSaudmediatypes` | public | numeric |  | :x: |
| `UPDaudmediatypes` | public | void |  | :x: |

### AuditionMediaXRefService.cfc (5 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `INSaudmedia_auditions_xref` | public | numeric |  | :x: |
| `DELaudmedia_auditions_xref` | public | void |  | :x: |
| `INSaudmedia_auditions_xref_24153` | public | numeric |  | :x: |
| `SELaudmedia_auditions_xref` | public | query |  | :x: |
| `INSaudmedia_auditions_xref_24568` | public | numeric |  | :x: |

### AuditionNetworkService.cfc (2 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `INSaudnetworks` | public | numeric |  | :x: |
| `UPDaudnetworks` | public | void |  | :x: |

### AuditionNetworkUserService.cfc (1 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `INSaudnetworks_user` | public | numeric |  | :x: |

### AuditionOpenCallOptionUserService.cfc (4 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELaudopencalloptions_user` | public | query |  | :x: |
| `SELaudopencalloptions_user_24262` | public | query |  | :x: |
| `SELaudopencalloptions_user_24280` | public | query |  | :x: |
| `INSaudopencalloptions_user` | public | numeric |  | :x: |

### AuditionPayCycleService.cfc (2 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELaudpaycycles` | public | query |  | :x: |
| `SELaudpaycycles_24579` | public | query |  | :x: |

### AuditionPlatformUserService.cfc (3 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELaudPlatforms_user_23778` | public | query |  | :x: |
| `INSaudPlatforms_user_23779` | public | numeric |  | :x: |
| `SELaudplatforms_user_24582` | public | query |  | :x: |

### AuditionPlatformsService.cfc (2 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `INSaudplatforms` | public | numeric |  | :x: |
| `UPDaudplatforms` | public | void |  | :x: |

### AuditionProjectService.cfc (47 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `getProjectsByContact` | public | query |  | :white_check_mark: |
| `UPDaudprojects_24586` | public | void |  | :x: |
| `DETaudprojects` | public | query |  | :x: |
| `SELaudprojects` | public | query |  | :x: |
| `SELaudprojects_23795` | public | query |  | :x: |
| `DETaudprojects_23811` | public | query |  | :x: |
| `UPDaudprojects` | public | void |  | :x: |
| `SELaudprojects_23961` | public | query |  | :x: |
| `UPDaudprojects_24011` | public | void |  | :x: |
| `UPDaudprojects_24013` | public | void |  | :x: |
| `UPDaudprojects_24015` | public | void |  | :x: |
| `SELaudprojects_24016` | public | query |  | :x: |
| `UPDaudprojects_24017` | public | void |  | :x: |
| `UPDaudprojects_24019` | public | void |  | :x: |
| `SELaudprojects_24062` | public | query |  | :x: |
| `SELaudprojects_24085` | public | query |  | :x: |
| `DETaudprojects_24089` | public | query |  | :x: |
| `SELaudprojects_24097` | public | query |  | :x: |
| `DETaudprojects_24106` | public | query |  | :x: |
| `DETaudprojects_24107` | public | query |  | :x: |
| `UPDaudprojects_24125` | public | void |  | :x: |
| `SELaudprojects_24230` | public | query |  | :x: |
| `SELaudprojects_24236` | public | query |  | :x: |
| `SELaudprojects_24237` | public | query |  | :x: |
| `SELaudprojects_24238` | public | query |  | :x: |
| `SELaudprojects_24239` | public | query |  | :x: |
| `SELaudprojects_24240` | public | query |  | :x: |
| `SELaudprojects_24241` | public | query |  | :x: |
| `SELaudprojects_24242` | public | query |  | :x: |
| `SELaudprojects_24244` | public | query |  | :x: |
| `SELaudprojects_24245` | public | query |  | :x: |
| `SELaudprojects_24246` | public | query |  | :x: |
| `getAuditionData` | public | query |  | :white_check_mark: |
| `SELaudprojects_24248` | public | query |  | :x: |
| `SELaudprojects_24250` | public | query |  | :x: |
| `SELaudprojects_24251` | public | query |  | :x: |
| `SELaudprojects_24353` | public | query |  | :x: |
| `INSaudprojects` | public | numeric |  | :x: |
| `SELaudprojects_24500` | public | query |  | :x: |
| `DETaudprojects_24543` | public | query |  | :x: |
| `SELaudprojects_24550` | public | query |  | :x: |
| `DETaudprojects_24553` | public | query |  | :x: |
| `DETaudprojects_24554` | public | query |  | :x: |
| `SELaudprojects_24559` | public | query |  | :x: |
| `getAuditions` | public | query |  | :white_check_mark: |
| `INSaudprojects_24585` | public | numeric |  | :x: |
| `DETaudprojects_24716` | public | query |  | :x: |

### AuditionProjectsCastingAboutService.cfc (2 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `INSaudprojects_castingabout` | public | numeric |  | :x: |
| `UPDaudprojects_castingabout` | public | void |  | :x: |

### AuditionQuestionTypeService.cfc (2 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `INSaudqtypes` | public | numeric |  | :x: |
| `UPDaudqtypes` | public | void |  | :x: |

### AuditionQuestionUserService.cfc (5 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELaudquestions_user` | public | query |  | :x: |
| `SELaudquestions_user_24078` | public | query |  | :x: |
| `SELaudquestions_user_24501` | public | query |  | :x: |
| `INSaudquestions_user` | public | numeric |  | :x: |
| `UPDaudquestions_user` | public | void |  | :x: |

### AuditionQuestionsDefaultService.cfc (2 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `INSaudquestions_default` | public | numeric |  | :x: |
| `UPDaudquestions_default` | public | void |  | :x: |

### AuditionRoleService.cfc (22 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `setFirstMeetingDates` | public | void |  | :white_check_mark: |
| `SELaudroles` | public | query |  | :x: |
| `INSaudroles` | public | numeric |  | :x: |
| `UPDaudroles` | public | void |  | :x: |
| `SELaudroles_23809` | public | query |  | :x: |
| `UPDaudroles_23810` | public | void |  | :x: |
| `UPDaudroles_23813` | public | void |  | :x: |
| `UPDaudroles_23814` | public | void |  | :x: |
| `SELaudroles_23851` | public | query |  | :x: |
| `DETaudroles` | public | query |  | :x: |
| `DETaudroles_24086` | public | query |  | :x: |
| `DETaudroles_24090` | public | query |  | :x: |
| `DETaudroles_24122` | public | query |  | :x: |
| `UPDaudroles_24126` | public | void |  | :x: |
| `SELaudroles_24165` | public | query |  | :x: |
| `UPDaudroles_24260` | public | void |  | :x: |
| `UPDaudroles_24299` | public | void |  | :x: |
| `INSaudroles_24372` | public | numeric |  | :x: |
| `UPDaudroles_24542` | public | void |  | :x: |
| `DETaudroles_24544` | public | query |  | :x: |
| `INSaudroles_24593` | public | numeric |  | :x: |
| `UPDaudroles_24594` | public | void |  | :x: |

### AuditionRoleTypeService.cfc (3 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELaudroletypes` | public | query |  | :x: |
| `INSaudroletypes` | public | numeric |  | :x: |
| `UPDaudroletypes` | public | void |  | :x: |

### AuditionSourceService.cfc (7 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELaudsources` | public | query |  | :x: |
| `SELaudsources_24222` | public | query |  | :x: |
| `SELaudsources_24359` | public | query |  | :x: |
| `SELaudsources_24371` | public | query |  | :x: |
| `INSaudsources` | public | numeric |  | :x: |
| `UPDaudsources` | public | void |  | :x: |
| `SELaudsources_24684` | public | query |  | :x: |

### AuditionStepService.cfc (6 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELaudsteps` | public | query |  | :x: |
| `SELaudsteps_23784` | public | query |  | :x: |
| `SELaudsteps_23792` | public | query |  | :x: |
| `SELaudsteps_24083` | public | query |  | :x: |
| `INSaudsteps` | public | numeric |  | :x: |
| `UPDaudsteps` | public | void |  | :x: |

### AuditionSubcategorieService.cfc (3 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELaudsubcategories` | public | query |  | :x: |
| `INSaudsubcategories` | public | numeric |  | :x: |
| `UPDaudsubcategories` | public | void |  | :x: |

### AuditionSubmitSiteUserService.cfc (10 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `UPDaudsubmitsites_user_24167` | public | void |  | :x: |
| `SELaudsubmitsites_user` | public | query |  | :x: |
| `SELaudsubmitsites_user_24034` | public | query |  | :x: |
| `UPDaudsubmitsites_user` | public | void |  | :x: |
| `INSaudsubmitsites_user` | public | numeric |  | :x: |
| `DETaudsubmitsites_user` | public | query |  | :x: |
| `SELaudsubmitsites_user_24265` | public | query |  | :x: |
| `SELaudsubmitsites_user_24295` | public | query |  | :x: |
| `UPDaudsubmitsites_user_24296` | public | void |  | :x: |
| `INSaudsubmitsites_user_24297` | public | numeric |  | :x: |

### AuditionToneUserService.cfc (2 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `INSaudtones_user` | public | numeric |  | :x: |
| `SELaudtones_user` | public | query |  | :x: |

### AuditionTonesService.cfc (2 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `INSaudtones` | public | numeric |  | :x: |
| `UPDaudtones` | public | void |  | :x: |

### AuditionTypeService.cfc (10 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELaudtypes` | public | query |  | :x: |
| `SELaudtypes_23793` | public | query |  | :x: |
| `SELaudtypes_24082` | public | query |  | :x: |
| `getAudtypes` | public | query |  | :white_check_mark: |
| `SELaudtypes_24231` | public | query |  | :x: |
| `SELaudtypes_24234` | public | query |  | :x: |
| `SELaudtypes_24526` | public | query |  | :x: |
| `INSaudtypes` | public | numeric |  | :x: |
| `SELaudtypes_24608` | public | query |  | :x: |
| `UPDaudtypes` | public | void |  | :x: |

### AuditionUnionService.cfc (3 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELaudunions` | public | query |  | :x: |
| `INSaudunions` | public | numeric |  | :x: |
| `UPDaudunions` | public | void |  | :x: |

### AuditionVocalTypeService.cfc (3 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELaudvocaltypes` | public | query |  | :x: |
| `INSaudvocaltypes` | public | numeric |  | :x: |
| `UPDaudvocaltypes` | public | void |  | :x: |

### AuditionVocalTypeXRefService.cfc (6 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `audvocaltypes_audition_xref` | public | query |  | :white_check_mark: |
| `SELaudvocaltypes_audition_xref` | public | query |  | :x: |
| `DELaudvocaltypes_audition_xref` | public | void |  | :x: |
| `INSaudvocaltypes_audition_xref` | public | numeric |  | :x: |
| `INSaudvocaltypes_audition_xref_24613` | public | numeric |  | :x: |
| `UPDaudvocaltypes_audition_xref` | public | void |  | :x: |

### BigBrotherService.cfc (2 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `INSbigbrother` | public | numeric |  | :x: |
| `RESbigbrother` | public | query |  | :x: |

### BirthdayService.cfc (1 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `getBirthdaysForDashboard` | public | query | Retrieves upcoming birthdays for a specific user | :white_check_mark: |

### CityService.cfc (1 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELcities` | public | query |  | :x: |

### ComponentService.cfc (5 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `getAllFields` | public | query | Describes the structure of the specified table and returns i... | :white_check_mark: |
| `SELpgcomps` | public | query |  | :x: |
| `menuItemsA` | public | query |  | :white_check_mark: |
| `menuItemsAud` | public | query |  | :white_check_mark: |
| `getPgComps` | public | query |  | :white_check_mark: |

### ContactAuditionService.cfc (12 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `INSaudcontacts_auditions_xref` | public | numeric |  | :x: |
| `INSaudcontacts_auditions_xref_2` | public | numeric |  | :x: |
| `INSaudcontacts_auditions_xref_23780` | public | void |  | :x: |
| `getAuditionContacts` | public | query |  | :white_check_mark: |
| `DELaudcontacts_auditions_xref` | public | void | Deletes a contact from the audcontacts_auditions_xref table ... | :x: |
| `INSaudcontacts_auditions_xref_24059` | public | void |  | :x: |
| `DELaudcontacts_auditions_xref_24127` | public | void |  | :x: |
| `INSaudcontacts_auditions_xref_24512` | public | numeric |  | :x: |
| `UPDaudcontacts_auditions_xref` | public | void |  | :x: |
| `DELaudcontacts_auditions_xref_24545` | public | numeric |  | :x: |
| `DELaudcontacts_auditions_xref_24548` | public | void |  | :x: |
| `INSaudcontacts_auditions_xref_24551` | public | void |  | :x: |

### ContactDuplicateService.cfc (6 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `init` | public | ContactDuplicateService |  | :white_check_mark: |
| `findDuplicatesByName` | public | query |  | :white_check_mark: |
| `findDuplicatesByEmail` | public | query |  | :white_check_mark: |
| `getContactDetails` | public | query |  | :white_check_mark: |
| `getContactItems` | public | query |  | :white_check_mark: |
| `mergeContacts` | public | struct |  | :white_check_mark: |

### ContactImportService.cfc (16 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `UPDCONTACTSIMPORT` | public | void |  | :x: |
| `DETcontactsimport` | public | query |  | :x: |
| `SELcontactsimport_24409` | public | query |  | :x: |
| `SELcontactsimport_f` | public | query |  | :x: |
| `SELcontactsimport_g` | public | query |  | :x: |
| `SELcontactsimport_h` | public | query |  | :x: |
| `SELcontactsimport_i` | public | query |  | :x: |
| `SELcontactsimport_j` | public | query |  | :x: |
| `SELcontactsimport_u` | public | query |  | :x: |
| `SELcontactsimport_address` | public | query |  | :x: |
| `SELcontactsimport_maints` | public | query |  | :x: |
| `getContactsImport` | public | query |  | :white_check_mark: |
| `getcontactsImportTag` | public | query |  | :white_check_mark: |
| `getImportsByUserID` | public | query | Retrieve import data for a specific user. | :white_check_mark: |
| `SELcontactsimport_24668` | public | query |  | :x: |
| `INScontactsimport` | public | numeric |  | :x: |

### ContactImportV2Service.cfc (36 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `safeDeserializeJSON` | private | any |  | :white_check_mark: |
| `computeFileHash` | public | string |  | :white_check_mark: |
| `findDuplicateJob` | public | struct |  | :white_check_mark: |
| `createJob` | public | struct |  | :white_check_mark: |
| `getJob` | public | struct |  | :white_check_mark: |
| `getJobsByUser` | public | query |  | :white_check_mark: |
| `updateJobStatus` | public | void |  | :white_check_mark: |
| `tryAcquireImportLock` | public | struct |  | :white_check_mark: |
| `deleteJob` | public | void |  | :white_check_mark: |
| `parseFile` | public | struct |  | :white_check_mark: |
| `storeColumnMappings` | private | void |  | :white_check_mark: |
| `autoMapColumn` | private | struct |  | :white_check_mark: |
| `getColumnMappings` | public | query |  | :white_check_mark: |
| `updateColumnMapping` | public | void |  | :white_check_mark: |
| `confirmColumnMappings` | public | void |  | :white_check_mark: |
| `processRows` | public | struct |  | :x: |
| `getRows` | public | struct |  | :white_check_mark: |
| `updateRow` | public | struct |  | :white_check_mark: |
| `setRowAction` | public | void |  | :white_check_mark: |
| `bulkSetAction` | public | void |  | :white_check_mark: |
| `validateForImport` | public | struct |  | :white_check_mark: |
| `executeImport` | public | struct |  | :white_check_mark: |
| `createContactFromRow` | private | numeric |  | :white_check_mark: |
| `updateExistingContact` | private | void |  | :white_check_mark: |
| `addContactItem` | private | void |  | :white_check_mark: |
| `addCompanyItem` | private | void |  | :white_check_mark: |
| `addAddressItem` | private | void |  | :white_check_mark: |
| `addNote` | private | void |  | :white_check_mark: |
| `itemExists` | private | boolean |  | :white_check_mark: |
| `enrollInRelationshipSystem` | private | struct |  | :white_check_mark: |
| `createSystemNotifications` | private | void |  | :white_check_mark: |
| `createContactFolders` | private | struct |  | :white_check_mark: |
| `logEvent` | private | void |  | :white_check_mark: |
| `getJobEvents` | public | query |  | :white_check_mark: |
| `getAvailableFields` | public | query |  | :white_check_mark: |
| `getJobStats` | public | struct |  | :white_check_mark: |

### ContactImportV3Service.cfc (40 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `init` | public | ContactImportV3Service |  | :white_check_mark: |
| `ok` | public | struct |  | :white_check_mark: |
| `fail` | public | struct |  | :white_check_mark: |
| `isImportV3Enabled` | public | boolean |  | :white_check_mark: |
| `getFeatureFlagStatus` | public | struct |  | :white_check_mark: |
| `getJob` | public | struct |  | :white_check_mark: |
| `assertJobOwnership` | public | struct |  | :white_check_mark: |
| `getJobForUser` | public | struct |  | :white_check_mark: |
| `logEvent` | public | boolean |  | :white_check_mark: |
| `acquireJobLock` | public | struct |  | :white_check_mark: |
| `releaseJobLock` | public | struct |  | :white_check_mark: |
| `setJobStatus` | public | struct |  | :white_check_mark: |
| `isValidTransition` | private | boolean |  | :white_check_mark: |
| `cleanupOldJobs` | public | struct |  | :white_check_mark: |
| `isPathWithinBase` | private | boolean |  | :white_check_mark: |
| `getCanonicalPath` | private | string |  | :white_check_mark: |
| `getUserJobHistory` | public | query |  | :white_check_mark: |
| `getJobHistory` | public | query |  | :white_check_mark: |
| `getRecentJobs` | public | struct |  | :white_check_mark: |
| `getDashboardStats` | public | struct |  | :white_check_mark: |
| `getAllowedUsers` | public | struct |  | :white_check_mark: |
| `addAllowedUser` | public | struct |  | :white_check_mark: |
| `removeAllowedUser` | public | struct |  | :white_check_mark: |
| `setFeatureFlag` | public | struct |  | :white_check_mark: |
| `finalizeJob` | public | struct |  | :white_check_mark: |
| `processRowForImport` | private | struct |  | :x: |
| `buildContactDataFromFacts` | private | struct |  | :white_check_mark: |
| `insertContactItems` | private | numeric |  | :white_check_mark: |
| `contactItemExists` | private | boolean |  | :white_check_mark: |
| `recordRowResult` | private | void |  | :white_check_mark: |
| `updateJobCounts` | private | void |  | :white_check_mark: |
| `getJobStats` | public | struct |  | :white_check_mark: |
| `getRows` | public | struct |  | :white_check_mark: |
| `getRowDetail` | public | struct |  | :white_check_mark: |
| `updateRowFacts` | public | struct |  | :white_check_mark: |
| `recomputeFullName` | private | void |  | :white_check_mark: |
| `recomputeRowStatus` | private | string |  | :white_check_mark: |
| `updateJobRowCounts` | private | void |  | :white_check_mark: |
| `setRowAction` | public | struct |  | :white_check_mark: |
| `bulkRowAction` | public | struct |  | :white_check_mark: |

### ContactItemService.cfc (83 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `getContactTagStatus` | public | string | Checks contact tags and returns the appropriate system scope | :white_check_mark: |
| `addTeam` | public | void |  | :white_check_mark: |
| `deleteAudContact` | public | void |  | :white_check_mark: |
| `deleteTeam` | public | void |  | :white_check_mark: |
| `itemsByCatActive` | public | struct |  | :white_check_mark: |
| `getActiveCategories` | remote | query | Get a list of active categories. | :white_check_mark: |
| `getInactiveCategories` | remote | query | Get a list of inactive categories. | :white_check_mark: |
| `SELfindscope_24712` | public | string |  | :x: |
| `SELcontactitems` | public | query |  | :x: |
| `SELcontactitems_23758` | public | query |  | :x: |
| `SELcontactitems_23759` | public | query |  | :x: |
| `INScontactitems` | public | numeric |  | :x: |
| `INScontactitems_23771` | public | numeric |  | :x: |
| `SELcontactitems_23840` | public | query |  | :x: |
| `SELcontactitems_23855` | public | query |  | :x: |
| `DETcontactitems` | public | query |  | :x: |
| `SELcontactitems_23889` | public | query |  | :x: |
| `SELcontactitems_23890` | public | query |  | :x: |
| `SELcontactitems_23891` | public | query |  | :x: |
| `SELcontactitems_23892` | public | query |  | :x: |
| `SELcontactitems_23893` | public | query |  | :x: |
| `SELcontactitems_23894` | public | query |  | :x: |
| `SELcontactitems_23895` | public | query |  | :x: |
| `SELcontactitems_23896` | public | query |  | :x: |
| `SELcontactitems_23897` | public | query |  | :x: |
| `SELcontactitems_23898` | public | query |  | :x: |
| `DETcontactitems_23910` | public | query |  | :x: |
| `REScontactitems` | public | query |  | :x: |
| `getContactDetails` | public | query |  | :white_check_mark: |
| `INScontactitems_23947` | public | numeric |  | :x: |
| `SELcontactitems_23948` | public | query |  | :x: |
| `UPDcontactitems` | public | void |  | :x: |
| `UPDcontactitems_23952` | public | void |  | :x: |
| `UPDcontactitems_23953` | public | void |  | :x: |
| `SELcontactitems_23954` | public | query |  | :x: |
| `INScontactitems_23955` | public | numeric |  | :x: |
| `SELcontactitems_23962` | public | query |  | :x: |
| `SELcontactitems_23963` | public | query |  | :x: |
| `SELcontactitems_23964` | public | query |  | :x: |
| `SELcontactitems_24040` | public | query |  | :x: |
| `INScontactitems_24043` | public | numeric |  | :x: |
| `UPDcontactitems_24046` | public | void |  | :x: |
| `INScontactitems_24049` | public | numeric |  | :x: |
| `INScontactitems_24050` | public | numeric |  | :x: |
| `INScontactitems_24051` | public | numeric |  | :x: |
| `INScontactitems_24052` | public | numeric |  | :x: |
| `INScontactitems_24057` | public | numeric |  | :x: |
| `INScontactitems_24058` | public | numeric |  | :x: |
| `SELcontactitems_24064` | public | query |  | :x: |
| `DETcontactitems_24168` | public | query |  | :x: |
| `UPDcontactitems_24178` | public | void |  | :x: |
| `UPDcontactitems_24179` | public | void |  | :x: |
| `SELcontactitems_24207` | public | query |  | :x: |
| `SELcontactitems_24313` | public | query |  | :x: |
| `SELcontactitems_24314` | public | query |  | :x: |
| `DELcontactitems` | public | void |  | :x: |
| `INScontactitems_24327` | public | numeric |  | :x: |
| `SELcontactitems_24329` | public | query |  | :x: |
| `SELcontactitems_24347` | public | query |  | :x: |
| `INScontactitems_24348` | public | numeric |  | :x: |
| `UPDCONTACTITEMS_24349` | public | void |  | :x: |
| `addContactItemsTag` | public | numeric |  | :white_check_mark: |
| `INScontactitems_24410` | public | numeric | Inserts a new contact item into the database. | :x: |
| `INScontactitems_24412` | public | numeric |  | :x: |
| `INScontactitems_24414` | public | numeric |  | :x: |
| `INScontactitems_24416` | public | numeric |  | :x: |
| `INScontactitems_24418` | public | numeric |  | :x: |
| `INScontactitems_24420` | public | numeric |  | :x: |
| `INScontactitems_24422` | public | numeric |  | :x: |
| `INScontactitems_24424` | public | numeric |  | :x: |
| `SELcontactitems_24620` | public | query |  | :x: |
| `SELcontactitems_24657` | public | query |  | :x: |
| `SELcontactitems_24663` | public | query |  | :x: |
| `SELcontactitems_24671` | public | query |  | :x: |
| `SELcontactitems_24672` | public | query |  | :x: |
| `SELcontactitems_24673` | public | query |  | :x: |
| `SELcontactitems_24682` | public | query |  | :x: |
| `SELcontactitems_24714` | public | query |  | :x: |
| `getSocialIcons` | public | query |  | :white_check_mark: |
| `SELcontactitems_24715` | public | query |  | :x: |
| `DETcontactitems_24719` | public | query |  | :x: |
| `SELcontactitems_24761` | public | query |  | :x: |
| `SELcontactitems_24764` | public | query |  | :x: |

### ContactSSService.cfc (2 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELcontacts_ss` | public | query |  | :x: |
| `SELcontacts_ss_23946` | public | query |  | :x: |

### ContactService.cfc (61 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `create` | public | numeric | Create a new contact record | :white_check_mark: |
| `read` | public | struct | Read a single contact record | :white_check_mark: |
| `update` | public | void |  | :white_check_mark: |
| `update22` | public | void | Update an existing contact record | :white_check_mark: |
| `updatebad` | public | void |  | :white_check_mark: |
| `updatse` | public | void | Update an existing contact record | :white_check_mark: |
| `delete` | public | void | Soft-delete a contact record | :white_check_mark: |
| `list` | public | query | List contacts with optional filters | :white_check_mark: |
| `updateContactUnique` | public | void |  | :white_check_mark: |
| `addMembers` | public | void |  | :white_check_mark: |
| `getSystemIdBasedOnTag` | public | numeric |  | :white_check_mark: |
| `getContactCount` | public | numeric |  | :white_check_mark: |
| `getFilteredContactsByEvent` | public | query |  | :white_check_mark: |
| `ru` | public | query |  | :white_check_mark: |
| `getFilteredContacts` | public | query |  | :white_check_mark: |
| `getContactUpdates` | public | query |  | :white_check_mark: |
| `SELcontactdetails` | public | query |  | :x: |
| `SELcontactdetails_23722` | public | query |  | :x: |
| `SELcontactdetails_23727` | public | query | Legacy wrapper - delegates to read() for single record | :x: |
| `INScontactdetails` | public | numeric | Legacy wrapper - delegates to create() | :x: |
| `INScontactdetails_23769` | public | numeric | Legacy wrapper - delegates to create() | :x: |
| `SELcontactdetails_23806` | public | query |  | :x: |
| `UPDcontactdetails` | public | void | Legacy wrapper - delegates to update() | :x: |
| `UPDcontactdetails_23816` | public | void | Legacy wrapper - dynamic field update | :x: |
| `INScontactdetails_23839` | public | numeric | Legacy wrapper - delegates to create() | :x: |
| `SELcontactdetails_23843` | public | query |  | :x: |
| `UPDcontactdetails_23861` | public | void |  | :x: |
| `SELcontactdetails_23888` | public | query |  | :x: |
| `SELcontactdetails_23906` | public | query |  | :x: |
| `SELcontactdetails_23913` | public | query |  | :x: |
| `getContactRecordName` | public | query |  | :white_check_mark: |
| `SELcontactdetails_23939` | public | query |  | :x: |
| `INScontactdetails_24000` | public | numeric | Legacy wrapper - delegates to create() | :x: |
| `INScontactdetails_24048` | public | numeric |  | :x: |
| `SELcontactdetails_24069` | public | query | Legacy wrapper - delegates to list() | :x: |
| `INScontactdetails_24070` | public | numeric | Legacy wrapper - delegates to create() | :x: |
| `DETcontactdetails` | public | query | Legacy wrapper - delegates to read() and converts to query | :x: |
| `UPDcontactdetails_24202` | public | void | Legacy wrapper - delegates to update() | :x: |
| `SELcontactdetails_24263` | public | query |  | :x: |
| `DETcontactdetails_24264` | public | query | Legacy wrapper - delegates to read() and converts to query | :x: |
| `SELcontactdetails_24293` | public | query |  | :x: |
| `INScontactdetails_24294` | public | numeric |  | :x: |
| `DETcontactdetails_24340` | public | query |  | :x: |
| `SELcontactdetails_24364` | public | query |  | :x: |
| `SELcontactdetails_24397` | public | query |  | :x: |
| `INScontactdetails_24399` | public | struct |  | :x: |
| `SELcontactdetails_24433` | public | query |  | :x: |
| `SELcontactdetails_24483` | public | query | Legacy wrapper - delegates to list() with Active filter | :x: |
| `SELcontactdetails_24515` | public | query |  | :x: |
| `INScontactdetails_24537` | public | numeric |  | :x: |
| `SELcontactdetails_24617` | public | query |  | :x: |
| `DETcontactdetails_24624` | public | query |  | :x: |
| `DETcontactdetails_24625` | public | query |  | :x: |
| `REScontactdetails` | public | query |  | :x: |
| `DETcontactdetails_24629` | public | query |  | :x: |
| `SELcontactdetails_24674` | public | query |  | :x: |
| `SELcontactdetails_24683` | public | query |  | :x: |
| `GetMyTeam` | public | query |  | :white_check_mark: |
| `getContactsByAudProject` | public | query |  | :white_check_mark: |
| `getContactForCard` | public | query |  | :white_check_mark: |
| `DETcontactdetails_24685` | public | query |  | :x: |

### ContactService_Consolidated.cfc (8 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `create` | public | numeric | Create a contact with flexible parameters | :white_check_mark: |
| `read` | public | query | Get contact details by ID | :white_check_mark: |
| `update` | public | void | Update contact with flexible parameters | :white_check_mark: |
| `list` | public | query | List contacts with flexible filtering | :white_check_mark: |
| `delete` | public | void | Soft delete a contact | :white_check_mark: |
| `getSqlType` | private | string |  | :white_check_mark: |
| `INScontactdetails_23839` | public | numeric | [DEPRECATED] Use create() instead | :x: |
| `SELcontactdetails_23843` | public | query | [DEPRECATED] Use list() instead | :x: |

### CountryService.cfc (4 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELcountries` | public | query |  | :x: |
| `SELcountries_24169` | public | query |  | :x: |
| `SELcountries_24637` | public | query |  | :x: |
| `SELcountries_24720` | public | query |  | :x: |

### DateFormatService.cfc (1 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELdateformats` | public | query |  | :x: |

### DebugService.cfc (1 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `insertDebugLog` | public | void |  | :white_check_mark: |

### DuplicateMatcherService.cfc (25 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `normalizeEmail` | public | string |  | :white_check_mark: |
| `normalizePhone` | public | string |  | :white_check_mark: |
| `normalizeName` | public | string |  | :white_check_mark: |
| `isDupeDetectionAvailable` | public | struct |  | :white_check_mark: |
| `buildUserDupeIndex` | public | struct |  | :white_check_mark: |
| `getCandidateContactIdsFromIndex` | public | array |  | :white_check_mark: |
| `getCandidateDetailsBatch` | public | struct |  | :white_check_mark: |
| `findDuplicatesWithIndex` | public | struct |  | :white_check_mark: |
| `getCandidateContactIds` | public | array |  | :white_check_mark: |
| `getCandidateContacts` | public | struct |  | :white_check_mark: |
| `getCandidatesByName` | public | struct |  | :white_check_mark: |
| `findDuplicatesSafe` | public | struct |  | :white_check_mark: |
| `findDuplicates` | public | struct |  | :white_check_mark: |
| `findDuplicatesBatch` | public | array |  | :white_check_mark: |
| `findByEmail` | private | query |  | :white_check_mark: |
| `findByPhone` | private | query |  | :white_check_mark: |
| `findByName` | private | query |  | :white_check_mark: |
| `findByNameAndCompany` | private | query |  | :white_check_mark: |
| `findByNameAndCity` | private | query |  | :white_check_mark: |
| `addCandidate` | private | void |  | :white_check_mark: |
| `normalizePhoneForMatch` | private | string |  | :white_check_mark: |
| `getContactDetails` | public | struct |  | :white_check_mark: |
| `getMatchingRules` | public | array |  | :white_check_mark: |
| `setThreshold` | public | void |  | :white_check_mark: |
| `getScoreDescription` | public | string |  | :white_check_mark: |

### EssenceService.cfc (9 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELessences` | public | query |  | :x: |
| `UPDessences` | public | void |  | :x: |
| `INSessences` | public | numeric |  | :x: |
| `DETessences` | public | query |  | :x: |
| `UPDessences_24181` | public | void |  | :x: |
| `SELessences_24270` | public | query |  | :x: |
| `SELessences_24282` | public | query |  | :x: |
| `INSessences_24283` | public | numeric |  | :x: |
| `SELessences_24658` | public | query |  | :x: |

### EventContactsXRefService.cfc (15 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `eventaudsync` | public | void |  | :white_check_mark: |
| `INSeventcontactsxref` | public | numeric |  | :x: |
| `SELeventcontactsxref` | public | query |  | :x: |
| `UPDeventcontactsxref` | public | void |  | :x: |
| `INSeventcontactsxref_23737` | public | numeric |  | :x: |
| `SELeventcontactsxref_23738` | public | query |  | :x: |
| `INSeventcontactsxref_24020` | public | numeric |  | :x: |
| `DELeventcontactsxref` | public | void |  | :x: |
| `deleteEventContactsXref` | public | query |  | :white_check_mark: |
| `SELeventcontactsxref_24060` | public | query |  | :x: |
| `INSeventcontactsxref_24061` | public | void |  | :x: |
| `SELeventcontactsxref_24489` | public | query |  | :x: |
| `SELeventcontactsxref_24499` | public | struct |  | :x: |
| `INSeventcontactsxref_24532` | public | numeric |  | :x: |
| `UPDeventcontactsxref_24549` | public | void |  | :x: |

### EventService.cfc (51 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `updateEventData` | public | void |  | :white_check_mark: |
| `SELevents_24105` | public | void |  | :x: |
| `UPDevents_24104` | public | void |  | :x: |
| `eventresults` | public | struct |  | :white_check_mark: |
| `INSevents` | public | numeric |  | :x: |
| `UPDevents` | public | void |  | :x: |
| `UPDevents_23725` | public | void |  | :x: |
| `UPDevents_23726` | public | void |  | :x: |
| `UPDevents_23731` | public | void |  | :x: |
| `UPDevents_23733` | public | void |  | :x: |
| `RESevents` | public | query |  | :x: |
| `UPDevents_23762` | public | void |  | :x: |
| `SELevents` | public | numeric |  | :x: |
| `SELevents_23785` | public | query |  | :x: |
| `SELevents_23786` | public | query |  | :x: |
| `SELevents_23787` | public | query |  | :x: |
| `SELevents_23788` | public | query |  | :x: |
| `SELevents_23789` | public | query |  | :x: |
| `INSevents_23790` | public | numeric |  | :x: |
| `SELevents_23803` | public | query |  | :x: |
| `UPDevents_23860` | public | void |  | :x: |
| `SELevents_24012` | public | query |  | :x: |
| `SELevents_24014` | public | query |  | :x: |
| `UPDevents_24018` | public | void |  | :x: |
| `INSevents_24096` | public | numeric |  | :x: |
| `UPDevents_24108` | public | void |  | :x: |
| `DETevents` | public | query |  | :x: |
| `UPDevents_24118` | public | void |  | :x: |
| `UPDevents_24119` | public | void |  | :x: |
| `SELevents_24123` | public | query |  | :x: |
| `UPDevents_24124` | public | void |  | :x: |
| `SELevents_24379` | public | query |  | :x: |
| `DETevents_24487` | public | query |  | :x: |
| `DETevents_24492` | public | query |  | :x: |
| `SELevents_24527` | public | query |  | :x: |
| `INSevents_24528` | public | numeric |  | :x: |
| `UPDevents_24530` | public | void |  | :x: |
| `UPDevents_24540` | public | void |  | :x: |
| `SELevents_24546` | public | query |  | :x: |
| `SELevents_24547` | public | query |  | :x: |
| `INSevents_24555` | public | numeric |  | :x: |
| `UPDevents_24556` | public | void |  | :x: |
| `UPDevents_24557` | public | void |  | :x: |
| `UPDevents_24558` | public | void |  | :x: |
| `SELevents_24597` | public | query |  | :x: |
| `SELevents_24618` | public | query |  | :x: |
| `SELevents_24659` | public | query |  | :x: |
| `RESevents_24660` | public | query |  | :x: |
| `DETevents_24675` | public | query |  | :x: |
| `SELevents_24686` | public | query |  | :x: |
| `SELevents_24695` | public | query |  | :x: |

### EventTypesService.cfc (1 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELeventtypes` | public | query |  | :x: |

### EventTypesUserService.cfc (8 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `DETeventtypes_user` | public | query |  | :x: |
| `UPDeventtypes_user` | public | void |  | :x: |
| `SELeventtypes_user` | public | query |  | :x: |
| `INSeventtypes_user` | public | void |  | :x: |
| `SELeventtypes_user_24484` | public | query |  | :x: |
| `SELeventtypes_user_24486` | public | query |  | :x: |
| `SELeventtypes_user_24619` | public | query |  | :x: |
| `SELeventtypes_user_24661` | public | query |  | :x: |

### ExportItemService.cfc (2 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `INSexportitems` | public | void |  | :x: |
| `SELexportitems` | public | query |  | :x: |

### ExportService.cfc (2 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `INSexports` | public | numeric |  | :x: |
| `UPDexports` | public | void |  | :x: |

### FTypeXRefService.cfc (1 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELftypexref` | public | query |  | :x: |

### FUActionService.cfc (2 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELfuactions` | public | query |  | :x: |
| `SELfuactions_24453` | public | query |  | :x: |

### FUSystemTypeService.cfc (1 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELfusystemtypes` | public | query |  | :x: |

### FileParserService.cfc (12 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `detectFileType` | public | string |  | :white_check_mark: |
| `detectEncoding` | public | string |  | :white_check_mark: |
| `detectDelimiter` | public | string |  | :white_check_mark: |
| `parseCSV` | public | struct |  | :white_check_mark: |
| `parseCSVContent` | private | struct |  | :white_check_mark: |
| `parseExcel` | public | struct |  | :white_check_mark: |
| `convertCellValue` | private | string |  | :white_check_mark: |
| `parseVCF` | public | struct |  | :white_check_mark: |
| `decodeQuotedPrintable` | private | string |  | :white_check_mark: |
| `parseFile` | public | struct |  | :white_check_mark: |
| `getFileSizeFormatted` | public | string |  | :white_check_mark: |
| `validateFileUpload` | public | struct |  | :white_check_mark: |

### FilteredQueryService.cfc (1 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELqFiltered` | public | query |  | :x: |

### GenderPronounService.cfc (1 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELgenderpronouns` | public | query |  | :x: |

### GenderPronounUserService.cfc (6 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELgenderpronouns_users` | public | query |  | :x: |
| `SELgenderpronouns_users_24203` | public | query |  | :x: |
| `INSgenderpronouns_users` | public | numeric |  | :x: |
| `SELgenderpronouns_users_24444` | public | query |  | :x: |
| `INSgenderpronouns_users_24445` | public | numeric |  | :x: |
| `SELgenderpronouns_users_24627` | public | query |  | :x: |

### GenreAuditionService.cfc (6 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELaudgenres_audition_xref` | public | query |  | :x: |
| `SELaudgenres_audition_xref_24274` | public | query |  | :x: |
| `DELaudgenres_audition_xref` | public | void |  | :x: |
| `INSaudgenres_audition_xref` | public | numeric |  | :x: |
| `INSaudgenres_audition_xref_24521` | public | numeric |  | :x: |
| `UPDaudgenres_audition_xref` | public | void |  | :x: |

### ImportAuditionsLogger.cfc (15 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `init` | public | ImportAuditionsLogger |  | :white_check_mark: |
| `setUserId` | public | void |  | :white_check_mark: |
| `setJobId` | public | void |  | :white_check_mark: |
| `debug` | public | void |  | :white_check_mark: |
| `info` | public | void |  | :white_check_mark: |
| `warn` | public | void |  | :white_check_mark: |
| `error` | public | void |  | :white_check_mark: |
| `fatal` | public | void |  | :white_check_mark: |
| `logEntry` | private | void |  | :white_check_mark: |
| `extractErrorDetail` | public | struct |  | :white_check_mark: |
| `buildErrorResponse` | public | struct |  | :white_check_mark: |
| `getCorrelationId` | public | string |  | :white_check_mark: |
| `getDebugTrail` | public | array |  | :white_check_mark: |
| `getElapsedMs` | public | numeric |  | :white_check_mark: |
| `generateCorrelationId` | private | string |  | :white_check_mark: |

### ImportV3Logger.cfc (15 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `init` | public | ImportV3Logger |  | :white_check_mark: |
| `setUserId` | public | void |  | :white_check_mark: |
| `setJobId` | public | void |  | :white_check_mark: |
| `debug` | public | void |  | :white_check_mark: |
| `info` | public | void |  | :white_check_mark: |
| `warn` | public | void |  | :white_check_mark: |
| `error` | public | void |  | :white_check_mark: |
| `fatal` | public | void |  | :white_check_mark: |
| `logEntry` | private | void |  | :white_check_mark: |
| `extractErrorDetail` | public | struct |  | :white_check_mark: |
| `buildErrorResponse` | public | struct |  | :white_check_mark: |
| `getCorrelationId` | public | string |  | :white_check_mark: |
| `getDebugTrail` | public | array |  | :white_check_mark: |
| `getElapsedMs` | public | numeric |  | :white_check_mark: |
| `generateCorrelationId` | private | string |  | :white_check_mark: |

### IncomeTypeService.cfc (1 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELincometypes` | public | query |  | :x: |

### InformationSchemaTableService.cfc (1 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELinformation_schema` | public | query |  | :x: |

### ItemCategoryService.cfc (6 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELitemcategory` | public | query |  | :x: |
| `DETitemcategory` | public | query |  | :x: |
| `SELitemcategory_24039` | public | query |  | :x: |
| `SELitemcategory_24465` | public | query |  | :x: |
| `SELitemcategory_24621` | public | query |  | :x: |
| `SELitemcategory_24722` | public | query |  | :x: |

### ItemCategoryXRefUserService.cfc (3 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `INSitemcatxref_user` | public | numeric |  | :x: |
| `SELitemcatxref_user` | public | query |  | :x: |
| `INSitemcatxref_user_24468` | public | numeric |  | :x: |

### ItemTypeService.cfc (5 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `getValueTypesByCategory` | public | struct |  | :white_check_mark: |
| `SELitemTypesByCategoryAndUser` | public | struct |  | :x: |
| `SELitemTypesByCategory_4` | public | struct |  | :x: |
| `SELitemtypes` | public | query |  | :x: |
| `SELitemtypes_24462` | public | query |  | :x: |

### ItemTypesUserService.cfc (4 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `INSitemtypes_user` | public | numeric |  | :x: |
| `SELitemtypes_user` | public | query |  | :x: |
| `INSitemtypes_user_24464` | public | numeric |  | :x: |
| `SELitemtypes_user_24466` | public | query |  | :x: |

### LinkService.cfc (5 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `getLinksByNoteId` | public | query |  | :white_check_mark: |
| `INSlinks` | public | numeric |  | :x: |
| `SELlinks` | public | query |  | :x: |
| `UPDlinks` | public | void | Updates the isdeleted field for a given linkid | :x: |
| `SELlinks_23981` | public | query |  | :x: |

### LocationService.cfc (2 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `getCountries` | public | query | Fetches all countries that have regions | :white_check_mark: |
| `getRegions` | public | query | Fetches regions for the selected country | :white_check_mark: |

### LookupService.cfc (4 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `getTags` | public | query | Fetches tags for a given user ID and search term. | :white_check_mark: |
| `getContacts` | public | query | Fetches contacts for a given user ID and search term. | :white_check_mark: |
| `getContactsNotTeam` | public | query | Fetches contacts for a given user ID and search term. | :white_check_mark: |
| `getAppointments` | public | query | Fetches upcoming events for a given user ID and search term. | :white_check_mark: |

### MeetingDurationService.cfc (5 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELmtgdurations` | public | query |  | :x: |
| `SELmtgdurations_24493` | public | query |  | :x: |
| `SELmtgdurations_24655` | public | query |  | :x: |
| `SELmtgdurations_24656` | public | query |  | :x: |
| `SELdurations` | public | query |  | :x: |

### NoteService.cfc (22 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `INSnoteslog` | public | numeric |  | :x: |
| `DELnoteslog` | public | void | Deletes a note by its ID | :x: |
| `DELnoteslog_23709` | public | void |  | :x: |
| `INSnoteslog_23730` | public | numeric |  | :x: |
| `SELnoteslog` | public | query |  | :x: |
| `UPDnoteslog` | public | void |  | :x: |
| `INSnoteslog_23966` | public | numeric |  | :x: |
| `UPDnoteslog_23967` | public | void |  | :x: |
| `INSnoteslog_23969` | public | numeric |  | :x: |
| `INSnoteslog_23972` | public | numeric |  | :x: |
| `UPDnoteslog_23974` | public | void |  | :x: |
| `UPDnoteslog_23980` | public | void |  | :x: |
| `SELnoteslog_23987` | public | query |  | :x: |
| `DETnoteslog` | public | query |  | :x: |
| `INSnoteslog_24319` | public | numeric |  | :x: |
| `INSnoteslog_24373` | public | numeric |  | :x: |
| `SELnoteslog_24400` | public | query |  | :x: |
| `INSnoteslog_24401` | public | numeric |  | :x: |
| `SELnoteslog_24698` | public | query |  | :x: |
| `SELnoteslog_24700` | public | query |  | :x: |
| `SELnoteslog_24702` | public | query |  | :x: |
| `SELnoteslog_24704` | public | query |  | :x: |

### NotificationService.cfc (30 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `updateNotification` | public | void |  | :white_check_mark: |
| `getNotifications` | public | query |  | :white_check_mark: |
| `addNotification` | public | numeric | Adds a notification, ensuring only one 'Pending' notificatio... | :white_check_mark: |
| `INSfunotifications_23817` | public | void |  | :x: |
| `removenotdups` | public | void |  | :white_check_mark: |
| `UPDfunotifications_23818` | public | void | Updates the status and optionally the start date of a notifi... | :x: |
| `UPDfunotifications_24032` | public | void |  | :x: |
| `UPDfunotifications_24130` | public | void |  | :x: |
| `UPDfunotifications_23823` | public | void |  | :x: |
| `UPDfunotifications` | public | void |  | :x: |
| `GetNotificationByID` | public | query |  | :white_check_mark: |
| `INSfunotifications_23941` | public | numeric | Adds a notification to the database | :x: |
| `INSfunotifications_23940` | public | numeric | Adds a notification to the database | :x: |
| `INSfunotifications` | public | numeric | Adds a notification to the database | :x: |
| `deleteNotificationBySystem` | public | void |  | :white_check_mark: |
| `delSystemNotifications` | public | void | Marks orphaned notifications as deleted. | :white_check_mark: |
| `SELfunotifications_24711` | public | query |  | :x: |
| `SELfunotifications_24706` | public | query |  | :x: |
| `SELfunotifications` | public | query |  | :x: |
| `SELfunotifications_24709` | public | query |  | :x: |
| `INSnotifications` | public | numeric |  | :x: |
| `INSnotifications_23830` | public | numeric |  | :x: |
| `INSnotifications_23937` | public | numeric |  | :x: |
| `UPDnotifications` | public | void |  | :x: |
| `UPDnotifications_24009` | public | void |  | :x: |
| `getRemindersTotal` | public | numeric |  | :white_check_mark: |
| `SELnotifications` | public | query |  | :x: |
| `SELfunotifications_24639` | public | query |  | :x: |
| `SELnotifications_24351` | public | query |  | :x: |
| `getNotificationsByBatchlist` | public | query | Fetch notifications by batchlist | :white_check_mark: |

### NotificationStatusService.cfc (1 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELnotstatuses` | public | query |  | :x: |

### NotificationsService.cfc (1 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `addNotifications` | public | numeric | Adds a notification to the notifications table. | :white_check_mark: |

### PageAppLinkService.cfc (3 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELpgapplinks` | public | query |  | :x: |
| `SELpgapplinks_24006` | public | query |  | :x: |
| `SELpgapplinks_24007` | public | query |  | :x: |

### PageAppLinks.cfc (2 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `GetPageAppLinks` | public | query |  | :white_check_mark: |
| `GetLinksForPageB` | public | query |  | :white_check_mark: |

### PageFieldService.cfc (3 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELpgfields` | public | query |  | :x: |
| `SELpgfields_24115` | public | query |  | :x: |
| `SELpgfields_24651` | public | query |  | :x: |

### PageService.cfc (34 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `getLinksTop` | public | query |  | :white_check_mark: |
| `getLinksBottom` | public | query |  | :white_check_mark: |
| `getLinksExtra` | public | query |  | :white_check_mark: |
| `getPagesByShare` | public | query |  | :white_check_mark: |
| `SELpgpages_24740` | public | query |  | :x: |
| `SELpgpages` | public | query |  | :x: |
| `SELpgpages_23868` | public | query |  | :x: |
| `DETpgpages` | public | query |  | :x: |
| `SELpgpages_23870` | public | query |  | :x: |
| `SELpgpages_23912` | public | query |  | :x: |
| `DETpgpages_23991` | public | query |  | :x: |
| `getDynamicQuery` | public | query |  | :white_check_mark: |
| `SELpgpages_24003` | public | query |  | :x: |
| `FindFields` | public | query |  | :white_check_mark: |
| `SELpgpages_24004` | public | query |  | :x: |
| `DETpgpages_24197` | public | query |  | :x: |
| `SELpgpages_24210` | public | query |  | :x: |
| `DETpgpages_24259` | public | query |  | :x: |
| `SELpgpages_24300` | public | query |  | :x: |
| `SELpgpages_24301` | public | query |  | :x: |
| `RESpgpages_24302` | public | query |  | :x: |
| `SELpgpages_24303` | public | query |  | :x: |
| `SELpgpages_24304` | public | query |  | :x: |
| `SELpgpages_24305` | public | query |  | :x: |
| `RESpgpages_24652` | public | query |  | :x: |
| `SELpgpages_24653` | public | query |  | :x: |
| `RESpgpages_24739` | public | query |  | :x: |
| `getDynamicQueryx` | public | query |  | :white_check_mark: |
| `RESpgpages_24777` | public | query |  | :x: |
| `SELpgpages_24778` | public | query |  | :x: |
| `getPageDetails` | public | struct | Fetch page details by page ID or URL | :white_check_mark: |
| `getPageLinksByLocation` | public | struct | Fetch top and bottom CSS/JS links for the given page | :white_check_mark: |
| `getIncludeLinks` | public | array | Fetch script_include links for the given page | :white_check_mark: |
| `pages_sel` | remote | query | Get a select list of active pages. | :white_check_mark: |

### PageTitleService.cfc (4 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `init` | public | PageTitleService |  | :white_check_mark: |
| `getPageConfiguration` | public | struct |  | :white_check_mark: |
| `buildBreadcrumbs` | public | array |  | :white_check_mark: |
| `renderActions` | public | string |  | :white_check_mark: |

### PaginationService.cfc (6 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `init` | public | PaginationService |  | :white_check_mark: |
| `calculatePagination` | public | struct |  | :white_check_mark: |
| `buildPaginationUrl` | public | string |  | :white_check_mark: |
| `renderPaginationControls` | public | string |  | :white_check_mark: |
| `renderPageInfo` | public | string |  | :white_check_mark: |
| `getPageSizeOptions` | public | string |  | :white_check_mark: |

### PanelService.cfc (1 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELpgpanels` | public | query |  | :x: |

### PanelUserService.cfc (14 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELpgpanels_user` | public | query |  | :x: |
| `UPDpgpanels_user` | public | void |  | :x: |
| `UPDpgpanels_user_23858` | public | void |  | :x: |
| `UPDpgpanels_user_23886` | public | void |  | :x: |
| `SELpgpanels_user_24136` | public | query |  | :x: |
| `pgPanelsFix` | public | void |  | :white_check_mark: |
| `SELpgpanels_user_24147` | public | query |  | :x: |
| `INSpgpanels_user` | public | numeric |  | :x: |
| `SELpgpanels_user_24435` | public | query |  | :x: |
| `INSpgpanels_user_24436` | public | numeric |  | :x: |
| `SELpgpanels_user_24440` | public | query |  | :x: |
| `INSpgpanels_user_24441` | public | numeric |  | :x: |
| `SELpgpanels_user_24640` | public | query |  | :x: |
| `SELpgpanels_user_24642` | public | query |  | :x: |

### PanelsMasterService.cfc (1 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELpgpanels_master` | public | query |  | :x: |

### PanelsUserXRefService.cfc (2 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `DELpgpanels_user_xref` | public | void |  | :x: |
| `INSpgpanels_user_xref` | public | numeric |  | :x: |

### QuotesService.cfc (1 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `getQuoteOfTheDay` | public | query |  | :white_check_mark: |

### RegionService.cfc (6 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `GetRegions` | public | query | Retrieve all regions ordered by region name. | :white_check_mark: |
| `SELregions` | public | query |  | :x: |
| `SELregions_24170` | public | query |  | :x: |
| `SELregions_24177` | public | query |  | :x: |
| `SELregions_24717` | public | query |  | :x: |
| `SELregions_24721` | public | query |  | :x: |

### RelationshipService.cfc (7 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `completeNotification` | public | struct |  | :white_check_mark: |
| `startSystemForContact` | public | struct |  | :white_check_mark: |
| `startMaintenanceIfNeeded` | public | struct |  | :white_check_mark: |
| `getNotificationDetails` | private | query |  | :white_check_mark: |
| `getNextPendingNotification` | private | query |  | :white_check_mark: |
| `logAction` | private | void |  | :white_check_mark: |
| `getSystemHealth` | public | struct |  | :white_check_mark: |

### ReportColorService.cfc (1 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELreportcolors` | public | query |  | :x: |

### ReportItemService.cfc (9 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `INSreportitems` | public | numeric |  | :x: |
| `SELreportitems` | public | query |  | :x: |
| `SELreportitems_24225` | public | query |  | :x: |
| `SELreportitems_24226` | public | query |  | :x: |
| `SELreportitems_24227` | public | query |  | :x: |
| `DELreportitems` | public | void |  | :x: |
| `INSreportitems_24233` | public | numeric |  | :x: |
| `UPDreportitems` | public | void |  | :x: |
| `RESreportitems` | public | query |  | :x: |

### ReportRangeService.cfc (6 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELreportranges` | public | query |  | :x: |
| `UPDreportranges` | public | void |  | :x: |
| `UPDreportranges_24221` | public | void |  | :x: |
| `SELreportranges_24229` | public | struct |  | :x: |
| `getReportRanges` | public | query |  | :white_check_mark: |
| `getCFSQLType` | public | string |  | :white_check_mark: |

### ReportUserService.cfc (9 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELreports_user` | public | query |  | :x: |
| `SELreports_user_24232` | public | query |  | :x: |
| `SELreports_user_24725` | public | query |  | :x: |
| `SELreports_user_24728` | public | query |  | :x: |
| `INSreports_user` | public | numeric |  | :x: |
| `SELreports_user_24733` | public | query |  | :x: |
| `SELreports_user_24734` | public | query |  | :x: |
| `SELreports_user_24736` | public | query |  | :x: |
| `SELreports_user_24737` | public | query |  | :x: |

### ReportsMasterService.cfc (1 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELreports_master` | public | query |  | :x: |

### ReportsRefreshService.cfc (14 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `report_2` | public | struct |  | :white_check_mark: |
| `report_3` | public | struct | Generates report 3, updates reportitems, and provides a summ... | :white_check_mark: |
| `report_4` | public | struct | Generates report 4, updates reportitems, and provides a summ... | :white_check_mark: |
| `report_5` | public | struct | Generates report 5, updates reportitems, and provides a summ... | :white_check_mark: |
| `report_6` | public | struct |  | :white_check_mark: |
| `report_7` | public | struct | Generates report 7, updates reportitems, and provides a summ... | :white_check_mark: |
| `report_8` | public | struct | Generates report 8, updates reportitems, and provides a summ... | :white_check_mark: |
| `report_9` | public | struct |  | :white_check_mark: |
| `report_10` | public | struct | Generates report 10, inserts into reportitems, and provides ... | :white_check_mark: |
| `report_11` | public | struct | Generates report 11, updates reportitems, and provides a sum... | :white_check_mark: |
| `report_12` | public | struct | Generates report 12, updates reportitems, and provides a sum... | :white_check_mark: |
| `report_13` | public | struct | Generates report 13, updates reportitems, and provides a sum... | :white_check_mark: |
| `report_17` | public | struct | Generates report 17, updates reportitems, and provides a sum... | :white_check_mark: |
| `report_18` | public | struct | Generates report 18, updates reportitems, and provides a sum... | :white_check_mark: |

### ShareService.cfc (4 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `GetShareDetailsByAudition` | public | query |  | :white_check_mark: |
| `GetShareDetails` | public | query |  | :white_check_mark: |
| `SELshares` | public | query |  | :x: |
| `shares` | public | query |  | :white_check_mark: |

### SiteLinkUserService.cfc (12 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `UPDsitelinks_user` | public | void |  | :x: |
| `SELsitelinks_user` | public | query |  | :x: |
| `UPDsitelinks_user_23854` | public | void | Updates the site icon for a user. | :x: |
| `UPDsitelinks_user_23883` | public | void |  | :x: |
| `UPDsitelinks_user_23930` | public | void |  | :x: |
| `SELsitelinks_user_23943` | public | query |  | :x: |
| `SELsitelinks_user_23958` | public | query |  | :x: |
| `SELsitelinks_user_23959` | public | query |  | :x: |
| `SELsitelinks_user_24138` | public | query |  | :x: |
| `INSsitelinks_user` | public | numeric |  | :x: |
| `SELsitelinks_user_24448` | public | query |  | :x: |
| `INSsitelinks_user_24449` | public | numeric |  | :x: |

### SiteLinksMasterService.cfc (1 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELsitelinks_master` | public | query |  | :x: |

### SiteLinksService.cfc (7 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `getSiteLinksByPanelId` | public | query | Retrieve site links for a specific panel ID. | :white_check_mark: |
| `getAllUrlsByPanelId` | public | string | Retrieve all URLs for a specific panel for the 'Open All' bu... | :white_check_mark: |
| `getLinkDetailsById` | public | query | Retrieve link details for a specific link ID. | :white_check_mark: |
| `updateSiteLinkDetails` | public | void | Check for duplicate sitenames and update site link details | :white_check_mark: |
| `updateSiteLink` | public | void | Updates the sitelinks_user table dynamically based on availa... | :white_check_mark: |
| `getSiteTypeDetailsByPanelId` | public | struct | Retrieve the sitetypeid and sitetypename for a specific pane... | :white_check_mark: |
| `getPanelData` | public | struct | Retrieves all necessary data for a links panel in a single c... | :white_check_mark: |

### SiteTypeMasterService.cfc (2 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELsitetypes_master` | public | query |  | :x: |
| `SELsitetypes_master_24437` | public | query |  | :x: |

### SiteTypeUserService.cfc (12 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELsitetypes_user` | public | query |  | :x: |
| `UPDsitetypes_user` | public | void |  | :x: |
| `SELsitetypes_user_24133` | public | query |  | :x: |
| `UPDsitetypes_user_24134` | public | void |  | :x: |
| `SELsitetypes_user_24144` | public | query |  | :x: |
| `INSsitetypes_user` | public | numeric |  | :x: |
| `SELsitetypes_user_24146` | public | query |  | :x: |
| `UPDsitetypes_user_24149` | public | void |  | :x: |
| `SELsitetypes_user_24438` | public | query |  | :x: |
| `INSsitetypes_user_24439` | public | numeric |  | :x: |
| `SELsitetypes_user_24447` | public | query |  | :x: |
| `SELsitetypes_user_24752` | public | query |  | :x: |

### SystemService.cfc (20 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `findSystemByID` | public | query | Finds a system by its ID | :white_check_mark: |
| `SELfusystemtypes` | public | query |  | :x: |
| `SELfusystems_23821` | public | query |  | :x: |
| `SELfusystems_23933` | public | query |  | :x: |
| `DETfusystems` | public | query |  | :x: |
| `SELfusystems_23938` | public | query |  | :x: |
| `SELfusystems_23944` | public | query |  | :x: |
| `SELfusystems` | public | query |  | :x: |
| `DETfusystems_24029` | public | query |  | :x: |
| `SELfusystems_24317` | public | query |  | :x: |
| `SELfusystems_24318` | public | query |  | :x: |
| `SELfusystems_24320` | public | query |  | :x: |
| `SELfusystems_24321` | public | query |  | :x: |
| `SELfusystems_24322` | public | query |  | :x: |
| `SELfusystems_24342` | public | query |  | :x: |
| `SELfusystems_24428` | public | query |  | :x: |
| `SELfusystems_24634` | public | query |  | :x: |
| `getFuSystemUsersBySystemID` | public | query |  | :white_check_mark: |
| `SELfusystems_24762` | public | query |  | :x: |
| `SELfusystems_24763` | public | query |  | :x: |

### SystemUserService.cfc (21 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `closeSystem` | public | void |  | :white_check_mark: |
| `findSystemByScope` | public | string | Finds system ID based on type and scope | :white_check_mark: |
| `getOldSystemDetails` | public | query | Gets the old system details including system scope and type | :white_check_mark: |
| `updateSystemUser` | public | void |  | :white_check_mark: |
| `addfuSystemUsers` | public | numeric |  | :white_check_mark: |
| `INSfusystemusers_batch` | public | numeric |  | :x: |
| `SELfusystemusers` | public | query |  | :x: |
| `SELfusystemusers_23864` | public | query |  | :x: |
| `UPDfusystemusers_23865` | public | void |  | :x: |
| `INSfusystemusers_23934` | public | numeric |  | :x: |
| `UPDfusystemusers_23935` | public | void |  | :x: |
| `SELfusystemusers_24031` | public | query |  | :x: |
| `getSystemUserByID` | public | query |  | :white_check_mark: |
| `UPDfusystemusers_24315` | public | void |  | :x: |
| `SELfusystemusers_24343` | public | query |  | :x: |
| `SELfusystemusers_24344` | public | query |  | :x: |
| `UPDfusystemusers_24345` | public | numeric |  | :x: |
| `SELfusystemusers_24426` | public | query |  | :x: |
| `INSfusystemusers_24427` | public | numeric |  | :x: |
| `getRemindersByRelationship` | public | query |  | :white_check_mark: |
| `SELfusystemusers_24758` | public | query |  | :x: |

### TagService.cfc (1 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELtags` | public | query |  | :x: |

### TagsUserService.cfc (15 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELtags_user` | public | query |  | :x: |
| `SELtags_user_23804` | public | query |  | :x: |
| `SELtags_user_23844` | public | query |  | :x: |
| `SELtags_user_24047` | public | query |  | :x: |
| `SELtags_user_24063` | public | query |  | :x: |
| `SELtags_user_24324` | public | query |  | :x: |
| `INStags_user` | public | numeric |  | :x: |
| `SELtags_user_24328` | public | query |  | :x: |
| `UPDtags_user` | public | void |  | :x: |
| `SELtags_user_24341` | public | query |  | :x: |
| `SELtags_user_24457` | public | query |  | :x: |
| `INStags_user_24458` | public | numeric |  | :x: |
| `UPDtags_user_24459` | public | void |  | :x: |
| `UPDtags_user_24460` | public | void |  | :x: |
| `SELtags_user_24765` | public | query |  | :x: |

### TaoVersionService.cfc (10 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `getActiveTaoVersions` | public | query | Fetches active versions with 'Pending' status | :white_check_mark: |
| `versions_sel` | public | query |  | :white_check_mark: |
| `SELtaoversions` | public | query |  | :x: |
| `SELtaoversions_24215` | public | query |  | :x: |
| `SELtaoversions_24331` | public | query |  | :x: |
| `SELtaoversions_24386` | public | query |  | :x: |
| `SELtaoversions_24387` | public | query |  | :x: |
| `SELtaoversions_24469` | public | query |  | :x: |
| `INStaoversions` | public | numeric |  | :x: |
| `UPDtaoversions` | public | void | Updates a version record in the taoversions table. | :x: |

### TicketPriorityService.cfc (1 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELticketpriority` | public | query |  | :x: |

### TicketService.cfc (30 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `UPDtickets` | public | void |  | :x: |
| `SELtickets` | public | query |  | :x: |
| `SELtickets_23720` | public | query |  | :x: |
| `UPDtickets_23866` | public | void | Updates the status of a ticket to Closed and marks it as del... | :x: |
| `SELtickets_23997` | public | query |  | :x: |
| `DETtickets` | public | query |  | :x: |
| `UPDtickets_24076` | public | void | Updates the ticket status based on ticket ID. | :x: |
| `UPDtickets_24077` | public | void |  | :x: |
| `DETtickets_24109` | public | query |  | :x: |
| `INStickets` | public | numeric |  | :x: |
| `DETtickets_24162` | public | query |  | :x: |
| `DETtickets_24208` | public | query |  | :x: |
| `UPDtickets_24216` | public | void |  | :x: |
| `DETtickets_24217` | public | query |  | :x: |
| `UPDtickets_24332` | public | void |  | :x: |
| `REStickets` | public | query |  | :x: |
| `UPDtickets_24335` | public | void |  | :x: |
| `UPDtickets_24337` | public | void |  | :x: |
| `UPDtickets_24339` | public | void |  | :x: |
| `UPDtickets_24384` | public | void |  | :x: |
| `DETtickets_24385` | public | query |  | :x: |
| `SELtickets_24472` | public | query |  | :x: |
| `SELtickets_24473` | public | query |  | :x: |
| `SELtickets_24480` | public | query |  | :x: |
| `DETtickets_24767` | public | query |  | :x: |
| `REStickets_24768` | public | query |  | :x: |
| `DETtickets_24782` | public | query |  | :x: |
| `DETtickets_24784` | public | query |  | :x: |
| `REStickets_24785` | public | query |  | :x: |
| `REStickets_24787` | public | query | Fetches version and ticket data. | :x: |

### TicketStatusService.cfc (3 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELticketstatuses` | public | query |  | :x: |
| `SELticketstatuses_24766` | public | query |  | :x: |
| `SELticketstatuses_24781` | public | query |  | :x: |

### TicketTestUserService.cfc (5 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELtickettestusers` | public | query |  | :x: |
| `INStickettestusers` | public | numeric |  | :x: |
| `UPDtickettestusers` | public | void |  | :x: |
| `SELtickettestusers_24474` | public | query |  | :x: |
| `SELtickettestusers_24475` | public | query |  | :x: |

### TicketTypeService.cfc (1 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELtickettypes` | public | query |  | :x: |

### TicketsLogTableService.cfc (1 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `INSticketslog` | public | void |  | :x: |

### TimeZoneService.cfc (2 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `SELtimezones` | public | query |  | :x: |
| `SELtimezones_24770` | public | query |  | :x: |

### UpdateLogService.cfc (2 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `INSupdatelog` | public | numeric |  | :x: |
| `RESupdatelog` | public | query |  | :x: |

### UploadService.cfc (2 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `INSuploads` | public | numeric |  | :x: |
| `DETuploads` | public | query |  | :x: |

### UserService.cfc (38 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `dateformatpref` | public | void | Updates the date format preference for a user and refreshes ... | :white_check_mark: |
| `getUserByHash` | public | query |  | :white_check_mark: |
| `update_cal` | public | numeric |  | :white_check_mark: |
| `users_sel` | public | query | Fetches a list of users with the minimum user ID for each re... | :white_check_mark: |
| `GetUserDetails` | public | struct |  | :white_check_mark: |
| `SELtaousers` | public | query |  | :x: |
| `SELtaousers_23718` | public | query |  | :x: |
| `SELtaousers_23721` | public | query |  | :x: |
| `UPDtaousers` | public | void |  | :x: |
| `SELtaousers_23842` | public | query |  | :x: |
| `UPDtaousers_23911` | public | void |  | :x: |
| `UPDtaousers_23945` | public | void |  | :x: |
| `UPDtaousers_23950` | public | void |  | :x: |
| `UPDtaousers_23951` | public | void |  | :x: |
| `SELtaousers_23956` | public | query |  | :x: |
| `UPDtaousers_23989` | public | void |  | :x: |
| `UPDtaousers_23990` | public | void | Updates the access token for a user based on their userid. | :x: |
| `SELtaousers_23998` | public | query |  | :x: |
| `UPDtaousers_23999` | public | void |  | :x: |
| `UPDtaousers_24001` | public | void |  | :x: |
| `SELtaousers_24002` | public | query |  | :x: |
| `SELtaousers_24072` | public | query |  | :x: |
| `DETtaousers` | public | query |  | :x: |
| `SELtaousers_24142` | public | query |  | :x: |
| `SELtaousers_24158` | public | query |  | :x: |
| `SELtaousers_24306` | public | query |  | :x: |
| `SELtaousers_24432` | public | query |  | :x: |
| `SELtaousers_24461` | public | query |  | :x: |
| `SELtaousers_24759` | public | query |  | :x: |
| `SELtaousers_24760` | public | query |  | :x: |
| `getUsers` | public | query | Fetches users grouped by record name | :white_check_mark: |
| `getUserById` | public | struct |  | :white_check_mark: |
| `listUsers` | public | struct |  | :white_check_mark: |
| `getUserStatuses` | public | query |  | :white_check_mark: |
| `getUserRoles` | public | query |  | :white_check_mark: |
| `createUser` | public | struct |  | :white_check_mark: |
| `updateUser` | public | struct |  | :white_check_mark: |
| `toggleUserStatus` | public | struct |  | :white_check_mark: |

### ValidationService.cfc (12 functions)

| Function Name | Access | Return Type | Hint | Conforming? |
|---------------|--------|-------------|------|-------------|
| `validateEmail` | public | struct |  | :white_check_mark: |
| `validatePhone` | public | struct |  | :white_check_mark: |
| `validateDate` | public | struct |  | :white_check_mark: |
| `validateURL` | public | struct |  | :white_check_mark: |
| `validateString` | public | struct |  | :white_check_mark: |
| `validateRequired` | public | struct |  | :white_check_mark: |
| `validateTag` | public | struct |  | :white_check_mark: |
| `validateField` | public | struct |  | :white_check_mark: |
| `validateRow` | public | struct |  | :white_check_mark: |
| `validateBatch` | public | struct |  | :white_check_mark: |
| `normalizeFullName` | public | struct |  | :white_check_mark: |
| `normalizeAddress` | public | struct |  | :white_check_mark: |

---
# PHASE 1B: /qry File Inventory

**Total QRY Files:** 1267
**Files with :lock: Security Issues (unparameterized queries):** 82

### Operation Type Distribution

Note: "UNKNOWN" means the file contains no direct SQL statement. These are typically
controller/logic files that call service CFCs or `<cfinclude>` other query files.
Despite living in `/include/qry/`, they are not themselves query files.

| Operation | Count |
|-----------|-------|
| UNKNOWN (no direct SQL) | 1074 |
| SELECT | 127 |
| UPDATE | 30 |
| INSERT | 24 |
| CREATE | 6 |
| DELETE | 6 |

### :lock: SECURITY: Unparameterized Query Files

These files contain `#variable#` interpolation in `<cfquery>` blocks without adequate
`cfqueryparam` usage. Each requires review and parameterization.

| # | File | SQL Operation | Tables |
|---|------|--------------|--------|
| 1 | `BatchDetails_548_1.cfm` | SELECT | based,contactdetails,the |
| 2 | `FIND_222_1.cfm` | SELECT | audplatforms_user_tbl,the |
| 3 | `FindModalTitle_265_1.cfm` | SELECT | pgapps,pgcomps,pgpages |
| 4 | `FindOld_266_1.cfm` | SELECT | the |
| 5 | `FindOld_311_1.cfm` | SELECT | name,the |
| 6 | `FindValue_107_5.cfm` | SELECT | based,the |
| 7 | `FindValue_107_6.cfm` | SELECT | based,the |
| 8 | `FindValue_107_8.cfm` | UPDATE | table,the |
| 9 | `FindValue_265_10.cfm` | SELECT | the |
| 10 | `FindValue_265_3.cfm` | SELECT | the |
| 11 | `FindValue_265_4.cfm` | SELECT | based,table,the |
| 12 | `FindValue_265_6.cfm` | UPDATE | table,the |
| 13 | `FindValue_265_8.cfm` | SELECT | the |
| 14 | `INSERT_315_1.cfm` | INSERT | for,the |
| 15 | `admin-support.cfm` | SELECT | application,pgpages,taousers,taousers_tbl,taoversions |
| 16 | `audmedia_details_225_1.cfm` | UNKNOWN | the |
| 17 | `audtypes_sel_221_6.cfm` | SELECT | audtypes |
| 18 | `bycat_529_3.cfm` | SELECT | audcategories,the |
| 19 | `casting_types_221_7.cfm` | SELECT | tags_user,the |
| 20 | `cat_221_3.cfm` | SELECT | audcategories,audsubcategories |
| 21 | `cat_221_4.cfm` | SELECT | audcategories,audsubcategories |
| 22 | `checkUnique_447_1.cfm` | SELECT | contact,contactdetails |
| 23 | `checkformaint_70_6.cfm` | SELECT | fusystems,fusystemusers |
| 24 | `checkformaint_72_6.cfm` | SELECT | fusystems,fusystemusers,the |
| 25 | `companies_521_5.cfm` | SELECT | contactdetails,contactitems,the |
| 26 | `delete_287_15.cfm` | DELETE | audvocaltypes_audition_xref,based,the |
| 27 | `details_451_1.cfm` | SELECT | contactdetails,taousers,the |
| 28 | `details_501_2.cfm` | SELECT | contactdetails,taousers |
| 29 | `details_502_2.cfm` | SELECT | contactdetails,taousers |
| 30 | `details_503_2.cfm` | SELECT | contactdetails,taousers |
| 31 | `details_504_3.cfm` | SELECT | contactdetails,taousers |
| 32 | `details_505_3.cfm` | SELECT | contactdetails,taousers |
| 33 | `eventdetails_336_3.cfm` | SELECT | events |
| 34 | `events_502_1.cfm` | SELECT | eventcontactsxref,events,eventtypes_user |
| 35 | `events_504_1.cfm` | SELECT | eventcontactsxref,events,eventtypes_user |
| 36 | `findSystem_70_7.cfm` | SELECT | based,fusystems,the |
| 37 | `find_107_4.cfm` | SELECT | based,the |
| 38 | `find_185_4.cfm` | SELECT | a,based,the |
| 39 | `find_265_2.cfm` | SELECT | based,the |
| 40 | `find_536_5.cfm` | SELECT | ftypexref_tbl,the |
| 41 | `ins_253_1.cfm` | DELETE | audmedia_auditions_xref,based,the |
| 42 | `insert_262_1.cfm` | INSERT | itemtypes_user,the |
| 43 | `insert_287_14.cfm` | INSERT | audgenres_audition_xref,the,with |
| 44 | `insert_564_1.cfm` | INSERT | eventtypes_user |
| 45 | `insertx_262_2.cfm` | INSERT | the,with |
| 46 | `note_503_1.cfm` | SELECT | based,noteslog,the |
| 47 | `note_504_2.cfm` | SELECT | based,noteslog,the |
| 48 | `notesContactDetails_506_2.cfm` | SELECT | contactdetails,noteslog,the |
| 49 | `notesContactDetails_507_2.cfm` | SELECT | contactdetails,noteslog,the |
| 50 | `notesContactDetails_508_2.cfm` | SELECT | along,contactdetails,noteslog,the |
| 51 | `notesContactDetails_509_2.cfm` | SELECT | contactdetails,noteslog,the |
| 52 | `pronouns_451_4.cfm` | SELECT | genderpronouns_users,the |
| 53 | `rangeselected_524_8.cfm` | SELECT | based,reportranges,the |
| 54 | `relationships_366_1.cfm` | SELECT | contactdetails |
| 55 | `results_451_3.cfm` | SELECT | contactdetails,the |
| 56 | `results_526_4.cfm` | UNKNOWN | the |
| 57 | `selects_107_11.cfm` | SELECT | a,the |
| 58 | `selects_107_12.cfm` | SELECT | the |
| 59 | `selects_107_7.cfm` | SELECT | a,the |
| 60 | `selects_107_9.cfm` | SELECT | a,the |
| 61 | `selects_245_1.cfm` | SELECT | a,the |
| 62 | `selects_245_2.cfm` | SELECT | a,for,the |
| 63 | `selects_265_11.cfm` | SELECT | a,the |
| 64 | `selects_265_5.cfm` | SELECT | a,the |
| 65 | `selects_265_7.cfm` | SELECT | a,based,the |
| 66 | `selects_265_9.cfm` | SELECT | a,the |
| 67 | `sq2_185_6.cfm` | UPDATE | the,with |
| 68 | `sql1_185_5.cfm` | UPDATE | the,with |
| 69 | `tname_ins_464_3.cfm` | INSERT | a,based |
| 70 | `tname_sel_529_1.cfm` | SELECT | a,audcategories |
| 71 | `tname_sel_530_1.cfm` | SELECT | audcategories,the |
| 72 | `tname_sel_531_1.cfm` | SELECT | a |
| 73 | `tname_sel_532_1.cfm` | SELECT | the |
| 74 | `tname_sel_533_1.cfm` | SELECT |  |
| 75 | `updateContact_72_2.cfm` | UPDATE | contact,contactdetails |
| 76 | `update_266_2.cfm` | UPDATE | based |
| 77 | `update_311_2.cfm` | UPDATE | based,statement |
| 78 | `updatesystem_70_4.cfm` | UPDATE | based,funotifications |
| 79 | `updatesystem_70_5.cfm` | UPDATE | fusystemusers,the,to |
| 80 | `updatesystem_72_4.cfm` | UPDATE | based,funotifications |
| 81 | `updatesystem_72_5.cfm` | UPDATE | fusystemusers,the,to |
| 82 | `uu_274_2.cfm` | SELECT | based,taousers,the |

### SELECT Files (127)

| File | Tables | Parameterized? | Security |
|------|--------|----------------|----------|
| `ActiveVersions.cfm` | taoversions | :warning: No |  |
| `BatchDetails_548_1.cfm` | based,contactdetails,the | :warning: No | :lock: UNPARAMETERIZED |
| `FIND_222_1.cfm` | audplatforms_user_tbl,the | :warning: No | :lock: UNPARAMETERIZED |
| `FindKey_526_1.cfm` | based,pgfields,the | :white_check_mark: |  |
| `FindKey_550_1.cfm` | for,pgfields,to | :white_check_mark: |  |
| `FindModalTitle_265_1.cfm` | pgapps,pgcomps,pgpages | :warning: No | :lock: UNPARAMETERIZED |
| `FindOld_266_1.cfm` | the | :warning: No | :lock: UNPARAMETERIZED |
| `FindOld_311_1.cfm` | name,the | :warning: No | :lock: UNPARAMETERIZED |
| `FindRefPage_136_1.cfm` | pgapps,pgcomps,pgpages | :white_check_mark: |  |
| `FindValue_107_5.cfm` | based,the | :warning: No | :lock: UNPARAMETERIZED |
| `FindValue_107_6.cfm` | based,the | :warning: No | :lock: UNPARAMETERIZED |
| `FindValue_265_10.cfm` | the | :warning: No | :lock: UNPARAMETERIZED |
| `FindValue_265_3.cfm` | the | :warning: No | :lock: UNPARAMETERIZED |
| `FindValue_265_4.cfm` | based,table,the | :warning: No | :lock: UNPARAMETERIZED |
| `FindValue_265_8.cfm` | the | :warning: No | :lock: UNPARAMETERIZED |
| `Findrec_228_2.cfm` | a,based,the | :white_check_mark: |  |
| `admin-support.cfm` | application,pgpages,taousers,taousers_tbl,taoversions | :warning: No | :lock: UNPARAMETERIZED |
| `audageranges_sel.cfm` |  | :warning: No |  |
| `audcategory_sel.cfm` |  | :warning: No |  |
| `auditions_ins.cfm` |  | :warning: No |  |
| `auditions_upd.cfm` |  | :warning: No |  |
| `audmediatypes_sel.cfm` |  | :warning: No |  |
| `audplatforms_sel.cfm` |  | :warning: No |  |
| `audqtypes_sel.cfm` |  | :warning: No |  |
| `audsteps_sel.cfm` | name | :warning: No |  |
| `audtypes_sel.cfm` | the | :warning: No |  |
| `audtypes_sel_221_6.cfm` | audtypes | :warning: No | :lock: UNPARAMETERIZED |
| `audunions_sel.cfm` |  | :warning: No |  |
| `audunions_sel_433_1.cfm` | audunions,countries,the | :white_check_mark: |  |
| `audvocaltypes_sel.cfm` | name | :warning: No |  |
| `bycat_529_3.cfm` | audcategories,the | :white_check_mark: | :lock: UNPARAMETERIZED |
| `casting_types_221_7.cfm` | tags_user,the | :warning: No | :lock: UNPARAMETERIZED |
| `castingdirectors_sel.cfm` | the | :warning: No |  |
| `cat_221_3.cfm` | audcategories,audsubcategories | :warning: No | :lock: UNPARAMETERIZED |
| `cat_221_4.cfm` | audcategories,audsubcategories | :warning: No | :lock: UNPARAMETERIZED |
| `checkUnique_447_1.cfm` | contact,contactdetails | :warning: No | :lock: UNPARAMETERIZED |
| `checkformaint_70_6.cfm` | fusystems,fusystemusers | :warning: No | :lock: UNPARAMETERIZED |
| `checkformaint_72_6.cfm` | fusystems,fusystemusers,the | :warning: No | :lock: UNPARAMETERIZED |
| `companies_521_5.cfm` | contactdetails,contactitems,the | :warning: No | :lock: UNPARAMETERIZED |
| `contacts_334_4.cfm` | contactdetails,the | :white_check_mark: |  |
| `contacts_335_5.cfm` | contact,contactdetails,the | :white_check_mark: |  |
| `contacts_336_4.cfm` | contactdetails,the | :white_check_mark: |  |
| `details.cfm` | from,identifiers,metadata,name,pgapps | :warning: No |  |
| `details_451_1.cfm` | contactdetails,taousers,the | :warning: No | :lock: UNPARAMETERIZED |
| `details_501_2.cfm` | contactdetails,taousers | :warning: No | :lock: UNPARAMETERIZED |
| `details_502_2.cfm` | contactdetails,taousers | :warning: No | :lock: UNPARAMETERIZED |
| `details_503_2.cfm` | contactdetails,taousers | :warning: No | :lock: UNPARAMETERIZED |
| `details_504_3.cfm` | contactdetails,taousers | :warning: No | :lock: UNPARAMETERIZED |
| `details_505_3.cfm` | contactdetails,taousers | :warning: No | :lock: UNPARAMETERIZED |
| `duplicatesByEmail.cfm` | contactdetails,contactitems,itemcategories | :white_check_mark: |  |
| `duplicatesByName.cfm` | contactdetails | :white_check_mark: |  |
| `essence_sel.cfm` |  | :warning: No |  |
| `eventdetails_336_3.cfm` | events | :warning: No | :lock: UNPARAMETERIZED |
| `events_502_1.cfm` | eventcontactsxref,events,eventtypes_user | :warning: No | :lock: UNPARAMETERIZED |
| `events_504_1.cfm` | eventcontactsxref,events,eventtypes_user | :warning: No | :lock: UNPARAMETERIZED |
| `events_byuser.cfm` | eventcontactsxref,the | :white_check_mark: |  |
| `findSystem_70_7.cfm` | based,fusystems,the | :warning: No | :lock: UNPARAMETERIZED |
| `find_107_4.cfm` | based,the | :warning: No | :lock: UNPARAMETERIZED |
| `find_185_4.cfm` | a,based,the | :warning: No | :lock: UNPARAMETERIZED |
| `find_265_2.cfm` | based,the | :warning: No | :lock: UNPARAMETERIZED |
| `find_300_1.cfm` | taoversions,the | :warning: No |  |
| `find_536_5.cfm` | ftypexref_tbl,the | :warning: No | :lock: UNPARAMETERIZED |
| `findp_536_4.cfm` | allfields,from | :warning: No |  |
| `headshots_sel.cfm` | the | :warning: No |  |
| `headshots_sel_unused.cfm` |  | :warning: No |  |
| `incometypes_sel.cfm` | the | :warning: No |  |
| `itemsAll.cfm` | the | :warning: No |  |
| `materials_sel_unused.cfm` |  | :warning: No |  |
| `note_503_1.cfm` | based,noteslog,the | :warning: No | :lock: UNPARAMETERIZED |
| `note_504_2.cfm` | based,noteslog,the | :warning: No | :lock: UNPARAMETERIZED |
| `note_505_2.cfm` | noteslog | :white_check_mark: |  |
| `notesContactDetails_506_2.cfm` | contactdetails,noteslog,the | :warning: No | :lock: UNPARAMETERIZED |
| `notesContactDetails_507_2.cfm` | contactdetails,noteslog,the | :warning: No | :lock: UNPARAMETERIZED |
| `notesContactDetails_508_2.cfm` | along,contactdetails,noteslog,the | :warning: No | :lock: UNPARAMETERIZED |
| `notesContactDetails_509_2.cfm` | contactdetails,noteslog,the | :warning: No | :lock: UNPARAMETERIZED |
| `notsActives_511_3.cfm` | actionusers,contactdetails,fuactionlinks,fuactions,funotifications | :white_check_mark: |  |
| `priorities_330_2.cfm` | the,ticketpriority | :warning: No |  |
| `priorities_556_3.cfm` | the,ticketpriority | :warning: No |  |
| `projectDetails_232_1.cfm` | audcategories,audcontracttypes,audnetworks,audprojects,audroles | :white_check_mark: |  |
| `pronouns_451_4.cfm` | genderpronouns_users,the | :warning: No | :lock: UNPARAMETERIZED |
| `ranges_332_1.cfm` | audageranges,for,the | :warning: No |  |
| `rangeselected_524_8.cfm` | based,reportranges,the | :warning: No | :lock: UNPARAMETERIZED |
| `relationships_334_1.cfm` | contactdetails,the | :white_check_mark: |  |
| `relationships_335_1.cfm` | contactdetails,the | :white_check_mark: |  |
| `relationships_336_1.cfm` | contactdetails,the | :white_check_mark: |  |
| `relationships_366_1.cfm` | contactdetails | :warning: No | :lock: UNPARAMETERIZED |
| `remoteUpdateC.cfm` |  | :warning: No |  |
| `remoteaudadd.cfm` |  | :warning: No |  |
| `results.cfm` |  | :warning: No |  |
| `results_451_3.cfm` | contactdetails,the | :warning: No | :lock: UNPARAMETERIZED |
| `select_cat_query.cfm` | a,query,the,with | :warning: No |  |
| `select_cat_user_query.cfm` |  | :warning: No |  |
| `select_query.cfm` | format,query,the | :warning: No |  |
| `select_user_query.cfm` | a,format,query,the | :warning: No |  |
| `select_user_query_noisdelete.cfm` | format,query | :warning: No |  |
| `selects_107_11.cfm` | a,the | :warning: No | :lock: UNPARAMETERIZED |
| `selects_107_12.cfm` | the | :warning: No | :lock: UNPARAMETERIZED |
| `selects_107_7.cfm` | a,the | :warning: No | :lock: UNPARAMETERIZED |
| `selects_107_9.cfm` | a,the | :warning: No | :lock: UNPARAMETERIZED |
| `selects_245_1.cfm` | a,the | :warning: No | :lock: UNPARAMETERIZED |
| `selects_245_2.cfm` | a,for,the | :warning: No | :lock: UNPARAMETERIZED |
| `selects_265_11.cfm` | a,the | :warning: No | :lock: UNPARAMETERIZED |
| `selects_265_5.cfm` | a,the | :warning: No | :lock: UNPARAMETERIZED |
| `selects_265_7.cfm` | a,based,the | :warning: No | :lock: UNPARAMETERIZED |
| `selects_265_9.cfm` | a,the | :warning: No | :lock: UNPARAMETERIZED |
| `statuses_555_2.cfm` | ticketstatuses | :warning: No |  |
| `systemnames_452_2.cfm` | fusystems,the | :warning: No |  |
| `systems_452_1.cfm` | fusystemtypes,the | :warning: No |  |
| `systems_453_1.cfm` | fusystemtypes,the | :warning: No |  |
| `thrivecart_results.cfm` | application,paymentplans,products,thrivecart | :white_check_mark: |  |
| `tname_sel_529_1.cfm` | a,audcategories | :white_check_mark: | :lock: UNPARAMETERIZED |
| `tname_sel_530_1.cfm` | audcategories,the | :white_check_mark: | :lock: UNPARAMETERIZED |
| `tname_sel_531_1.cfm` | a | :warning: No | :lock: UNPARAMETERIZED |
| `tname_sel_532_1.cfm` | the | :white_check_mark: | :lock: UNPARAMETERIZED |
| `tname_sel_533_1.cfm` |  | :white_check_mark: | :lock: UNPARAMETERIZED |
| `toastmenu_549_2.cfm` | contactdetails,notifications | :white_check_mark: |  |
| `toasts_549_1.cfm` | contactdetails,notifications | :white_check_mark: |  |
| `types_335_2.cfm` | eventtypes_user,the | :white_check_mark: |  |
| `types_336_2.cfm` | eventtypes_user,the | :white_check_mark: |  |
| `u_524_2.cfm` | based,taousers,the | :white_check_mark: |  |
| `update.cfm` | identifiers,metadata,name,query | :warning: No |  |
| `users_274_4.cfm` | taousers,the | :warning: No |  |
| `uu_274_2.cfm` | based,taousers,the | :warning: No | :lock: UNPARAMETERIZED |
| `x_291_1.cfm` | shares | :warning: No |  |
| `x_464_2.cfm` | allfields,the | :warning: No |  |
| `x_536_3.cfm` | allfields,the | :warning: No |  |
| `y_536_1.cfm` | from,names,the | :warning: No |  |

### INSERT Files (24)

| File | Tables | Parameterized? | Security |
|------|--------|----------------|----------|
| `INSERT_315_1.cfm` | for,the | :warning: No | :lock: UNPARAMETERIZED |
| `add_aud_contact.cfm` | audcontacts_auditions_xref | :warning: No |  |
| `audtones_ins.cfm` | the | :warning: No |  |
| `audtypes_ins.cfm` | the | :warning: No |  |
| `audunions_ins.cfm` | the | :warning: No |  |
| `audvocaltypes_audition_xref_ins.cfm` | the,using | :warning: No |  |
| `audvocaltypes_ins.cfm` | the | :warning: No |  |
| `insert_202_2.cfm` | contactitems_tbl,the | :white_check_mark: |  |
| `insert_202_3.cfm` | contactitems_tbl,the | :white_check_mark: |  |
| `insert_262_1.cfm` | itemtypes_user,the | :warning: No | :lock: UNPARAMETERIZED |
| `insert_287_14.cfm` | audgenres_audition_xref,the,with | :warning: No | :lock: UNPARAMETERIZED |
| `insert_28_5.cfm` | contactitems_tbl,the | :white_check_mark: |  |
| `insert_28_6.cfm` | contactitems_tbl,the | :white_check_mark: |  |
| `insert_28_8.cfm` | contactitems_tbl,the | :white_check_mark: |  |
| `insert_367_2.cfm` | contactitems_tbl,the | :white_check_mark: |  |
| `insert_367_3.cfm` | contactitems_tbl,the,with | :white_check_mark: |  |
| `insert_367_5.cfm` | contactitems_tbl,the | :white_check_mark: |  |
| `insert_367_6.cfm` | contactitems_tbl,the | :white_check_mark: |  |
| `insert_564_1.cfm` | eventtypes_user | :warning: No | :lock: UNPARAMETERIZED |
| `inserttlog.cfm` | the | :warning: No |  |
| `insertx_262_2.cfm` | the,with | :warning: No | :lock: UNPARAMETERIZED |
| `reports.cfm` |  | :warning: No |  |
| `sql.cfm` | found | :white_check_mark: |  |
| `tname_ins_464_3.cfm` | a,based | :white_check_mark: | :lock: UNPARAMETERIZED |

### UPDATE Files (30)

| File | Tables | Parameterized? | Security |
|------|--------|----------------|----------|
| `FindValue_107_8.cfm` | table,the | :warning: No | :lock: UNPARAMETERIZED |
| `FindValue_265_6.cfm` | table,the | :warning: No | :lock: UNPARAMETERIZED |
| `audgenres_update.cfm` | audition | :warning: No |  |
| `audition.cfm` | done,the | :warning: No |  |
| `audlocations_ins_58_1.cfm` | the | :warning: No |  |
| `audsubcategories_upd.cfm` | query,with | :warning: No |  |
| `audtones_upd.cfm` | query,with | :warning: No |  |
| `audtypes_upd.cfm` | query,with | :warning: No |  |
| `audunions_upd.cfm` | query,with | :warning: No |  |
| `audvocaltypes_audition_xref_upd.cfm` | the,with | :warning: No |  |
| `audvocaltypes_upd.cfm` | based,query | :warning: No |  |
| `contact_info.cfm` | funotifications,fusystemusers | :warning: No |  |
| `dd_365_6.cfm` | events,the | :warning: No |  |
| `notesContact.cfm` |  | :warning: No |  |
| `query_0_314_1.cfm` | based,pgpanels_user,the | :white_check_mark: |  |
| `remote_aud_project_update.cfm` | button,project | :warning: No |  |
| `sq2_185_6.cfm` | the,with | :warning: No | :lock: UNPARAMETERIZED |
| `sql1_185_5.cfm` | the,with | :warning: No | :lock: UNPARAMETERIZED |
| `t_365_4.cfm` | events,the | :warning: No |  |
| `updateContact_72_2.cfm` | contact,contactdetails | :warning: No | :lock: UNPARAMETERIZED |
| `update_266_2.cfm` | based | :white_check_mark: | :lock: UNPARAMETERIZED |
| `update_311_2.cfm` | based,statement | :white_check_mark: | :lock: UNPARAMETERIZED |
| `update_550_4.cfm` | based,resultsquery,the | :warning: No |  |
| `update_552_1.cfm` | actionusers_tbl,the | :white_check_mark: |  |
| `update_553_1.cfm` | actionusers_tbl,the | :white_check_mark: |  |
| `updatenote_177_1.cfm` | based,noteslog,the,with | :white_check_mark: |  |
| `updatesystem_70_4.cfm` | based,funotifications | :warning: No | :lock: UNPARAMETERIZED |
| `updatesystem_70_5.cfm` | fusystemusers,the,to | :warning: No | :lock: UNPARAMETERIZED |
| `updatesystem_72_4.cfm` | based,funotifications | :warning: No | :lock: UNPARAMETERIZED |
| `updatesystem_72_5.cfm` | fusystemusers,the,to | :warning: No | :lock: UNPARAMETERIZED |

### DELETE Files (6)

| File | Tables | Parameterized? | Security |
|------|--------|----------------|----------|
| `dashboardupdate2.cfm` | the | :warning: No |  |
| `delete_233_1.cfm` |  | :warning: No |  |
| `delete_287_15.cfm` | audvocaltypes_audition_xref,based,the | :warning: No | :lock: UNPARAMETERIZED |
| `delete_287_5.cfm` | audessences_audtion_xref,based,the | :white_check_mark: |  |
| `delete_ref_368_4.cfm` |  | :warning: No |  |
| `ins_253_1.cfm` | audmedia_auditions_xref,based,the | :warning: No | :lock: UNPARAMETERIZED |

### UNKNOWN Files (1074)

| File | Tables | Parameterized? | Security |
|------|--------|----------------|----------|
| `AUDintoEVENTS.cfm` |  | :warning: No |  |
| `AddExport_115_1.cfm` |  | :warning: No |  |
| `Audplatforms_user_sel_396_1.cfm` |  | :warning: No |  |
| `BatchDetails_304_1.cfm` |  | :warning: No |  |
| `Booked_check_29_8.cfm` |  | :warning: No |  |
| `CLEAN_169_2.cfm` |  | :warning: No |  |
| `C_318_2.cfm` |  | :warning: No |  |
| `C_73_2.cfm` |  | :warning: No |  |
| `CompleteTargetSystems_157_4.cfm` |  | :warning: No |  |
| `DeleteNote_4_2.cfm` |  | :warning: No |  |
| `DeleteNote_4_4.cfm` |  | :warning: No |  |
| `FINDK_159_4.cfm` |  | :warning: No |  |
| `FIND_14_5.cfm` |  | :warning: No |  |
| `FIND_18_3.cfm` |  | :warning: No |  |
| `FIND_28_10.cfm` |  | :warning: No |  |
| `FIND_318_4.cfm` |  | :warning: No |  |
| `FINDz_159_6.cfm` |  | :warning: No |  |
| `FInd_374_2.cfm` |  | :warning: No |  |
| `FindActive_304_4.cfm` |  | :warning: No |  |
| `FindDetails_107_2.cfm` |  | :warning: No |  |
| `FindDetails_284_1.cfm` |  | :warning: No |  |
| `FindEvent_222_4.cfm` |  | :warning: No |  |
| `FindFields_188_7.cfm` |  | :warning: No |  |
| `FindJoins_466_3.cfm` |  | :warning: No |  |
| `FindJoins_526_3.cfm` |  | :warning: No |  |
| `FindJoins_550_3.cfm` |  | :warning: No |  |
| `FindKey_185_3.cfm` |  | :warning: No |  |
| `FindKey_228_1.cfm` |  | :warning: No |  |
| `FindKey_466_1.cfm` |  | :warning: No |  |
| `FindLinksB.cfm` |  | :warning: No |  |
| `FindLinksB_188_9.cfm` |  | :warning: No |  |
| `FindLinksExtra_188_10.cfm` |  | :warning: No |  |
| `FindLinksT_188_8.cfm` |  | :warning: No |  |
| `FindModalTitle_107_3.cfm` |  | :warning: No |  |
| `FindPage_188_6.cfm` |  | :warning: No |  |
| `FindRefPage_135_1.cfm` |  | :warning: No |  |
| `FindRefcontacts_135_2.cfm` |  | :warning: No |  |
| `FindResults_185_2.cfm` |  | :warning: No |  |
| `FindResults_466_2.cfm` |  | :warning: No |  |
| `FindResults_526_2.cfm` |  | :warning: No |  |
| `FindResults_550_2.cfm` |  | :warning: No |  |
| `FindScope_304_2.cfm` |  | :warning: No |  |
| `FindSystemOld_294_7.cfm` |  | :warning: No |  |
| `FindSystem_294_6.cfm` |  | :warning: No |  |
| `FindSystem_304_3.cfm` |  | :warning: No |  |
| `FindUser_188_1.cfm` |  | :warning: No |  |
| `FindUser_188_5.cfm` |  | :warning: No |  |
| `FindUser_538_1.cfm` |  | :warning: No |  |
| `FindUser_539_1.cfm` |  | :warning: No |  |
| `Find_114_1.cfm` |  | :warning: No |  |
| `Find_159_12.cfm` |  | :warning: No |  |
| `Findchild_107_1.cfm` |  | :warning: No |  |
| `Finddetails_185_1.cfm` |  | :warning: No |  |
| `Finddetails_266_4.cfm` |  | :warning: No |  |
| `Findemail_167_3.cfm` |  | :warning: No |  |
| `Findemail_48_3.cfm` |  | :warning: No |  |
| `Findit_282_7.cfm` |  | :warning: No |  |
| `Findphone_167_2.cfm` |  | :warning: No |  |
| `Findphone_48_2.cfm` |  | :warning: No |  |
| `Findtotal_249_4.cfm` |  | :warning: No |  |
| `Findtotal_318_9.cfm` |  | :warning: No |  |
| `INSERT_22_1.cfm` |  | :warning: No |  |
| `INSERT_266_3.cfm` |  | :warning: No |  |
| `INSERT_316_1.cfm` |  | :warning: No |  |
| `INScontactdetails.cfm` | the | :warning: No |  |
| `InsertContact_188_2.cfm` |  | :warning: No |  |
| `InsertContact_188_3.cfm` |  | :warning: No |  |
| `InsertContact_188_4.cfm` |  | :warning: No |  |
| `InsertNote_14_8.cfm` |  | :warning: No |  |
| `InsertNote_169_1.cfm` |  | :warning: No |  |
| `InsertNote_171_1.cfm` |  | :warning: No |  |
| `InsertNote_173_1.cfm` |  | :warning: No |  |
| `InsertNote_294_8.cfm` |  | :warning: No |  |
| `InsertNote_308_22.cfm` |  | :warning: No |  |
| `InsertNote_315_8.cfm` |  | :warning: No |  |
| `InsertNote_4_1.cfm` |  | :warning: No |  |
| `Insert_157_6.cfm` |  | :warning: No |  |
| `Insert_159_13.cfm` |  | :warning: No |  |
| `Insert_213_1.cfm` |  | :warning: No |  |
| `Insert_71_8.cfm` |  | :warning: No |  |
| `Insert_72_8.cfm` |  | :warning: No |  |
| `Insert_ReportItems_146_2.cfm` |  | :warning: No |  |
| `Insert_ReportItems_282_6.cfm` |  | :warning: No |  |
| `NotesAud.cfm` |  | :warning: No |  |
| `Pin_check_29_7.cfm` |  | :warning: No |  |
| `RPGAdd_288_5.cfm` |  | :warning: No |  |
| `RPGFields_288_2.cfm` |  | :warning: No |  |
| `RPGResults_288_3.cfm` |  | :warning: No |  |
| `RPGUpdate_288_6.cfm` |  | :warning: No |  |
| `RPG_288_1.cfm` |  | :warning: No |  |
| `RPGkey_288_4.cfm` |  | :warning: No |  |
| `Redirect_check_29_6.cfm` |  | :warning: No |  |
| `SEL_Media_types_material.cfm` |  | :warning: No |  |
| `SELaudnoteslog.cfm` |  | :warning: No |  |
| `SELnoteslog.cfm` |  | :warning: No |  |
| `SystemsActiveContact.cfm` |  | :warning: No |  |
| `SystemsContact.cfm` | the | :warning: No |  |
| `Systems_540_1.cfm` |  | :warning: No |  |
| `TagsContact_541_1.cfm` |  | :warning: No |  |
| `Type_208_1.cfm` |  | :warning: No |  |
| `U_73_1.cfm` |  | :warning: No |  |
| `account_info.cfm` |  | :warning: No |  |
| `action_user_295_2.cfm` |  | :warning: No |  |
| `action_user_del_295_3.cfm` |  | :warning: No |  |
| `actiondetails_194_1.cfm` |  | :warning: No |  |
| `actions_159_2.cfm` |  | :warning: No |  |
| `activate_222_3.cfm` |  | :warning: No |  |
| `addActionUsers.cfm` |  | :warning: No |  |
| `addDaysNo_157_7.cfm` |  | :warning: No |  |
| `addDaysNo_315_35.cfm` |  | :warning: No |  |
| `addDaysNo_5_2.cfm` |  | :warning: No |  |
| `addMembers.cfm` |  | :warning: No |  |
| `addNotification.cfm` |  | :warning: No |  |
| `addNotification_157_10.cfm` |  | :warning: No |  |
| `addNotification_157_9.cfm` |  | :warning: No |  |
| `addNotification_315_37.cfm` |  | :warning: No |  |
| `addNotification_315_38.cfm` |  | :warning: No |  |
| `addNotification_326_1.cfm` |  | :warning: No |  |
| `addNotification_5_4.cfm` |  | :warning: No |  |
| `addNotification_71_1.cfm` |  | :warning: No |  |
| `addNotification_71_3.cfm` |  | :warning: No |  |
| `addNotification_72_1.cfm` |  | :warning: No |  |
| `addNotification_placeholder.cfm` |  | :warning: No |  |
| `addNotifications.cfm` |  | :warning: No |  |
| `addSystem.cfm` |  | :warning: No |  |
| `addSystem_157_3.cfm` |  | :warning: No |  |
| `addSystem_315_34.cfm` |  | :warning: No |  |
| `addSystem_327_1.cfm` |  | :warning: No |  |
| `addTeam.cfm` |  | :warning: No |  |
| `add_149_1.cfm` |  | :warning: No |  |
| `add_14_1.cfm` |  | :warning: No |  |
| `add_14_6.cfm` |  | :warning: No |  |
| `add_197_3.cfm` |  | :warning: No |  |
| `add_199_3.cfm` |  | :warning: No |  |
| `add_201_1.cfm` |  | :warning: No |  |
| `add_202_1.cfm` |  | :warning: No |  |
| `add_211_1.cfm` |  | :warning: No |  |
| `add_240_1.cfm` |  | :warning: No |  |
| `add_242_2.cfm` |  | :warning: No |  |
| `add_249_5.cfm` |  | :warning: No |  |
| `add_249_6.cfm` |  | :warning: No |  |
| `add_257_1.cfm` |  | :warning: No |  |
| `add_270_3.cfm` |  | :warning: No |  |
| `add_287_20.cfm` |  | :warning: No |  |
| `add_287_23.cfm` |  | :warning: No |  |
| `add_28_4.cfm` | the | :warning: No |  |
| `add_315_6.cfm` | submitted | :warning: No |  |
| `add_318_10.cfm` |  | :warning: No |  |
| `add_365_3.cfm` |  | :warning: No |  |
| `add_367_4.cfm` |  | :warning: No |  |
| `add_383_3.cfm` |  | :warning: No |  |
| `add_82_1.cfm` |  | :warning: No |  |
| `add_cd_202_7.cfm` |  | :warning: No |  |
| `add_cd_28_12.cfm` |  | :warning: No |  |
| `add_cd_368_10.cfm` |  | :warning: No |  |
| `add_sitetype_205_1.cfm` |  | :warning: No |  |
| `add_sitetype_249_2.cfm` |  | :warning: No |  |
| `addfuSystemUsers.cfm` |  | :warning: No |  |
| `addmissing_33_3.cfm` |  | :warning: No |  |
| `address_315_30.cfm` |  | :warning: No |  |
| `address_insert_315_31.cfm` |  | :warning: No |  |
| `admin-support-details.cfm` |  | :warning: No |  |
| `admin-support-update.cfm` | pageservice,userservice,various,versionsservice | :warning: No |  |
| `admin-update-log.cfm` |  | :warning: No |  |
| `ageranges_sel.cfm` |  | :warning: No |  |
| `allfields_536_2.cfm` |  | :warning: No |  |
| `appoint-add.cfm` |  | :warning: No |  |
| `appoint-info.cfm` |  | :warning: No |  |
| `appoint-update.cfm` |  | :warning: No |  |
| `appoint.cfm` |  | :warning: No |  |
| `attachdetails_109_1.cfm` |  | :warning: No |  |
| `attachdetails_25_1.cfm` |  | :warning: No |  |
| `attachments_181_2.cfm` |  | :warning: No |  |
| `attendees_334_5.cfm` |  | :warning: No |  |
| `attendees_336_5.cfm` |  | :warning: No |  |
| `aud_det.cfm` |  | :warning: No |  |
| `aud_det_221_9.cfm` |  | :warning: No |  |
| `aud_det_440_1.cfm` |  | :warning: No |  |
| `aud_details_217_1.cfm` |  | :warning: No |  |
| `aud_details_219_1.cfm` |  | :warning: No |  |
| `aud_questions.cfm` |  | :warning: No |  |
| `audageranges_audtion_xref_368_11.cfm` |  | :warning: No |  |
| `audageranges_audtion_xref_ins.cfm` |  | :warning: No |  |
| `audageranges_audtion_xref_ins_337_1.cfm` |  | :warning: No |  |
| `audageranges_audtion_xref_ins_338_1.cfm` |  | :warning: No |  |
| `audageranges_audtion_xref_upd.cfm` |  | :warning: No |  |
| `audageranges_ins.cfm` |  | :warning: No |  |
| `audageranges_ins_339_1.cfm` |  | :warning: No |  |
| `audageranges_ins_341_1.cfm` |  | :warning: No |  |
| `audageranges_upd.cfm` |  | :warning: No |  |
| `audanswers_ins.cfm` |  | :warning: No |  |
| `audanswers_ins_215_1.cfm` |  | :warning: No |  |
| `audanswers_ins_342_1.cfm` |  | :warning: No |  |
| `audanswers_ins_343_1.cfm` |  | :warning: No |  |
| `audanswers_upd.cfm` |  | :warning: No |  |
| `audbooktypes_sel_221_13.cfm` |  | :warning: No |  |
| `audcallbacktypes_sel.cfm` |  | :warning: No |  |
| `audcallbacktypes_sel_344_1.cfm` |  | :warning: No |  |
| `audcallbacktypes_sel_def_344_2.cfm` |  | :warning: No |  |
| `audcategories_ins.cfm` |  | :warning: No |  |
| `audcategories_ins_345_1.cfm` |  | :warning: No |  |
| `audcategories_ins_347_1.cfm` |  | :warning: No |  |
| `audcategories_sel.cfm` | name | :warning: No |  |
| `audcategories_upd.cfm` |  | :warning: No |  |
| `audcontacts.cfm` |  | :warning: No |  |
| `audcontacts_auditions_xref_ins.cfm` |  | :warning: No |  |
| `audcontacts_auditions_xref_ins_350_1.cfm` |  | :warning: No |  |
| `audcontacts_auditions_xref_ins_351_1.cfm` |  | :warning: No |  |
| `audcontacts_auditions_xref_upd.cfm` |  | :warning: No |  |
| `audcontacts_sel_349_2.cfm` |  | :warning: No |  |
| `audcontracttypes_ins.cfm` |  | :warning: No |  |
| `audcontracttypes_ins_352_1.cfm` |  | :warning: No |  |
| `audcontracttypes_ins_354_1.cfm` |  | :warning: No |  |
| `audcontracttypes_sel.cfm` |  | :warning: No |  |
| `audcontracttypes_upd.cfm` |  | :warning: No |  |
| `auddialects_ins.cfm` |  | :warning: No |  |
| `auddialects_ins_355_1.cfm` |  | :warning: No |  |
| `auddialects_ins_357_1.cfm` |  | :warning: No |  |
| `auddialects_sel.cfm` |  | :warning: No |  |
| `auddialects_upd.cfm` |  | :warning: No |  |
| `auddialects_user_sel_358_1.cfm` |  | :warning: No |  |
| `audessences_audtion_xref_49_1.cfm` |  | :warning: No |  |
| `audgenres_audition_xref.cfm` |  | :warning: No |  |
| `audgenres_audition_xref_359_1.cfm` |  | :warning: No |  |
| `audgenres_audition_xref_ins.cfm` |  | :warning: No |  |
| `audgenres_audition_xref_ins_360_1.cfm` |  | :warning: No |  |
| `audgenres_audition_xref_ins_361_1.cfm` |  | :warning: No |  |
| `audgenres_audition_xref_upd.cfm` |  | :warning: No |  |
| `audgenres_ins.cfm` |  | :warning: No |  |
| `audgenres_sel.cfm` |  | :warning: No |  |
| `audgenres_upd.cfm` |  | :warning: No |  |
| `audition-add.cfm` |  | :warning: No |  |
| `audition-add2.cfm` |  | :warning: No |  |
| `auditionDetails_222_5.cfm` |  | :warning: No |  |
| `auditionDetails_29_3.cfm` |  | :warning: No |  |
| `auditionDetails_369_1.cfm` |  | :warning: No |  |
| `auditiondetails.cfm` |  | :warning: No |  |
| `auditionprojectDetails_370_1.cfm` |  | :warning: No |  |
| `auditionprojectDetails_66_1.cfm` |  | :warning: No |  |
| `auditionprojectdetails.cfm` |  | :warning: No |  |
| `auditions.cfm` |  | :warning: No |  |
| `auditions_import.cfm` |  | :warning: No |  |
| `auditions_ins_221_8.cfm` |  | :warning: No |  |
| `auditions_ins_32_1.cfm` |  | :warning: No |  |
| `auditions_ins_373_1.cfm` |  | :warning: No |  |
| `auditions_ins_374_1.cfm` |  | :warning: No |  |
| `auditionsimport.cfm` |  | :warning: No |  |
| `auditlog.cfm` |  | :warning: No |  |
| `audlink_details_237_1.cfm` |  | :warning: No |  |
| `audlocations_ins_218_1.cfm` |  | :warning: No |  |
| `audlocations_sel.cfm` |  | :warning: No |  |
| `audlocations_sel_376_1.cfm` |  | :warning: No |  |
| `audlocations_upd_37_1.cfm` |  | :warning: No |  |
| `audmedia.cfm` |  | :warning: No |  |
| `audmedia_377_1.cfm` |  | :warning: No |  |
| `audmedia_384_1.cfm` |  | :warning: No |  |
| `audmedia_38_1.cfm` |  | :warning: No |  |
| `audmedia_audroles_xref_ins.cfm` |  | :warning: No |  |
| `audmedia_audroles_xref_ins_381_1.cfm` |  | :warning: No |  |
| `audmedia_audroles_xref_ins_382_1.cfm` |  | :warning: No |  |
| `audmedia_audroles_xref_upd.cfm` |  | :warning: No |  |
| `audmedia_details_225_1.cfm` | the | :warning: No | :lock: UNPARAMETERIZED |
| `audmedia_details_226_1.cfm` |  | :warning: No |  |
| `audmedia_details_238_1.cfm` |  | :warning: No |  |
| `audmedia_headshots_delete.cfm` |  | :warning: No |  |
| `audmedia_ins.cfm` |  | :warning: No |  |
| `audmedia_ins_383_1.cfm` |  | :warning: No |  |
| `audmedia_picklist_385_1.cfm` |  | :warning: No |  |
| `audmedia_upd.cfm` |  | :warning: No |  |
| `audmedia_upd_386_1.cfm` |  | :warning: No |  |
| `audmediatypes_ins.cfm` |  | :warning: No |  |
| `audmediatypes_ins_378_1.cfm` |  | :warning: No |  |
| `audmediatypes_ins_380_1.cfm` |  | :warning: No |  |
| `audmediatypes_upd.cfm` |  | :warning: No |  |
| `audnetworks_ins.cfm` |  | :warning: No |  |
| `audnetworks_ins_387_1.cfm` |  | :warning: No |  |
| `audnetworks_ins_389_1.cfm` |  | :warning: No |  |
| `audnetworks_sel.cfm` |  | :warning: No |  |
| `audnetworks_upd.cfm` |  | :warning: No |  |
| `audnetworks_user_sel.cfm` |  | :warning: No |  |
| `audpaycycles_sel.cfm` |  | :warning: No |  |
| `audpaycycles_sel_391_1.cfm` |  | :warning: No |  |
| `audpaycyles_sel.cfm` |  | :warning: No |  |
| `audpaycyles_sel_392_1.cfm` |  | :warning: No |  |
| `audplatforms_ins.cfm` |  | :warning: No |  |
| `audplatforms_ins_393_1.cfm` |  | :warning: No |  |
| `audplatforms_ins_395_1.cfm` |  | :warning: No |  |
| `audplatforms_upd.cfm` |  | :warning: No |  |
| `audplatforms_user_sel.cfm` |  | :warning: No |  |
| `audprojects_castingabout_ins.cfm` |  | :warning: No |  |
| `audprojects_castingabout_ins_397_1.cfm` |  | :warning: No |  |
| `audprojects_castingabout_ins_398_1.cfm` |  | :warning: No |  |
| `audprojects_castingabout_upd.cfm` |  | :warning: No |  |
| `audprojects_ins.cfm` | the | :warning: No |  |
| `audprojects_ins_308_19.cfm` |  | :warning: No |  |
| `audprojects_ins_399_1.cfm` |  | :warning: No |  |
| `audprojects_ins_401_1.cfm` |  | :warning: No |  |
| `audprojects_ins_67_1.cfm` |  | :warning: No |  |
| `audprojects_sel.cfm` | name | :warning: No |  |
| `audprojects_upd.cfm` |  | :warning: No |  |
| `audqtypes_ins.cfm` |  | :warning: No |  |
| `audqtypes_ins_402_1.cfm` |  | :warning: No |  |
| `audqtypes_ins_404_1.cfm` |  | :warning: No |  |
| `audqtypes_upd.cfm` |  | :warning: No |  |
| `audquestions_default_ins.cfm` | the | :warning: No |  |
| `audquestions_default_ins_405_1.cfm` |  | :warning: No |  |
| `audquestions_default_ins_406_1.cfm` |  | :warning: No |  |
| `audquestions_default_upd.cfm` |  | :warning: No |  |
| `audquestions_user_ins.cfm` |  | :warning: No |  |
| `audquestions_user_ins_407_1.cfm` |  | :warning: No |  |
| `audquestions_user_ins_408_1.cfm` |  | :warning: No |  |
| `audquestions_user_upd.cfm` |  | :warning: No |  |
| `audroles_ins.cfm` |  | :warning: No |  |
| `audroles_ins_308_21.cfm` |  | :warning: No |  |
| `audroles_ins_39_1.cfm` |  | :warning: No |  |
| `audroles_ins_409_1.cfm` |  | :warning: No |  |
| `audroles_ins_411_1.cfm` |  | :warning: No |  |
| `audroles_sel.cfm` |  | :warning: No |  |
| `audroles_upd.cfm` |  | :warning: No |  |
| `audroles_upd_287_25.cfm` |  | :warning: No |  |
| `audroletypes_ins.cfm` |  | :warning: No |  |
| `audroletypes_ins_412_1.cfm` |  | :warning: No |  |
| `audroletypes_ins_414_1.cfm` |  | :warning: No |  |
| `audroletypes_sel.cfm` |  | :warning: No |  |
| `audroletypes_sel_27_2.cfm` |  | :warning: No |  |
| `audroletypes_upd.cfm` |  | :warning: No |  |
| `auds_byrole.cfm` |  | :warning: No |  |
| `audsources_281_1.cfm` |  | :warning: No |  |
| `audsources_ins.cfm` |  | :warning: No |  |
| `audsources_ins_415_1.cfm` |  | :warning: No |  |
| `audsources_ins_417_1.cfm` |  | :warning: No |  |
| `audsources_sel.cfm` |  | :warning: No |  |
| `audsources_sel_499_2.cfm` |  | :warning: No |  |
| `audsources_upd.cfm` |  | :warning: No |  |
| `audsteps_ins.cfm` |  | :warning: No |  |
| `audsteps_ins_418_1.cfm` |  | :warning: No |  |
| `audsteps_ins_420_1.cfm` |  | :warning: No |  |
| `audsteps_sel_217_3.cfm` |  | :warning: No |  |
| `audsteps_sel_31_2.cfm` |  | :warning: No |  |
| `audsteps_upd.cfm` |  | :warning: No |  |
| `audsubcategories_ins.cfm` |  | :warning: No |  |
| `audsubcategories_ins_421_1.cfm` |  | :warning: No |  |
| `audsubcategories_ins_423_1.cfm` |  | :warning: No |  |
| `audsubcategories_sel.cfm` |  | :warning: No |  |
| `audtones_ins_425_1.cfm` |  | :warning: No |  |
| `audtones_ins_427_1.cfm` |  | :warning: No |  |
| `audtones_sel.cfm` |  | :warning: No |  |
| `audtones_user_sel.cfm` | the | :warning: No |  |
| `audtones_user_sel_428_1.cfm` |  | :warning: No |  |
| `audtypes_ins_429_1.cfm` |  | :warning: No |  |
| `audtypes_ins_431_1.cfm` |  | :warning: No |  |
| `audtypes_sel_217_2.cfm` |  | :warning: No |  |
| `audtypes_sel_221_11.cfm` |  | :warning: No |  |
| `audtypes_sel_27_3.cfm` |  | :warning: No |  |
| `audtypes_sel_31_3.cfm` |  | :warning: No |  |
| `audtypes_sel_430_1.cfm` |  | :warning: No |  |
| `audunions_ins_432_1.cfm` |  | :warning: No |  |
| `audunions_ins_434_1.cfm` |  | :warning: No |  |
| `audunions_sel_40_1.cfm` |  | :warning: No |  |
| `audvocaltypes_audition_xref.cfm` |  | :warning: No |  |
| `audvocaltypes_audition_xref_ins_435_1.cfm` |  | :warning: No |  |
| `audvocaltypes_audition_xref_ins_436_1.cfm` |  | :warning: No |  |
| `audvocaltypes_ins_437_1.cfm` |  | :warning: No |  |
| `audvocaltypes_ins_439_1.cfm` |  | :warning: No |  |
| `birthdays.cfm` |  | :warning: No |  |
| `birthdays_442_1.cfm` |  | :warning: No |  |
| `book_det_57_1.cfm` |  | :warning: No |  |
| `bro_add_53_1.cfm` |  | :warning: No |  |
| `c_83_2.cfm` |  | :warning: No |  |
| `calendar-appoint.cfm` |  | :warning: No |  |
| `callback_check_29_5.cfm` |  | :warning: No |  |
| `casting_types_27_4.cfm` |  | :warning: No |  |
| `castingdirectors_sel_445_1.cfm` |  | :warning: No |  |
| `cat_27_1.cfm` |  | :warning: No |  |
| `categories.cfm` | the | :warning: No |  |
| `categories_446_1.cfm` |  | :warning: No |  |
| `categories_524_11.cfm` |  | :warning: No |  |
| `cats_529_2.cfm` |  | :warning: No |  |
| `cdcheck_368_9.cfm` |  | :warning: No |  |
| `cds_31_4.cfm` |  | :warning: No |  |
| `checkUniqueContact.cfm` |  | :warning: No |  |
| `checkUnique_157_8.cfm` |  | :warning: No |  |
| `checkUnique_315_36.cfm` |  | :warning: No |  |
| `checkUnique_5_3.cfm` |  | :warning: No |  |
| `check_318_36.cfm` |  | :warning: No |  |
| `checkformaint_71_6.cfm` |  | :warning: No |  |
| `cities.cfm` | the | :warning: No |  |
| `cities_448_1.cfm` |  | :warning: No |  |
| `close2_294_5.cfm` |  | :warning: No |  |
| `close_294_4.cfm` |  | :warning: No |  |
| `companies_198_4.cfm` |  | :warning: No |  |
| `companies_203_3.cfm` |  | :warning: No |  |
| `contact.cfm` |  | :warning: No |  |
| `contacts.cfm` | the | :warning: No |  |
| `contacts_333_1.cfm` |  | :warning: No |  |
| `contacts_all.cfm` | the | :warning: No |  |
| `contacts_all_tabs.cfm` | the | :warning: No |  |
| `contacts_check.cfm` |  | :warning: No |  |
| `correct_191_10.cfm` |  | :warning: No |  |
| `cos_31_5.cfm` |  | :warning: No |  |
| `coss_371_1.cfm` |  | :warning: No |  |
| `cu_83_1.cfm` |  | :warning: No |  |
| `d_18_2.cfm` |  | :warning: No |  |
| `d_298_8.cfm` |  | :warning: No |  |
| `dash_rr.cfm` |  | :warning: No |  |
| `dashboard.cfm` |  | :warning: No |  |
| `dashboard_new.cfm` |  | :warning: No |  |
| `dashboardoptions.cfm` | the | :warning: No |  |
| `dashboards_458_1.cfm` |  | :warning: No |  |
| `dashboards_459_1.cfm` |  | :warning: No |  |
| `dashboardzz_93_1.cfm` |  | :warning: No |  |
| `dataset_x_281_4.cfm` |  | :warning: No |  |
| `dateformats.cfm` | the | :warning: No |  |
| `dd_14_4.cfm` |  | :warning: No |  |
| `de_283_3.cfm` |  | :warning: No |  |
| `del2_230_2.cfm` |  | :warning: No |  |
| `del2_232_5.cfm` |  | :warning: No |  |
| `del3_232_6.cfm` |  | :warning: No |  |
| `del4_232_7.cfm` |  | :warning: No |  |
| `delSystemNotifications.cfm` |  | :warning: No |  |
| `del_159_10.cfm` |  | :warning: No |  |
| `del_159_11.cfm` |  | :warning: No |  |
| `del_191_1.cfm` |  | :warning: No |  |
| `del_230_1.cfm` |  | :warning: No |  |
| `del_232_4.cfm` |  | :warning: No |  |
| `del_233_2.cfm` |  | :warning: No |  |
| `del_25_2.cfm` |  | :warning: No |  |
| `del_277_4.cfm` |  | :warning: No |  |
| `del_460_1.cfm` |  | :warning: No |  |
| `del_465_1.cfm` |  | :warning: No |  |
| `del_99_1.cfm` |  | :warning: No |  |
| `delete2_368_8.cfm` |  | :warning: No |  |
| `deleteNotificationBySystem.cfm` |  | :warning: No |  |
| `deleteTeam.cfm` |  | :warning: No |  |
| `delete_102_1.cfm` |  | :warning: No |  |
| `delete_15_1.cfm` |  | :warning: No |  |
| `delete_191_8.cfm` |  | :warning: No |  |
| `delete_287_1.cfm` |  | :warning: No |  |
| `delete_287_2.cfm` |  | :warning: No |  |
| `delete_287_3.cfm` |  | :warning: No |  |
| `delete_287_4.cfm` |  | :warning: No |  |
| `delete_298_1.cfm` |  | :warning: No |  |
| `delete_304_6.cfm` |  | :warning: No |  |
| `delete_368_7.cfm` |  | :warning: No |  |
| `delete_all_282_1.cfm` |  | :warning: No |  |
| `delete_team.cfm` |  | :warning: No |  |
| `deletelink_150_2.cfm` |  | :warning: No |  |
| `deletenote_103_1.cfm` |  | :warning: No |  |
| `deletesystem_104_2.cfm` |  | :warning: No |  |
| `deleteticket_100_1.cfm` |  | :warning: No |  |
| `deleteticket_105_1.cfm` |  | :warning: No |  |
| `details_106_1.cfm` |  | :warning: No |  |
| `details_198_1.cfm` |  | :warning: No |  |
| `details_212_1.cfm` |  | :warning: No |  |
| `details_223_1.cfm` |  | :warning: No |  |
| `details_229_1.cfm` |  | :warning: No |  |
| `details_257_3.cfm` |  | :warning: No |  |
| `details_259_1.cfm` |  | :warning: No |  |
| `details_261_1.cfm` |  | :warning: No |  |
| `details_263_1.cfm` |  | :warning: No |  |
| `details_269_3.cfm` |  | :warning: No |  |
| `details_274_1.cfm` |  | :warning: No |  |
| `details_275_2.cfm` |  | :warning: No |  |
| `details_303_3.cfm` |  | :warning: No |  |
| `details_312_2.cfm` |  | :warning: No |  |
| `details_456_1.cfm` |  | :warning: No |  |
| `details_466_4.cfm` | a | :warning: No |  |
| `details_484_1.cfm` |  | :warning: No |  |
| `details_500_1.cfm` |  | :warning: No |  |
| `details_521_1.cfm` |  | :warning: No |  |
| `details_543_2.cfm` |  | :warning: No |  |
| `details_555_1.cfm` |  | :warning: No |  |
| `details_556_1.cfm` |  | :warning: No |  |
| `duration.cfm` |  | :warning: No |  |
| `duration_467_1.cfm` |  | :warning: No |  |
| `durations_468_1.cfm` |  | :warning: No |  |
| `e_315_16.cfm` |  | :warning: No |  |
| `e_insert_315_17.cfm` |  | :warning: No |  |
| `emailcheck.cfm` | the | :warning: No |  |
| `emailcheck_469_1.cfm` |  | :warning: No |  |
| `err_308_3.cfm` |  | :warning: No |  |
| `err_308_4.cfm` |  | :warning: No |  |
| `err_308_5.cfm` |  | :warning: No |  |
| `err_308_7.cfm` |  | :warning: No |  |
| `err_308_9.cfm` |  | :warning: No |  |
| `essence_sel_470_1.cfm` |  | :warning: No |  |
| `essences_286_10.cfm` |  | :warning: No |  |
| `eventdetails_335_3.cfm` |  | :warning: No |  |
| `eventresults.cfm` |  | :warning: No |  |
| `eventresults_471_1.cfm` |  | :warning: No |  |
| `events.cfm` | the | :warning: No |  |
| `events_166_1.cfm` |  | :warning: No |  |
| `events_203_1.cfm` |  | :warning: No |  |
| `events_232_3.cfm` |  | :warning: No |  |
| `events_368_5.cfm` |  | :warning: No |  |
| `events_424_1.cfm` |  | :warning: No |  |
| `events_472_1.cfm` |  | :warning: No |  |
| `events_501_1.cfm` |  | :warning: No |  |
| `events_505_1.cfm` |  | :warning: No |  |
| `events_nobooking_368_6.cfm` |  | :warning: No |  |
| `eventss_443_1.cfm` |  | :warning: No |  |
| `eventtypes_user.cfm` | the | :warning: No |  |
| `eventtypes_user_443_2.cfm` |  | :warning: No |  |
| `eventtypes_user_473_1.cfm` |  | :warning: No |  |
| `export_ac_115_15.cfm` |  | :warning: No |  |
| `export_ac_31_6.cfm` |  | :warning: No |  |
| `f_315_18.cfm` |  | :warning: No |  |
| `f_insert_315_19.cfm` |  | :warning: No |  |
| `fetchContactItems.cfm` | the | :warning: No |  |
| `fetchLocationService.cfm` |  | :warning: No |  |
| `fetchUsers.cfm` |  | :warning: No |  |
| `fetch_folowup.cfm` |  | :warning: No |  |
| `fin_recordname_157_1.cfm` |  | :warning: No |  |
| `finall_20_1.cfm` |  | :warning: No |  |
| `find2_318_17.cfm` |  | :warning: No |  |
| `findLinksT.cfm` |  | :warning: No |  |
| `findSubCatId_316_2.cfm` |  | :warning: No |  |
| `findSystemByScope.cfm` |  | :warning: No |  |
| `findSystem_71_7.cfm` |  | :warning: No |  |
| `findUserById.cfm` |  | :warning: No |  |
| `find_150_1.cfm` |  | :warning: No |  |
| `find_197_1.cfm` |  | :warning: No |  |
| `find_212_3.cfm` |  | :warning: No |  |
| `find_242_1.cfm` |  | :warning: No |  |
| `find_246_1.cfm` |  | :warning: No |  |
| `find_249_1.cfm` |  | :warning: No |  |
| `find_270_2.cfm` |  | :warning: No |  |
| `find_283_6.cfm` |  | :warning: No |  |
| `find_292_5.cfm` |  | :warning: No |  |
| `find_298_2.cfm` |  | :warning: No |  |
| `find_303_1.cfm` |  | :warning: No |  |
| `find_308_2.cfm` |  | :warning: No |  |
| `find_313_1.cfm` |  | :warning: No |  |
| `find_315_2.cfm` |  | :warning: No |  |
| `find_315_4.cfm` |  | :warning: No |  |
| `find_316_3.cfm` |  | :warning: No |  |
| `find_317_1.cfm` |  | :warning: No |  |
| `find_318_13.cfm` |  | :warning: No |  |
| `find_318_16.cfm` |  | :warning: No |  |
| `find_318_20.cfm` |  | :warning: No |  |
| `find_318_26.cfm` |  | :warning: No |  |
| `find_318_32.cfm` |  | :warning: No |  |
| `find_318_35.cfm` |  | :warning: No |  |
| `find_318_7.cfm` |  | :warning: No |  |
| `find_320_1.cfm` |  | :warning: No |  |
| `find_383_2.cfm` |  | :warning: No |  |
| `find_524_4.cfm` |  | :warning: No |  |
| `find_cat_308_17.cfm` |  | :warning: No |  |
| `find_d_104_1.cfm` |  | :warning: No |  |
| `find_events_309_2.cfm` |  | :warning: No |  |
| `find_fu_157_2.cfm` |  | :warning: No |  |
| `find_new_277_3.cfm` |  | :warning: No |  |
| `find_new_BusinessEmail_115_4.cfm` |  | :warning: No |  |
| `find_new_Company_115_6.cfm` |  | :warning: No |  |
| `find_new_PersonalEmail_115_5.cfm` |  | :warning: No |  |
| `find_new_Website_115_3.cfm` |  | :warning: No |  |
| `find_new_WorkPhone_115_7.cfm` |  | :warning: No |  |
| `find_new_address_115_10.cfm` |  | :warning: No |  |
| `find_new_address_other_115_11.cfm` |  | :warning: No |  |
| `find_new_homePhone_115_9.cfm` |  | :warning: No |  |
| `find_new_mobilePhone_115_8.cfm` |  | :warning: No |  |
| `find_new_tag_115_12.cfm` |  | :warning: No |  |
| `find_note_315_7.cfm` |  | :warning: No |  |
| `find_orphan_298_7.cfm` |  | :warning: No |  |
| `find_source_308_20.cfm` |  | :warning: No |  |
| `find_subcat_308_16.cfm` |  | :warning: No |  |
| `find_subcat_308_18.cfm` |  | :warning: No |  |
| `find_subsite_287_21.cfm` |  | :warning: No |  |
| `find_typesmediatypeid_42_2.cfm` |  | :warning: No |  |
| `findc_286_2.cfm` |  | :warning: No |  |
| `findc_286_4.cfm` |  | :warning: No |  |
| `findcat_308_6.cfm` |  | :warning: No |  |
| `findcd_308_13.cfm` |  | :warning: No |  |
| `findcompany.cfm` | the | :warning: No |  |
| `findcompany_476_1.cfm` |  | :warning: No |  |
| `findcountry_199_4.cfm` |  | :warning: No |  |
| `findcountry_261_2.cfm` |  | :warning: No |  |
| `findcountry_521_2.cfm` |  | :warning: No |  |
| `findd_221_10.cfm` |  | :warning: No |  |
| `findd_335_4.cfm` |  | :warning: No |  |
| `findg_286_11.cfm` |  | :warning: No |  |
| `findg_287_19.cfm` |  | :warning: No |  |
| `findge_286_14.cfm` |  | :warning: No |  |
| `findid_146_1.cfm` |  | :warning: No |  |
| `findid_282_5.cfm` |  | :warning: No |  |
| `findit2_287_6.cfm` |  | :warning: No |  |
| `findit_249_3.cfm` |  | :warning: No |  |
| `findit_278_1.cfm` |  | :warning: No |  |
| `findit_286_12.cfm` |  | :warning: No |  |
| `findit_287_11.cfm` |  | :warning: No |  |
| `findit_287_8.cfm` |  | :warning: No |  |
| `findit_49_2.cfm` |  | :warning: No |  |
| `finditems_524_6.cfm` |  | :warning: No |  |
| `findloc_365_2.cfm` |  | :warning: No |  |
| `findnumber_202_8.cfm` |  | :warning: No |  |
| `findp_292_4.cfm` |  | :warning: No |  |
| `findproject_218_2.cfm` |  | :warning: No |  |
| `findregion_199_5.cfm` |  | :warning: No |  |
| `findregion_261_3.cfm` |  | :warning: No |  |
| `findregion_262_4.cfm` |  | :warning: No |  |
| `findregion_521_3.cfm` |  | :warning: No |  |
| `findsame_304_5.cfm` |  | :warning: No |  |
| `findsame_305_2.cfm` |  | :warning: No |  |
| `findscope.cfm` |  | :warning: No |  |
| `findscope_539_2.cfm` |  | :warning: No |  |
| `findscope_old_294_2.cfm` |  | :warning: No |  |
| `findsource_308_8.cfm` |  | :warning: No |  |
| `findstep_29_4.cfm` |  | :warning: No |  |
| `findsubs_259_3.cfm` |  | :warning: No |  |
| `findsystem_315_33.cfm` |  | :warning: No |  |
| `findt_272_2.cfm` |  | :warning: No |  |
| `findt_286_7.cfm` |  | :warning: No |  |
| `findt_286_9.cfm` |  | :warning: No |  |
| `findtag_97_1.cfm` |  | :warning: No |  |
| `findtype_365_1.cfm` |  | :warning: No |  |
| `fix_191_9.cfm` |  | :warning: No |  |
| `followups_33_2.cfm` |  | :warning: No |  |
| `folowup_body.cfm` |  | :warning: No |  |
| `fu_actions.cfm` | the | :warning: No |  |
| `g_315_20.cfm` |  | :warning: No |  |
| `g_insert_315_21.cfm` |  | :warning: No |  |
| `genres_286_13.cfm` |  | :warning: No |  |
| `getActionUsers.cfm` |  | :warning: No |  |
| `getActiveTaoVersions.cfm` |  | :warning: No |  |
| `getActiveVersions.cfm` |  | :warning: No |  |
| `getAllCountries.cfm` |  | :warning: No |  |
| `getAllDateFormats.cfm` |  | :warning: No |  |
| `getAllRegions.cfm` |  | :warning: No |  |
| `getAllTimezones.cfm` |  | :warning: No |  |
| `getAuditionImportErrors.cfm` |  | :warning: No |  |
| `getAuditionImportResults.cfm` |  | :warning: No |  |
| `getAuditionLinks.cfm` |  | :warning: No |  |
| `getAuditionMaterials.cfm` |  | :warning: No |  |
| `getAuditionMediaPicklist.cfm` |  | :warning: No |  |
| `getAuditionMediaTypes.cfm` |  | :warning: No |  |
| `getAuditionUploadDetails.cfm` |  | :warning: No |  |
| `getAuditions.cfm` |  | :warning: No |  |
| `getCategories_132_2.cfm` |  | :warning: No |  |
| `getCategories_196_1.cfm` |  | :warning: No |  |
| `getContactTagStatus.cfm` |  | :warning: No |  |
| `getContactsByAudProject.cfm` |  | :warning: No |  |
| `getContactsImportByUploadID.cfm` |  | :warning: No |  |
| `getFuSystemUsersBySystemID.cfm` |  | :warning: No |  |
| `getLinksByNoteId.cfm` |  | :warning: No |  |
| `getMinimalTimezones.cfm` |  | :warning: No |  |
| `getMyTeam.cfm` |  | :warning: No |  |
| `getNoteDetails.cfm` |  | :warning: No |  |
| `getNotificationByID.cfm` |  | :warning: No |  |
| `getNotificationsBySystem.cfm` |  | :warning: No |  |
| `getOldSystemDetails.cfm` |  | :warning: No |  |
| `getRecord_132_1.cfm` |  | :warning: No |  |
| `getRemindersByRelationship.cfm` |  | :warning: No |  |
| `getSocialIcons.cfm` |  | :warning: No |  |
| `getSources_132_3.cfm` |  | :warning: No |  |
| `getSystemUserByID.cfm` |  | :warning: No |  |
| `getUserDetails.cfm` |  | :warning: No |  |
| `getUsers.cfm` |  | :warning: No |  |
| `h_315_22.cfm` |  | :warning: No |  |
| `h_insert_315_23.cfm` |  | :warning: No |  |
| `headshots_377_2.cfm` |  | :warning: No |  |
| `headshots_sel_478_1.cfm` |  | :warning: No |  |
| `headshots_sel_479_1.cfm` |  | :warning: No |  |
| `headshots_sel_494_1.cfm` |  | :warning: No |  |
| `headshots_sel_495_1.cfm` |  | :warning: No |  |
| `i_315_24.cfm` |  | :warning: No |  |
| `i_insert_315_25.cfm` |  | :warning: No |  |
| `import.cfm` |  | :warning: No |  |
| `imports.cfm` |  | :warning: No |  |
| `imports_140_4.cfm` |  | :warning: No |  |
| `imports_372_1.cfm` |  | :warning: No |  |
| `imports_485_1.cfm` |  | :warning: No |  |
| `incometypes_sel_486_1.cfm` |  | :warning: No |  |
| `ins_252_1.cfm` |  | :warning: No |  |
| `ins_252_2.cfm` |  | :warning: No |  |
| `insert_115_13.cfm` |  | :warning: No |  |
| `insert_159_5.cfm` |  | :warning: No |  |
| `insert_199_1.cfm` |  | :warning: No |  |
| `insert_201_2.cfm` |  | :warning: No |  |
| `insert_201_3.cfm` |  | :warning: No |  |
| `insert_201_4.cfm` |  | :warning: No |  |
| `insert_201_5.cfm` |  | :warning: No |  |
| `insert_202_5.cfm` |  | :warning: No |  |
| `insert_202_6.cfm` |  | :warning: No |  |
| `insert_277_1.cfm` |  | :warning: No |  |
| `insert_277_2.cfm` |  | :warning: No |  |
| `insert_287_10.cfm` |  | :warning: No |  |
| `insert_287_12.cfm` |  | :warning: No |  |
| `insert_287_13.cfm` |  | :warning: No |  |
| `insert_287_16.cfm` |  | :warning: No |  |
| `insert_287_18.cfm` |  | :warning: No |  |
| `insert_287_24.cfm` |  | :warning: No |  |
| `insert_287_7.cfm` |  | :warning: No |  |
| `insert_287_9.cfm` |  | :warning: No |  |
| `insert_28_11.cfm` |  | :warning: No |  |
| `insert_28_2.cfm` |  | :warning: No |  |
| `insert_28_3.cfm` |  | :warning: No |  |
| `insert_298_5.cfm` |  | :warning: No |  |
| `insert_305_3.cfm` |  | :warning: No |  |
| `insert_305_4.cfm` |  | :warning: No |  |
| `insert_318_14.cfm` |  | :warning: No |  |
| `insert_318_18.cfm` |  | :warning: No |  |
| `insert_318_21.cfm` |  | :warning: No |  |
| `insert_318_24.cfm` |  | :warning: No |  |
| `insert_318_27.cfm` |  | :warning: No |  |
| `insert_318_33.cfm` |  | :warning: No |  |
| `insert_318_37.cfm` |  | :warning: No |  |
| `insert_318_5.cfm` |  | :warning: No |  |
| `insert_318_8.cfm` |  | :warning: No |  |
| `insert_320_2.cfm` |  | :warning: No |  |
| `insert_41_1.cfm` |  | :warning: No |  |
| `insert_41_3.cfm` |  | :warning: No |  |
| `insert_460_3.cfm` |  | :warning: No |  |
| `insert_524_5.cfm` |  | :warning: No |  |
| `insert_tag_298_3.cfm` |  | :warning: No |  |
| `inserts_14_7.cfm` |  | :warning: No |  |
| `inserts_18_5.cfm` |  | :warning: No |  |
| `inserts_202_9.cfm` |  | :warning: No |  |
| `inserts_365_7.cfm` |  | :warning: No |  |
| `inserttlog_487_1.cfm` |  | :warning: No |  |
| `insertx_199_2.cfm` |  | :warning: No |  |
| `itemDetails_130_1.cfm` |  | :warning: No |  |
| `items.cfm` | the | :warning: No |  |
| `itemsAll_489_1.cfm` |  | :warning: No |  |
| `items_488_1.cfm` |  | :warning: No |  |
| `itemsbycatActive.cfm` |  | :warning: No |  |
| `itemsbycatActive_490_1.cfm` |  | :warning: No |  |
| `j_315_26.cfm` |  | :warning: No |  |
| `j_insert_315_27.cfm` |  | :warning: No |  |
| `jsons_50_1.cfm` |  | :warning: No |  |
| `jsons_myteam_50_2.cfm` |  | :warning: No |  |
| `jtags_50_3.cfm` |  | :warning: No |  |
| `k_195_2.cfm` |  | :warning: No |  |
| `labels_x_281_5.cfm` |  | :warning: No |  |
| `lastupdates.cfm` |  | :warning: No |  |
| `linkdetails_309_1.cfm` |  | :warning: No |  |
| `linkmedia_152_1.cfm` |  | :warning: No |  |
| `links_181_1.cfm` |  | :warning: No |  |
| `links_182_1.cfm` |  | :warning: No |  |
| `links_183_1.cfm` |  | :warning: No |  |
| `locationDetails.cfm` |  | :warning: No |  |
| `locationDetails_492_1.cfm` |  | :warning: No |  |
| `lookup_contacts.cfm` |  | :warning: No |  |
| `m_318_3.cfm` |  | :warning: No |  |
| `maints_315_32.cfm` |  | :warning: No |  |
| `master_164_4.cfm` |  | :warning: No |  |
| `materials_details.cfm` | the | :warning: No |  |
| `materials_details_493_1.cfm` |  | :warning: No |  |
| `materials_sel.cfm` |  | :warning: No |  |
| `menuItemsA_496_2.cfm` |  | :warning: No |  |
| `menuItemsAud_496_3.cfm` |  | :warning: No |  |
| `menuItemsU_496_1.cfm` |  | :warning: No |  |
| `menuitems.cfm` |  | :warning: No |  |
| `myaccount.cfm` |  | :warning: No |  |
| `mylinks.cfm` |  | :warning: No |  |
| `mylinks_159_1.cfm` |  | :warning: No |  |
| `mylinks_498_1.cfm` |  | :warning: No |  |
| `mylinks_user_164_2.cfm` |  | :warning: No |  |
| `mylinks_user_del_164_3.cfm` |  | :warning: No |  |
| `mysystems_295_1.cfm` |  | :warning: No |  |
| `mytags_167_1.cfm` |  | :warning: No |  |
| `mytags_48_1.cfm` |  | :warning: No |  |
| `myteam.cfm` |  | :warning: No |  |
| `myteam_499_1.cfm` |  | :warning: No |  |
| `new_312_4.cfm` |  | :warning: No |  |
| `note-add-aud.cfm` | the | :warning: No |  |
| `note-add-event.cfm` |  | :warning: No |  |
| `note-add.cfm` |  | :warning: No |  |
| `note-update-aud.cfm` |  | :warning: No |  |
| `note-update-event.cfm` |  | :warning: No |  |
| `note-update.cfm` |  | :warning: No |  |
| `notesContactDetails_180_2.cfm` |  | :warning: No |  |
| `notesContact_507_1.cfm` |  | :warning: No |  |
| `notesEvent.cfm` |  | :warning: No |  |
| `notesEvent_180_1.cfm` |  | :warning: No |  |
| `notesEvent_508_1.cfm` |  | :warning: No |  |
| `notesRelationship_509_1.cfm` |  | :warning: No |  |
| `notes_186_1.cfm` |  | :warning: No |  |
| `notesaud_506_1.cfm` |  | :warning: No |  |
| `notesrelationship.cfm` |  | :warning: No |  |
| `notsActive_510_1.cfm` |  | :warning: No |  |
| `notsActive_511_2.cfm` |  | :warning: No |  |
| `notsActives_458_2.cfm` |  | :warning: No |  |
| `notsActives_461_1.cfm` |  | :warning: No |  |
| `notsInactive_510_2.cfm` |  | :warning: No |  |
| `notsNext_514_1.cfm` |  | :warning: No |  |
| `notsactive.cfm` |  | :warning: No |  |
| `notsactivedash.cfm` |  | :warning: No |  |
| `notsall.cfm` |  | :warning: No |  |
| `notsall_512_1.cfm` |  | :warning: No |  |
| `notsnext.cfm` |  | :warning: No |  |
| `old_312_3.cfm` |  | :warning: No |  |
| `opencalls_286_1.cfm` |  | :warning: No |  |
| `pages_10_4.cfm` |  | :warning: No |  |
| `pages_274_3.cfm` |  | :warning: No |  |
| `pgPanelsFix.cfm` |  | :warning: No |  |
| `pgpanels_460_2.cfm` |  | :warning: No |  |
| `pgpanels_94_2.cfm` |  | :warning: No |  |
| `phonecheck.cfm` | the | :warning: No |  |
| `phonecheck_515_1.cfm` |  | :warning: No |  |
| `priorities_274_7.cfm` |  | :warning: No |  |
| `profiles.cfm` |  | :warning: No |  |
| `profiles_516_1.cfm` |  | :warning: No |  |
| `projectDetails.cfm` | the | :warning: No |  |
| `projectDetails_221_1.cfm` |  | :warning: No |  |
| `projectDetails_222_6.cfm` |  | :warning: No |  |
| `projectDetails_368_2.cfm` |  | :warning: No |  |
| `projectDetails_517_1.cfm` |  | :warning: No |  |
| `pronouns_210_1.cfm` |  | :warning: No |  |
| `pronouns_456_4.cfm` |  | :warning: No |  |
| `qCount_77_2.cfm` |  | :warning: No |  |
| `qFiltered_77_1.cfm` |  | :warning: No |  |
| `qFiltered_79_1.cfm` |  | :warning: No |  |
| `qry_block_1_1.cfm` |  | :warning: No |  |
| `qry_block_1_2.cfm` |  | :warning: No |  |
| `queryFullNames_129_1.cfm` |  | :warning: No |  |
| `questions_441_1.cfm` |  | :warning: No |  |
| `questions_check_29_9.cfm` |  | :warning: No |  |
| `r_462_1.cfm` |  | :warning: No |  |
| `ranges_286_6.cfm` |  | :warning: No |  |
| `ranges_524_7.cfm` |  | :warning: No |  |
| `rangeselected_282_2.cfm` |  | :warning: No |  |
| `ratio_13_524_12.cfm` |  | :warning: No |  |
| `ratio_17_524_13.cfm` |  | :warning: No |  |
| `refer_details_451_2.cfm` |  | :warning: No |  |
| `refer_details_456_2.cfm` |  | :warning: No |  |
| `referrals_286_3.cfm` |  | :warning: No |  |
| `refers_210_2.cfm` |  | :warning: No |  |
| `regions.cfm` |  | :warning: No |  |
| `relationships_13_1.cfm` |  | :warning: No |  |
| `reldetails_271_1.cfm` |  | :warning: No |  |
| `rels.cfm` | the | :warning: No |  |
| `reminders.cfm` |  | :warning: No |  |
| `reminders_511_1.cfm` |  | :warning: No |  |
| `remove2_191_12.cfm` |  | :warning: No |  |
| `remove_191_11.cfm` |  | :warning: No |  |
| `removenotdups.cfm` |  | :warning: No |  |
| `report_10_282_3.cfm` |  | :warning: No |  |
| `report_11_282_9.cfm` |  | :warning: No |  |
| `report_12_282_10.cfm` |  | :warning: No |  |
| `report_13_282_12.cfm` |  | :warning: No |  |
| `report_17_282_11.cfm` |  | :warning: No |  |
| `report_18_282_21.cfm` |  | :warning: No |  |
| `report_2_282_24.cfm` |  | :warning: No |  |
| `report_3_282_13.cfm` |  | :warning: No |  |
| `report_4_loop_282_4.cfm` |  | :warning: No |  |
| `report_5_282_14.cfm` |  | :warning: No |  |
| `report_6_282_15.cfm` |  | :warning: No |  |
| `report_6_282_16.cfm` |  | :warning: No |  |
| `report_6_282_17.cfm` |  | :warning: No |  |
| `report_6_282_18.cfm` |  | :warning: No |  |
| `report_6_282_19.cfm` |  | :warning: No |  |
| `report_7_282_20.cfm` |  | :warning: No |  |
| `report_8_282_22.cfm` |  | :warning: No |  |
| `report_9_282_23.cfm` |  | :warning: No |  |
| `reportcheck_524_1.cfm` |  | :warning: No |  |
| `reportcolors.cfm` | for,the | :warning: No |  |
| `reportcolors_523_1.cfm` |  | :warning: No |  |
| `reportitems_x_281_3.cfm` |  | :warning: No |  |
| `reportrefresh.cfm` | border | :warning: No |  |
| `reports_524_9.cfm` |  | :warning: No |  |
| `restoreActionUsers.cfm` |  | :warning: No |  |
| `restorenotdups.cfm` |  | :warning: No |  |
| `results_125_1.cfm` |  | :warning: No |  |
| `results_141_2.cfm` |  | :warning: No |  |
| `results_142_1.cfm` |  | :warning: No |  |
| `results_330_1.cfm` |  | :warning: No |  |
| `results_331_1.cfm` |  | :warning: No |  |
| `results_371_2.cfm` |  | :warning: No |  |
| `results_375_1.cfm` |  | :warning: No |  |
| `results_43_1.cfm` |  | :warning: No |  |
| `results_456_3.cfm` |  | :warning: No |  |
| `results_526_4.cfm` | the | :warning: No | :lock: UNPARAMETERIZED |
| `results_544_1.cfm` |  | :warning: No |  |
| `results_556_2.cfm` |  | :warning: No |  |
| `results_557_1.cfm` |  | :warning: No |  |
| `roleDetails_221_2.cfm` |  | :warning: No |  |
| `roleDetails_232_2.cfm` |  | :warning: No |  |
| `roleDetails_368_3.cfm` |  | :warning: No |  |
| `rolecheck_29_2.cfm` |  | :warning: No |  |
| `rolecheck_90_1.cfm` |  | :warning: No |  |
| `rr_283_2.cfm` |  | :warning: No |  |
| `ru.cfm` |  | :warning: No |  |
| `selectActions.cfm` |  | :warning: No |  |
| `set_missing.cfm` |  | :warning: No |  |
| `share.cfm` |  | :warning: No |  |
| `shares_534_1.cfm` |  | :warning: No |  |
| `sitetypes.cfm` | the | :warning: No |  |
| `sitetypes_535_1.cfm` |  | :warning: No |  |
| `stats_524_10.cfm` |  | :warning: No |  |
| `statuses_10_2.cfm` |  | :warning: No |  |
| `statuses_274_5.cfm` |  | :warning: No |  |
| `statuses_543_1.cfm` |  | :warning: No |  |
| `statuses_554_1.cfm` |  | :warning: No |  |
| `steps_29_1.cfm` |  | :warning: No |  |
| `submitsitefix_368_1.cfm` |  | :warning: No |  |
| `subsites_189_1.cfm` |  | :warning: No |  |
| `subsites_286_5.cfm` |  | :warning: No |  |
| `sudetails_157_5.cfm` |  | :warning: No |  |
| `sysActive.cfm` |  | :warning: No |  |
| `sysActive_537_1.cfm` |  | :warning: No |  |
| `sysAvail_539_3.cfm` |  | :warning: No |  |
| `systemNotificationsActive.cfm` |  | :warning: No |  |
| `systemnames_453_2.cfm` |  | :warning: No |  |
| `systems_454_1.cfm` |  | :warning: No |  |
| `t_14_2.cfm` |  | :warning: No |  |
| `tag_315_10.cfm` |  | :warning: No |  |
| `tag_315_12.cfm` |  | :warning: No |  |
| `tag_315_14.cfm` |  | :warning: No |  |
| `tag_insert_315_11.cfm` |  | :warning: No |  |
| `tag_insert_315_13.cfm` |  | :warning: No |  |
| `tag_insert_315_15.cfm` |  | :warning: No |  |
| `tagsContact.cfm` |  | :warning: No |  |
| `tags_200_1.cfm` |  | :warning: No |  |
| `tags_203_2.cfm` |  | :warning: No |  |
| `tags_76_1.cfm` |  | :warning: No |  |
| `tagsvalid.cfm` | a | :warning: No |  |
| `tagsvalid_542_1.cfm` |  | :warning: No |  |
| `testing.cfm` |  | :warning: No |  |
| `testings.cfm` | the | :warning: No |  |
| `thrivecartdetails.cfm` |  | :warning: No |  |
| `ticketme_323_4.cfm` |  | :warning: No |  |
| `ticketusers_10_6.cfm` |  | :warning: No |  |
| `ticketusers_323_3.cfm` |  | :warning: No |  |
| `timezones.cfm` | the | :warning: No |  |
| `tmpcontactgroups.cfm` | based,the | :warning: No |  |
| `toastmenu_306_2.cfm` |  | :warning: No |  |
| `toasts.cfm` |  | :warning: No |  |
| `toasts_306_1.cfm` |  | :warning: No |  |
| `tt_14_3.cfm` |  | :warning: No |  |
| `tt_365_5.cfm` |  | :warning: No |  |
| `types.cfm` |  | :warning: No |  |
| `types_10_3.cfm` |  | :warning: No |  |
| `types_198_2.cfm` |  | :warning: No |  |
| `types_198_3.cfm` |  | :warning: No |  |
| `types_256_2.cfm` |  | :warning: No |  |
| `types_261_4.cfm` |  | :warning: No |  |
| `types_261_5.cfm` |  | :warning: No |  |
| `types_333_2.cfm` |  | :warning: No |  |
| `types_334_2.cfm` |  | :warning: No |  |
| `types_42_1.cfm` |  | :warning: No |  |
| `types_44_1.cfm` |  | :warning: No |  |
| `types_521_4.cfm` |  | :warning: No |  |
| `u_315_28.cfm` |  | :warning: No |  |
| `u_318_30.cfm` |  | :warning: No |  |
| `u_insert_315_29.cfm` |  | :warning: No |  |
| `up_195_3.cfm` |  | :warning: No |  |
| `up_31_1.cfm` |  | :warning: No |  |
| `update2_262_6.cfm` |  | :warning: No |  |
| `update2_280_2.cfm` |  | :warning: No |  |
| `update2_280_3.cfm` |  | :warning: No |  |
| `updateActionUsers.cfm` |  | :warning: No |  |
| `updateActionUsersByActionUpdate.cfm` |  | :warning: No |  |
| `updateActionUsersByExcludeAction.cfm` |  | :warning: No |  |
| `updateContactUnique.cfm` |  | :warning: No |  |
| `updateContact_71_2.cfm` |  | :warning: No |  |
| `updateEventData.cfm` |  | :warning: No |  |
| `updateEvent_222_7.cfm` |  | :warning: No |  |
| `updateExport_115_14.cfm` |  | :warning: No |  |
| `updateNotification.cfm` |  | :warning: No |  |
| `updateNotificationCompleted.cfm` |  | :warning: No |  |
| `updateNotificationNext.cfm` |  | :warning: No |  |
| `updateSystemUserCompleted.cfm` |  | :warning: No |  |
| `updateUserToken_133_1.cfm` |  | :warning: No |  |
| `updateUserToken_184_1.cfm` |  | :warning: No |  |
| `updateUserToken_184_2.cfm` |  | :warning: No |  |
| `update_101_1.cfm` |  | :warning: No |  |
| `update_113_1.cfm` |  | :warning: No |  |
| `update_114_2.cfm` |  | :warning: No |  |
| `update_114_3.cfm` |  | :warning: No |  |
| `update_145_1.cfm` |  | :warning: No |  |
| `update_151_1.cfm` |  | :warning: No |  |
| `update_159_3.cfm` |  | :warning: No |  |
| `update_159_7.cfm` |  | :warning: No |  |
| `update_159_8.cfm` |  | :warning: No |  |
| `update_159_9.cfm` |  | :warning: No |  |
| `update_187_1.cfm` |  | :warning: No |  |
| `update_187_2.cfm` |  | :warning: No |  |
| `update_18_1.cfm` |  | :warning: No |  |
| `update_191_3.cfm` |  | :warning: No |  |
| `update_191_5.cfm` |  | :warning: No |  |
| `update_191_7.cfm` |  | :warning: No |  |
| `update_197_2.cfm` |  | :warning: No |  |
| `update_199_6.cfm` |  | :warning: No |  |
| `update_213_2.cfm` |  | :warning: No |  |
| `update_260_2.cfm` |  | :warning: No |  |
| `update_262_5.cfm` |  | :warning: No |  |
| `update_264_1.cfm` |  | :warning: No |  |
| `update_275_1.cfm` |  | :warning: No |  |
| `update_282_8.cfm` |  | :warning: No |  |
| `update_285_1.cfm` |  | :warning: No |  |
| `update_287_22.cfm` |  | :warning: No |  |
| `update_299_2.cfm` |  | :warning: No |  |
| `update_300_2.cfm` |  | :warning: No |  |
| `update_302_1.cfm` |  | :warning: No |  |
| `update_303_2.cfm` |  | :warning: No |  |
| `update_308_10.cfm` |  | :warning: No |  |
| `update_310_1.cfm` |  | :warning: No |  |
| `update_312_1.cfm` |  | :warning: No |  |
| `update_315_5.cfm` |  | :warning: No |  |
| `update_322_1.cfm` |  | :warning: No |  |
| `update_367_7.cfm` |  | :warning: No |  |
| `update_373_2.cfm` |  | :warning: No |  |
| `update_551_1.cfm` |  | :warning: No |  |
| `update_55_2.cfm` |  | :warning: No |  |
| `update_56_1.cfm` |  | :warning: No |  |
| `update_68_1.cfm` |  | :warning: No |  |
| `update_68_2.cfm` |  | :warning: No |  |
| `update_91_2.cfm` |  | :warning: No |  |
| `update_92_1.cfm` |  | :warning: No |  |
| `update_9_1.cfm` |  | :warning: No |  |
| `update_Iscasting_318_29.cfm` |  | :warning: No |  |
| `update_action_users.cfm` | based | :warning: No |  |
| `update_action_users2.cfm` |  | :warning: No |  |
| `update_cal.cfm` |  | :warning: No |  |
| `update_contact_308_23.cfm` |  | :warning: No |  |
| `update_record_313_2.cfm` |  | :warning: No |  |
| `update_tags_318_28.cfm` |  | :warning: No |  |
| `updatecontact_270_1.cfm` |  | :warning: No |  |
| `updatenote_175_1.cfm` |  | :warning: No |  |
| `updatenote_179_1.cfm` |  | :warning: No |  |
| `updates_239_1.cfm` |  | :warning: No |  |
| `updates_491_1.cfm` |  | :warning: No |  |
| `updatesystem_71_4.cfm` |  | :warning: No |  |
| `updatesystem_71_5.cfm` |  | :warning: No |  |
| `updateticket_213_3.cfm` |  | :warning: No |  |
| `updateticket_213_4.cfm` |  | :warning: No |  |
| `upload_details_141_1.cfm` |  | :warning: No |  |
| `usercontact_159_14.cfm` |  | :warning: No |  |
| `users_10_1.cfm` |  | :warning: No |  |
| `users_212_2.cfm` |  | :warning: No |  |
| `users_256_1.cfm` |  | :warning: No |  |
| `users_318_1.cfm` |  | :warning: No |  |
| `uu_223_2.cfm` |  | :warning: No |  |
| `uu_33_1.cfm` |  | :warning: No |  |
| `values_x_281_6.cfm` |  | :warning: No |  |
| `vers_274_8.cfm` |  | :warning: No |  |
| `vers_323_1.cfm` |  | :warning: No |  |
| `vers_330_3.cfm` |  | :warning: No |  |
| `version-add.cfm` | the | :warning: No |  |
| `version-update.cfm` | the | :warning: No |  |
| `version.cfm` |  | :warning: No |  |
| `versions.cfm` | the | :warning: No |  |
| `versions_10_5.cfm` |  | :warning: No |  |
| `versions_323_2.cfm` |  | :warning: No |  |
| `vocals_286_8.cfm` |  | :warning: No |  |
| `x_115_2.cfm` |  | :warning: No |  |
| `x_191_2.cfm` |  | :warning: No |  |
| `x_214_1.cfm` |  | :warning: No |  |
| `x_240_3.cfm` |  | :warning: No |  |
| `x_280_1.cfm` |  | :warning: No |  |
| `x_283_1.cfm` |  | :warning: No |  |
| `x_292_3.cfm` |  | :warning: No |  |
| `x_308_11.cfm` |  | :warning: No |  |
| `x_308_12.cfm` |  | :warning: No |  |
| `x_315_3.cfm` |  | :warning: No |  |
| `x_318_12.cfm` |  | :warning: No |  |
| `x_318_15.cfm` |  | :warning: No |  |
| `x_318_25.cfm` |  | :warning: No |  |
| `x_318_31.cfm` |  | :warning: No |  |
| `x_318_34.cfm` |  | :warning: No |  |
| `x_318_6.cfm` |  | :warning: No |  |
| `x_41_2.cfm` |  | :warning: No |  |
| `x_524_3.cfm` |  | :warning: No |  |
| `x_91_1.cfm` |  | :warning: No |  |
| `x_94_1.cfm` |  | :warning: No |  |
| `xs_283_5.cfm` |  | :warning: No |  |
| `xs_318_19.cfm` |  | :warning: No |  |
| `xs_318_22.cfm` |  | :warning: No |  |
| `xx_55_1.cfm` |  | :warning: No |  |
| `y_191_4.cfm` |  | :warning: No |  |
| `y_292_1.cfm` |  | :warning: No |  |
| `y_298_6.cfm` |  | :warning: No |  |
| `y_308_1.cfm` |  | :warning: No |  |
| `z_191_6.cfm` |  | :warning: No |  |

---
# PHASE 1C: Full Template Inventory (.cfm files outside /include/qry/)

**Total Template Files:** 777

### Directory Distribution

| Directory | File Count |
|-----------|------------|
| `(root)` | 12 |
| `ajax/import` | 10 |
| `ajax/import-auditions` | 11 |
| `ajax/importv3` | 22 |
| `app` | 8 |
| `app/action` | 1 |
| `app/actions` | 1 |
| `app/admin-import-v3` | 1 |
| `app/admin-relationship` | 1 |
| `app/admin-support` | 1 |
| `app/admin-support-details` | 1 |
| `app/admin-support-update` | 1 |
| `app/admin-update-log` | 1 |
| `app/admin-users` | 4 |
| `app/admin-users-detail` | 1 |
| `app/admin-users/ajax` | 6 |
| `app/ajax` | 2 |
| `app/application` | 1 |
| `app/applications` | 1 |
| `app/appoint` | 1 |
| `app/appoint-add` | 1 |
| `app/appoint-update` | 1 |
| `app/assets/js` | 12 |
| `app/aud-ageranges-Details` | 1 |
| `app/aud-ageranges-Results` | 1 |
| `app/aud-categories-Details` | 1 |
| `app/aud-categories-Results` | 1 |
| `app/aud-contracttypes-Details` | 1 |
| `app/aud-contracttypes-Results` | 1 |
| `app/aud-dialects-Details` | 1 |
| `app/aud-dialects-Results` | 1 |
| `app/aud-genres-Details` | 1 |
| `app/aud-genres-Results` | 1 |
| `app/aud-media-Details` | 1 |
| `app/aud-media-Results` | 1 |
| `app/aud-mediatypes-Details` | 1 |
| `app/aud-mediatypes-Results` | 1 |
| `app/aud-networks-Details` | 1 |
| `app/aud-networks-Results` | 1 |
| `app/aud-platforms-Details` | 1 |
| `app/aud-platforms-Results` | 1 |
| `app/aud-projects-Details` | 1 |
| `app/aud-projects-Results` | 1 |
| `app/aud-qtypes-Details` | 1 |
| `app/aud-qtypes-Results` | 1 |
| `app/aud-questions-default-Details` | 1 |
| `app/aud-questions-default-Results` | 1 |
| `app/aud-questions-user-Details` | 1 |
| `app/aud-questions-user-Results` | 1 |
| `app/aud-roles-Details` | 1 |
| `app/aud-roles-Results` | 1 |
| `app/aud-roletypes-Details` | 1 |
| `app/aud-roletypes-Results` | 1 |
| `app/aud-sources-Details` | 1 |
| `app/aud-sources-Results` | 1 |
| `app/aud-subcategories-Details` | 1 |
| `app/aud-subcategories-Results` | 1 |
| `app/aud-tones-Details` | 1 |
| `app/aud-tones-Results` | 1 |
| `app/aud-types-Details` | 1 |
| `app/aud-types-Results` | 1 |
| `app/aud-unions-Details` | 1 |
| `app/aud-unions-Results` | 1 |
| `app/aud-vocaltypes-Details` | 1 |
| `app/aud-vocaltypes-Results` | 1 |
| `app/audition` | 1 |
| `app/audition-add` | 2 |
| `app/audition-update` | 1 |
| `app/auditions` | 1 |
| `app/auditions-import` | 1 |
| `app/auditlog` | 1 |
| `app/billing` | 1 |
| `app/calendar-appoint` | 1 |
| `app/cancellations` | 1 |
| `app/categories` | 1 |
| `app/category` | 1 |
| `app/component` | 1 |
| `app/components` | 1 |
| `app/contact` | 1 |
| `app/contact-duplicates` | 2 |
| `app/contacts` | 1 |
| `app/contacts-import` | 1 |
| `app/contacts-import-v2` | 1 |
| `app/contacts-import-v3` | 1 |
| `app/dashboard` | 1 |
| `app/dashboard_new` | 1 |
| `app/eventcontactsxref` | 1 |
| `app/field` | 1 |
| `app/fields` | 1 |
| `app/finances` | 1 |
| `app/goals` | 1 |
| `app/image-upload` | 1 |
| `app/image-upload-contact` | 1 |
| `app/import` | 1 |
| `app/imports` | 1 |
| `app/integretions` | 1 |
| `app/itemcatxref` | 1 |
| `app/myaccount` | 2 |
| `app/mylinks` | 1 |
| `app/myteam` | 1 |
| `app/note-add` | 1 |
| `app/note-add-aud` | 1 |
| `app/note-add-event` | 1 |
| `app/note-update` | 1 |
| `app/note-update-aud` | 1 |
| `app/note-update-event` | 1 |
| `app/notes` | 1 |
| `app/notifications` | 1 |
| `app/page` | 1 |
| `app/pages` | 1 |
| `app/pgapplinks` | 1 |
| `app/pgpagespluginsxref` | 1 |
| `app/pgplugins` | 1 |
| `app/prefs` | 1 |
| `app/reminders` | 1 |
| `app/reports` | 1 |
| `app/reportsrefresh` | 1 |
| `app/security` | 1 |
| `app/settings` | 1 |
| `app/setup` | 1 |
| `app/share` | 1 |
| `app/support` | 1 |
| `app/system` | 1 |
| `app/system-prefs` | 1 |
| `app/system-types` | 1 |
| `app/system-users` | 1 |
| `app/systems` | 1 |
| `app/test` | 1 |
| `app/testing` | 1 |
| `app/testings` | 1 |
| `app/tmpcontactgroups-Results` | 1 |
| `app/types` | 1 |
| `app/useradministrator` | 1 |
| `app/version` | 1 |
| `app/version-add` | 1 |
| `app/version-update` | 1 |
| `app/versions` | 1 |
| `audition-update` | 1 |
| `database` | 11 |
| `include` | 377 |
| `include/scripts` | 1 |
| `login` | 1 |
| `oauth` | 1 |
| `recover` | 4 |
| `sched` | 121 |
| `scripts/dev` | 1 |
| `scripts/relationship_system` | 2 |
| `services` | 1 |
| `setup` | 7 |
| `share` | 19 |
| `share/assets` | 12 |

### `(root)/` (12 files)

- `admin-calendar-cleanup.cfm`
- `auth-recoverpw.cfm`
- `calendar-appoint.cfm`
- `codex-test.cfm`
- `debug-calendar-events.cfm`
- `diagnostic.cfm`
- `index.cfm`
- `ipn-cancelled.cfm`
- `ipn-handler.cfm`
- `loginform.cfm`
- `test-ipn-cancelled.cfm`
- `test-ipn-cli.cfm`

### `ajax/import/` (10 files)

- `bulk-action.cfm`
- `columns.cfm`
- `dry-run.cfm`
- `finalize.cfm`
- `parse.cfm`
- `row-action.cfm`
- `rows.cfm`
- `status.cfm`
- `update-row.cfm`
- `upload.cfm`

### `ajax/import-auditions/` (11 files)

- `columns.cfm`
- `fact_update.cfm`
- `finalize.cfm`
- `history.cfm`
- `parse.cfm`
- `recompute.cfm`
- `row.cfm`
- `row_action.cfm`
- `rows.cfm`
- `status.cfm`
- `upload.cfm`

### `ajax/importv3/` (22 files)

- `admin_cleanup.cfm`
- `admin_dashboard.cfm`
- `check_tables.cfm`
- `columns.cfm`
- `diag.cfm`
- `diagnostics.cfm`
- `fact_update.cfm`
- `finalize.cfm`
- `finalize_test.cfm`
- `finalize_update.cfm`
- `history.cfm`
- `normalize_fact_fieldnames.cfm`
- `parse.cfm`
- `preview_update.cfm`
- `recompute.cfm`
- `row.cfm`
- `row_action.cfm`
- `rows.cfm`
- `status.cfm`
- `test_finalize.cfm`
- `test_parse.cfm`
- `upload.cfm`

### `app/` (8 files)

- `ajaxController.cfm`
- `audition_check.cfm`
- `autolookup.cfm`
- `autolookup2.cfm`
- `index.cfm`
- `insert_files.cfm`
- `login2.cfm`
- `logout.cfm`

### `app/action/` (1 files)

- `index.cfm`

### `app/actions/` (1 files)

- `index.cfm`

### `app/admin-import-v3/` (1 files)

- `index.cfm`

### `app/admin-relationship/` (1 files)

- `index.cfm`

### `app/admin-support/` (1 files)

- `index.cfm`

### `app/admin-support-details/` (1 files)

- `index.cfm`

### `app/admin-support-update/` (1 files)

- `index.cfm`

### `app/admin-update-log/` (1 files)

- `index.cfm`

### `app/admin-users/` (4 files)

- `admin-guard.cfm`
- `detail.cfm`
- `index.cfm`
- `setup-verification.cfm`

### `app/admin-users-detail/` (1 files)

- `index.cfm`

### `app/admin-users/ajax/` (6 files)

- `get.cfm`
- `list.cfm`
- `preview-email.cfm`
- `save.cfm`
- `send-email.cfm`
- `toggle-status.cfm`

### `app/ajax/` (2 files)

- `load_reminders.cfm`
- `update_notification_status.cfm`

### `app/application/` (1 files)

- `index.cfm`

### `app/applications/` (1 files)

- `index.cfm`

### `app/appoint/` (1 files)

- `index.cfm`

### `app/appoint-add/` (1 files)

- `index.cfm`

### `app/appoint-update/` (1 files)

- `index.cfm`

### `app/assets/js/` (12 files)

- `autolookup.cfm`
- `autolookupbackup.cfm`
- `calendar2.cfm`
- `calendar2_backup2.cfm`
- `calendar2v.cfm`
- `croppie.cfm`
- `dragula_dashboard.cfm`
- `dt_eventscontact.cfm`
- `dt_notescontact.cfm`
- `eventtypes_user.cfm`
- `lookup.cfm`
- `note-add-event.cfm`

### `app/aud-ageranges-Details/` (1 files)

- `index.cfm`

### `app/aud-ageranges-Results/` (1 files)

- `index.cfm`

### `app/aud-categories-Details/` (1 files)

- `index.cfm`

### `app/aud-categories-Results/` (1 files)

- `index.cfm`

### `app/aud-contracttypes-Details/` (1 files)

- `index.cfm`

### `app/aud-contracttypes-Results/` (1 files)

- `index.cfm`

### `app/aud-dialects-Details/` (1 files)

- `index.cfm`

### `app/aud-dialects-Results/` (1 files)

- `index.cfm`

### `app/aud-genres-Details/` (1 files)

- `index.cfm`

### `app/aud-genres-Results/` (1 files)

- `index.cfm`

### `app/aud-media-Details/` (1 files)

- `index.cfm`

### `app/aud-media-Results/` (1 files)

- `index.cfm`

### `app/aud-mediatypes-Details/` (1 files)

- `index.cfm`

### `app/aud-mediatypes-Results/` (1 files)

- `index.cfm`

### `app/aud-networks-Details/` (1 files)

- `index.cfm`

### `app/aud-networks-Results/` (1 files)

- `index.cfm`

### `app/aud-platforms-Details/` (1 files)

- `index.cfm`

### `app/aud-platforms-Results/` (1 files)

- `index.cfm`

### `app/aud-projects-Details/` (1 files)

- `index.cfm`

### `app/aud-projects-Results/` (1 files)

- `index.cfm`

### `app/aud-qtypes-Details/` (1 files)

- `index.cfm`

### `app/aud-qtypes-Results/` (1 files)

- `index.cfm`

### `app/aud-questions-default-Details/` (1 files)

- `index.cfm`

### `app/aud-questions-default-Results/` (1 files)

- `index.cfm`

### `app/aud-questions-user-Details/` (1 files)

- `index.cfm`

### `app/aud-questions-user-Results/` (1 files)

- `index.cfm`

### `app/aud-roles-Details/` (1 files)

- `index.cfm`

### `app/aud-roles-Results/` (1 files)

- `index.cfm`

### `app/aud-roletypes-Details/` (1 files)

- `index.cfm`

### `app/aud-roletypes-Results/` (1 files)

- `index.cfm`

### `app/aud-sources-Details/` (1 files)

- `index.cfm`

### `app/aud-sources-Results/` (1 files)

- `index.cfm`

### `app/aud-subcategories-Details/` (1 files)

- `index.cfm`

### `app/aud-subcategories-Results/` (1 files)

- `index.cfm`

### `app/aud-tones-Details/` (1 files)

- `index.cfm`

### `app/aud-tones-Results/` (1 files)

- `index.cfm`

### `app/aud-types-Details/` (1 files)

- `index.cfm`

### `app/aud-types-Results/` (1 files)

- `index.cfm`

### `app/aud-unions-Details/` (1 files)

- `index.cfm`

### `app/aud-unions-Results/` (1 files)

- `index.cfm`

### `app/aud-vocaltypes-Details/` (1 files)

- `index.cfm`

### `app/aud-vocaltypes-Results/` (1 files)

- `index.cfm`

### `app/audition/` (1 files)

- `index.cfm`

### `app/audition-add/` (2 files)

- `audition_check.cfm`
- `index.cfm`

### `app/audition-update/` (1 files)

- `index.cfm`

### `app/auditions/` (1 files)

- `index.cfm`

### `app/auditions-import/` (1 files)

- `index.cfm`

### `app/auditlog/` (1 files)

- `index.cfm`

### `app/billing/` (1 files)

- `index.cfm`

### `app/calendar-appoint/` (1 files)

- `index.cfm`

### `app/cancellations/` (1 files)

- `index.cfm`

### `app/categories/` (1 files)

- `index.cfm`

### `app/category/` (1 files)

- `index.cfm`

### `app/component/` (1 files)

- `index.cfm`

### `app/components/` (1 files)

- `index.cfm`

### `app/contact/` (1 files)

- `index.cfm`

### `app/contact-duplicates/` (2 files)

- `contact-duplicates.cfm`
- `index.cfm`

### `app/contacts/` (1 files)

- `index.cfm`

### `app/contacts-import/` (1 files)

- `index.cfm`

### `app/contacts-import-v2/` (1 files)

- `index.cfm`

### `app/contacts-import-v3/` (1 files)

- `index.cfm`

### `app/dashboard/` (1 files)

- `index.cfm`

### `app/dashboard_new/` (1 files)

- `index.cfm`

### `app/eventcontactsxref/` (1 files)

- `index.cfm`

### `app/field/` (1 files)

- `index.cfm`

### `app/fields/` (1 files)

- `index.cfm`

### `app/finances/` (1 files)

- `index.cfm`

### `app/goals/` (1 files)

- `index.cfm`

### `app/image-upload/` (1 files)

- `index.cfm`

### `app/image-upload-contact/` (1 files)

- `index.cfm`

### `app/import/` (1 files)

- `index.cfm`

### `app/imports/` (1 files)

- `index.cfm`

### `app/integretions/` (1 files)

- `index.cfm`

### `app/itemcatxref/` (1 files)

- `index.cfm`

### `app/myaccount/` (2 files)

- `index.cfm`
- `update_newsletter.cfm`

### `app/mylinks/` (1 files)

- `index.cfm`

### `app/myteam/` (1 files)

- `index.cfm`

### `app/note-add/` (1 files)

- `index.cfm`

### `app/note-add-aud/` (1 files)

- `index.cfm`

### `app/note-add-event/` (1 files)

- `index.cfm`

### `app/note-update/` (1 files)

- `index.cfm`

### `app/note-update-aud/` (1 files)

- `index.cfm`

### `app/note-update-event/` (1 files)

- `index.cfm`

### `app/notes/` (1 files)

- `index.cfm`

### `app/notifications/` (1 files)

- `index.cfm`

### `app/page/` (1 files)

- `index.cfm`

### `app/pages/` (1 files)

- `index.cfm`

### `app/pgapplinks/` (1 files)

- `index.cfm`

### `app/pgpagespluginsxref/` (1 files)

- `index.cfm`

### `app/pgplugins/` (1 files)

- `index.cfm`

### `app/prefs/` (1 files)

- `index.cfm`

### `app/reminders/` (1 files)

- `index.cfm`

### `app/reports/` (1 files)

- `index.cfm`

### `app/reportsrefresh/` (1 files)

- `index.cfm`

### `app/security/` (1 files)

- `index.cfm`

### `app/settings/` (1 files)

- `index.cfm`

### `app/setup/` (1 files)

- `index.cfm`

### `app/share/` (1 files)

- `index.cfm`

### `app/support/` (1 files)

- `index.cfm`

### `app/system/` (1 files)

- `index.cfm`

### `app/system-prefs/` (1 files)

- `index.cfm`

### `app/system-types/` (1 files)

- `index.cfm`

### `app/system-users/` (1 files)

- `index.cfm`

### `app/systems/` (1 files)

- `index.cfm`

### `app/test/` (1 files)

- `index.cfm`

### `app/testing/` (1 files)

- `index.cfm`

### `app/testings/` (1 files)

- `index.cfm`

### `app/tmpcontactgroups-Results/` (1 files)

- `index.cfm`

### `app/types/` (1 files)

- `index.cfm`

### `app/useradministrator/` (1 files)

- `index.cfm`

### `app/version/` (1 files)

- `index.cfm`

### `app/version-add/` (1 files)

- `index.cfm`

### `app/version-update/` (1 files)

- `index.cfm`

### `app/versions/` (1 files)

- `index.cfm`

### `audition-update/` (1 files)

- `index.cfm`

### `database/` (11 files)

- `admin-guard.cfm`
- `enable-importv3.cfm`
- `run-import-v2-migrations.cfm`
- `run-import-v3-indexes.cfm`
- `run-migration.cfm`
- `run-v3-migration.cfm`
- `test-cleanup-proof.cfm`
- `test-diagnostics-proof.cfm`
- `test-feature-flags-proof.cfm`
- `verify-migration.cfm`
- `verify-v3-migration.cfm`

### `include/` (377 files)

- `AddSystemToContact.cfm`
- `Applicationx.cfm`
- `DetailPage.cfm`
- `Implemented_section.cfm`
- `Insert_ReportItem.cfm`
- `ModalRemoteNewForm.cfm`
- `TagChange.cfm`
- `UpdateFormUpdate.cfm`
- `account_info.cfm`
- `account_info_mobile_code.cfm`
- `add_system.cfm`
- `addeventtype.cfm`
- `addeventtypeadd.cfm`
- `addnote.cfm`
- `admin-support-details.cfm`
- `admin-support-update.cfm`
- `admin-support-update2.cfm`
- `admin-support.cfm`
- `admin-support_backup.cfm`
- `admin-support_optimized.cfm`
- `admin-update-log.cfm`
- `admin-users-detail.cfm`
- `admin-users.cfm`
- `appoint-add.cfm`
- `appoint-add2.cfm`
- `appoint-delete.cfm`
- `appoint-info.cfm`
- `appoint-update.cfm`
- `appoint-update2.cfm`
- `appoint.cfm`
- `appointments_pane.cfm`
- `attachmentadd.cfm`
- `attachmentadd2.cfm`
- `attachmentadd2aud.cfm`
- `attachmentaddaud.cfm`
- `attachmentdel.cfm`
- `attachmentdelaud.cfm`
- `aud_assessment_add.cfm`
- `aud_book_pane.cfm`
- `aud_call_pane.cfm`
- `aud_head_pane.cfm`
- `aud_mat_pane.cfm`
- `aud_notes_pane.cfm`
- `aud_ques_pane.cfm`
- `aud_rel_pane.cfm`
- `aud_role_pane.cfm`
- `audition-add.cfm`
- `audition-add2.cfm`
- `audition-update.cfm`
- `audition.cfm`
- `audition_check.cfm`
- `auditions.cfm`
- `auditions_ins.cfm`
- `auditions_new.cfm`
- `auditlog.cfm`
- `audlocupdate2.cfm`
- `audmedia.cfm`
- `audroles_ins.cfm`
- `audunions_sel.cfm`
- `autocomplete.cfm`
- `batchcomplete.cfm`
- `batchskip.cfm`
- `bigbrotherinclude.cfm`
- `birthday_fix.cfm`
- `birthdays.cfm`
- `booked.cfm`
- `bookupdateform.cfm`
- `bookupdateform2.cfm`
- `calendar-appoint.cfm`
- `calendarModal.cfm`
- `calendarModalAddEventType.cfm`
- `calendarModalSubscription.cfm`
- `calendarModalUpdateEventType.cfm`
- `calendarSectionCalendar.cfm`
- `calendarSectionCalendarx.cfm`
- `calendarSectionLegend.cfm`
- `card.cfm`
- `card_old.cfm`
- `card_photo.cfm`
- `castingnetworks_notifications.cfm`
- `catupdateform.cfm`
- `catupdateform2.cfm`
- `changestatus.cfm`
- `companylookup.cfm`
- `complete_not.cfm`
- `complete_not_ajax.cfm`
- `complete_not_batch.cfm`
- `complete_not_batch_backup_20251211.cfm`
- `complete_not_batch_old.cfm`
- `complete_not_skip.cfm`
- `contact_add.cfm`
- `contact_info.cfm`
- `contact_pane.cfm`
- `contact_view.cfm`
- `contactfolder_setup.cfm`
- `contacts.cfm`
- `contacts_all.cfm`
- `contacts_all_tabs.cfm`
- `contacts_attendees.cfm`
- `contacts_check.cfm`
- `contacts_grid.cfm`
- `contacts_ss.cfm`
- `contacts_table.cfm`
- `contacts_table_attendees.cfm`
- `core.cfm`
- `core_nomenu.cfm`
- `core_title.cfm`
- `core_title_175.cfm`
- `coreb.cfm`
- `customicon.cfm`
- `customicon_single.cfm`
- `dash_repteam.cfm`
- `dash_rr.cfm`
- `dashboard_new.cfm`
- `dashboard_pane.cfm`
- `dashboardupdate.cfm`
- `dashboardupdate2.cfm`
- `debugLog.cfm`
- `debugging_log.cfm`
- `delaudmedia.cfm`
- `deleteContacts.cfm`
- `delete_audcontact.cfm`
- `delete_team.cfm`
- `deleteappointment.cfm`
- `deleteessence.cfm`
- `deletenote.cfm`
- `deletesystemfromrel.cfm`
- `deleteticket.cfm`
- `details.cfm`
- `download.cfm`
- `download_aud.cfm`
- `download_audition_template.cfm`
- `download_contact_template.cfm`
- `download_media.cfm`
- `eventcontacts_pane.cfm`
- `eventnotes_pane.cfm`
- `excludeaction.cfm`
- `excludelink.cfm`
- `excludesitetype.cfm`
- `exportContacts.cfm`
- `export_auditions.cfm`
- `fetch.cfm`
- `fetchPageService.cfm`
- `fetch_panelname.cfm`
- `fetch_sitename.cfm`
- `fetch_sitetypename.cfm`
- `fetch_siteurl.cfm`
- `fetch_updated_row.cfm`
- `findname.cfm`
- `folder_setup.cfm`
- `folowup_body.cfm`
- `footer.cfm`
- `formatPhoneNumber.cfm`
- `get_dashboard_reminders.cfm`
- `get_google_calendars.cfm`
- `get_notifications.cfm`
- `get_record_data.cfm`
- `get_reminders.cfm`
- `getmodalcontent.cfm`
- `google_auth.cfm`
- `hostcolor.cfm`
- `icsmaker.cfm`
- `image-upload-contact.cfm`
- `image-upload.cfm`
- `image_upload-contact2.cfm`
- `image_upload2.cfm`
- `import-auditions-v3.cfm`
- `import-auditions.cfm`
- `import-contacts-v3.cfm`
- `import-contacts.cfm`
- `import-contacts_old.cfm`
- `import.cfm`
- `imports.cfm`
- `includeaction.cfm`
- `leftbar.cfm`
- `linkadd.cfm`
- `linkadd2.cfm`
- `linkdel.cfm`
- `linkinclude.cfm`
- `linkmedia.cfm`
- `load_headshot.cfm`
- `load_headshot_gallery.cfm`
- `mantra.cfm`
- `matupdateform.cfm`
- `mediadownload.cfm`
- `merge_contacts_interface.cfm`
- `modal.cfm`
- `modal_generic.cfm`
- `modalansweryes.cfm`
- `mybilling_pane.cfm`
- `mybilling_pane_n32.cfm`
- `mybilling_pane_old.cfm`
- `mybrand_pane.cfm`
- `myheadshots_pane.cfm`
- `myinfo_pane.cfm`
- `mylinks_pane.cfm`
- `mylinks_user.cfm`
- `mymaterials_pane.cfm`
- `myteam_pane.cfm`
- `myteam_pane_backup.cfm`
- `myteam_pane_fixed.cfm`
- `note-add-aud.cfm`
- `note-add-aud2.cfm`
- `note-add-event.cfm`
- `note-add-event2.cfm`
- `note-add.cfm`
- `note-add2.cfm`
- `note-update-aud.cfm`
- `note-update-aud2.cfm`
- `note-update-event.cfm`
- `note-update-event2.cfm`
- `note-update.cfm`
- `note-update2.cfm`
- `notesEvent.cfm`
- `notes_aud_pane.cfm`
- `notes_event_pane.cfm`
- `notes_relationship_pane.cfm`
- `oauth_callback.cfm`
- `order.cfm`
- `patchnotes.cfm`
- `pgload.cfm`
- `pgload_setup.cfm`
- `prefs_pane.cfm`
- `process.cfm`
- `projdate_fix_user.cfm`
- `reminder_pane.cfm`
- `reminder_pane_fucked.cfm`
- `reminder_pane_old.cfm`
- `reminders.cfm`
- `remotaudmatadd.cfm`
- `remoteAddCAdd.cfm`
- `remoteAddContact.cfm`
- `remoteAddContactAdd.cfm`
- `remoteAddContactAddaud.cfm`
- `remoteAddContactAud.cfm`
- `remoteAddEssenceContact.cfm`
- `remoteAddEssenceContact2.cfm`
- `remoteAddName.cfm`
- `remoteAddNameAdd.cfm`
- `remoteDelete.cfm`
- `remoteDelete2.cfm`
- `remoteDeleteForm.cfm`
- `remoteDeleteFormAud.cfm`
- `remoteDeleteFormAudDelete.cfm`
- `remoteDeleteFormAudproject.cfm`
- `remoteDeleteFormAudprojectDelete.cfm`
- `remoteDeleteFormDelete.cfm`
- `remoteDeleteFormLink.cfm`
- `remoteDeleteFormNote.cfm`
- `remoteDeleteFormNoteAud.cfm`
- `remoteDeleteLink2.cfm`
- `remoteDeleteaudmedia.cfm`
- `remoteDeleteaudmedia2.cfm`
- `remoteDeleteheadshots_auditions_xref.cfm`
- `remoteDeleteheadshots_auditions_xref2.cfm`
- `remoteDeletelink.cfm`
- `remoteNewForm.cfm`
- `remoteNewFormAdd.cfm`
- `remotePanelAdd.cfm`
- `remoteRemoveaudmedia.cfm`
- `remoteRemoveaudmedia2.cfm`
- `remoteSupportForm.cfm`
- `remoteSupportFormAdd.cfm`
- `remoteUpdateC.cfm`
- `remoteUpdateCUpdate.cfm`
- `remoteUpdateEssenceContact.cfm`
- `remoteUpdateEssenceContact2.cfm`
- `remoteUpdateForm.cfm`
- `remoteUpdateFormUpdate.cfm`
- `remoteUpdateMaterial.cfm`
- `remoteUpdateMaterial2.cfm`
- `remoteUpdateName.cfm`
- `remoteUpdateNameUpdate.cfm`
- `remoteUpdateSUID.cfm`
- `remoteUpdateTag.cfm`
- `remoteUpdateaudsubmitsite.cfm`
- `remoteUpdateaudsubmitsite2.cfm`
- `remoteUserUpdate.cfm`
- `remoteUserUpdated.cfm`
- `remote_aud_project_update.cfm`
- `remote_aud_project_update2.cfm`
- `remote_load.cfm`
- `remoteactionUpdate.cfm`
- `remoteactionUpdateUpdate.cfm`
- `remoteaddC.cfm`
- `remoteaddHeadshot.cfm`
- `remoteaddHeadshot2.cfm`
- `remoteaddMaterial.cfm`
- `remoteaddMaterial2.cfm`
- `remoteaddaudsubmitsite.cfm`
- `remoteaddaudsubmitsite2.cfm`
- `remoteapprove.cfm`
- `remoteapprove2.cfm`
- `remoteassForm.cfm`
- `remoteassFormUpdate.cfm`
- `remoteaudadd.cfm`
- `remoteaudaddform.cfm`
- `remoteaudaddform2.cfm`
- `remoteaudmatadd2.cfm`
- `remoteaudupdateform.cfm`
- `remoteaudupdateform2.cfm`
- `remotecontent.cfm`
- `remoteheadingupdate.cfm`
- `remoteheadingupdate2.cfm`
- `remotelinkAdd.cfm`
- `remotelinkUpdate.cfm`
- `remotelinkUpdateUpdate.cfm`
- `remotelinkadd2.cfm`
- `remotenotedetails.cfm`
- `remotepaneladd2.cfm`
- `remoteselectedheadshot2.cfm`
- `remoteselectedmaterial2.cfm`
- `remoteselectheadshot.cfm`
- `remoteselectmaterial.cfm`
- `remoteticketupdate.cfm`
- `remoteverticketupdate.cfm`
- `remoteverticketupdate2.cfm`
- `remove_team.cfm`
- `removestatus.cfm`
- `reportrangegenerator.cfm`
- `reports.cfm`
- `reportsRefresh.cfm`
- `reports_backup.cfm`
- `restoreaction.cfm`
- `results.cfm`
- `rolecheck.cfm`
- `roleupdateform.cfm`
- `roleupdateform2.cfm`
- `rpg_load.cfm`
- `savedashboard.cfm`
- `security_pane.cfm`
- `share.cfm`
- `sql.cfm`
- `systemchange.cfm`
- `systemprefs_pane.cfm`
- `systems_452_1.cfm`
- `tab_check.cfm`
- `tab_check_account.cfm`
- `temp.cfm`
- `test.cfm`
- `test_auditions_pagination.cfm`
- `test_core_title.cfm`
- `test_dontwork.cfm`
- `testing.cfm`
- `thrivecart_results.cfm`
- `ticket_email_client.cfm`
- `ticketclose.cfm`
- `ticketcomplete.cfm`
- `ticketemail.cfm`
- `ticketpass.cfm`
- `tmpcontactgroups.cfm`
- `tmpcontacttags.cfm`
- `toast.cfm`
- `topbar.cfm`
- `transfer_audition.cfm`
- `transfer_audition_back .cfm`
- `update_cal.cfm`
- `update_import_auditions.cfm`
- `update_media_name.cfm`
- `update_order.cfm`
- `update_reminder_status.cfm`
- `update_selected_headshot.cfm`
- `update_thrivecart_status.cfm`
- `updateeventtype.cfm`
- `updateeventtypeupdate.cfm`
- `updatetickver2.cfm`
- `upload.cfm`
- `upload_audition.cfm`
- `upload_audition_back.cfm`
- `upload_update_audition.cfm`
- `user_setup.cfm`
- `version-add.cfm`
- `version-add2.cfm`
- `version-update.cfm`
- `version-update2.cfm`
- `version.cfm`
- `versions.cfm`

### `include/scripts/` (1 files)

- `folder_setup.cfm`

### `login/` (1 files)

- `login2.cfm`

### `oauth/` (1 files)

- `oauth_callback.cfm`

### `recover/` (4 files)

- `404.cfm`
- `Application.cfm`
- `index.cfm`
- `setup2.cfm`

### `sched/` (121 files)

- `account_info.cfm`
- `actionusers_fix.cfm`
- `admin-calendar-cleanup.cfm`
- `appoint-update2.cfm`
- `assetsfoundfix.cfm`
- `au_fix.cfm`
- `auddialects_fix.cfm`
- `audgenres_fix.cfm`
- `audnetworks_fix.cfm`
- `audplatforms_fix.cfm`
- `audtones_fix.cfm`
- `aufix.cfm`
- `avatar_loop.cfm`
- `avatar_loop2.cfm`
- `backup.cfm`
- `birthday_fix.cfm`
- `cal_fix.cfm`
- `cancel.cfm`
- `cancel2.cfm`
- `cf_gen_fetch.cfm`
- `cfoutput.cfm`
- `column_details.cfm`
- `column_details_view.cfm`
- `comments.cfm`
- `count_cfinclude_include.cfm`
- `count_cfinclude_qry.cfm`
- `count_include.cfm`
- `count_qry.cfm`
- `customicon.cfm`
- `customicon3.cfm`
- `customicon7.cfm`
- `customicon_exiting.cfm`
- `customicon_loop.cfm`
- `dateaddedfix.cfm`
- `delete.cfm`
- `devtoapp.cfm`
- `dir_fix1.cfm`
- `dir_fix2.cfm`
- `dir_search.cfm`
- `dir_search_INCLUDE.cfm`
- `dirfix.cfm`
- `email_test.cfm`
- `encode.cfm`
- `error.cfm`
- `events_completed.cfm`
- `events_completed_wo_system.cfm`
- `extract.cfm`
- `extract_queries.cfm`
- `extract_queries_overwrite.cfm`
- `extract_queries_overwrite_qry.cfm`
- `extracts.cfm`
- `extracts_for_multiple.cfm`
- `extracts_new.cfm`
- `extracts_newest.cfm`
- `extracts_newest_qry.cfm`
- `find_missing_db_include.cfm`
- `find_missing_db_qry.cfm`
- `find_parents.cfm`
- `find_parents_include.cfm`
- `find_parents_include_qry.cfm`
- `find_qry_details_qry.cfm`
- `find_qry_table_and_type_qry.cfm`
- `find_query_name.cfm`
- `find_schema.cfm`
- `findcfm.cfm`
- `findmissing.cfm`
- `folder_setup.cfm`
- `from.cfm`
- `gen_insert.cfm`
- `hash_fix_loop.cfm`
- `hash_loop.cfm`
- `icon_cleanup.cfm`
- `icsmaker.cfm`
- `import-contacts.cfm`
- `insertModels.cfm`
- `insert_files.cfm`
- `insert_functions_view.cfm`
- `modelfix.cfm`
- `panelfix.cfm`
- `percent.cfm`
- `pgfix.cfm`
- `psw_fix.cfm`
- `qry_count.cfm`
- `qry_table.cfm`
- `release_fix.cfm`
- `release_fix_qry.cfm`
- `remote_load.cfm`
- `remove_comments_from_qry_details.cfm`
- `remove_duplicates_from qry.cfm`
- `remove_duplicates_fromqry.cfm`
- `replace_bad.cfm`
- `replacement.cfm`
- `setup-verification.cfm`
- `setup_check.cfm`
- `setup_loop.cfm`
- `sitelinks_fix.cfm`
- `sitelinksfix.cfm`
- `standalone_email_test.cfm`
- `table.cfm`
- `tablefix.cfm`
- `temp.cfm`
- `temp_chain.cfm`
- `test.cfm`
- `thrivecart_email.cfm`
- `thrivecart_process.cfm`
- `thrivecart_process_audition.cfm`
- `ticketfix.cfm`
- `tickets_loop.cfm`
- `tmp_q_update.cfm`
- `tree.cfm`
- `type.cfm`
- `update_tao_files.cfm`
- `user_setup.cfm`
- `user_setup_core copy.cfm`
- `user_setup_core.cfm`
- `user_setup_corex.cfm`
- `user_setup_loop.cfm`
- `usercontact.cfm`
- `usersprod2_loop.cfm`
- `usersprod_loop.cfm`
- `view_compare.cfm`

### `scripts/dev/` (1 files)

- `importv3_regression_check.cfm`

### `scripts/relationship_system/` (2 files)

- `repair_relationship_system.cfm`
- `run_audit.cfm`

### `services/` (1 files)

- `Application.cfm`

### `setup/` (7 files)

- `Filecheck.cfm`
- `contact_info.cfm`
- `create_auditionsimport_error_table.cfm`
- `index.cfm`
- `setup-complete.cfm`
- `setup2.cfm`
- `user_setup_core.cfm`

### `share/` (19 files)

- `calendar_shared.cfm`
- `contact.cfm`
- `export.cfm`
- `generate_token.cfm`
- `generate_tokens_all_users.cfm`
- `get_note_details.cfm`
- `index.cfm`
- `invalid_share_type.cfm`
- `invalid_token.cfm`
- `pgload.cfm`
- `relationships_shared.cfm`
- `remoteShareViewC.cfm`
- `remoteUpdateForm.cfm`
- `remote_load.cfm`
- `remote_load_common.cfm`
- `share.cfm`
- `share_contact_details.cfm`
- `test_share.cfm`
- `topmenu_main.cfm`

### `share/assets/` (12 files)

- `autolookup.cfm`
- `autolookupbackup.cfm`
- `calendar2.cfm`
- `calendar2_backup2.cfm`
- `calendar2v.cfm`
- `croppie.cfm`
- `dragula_dashboard.cfm`
- `dt_eventscontact.cfm`
- `dt_notescontact.cfm`
- `eventtypes_user.cfm`
- `lookup.cfm`
- `note-add-event.cfm`
