
<cfinclude template="/include/qry/addfuSystemUsers.cfm" />

<cfoutput>
    <cfset no_added = #no_added# + 1 />
</cfoutput>

<cfif #dbug# is "Y">
    <cfoutput>
        <p>New system added.</p>
        <p>Total added: #no_added#</p>
    </cfoutput>
</cfif>

<!--- Determine action items needed for new system --->  
<cfinclude template="/include/qry/addDaysNo_5_2.cfm" />

<!--- Loop action items ---> 
<cfloop query="addDaysNo">
    <!--- add_action "Y" by default ---> 
    <cfset add_action = "Y" />

    <!--- isunique = 1: only completed once per contact  --->     
    <cfif #adddaysno.isunique# is "1">
        <!--- 
            Unique types:
            newsletter_yn
            socialmedia_yn
            googlealert_yn
        --->
        <cfinclude template="/include/qry/checkUnique_5_3.cfm" />
        
        <!--- if recordcount is 1, the action has been completed. Don't add action.  --->  
        <cfif #checkunique.recordcount# is "1">
            <cfset add_action = "N" />
            <cfoutput>
                #adddaysno.actionid# - #adddaysno.actiontitle# not added
                <br>
            </cfoutput>
        </cfif>
    </cfif>

    <!--- If add_action is still Y, add the action item --->
    <cfif #add_action# is "Y">
        <!--- set the start date as current date plus actiondaysno --->
        <cfset notstartdate = dateAdd('d', actionDaysNo, new_currentstartdate) />
        
        <!--- if start date is today or older, add as current active notification --->
        <cfif notstartdate lte currentstartdate>
            <cfinclude template="/include/qry/addNotification_5_4.cfm" />
        </cfif>
        
        <!--- if start date in the future, add "future" status --->
        <cfif notstartdate gt currentstartdate>
            <cfinclude template="/include/qry/addNotification_5_4.cfm" />
        </cfif>
    </cfif>
</cfloop>

