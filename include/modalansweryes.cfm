<!--- This ColdFusion page processes system updates based on audition dates and manages notifications accordingly. --->

<cfset sunotes = "Added via past date audition." />

<cfinclude template="/include/qry/fin_recordname_157_1.cfm" />

<!--- Check if a record is found in fin_recordname --->
<cfif #fin_recordname.recordcount# is "1">
    
    <cfset new_contactname = fin_recordname.recordname />

    <cfinclude template="/include/qry/find_fu_157_2.cfm" />

    <!--- Check if no records are found in find_fu --->
    <cfif #find_fu.recordcount# is "0">

        <cfoutput>
            <cfset suStartDate = "#DateFormat(new_suStartDate, 'yyyy-mm-dd')#" />
            <cfset currentStartDate = "#DateFormat(new_suStartDate, 'yyyy-mm-dd')#" />
        </cfoutput>

        <cfinclude template="/include/qry/addSystem_157_3.cfm" />

        <cfinclude template="/include/qry/CompleteTargetSystems_157_4.cfm" />
        <cfinclude template="/include/qry/sudetails_157_5.cfm" />
        <cfinclude template="/include/qry/Insert_157_6.cfm" />
        <cfinclude template="/include/qry/addDaysNo_157_7.cfm" />

        <cfset add_action = "Y" />
        <cfset new_actionid = addDaysNo.actionid />
        <cfset actiondaysno = numberformat(addDaysNo.actiondaysno) />

        <!--- Check if addDaysNo is unique --->
        <cfif #adddaysno.isunique# is "1">
            <cfinclude template="/include/qry/checkUnique_157_8.cfm" />

            <!--- Check if the unique record exists --->
            <cfif #checkunique.recordcount# is "1">
                <cfset #add_action# = "N" />
            </cfif>
        </cfif>

        <!--- Proceed if action is still set to "Y" --->
        <cfif #add_action# is "Y">

            <cfif #actiondaysno# is "">
                <cfset actiondaysno = 0 />
            </cfif>

            <cfset notstartdate = dateAdd('d', actionDaysNo, currentstartdate) />

            <!--- Check if the not start date is less than or equal to the current start date --->
            <cfif notstartdate lte currentstartdate>
                <cfinclude template="/include/qry/addNotification_157_9.cfm" />
            <cfelse>
                <cfinclude template="/include/qry/addNotification_157_10.cfm" />
            </cfif>

        </cfif>

    </cfif>
</cfif>
