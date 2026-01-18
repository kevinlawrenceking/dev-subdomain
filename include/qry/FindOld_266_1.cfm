<!--- This ColdFusion page retrieves the old value of a specified record from the database based on the provided record ID. --->

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
