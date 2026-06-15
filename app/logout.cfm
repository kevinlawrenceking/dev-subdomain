<cfif #isdefined('userid')# >

 <cfset StructDelete(Session, "userid")>

    </cfif>

 <!--- Clear any impersonation state so it never leaks into the next login --->
 <cfset StructDelete(Session, "impersonating")>
 <cfset StructDelete(Session, "adminUserid")>

     <cflocation url="/loginform.cfm" />

