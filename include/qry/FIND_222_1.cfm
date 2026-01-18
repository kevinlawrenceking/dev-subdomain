<!--- This ColdFusion page retrieves the audplatformid for a specific user and platform from the database. --->

<cfquery name="FIND" maxrows="1">
    <!--- Query to select audplatformid based on userid and CustomPlatform --->
    Select audplatformid 
    from audPlatforms_user_tbl 
    where userid = #userid# 
    and audplatform = '#CustomPlatform#'
</cfquery>
