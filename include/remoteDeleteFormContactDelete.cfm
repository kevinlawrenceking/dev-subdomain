<!--- Soft-deletes a contact (relationship) after verifying ownership. --->

<cfparam name="form.contactid" default="0" />

<!--- Ownership guard: only allow the owning user to delete the contact --->
<cfquery name="ownerCheck" datasource="#application.dsn#">
    SELECT contactid
    FROM contactdetails
    WHERE contactid = <cfqueryparam value="#form.contactid#" cfsqltype="CF_SQL_INTEGER">
      AND userid = <cfqueryparam value="#session.userid#" cfsqltype="CF_SQL_INTEGER">
      AND isdeleted = 0
</cfquery>

<cfif ownerCheck.recordcount EQ 0>
    <cflocation url="/app/contacts/" addtoken="false" />
</cfif>

<cfset request.svc("ContactService").delete(contactid=form.contactid)>

<cflocation url="/app/contacts/" addtoken="false" />
