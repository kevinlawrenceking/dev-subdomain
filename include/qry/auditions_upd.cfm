

<cfparam name="new_userid" default="" />

<cfparam name="new_audRoleID" default="" />

<cfparam name="new_audTypeID" default="" />

<cfparam name="new_audLocation" default="" />

<cfparam name="new_audlocid" default="" />

<cfparam name="new_eventStart" default="" />

<cfparam name="new_eventStartTime" default="" />

<cfparam name="new_eventStopTime" default="" />

<cfparam name="new_audplatformid" default="" />

<cfparam name="new_audStepID" default="1" />

<cfparam name="new_parkingDetails" default="" />

<cfparam name="new_workwithcoach" default="0" />

<cfparam name="new_isDeleted" default="0" />

<cfparam name="new_trackmileage" default="0" />

<cfparam name="new_audbooktypid" default="0" />

<cfparam name="new_callbacktypid" default="" />

<cfparam name="new_eventLocation" default="" />

<cfparam name="new_audlocadd1" default="" />

<cfparam name="new_audlocadd2" default="" />

<cfparam name="new_audcity" default="" />

<cfparam name="new_region_id" default="" />



<cfparam name="new_audzip" default="" />

<cfif #new_eventStartTime# is not "">

    <cfinclude template="/include/qry/duration.cfm" />

 <cfset new_durseconds = duration.durseconds />

<cfset new_eventStopTime = "#DateAdd("s","#new_eventStartTime#","#new_durseconds#")#" />

<cfoutput>
    
    new_eventStartTime: #timeformat(new_eventStartTime,'HH:MM:SS')#<BR>
    new_durseconds: #new_durseconds#<BR>
workwithcoach: #new_workwithcoach#<BR>
  statement:     SELECT ADDTIME("#timeformat('#new_eventStartTime#','HH:MM:SS')#", "#new_durseconds#") as new_eventStopTime <BR>  

<cfset new_eventStopTime="#timeformat(DateAdd("s","#new_durseconds#","#new_eventStartTime#"),'HH:MM:SS')#" />
    
    new_eventStopTime: #new_eventStopTime#<BR>
    
</cfoutput>

</cfif>


<cfinclude template="/include/qry/auditions_ins_374_1.cfm" />

<cfoutput>

        <cfset eventstart="#new_eventStart#" />

        <cfset eventStartTime="#new_eventStartTime#" />

        <cfset eventStopTime="#new_eventStopTime#" />
eventstop: #new_eventStopTime#
    </cfoutput>


