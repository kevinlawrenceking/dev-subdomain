<!--- This ColdFusion page processes audition questions and answers, including setting parameters and looping through questions to include answers. --->

<cfinclude template="/include/qry/aud_questions.cfm" />

<cfparam name="eventid" default="0" />
<cfparam name="new_eventid" default="0" />
<cfparam name="new_aText" default="" />
<cfparam name="new_aRating" default="" />
<cfparam name="new_aMemo" default="" />
<cfparam name="new_isDeleted" default="0" />

<!--- Loop through each question in the query "questions" --->
<cfloop query="questions">
    
    <cfset new_qid = questions.qid />
    <cfset new_answerid = questions.answerid />
    <cfset new_qtype = questions.qtype />
    <cfset new_value = "#evaluate('q#questions.qid#')#" />
    
    <!--- Include the answers for the current question --->
    <cfinclude template="/include/qry/audanswers_ins_215_1.cfm" />
    
</cfloop>

<!--- Redirect to the audition page with the specified parameters --->
<cflocation url="/app/audition/?audprojectid=#audprojectid#&eventid=#eventid#&secid=176" />
