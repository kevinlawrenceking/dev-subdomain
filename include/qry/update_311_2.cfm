<!--- This ColdFusion page updates a specified field in a database table based on a given record ID. --->
<cfquery name="update">
    <!--- Execute an update statement on the specified table. --->
    UPDATE #compTable#
    Set #fname# = <Cfqueryparam value="#newvalue#" cfsqltype="#fsqltype#" />
    where #recname# = <Cfqueryparam value="#recid#" cfsqltype="#fidsqltype#" />
</cfquery>
