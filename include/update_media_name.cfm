<!---
  POST /include/update_media_name.cfm   (ticket 2547 - headshot rename did not persist)
  Called by include/card_photo.cfm. CSRF is enforced by include/Application.cfc (X-CSRF-Token
  header). Reads form.* explicitly (app/Application.cfc enables implicit scope search, so a bare
  name could also resolve from url or cookie) and only renames media owned by the session user.
  Response body stays plain text "success" / "error".
--->
<cfcontent type="text/plain" reset="true">

<cfif NOT structKeyExists(session, "userid") OR NOT isValid("integer", session.userid)>
    <cfheader statuscode="401">
    <cfoutput>error</cfoutput>
    <cfabort>
</cfif>

<cfparam name="form.mediaid" default="">
<cfparam name="form.medianame" default="">

<cfset newName = trim(form.medianame)>

<cfif isValid("integer", form.mediaid) AND len(newName) GT 0 AND len(newName) LTE 255>
    <cfquery result="updResult">
        UPDATE audmedia
        SET medianame = <cfqueryparam value="#newName#" cfsqltype="CF_SQL_VARCHAR">
        WHERE mediaid = <cfqueryparam value="#form.mediaid#" cfsqltype="CF_SQL_INTEGER">
          AND userid  = <cfqueryparam value="#session.userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
    <!--- MySQL reports 0 affected rows when the name is unchanged; confirm the row is ours. --->
    <cfif val(updResult.recordCount) GTE 1>
        <cfoutput>success</cfoutput>
    <cfelse>
        <cfquery name="qOwn">
            SELECT mediaid FROM audmedia
            WHERE mediaid = <cfqueryparam value="#form.mediaid#" cfsqltype="CF_SQL_INTEGER">
              AND userid  = <cfqueryparam value="#session.userid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
        <cfoutput>#(qOwn.recordCount ? "success" : "error")#</cfoutput>
    </cfif>
<cfelse>
    <cfoutput>error</cfoutput>
</cfif>
