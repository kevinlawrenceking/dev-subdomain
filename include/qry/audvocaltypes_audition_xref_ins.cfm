<!--- This ColdFusion page inserts a new record into the audvocaltypes_audition_xref table using provided role and vocal type IDs. --->

<cfparam name="new_audRoleID" default="" />
<cfparam name="new_vocaltypeid" default="" />

<!--- Insert a new record into the audvocaltypes_audition_xref table --->
<cfinclude template="/include/qry/audvocaltypes_audition_xref_ins_435_1.cfm" />

