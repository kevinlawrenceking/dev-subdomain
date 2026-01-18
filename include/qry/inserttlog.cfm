<!--- This ColdFusion page logs ticket details into the ticketslog_tbl database table. --->

<cfoutput>
    <!--- Outputting the SQL INSERT statement for logging ticket details. --->
    INSERT INTO `ticketslog_tbl` (`tlogDetails`, `userID`, `ticketid`, `ticketstatus`) VALUES
        ( #new_tlogDetails#
        , #userid#
        , #new_ticketid#
        , #new_ticketstatus#
        );
</cfoutput>

<cfinclude template="/include/qry/inserttlog_487_1.cfm" />

