<!--- This ColdFusion page handles the insertion of user category references into the itemcatxref_user table. --->

<cfquery name="insertx">
    <!--- Insert a new record into the itemcatxref_user table with specified typeid, catid, userid, and IsCustom set to 1. --->
    INSERT INTO `itemcatxref_user` 
    (`typeid`, `catid`, `userid`, `IsCustom`) 
    VALUES 
    (#new_typeid#, #catid#, #userid#, 1);
</cfquery>
