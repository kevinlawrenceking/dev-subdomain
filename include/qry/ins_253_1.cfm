<!--- This ColdFusion page handles the deletion of records from the audmedia_auditions_xref table based on media ID and audition project ID. --->

<cfquery name="ins">   
    <!--- Delete records from the audmedia_auditions_xref table where the media ID and audition project ID match the provided values. --->
    delete from audmedia_auditions_xref 
    where mediaid = #mediaid# 
    and audprojectid = #audprojectid# 
</cfquery>
