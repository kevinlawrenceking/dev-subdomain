<!--- This ColdFusion page retrieves a parameter from the ftypexref_tbl based on the provided ftypefull value. --->

<cfquery name="find">
    SELECT cfparam 
    FROM ftypexref_tbl 
    WHERE ftypefull = '#x.type#'
</cfquery>
