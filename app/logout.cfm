<cfif #isdefined('userid')# >

 <cfset StructDelete(Session, "userid")>

    </cfif>

<cfset StructDelete(Session, "impersonating")>
<cfset StructDelete(Session, "impersonatorUserid")>

     <cflocation url="/loginform.cfm" />

