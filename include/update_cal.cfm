    <Cfif #calendtime# is "00:00:00">

        <cfset calendtime="23:59:59" />

    </cfif>

    

<cfinclude template="/include/qry/update_cal.cfm" />

<cfset userService = createObject("component", "services.UserService")>
<cfset userService.dateformatpref(
    userid = userid,
    dateformatid = form.dateformatid
)>


<Cflocation url="/app/myaccount/?new_pgid=124&t4=1" />