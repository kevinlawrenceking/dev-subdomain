<cfparam name="emailUser" default="N" />
<cfparam name="patchNote" default="" />

<cfinclude template="/include/qry/find_300_1.cfm" />
<cfset nextVerId = find.verid />
<cfinclude template="/include/qry/update_300_2.cfm" />
<cfinclude template="/include/qry/details_303_3.cfm" />

<!---
  TAO-SPEC-2026-005 (user-facing error mgmt flow): the user completion/resolution
  email is now sent by the single logged, idempotent sender
  /ajax/admin-support/send-resolution-email.cfm (triggered from the ticket-detail
  "Send Resolution Email to User" button, keyed on developerResponse, idempotent on
  resolvedEmailSentAt, logged to ticketslog_tbl).

  The previous cfmail block here never fired (the form posts email_user but this page
  read emailUser) and is removed to avoid a second, unlogged completion sender. This
  page now only performs the status transition (update_300_2 -> ticketstatus='Completed',
  ticketCompletedDate, complete_email=1) above.
  // TECH-DEBT: the 14 ad-hoc cfmail templates should be consolidated into emailService.cfc.
--->

<!--- Redirect to the admin support page --->
<cflocation url="/app/admin-support/" />

<!--- Changes made: 
1. Removed unnecessary <cfoutput> tags around variable outputs.
2. Avoided using # symbols within conditional checks unless essential.
3. Standardized variable names and casing.
4. Ensured consistent attribute quoting, spacing, and formatting.
5. Used uniform date and time formatting across the code.
6. Removed cftry and cfcatch blocks entirely.
7. For any # symbols inside <cfoutput> blocks that are not meant as ColdFusion variables (e.g., for hex color codes or jQuery syntax), used double pound signs ## to avoid interpretation as variables.
--->