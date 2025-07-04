<cfset def_suStartDate=dateFormat(Now(),'yyyy-mm-dd')/>
 
 <cfparam name="SuStartDate" default="#def_suStartDate#" />


<cfset systemUserService = createObject("component", "services.SystemUserService")>
<cfset NewSUID = systemUserService.addfuSystemUsers(
    systemid = systemid,
    contactid = contactid,
    userid = userid,
    suStartDate = suStartDate
)>