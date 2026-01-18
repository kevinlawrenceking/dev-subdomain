<!--- This ColdFusion page updates the audvocaltypes_audition_xref table with new audition role and vocal type IDs based on provided parameters. --->

<cfparam name="new_audRoleID" default="" />
<cfparam name="new_vocaltypeid" default="" />

<!--- Query to update the audvocaltypes_audition_xref table --->
<cfinclude template="/include/qry/audvocaltypes_audition_xref_ins_436_1.cfm" />

