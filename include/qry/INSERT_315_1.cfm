<!--- This ColdFusion page handles the insertion of user uploads into the database. --->

<cfquery name="INSERT" result="result">
    <!--- Insert a new record into the uploads table for the specified user ID. --->
    INSERT INTO `uploads` (userid)
    VALUES (#userid#)
</cfquery>
