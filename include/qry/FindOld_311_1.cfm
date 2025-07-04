<!--- This ColdFusion page retrieves the old value of a record based on the provided record ID and table name. --->

<cfquery name="FindOld">
    <!--- Query to select the old value and record name from the specified table. --->
    Select 
        c.#fname# as OldValue,
        recordname
    from 
        #compTable# c 
        #compInner#
    WHERE 
        c.#recname# = #recid#
</cfquery>
