<!--- This ColdFusion page inserts a new item type for a specific user into the itemtypes_user table. --->

<cfquery name="insert" result="typeresult">
    <!--- Insert a new item type for a user into the database --->
    INSERT INTO itemtypes_user (valuetype, userid)
    VALUES ('#customtype#', #userid#)
</cfquery>
