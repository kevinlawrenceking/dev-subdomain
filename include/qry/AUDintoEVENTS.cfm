<cfparam name="new_audtypeid" default="" />

<cfparam name="new_audLocation" default="" />

<cfparam name="new_audlocid" default="" />

<cfparam name="new_eventStart" default="" />

<cfparam name="new_eventStartTime" default="" />

<cfparam name="new_eventStopTime" default="" />

<cfparam name="new_contactid" default="" />

<cfif #new_audtypeid# is not "">

    <cfinclude template="/include/qry/findtype_365_1.cfm" />

    <cfoutput>

        <cfset new_audtype="#findtype.audtype#" />

    </cfoutput>

    <cfif #new_audtype# is "Online">

        <cfif #new_audlocation# is not "">

            <cfset eventLocation="Online: #new_audLocation#" />

        </cfif>

        <Cfif #new_audlocation# is "">

            <cfset eventlocation="" />

        </Cfif>

    </cfif>

    <cfif #new_audtype# is not "Online">

        <cfif #new_audlocid# is not "0">

            <cfinclude template="/include/qry/findloc_365_2.cfm" />

            <cfoutput>

                <cfset eventlocation="#findloc.eventLocation#, #findloc.audlocadd1#, #findloc.audlocadd2#, #findloc.audcity#,#findloc.regionname# #findloc.audzip#, #findloc.countryname#" />

            </cfoutput>

        </cfif>

        <cfif #new_audlocid# is "0">

            <cfset eventlocation="" />

        </cfif>

    </cfif>

    <cfoutput>

        <cfset eventstart="#new_eventStart#" />

        <cfset eventStartTime="#new_eventStartTime#" />

        <cfset eventStopTime="#new_eventStopTime#" />

    </cfoutput>

<cfinclude template="/include/qry/add_365_3.cfm" />

    <cfinclude template="/include/qry/t_365_4.cfm" />

    <cfinclude template="/include/qry/tt_365_5.cfm" />

    <cfinclude template="/include/qry/dd_365_6.cfm" />

    <cfinclude template="/include/qry/inserts_365_7.cfm" />

</cfif>

