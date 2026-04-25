    <Cfif #calendtime# is "00:00:00">

        <cfset calendtime="23:59:59" />

    </cfif>

    <!--- Reject end-before-start so we don't poison the appointment slot dropdowns. --->
    <cfif structKeyExists(form, "calstarttime") AND structKeyExists(form, "calendtime")
          AND len(trim(form.calendtime)) AND len(trim(form.calstarttime))
          AND form.calendtime LTE form.calstarttime>
        <cflocation url="/app/myaccount/?new_pgid=124&t4=1&prefError=time" addtoken="false" />
    </cfif>

<cfinclude template="/include/qry/update_cal.cfm" />

<cfset userService = request.svc("UserService")>
<cfset userService.dateformatpref(
    userid = userid,
    dateformatid = form.dateformatid
)>


<Cflocation url="/app/myaccount/?new_pgid=124&t4=1" />