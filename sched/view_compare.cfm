<cfquery result="result" name="find_table" datasource="abod" >
SELECT qry_table 
FROM tao_files 
WHERE qry_view IS NULL AND qry_type = 'sel' AND qry_source = 'view' AND qry_table IS NOT null
ORDER BY qry_table, qry_details
LIMIT 1;
</cfquery>

<Cfloop query="find_table">

<cfquery result="result" name="x" datasource="abod" >
SELECT id,qry_details,qry_table 
FROM  tao_files 
WHERE qry_type = 'sel' 
AND qry_source = 'view' 
and qry_view is null
AND qry_table IS NOT NULL AND qry_table = '#find_table.qry_table#'
ORDER BY qry_table, qry_details;
</cfquery>

<cfoutput>
<h2>table: #find_table.qry_table#</h2></cfoutput>

<cfif #x.recordcount# is "1">

<p>Create a view from this query</p>

<p>Generate the sql to write the views</p>

<p>Ignore any conditions that include variables</p>

<p>Ignore the order by and don't include</p>

<p>Every column must be prefixed with its table alias to avoid ambiguity.</p>
<p>When joins are involved, all columns should be fully qualified with their corresponding table aliases.</p>

<p>Ensure that all columns used in the WHERE clause are included in the SELECT statement of the view. For example, 
if the query is SELECT id, name FROM table WHERE userid = #userid#, the view should be created as 
SELECT id, name, userid FROM table to allow filtering on userid in the future.</p>

<p>***IMPORTANT*** After generating the query, **automatically remove any duplicate columns** 
that are listed multiple times. For example, if `a.audroleid` and `ad.audroleid` are both in the 
SELECT statement, only keep one of them.
</p>

<p>come up with a name for the view making it "vm_" + qry_table + "_" + a secondary table name to make the view name unique</p>

<p>update the tao_files table</p>

<p>if the view already exits, first drop it</p>

<p>UPDATE TAO_FILES SET QRY_VIEW = `NAME OF VIEW` WHERE ID = `ID`</p>

<P>SEPARATE the queries with semi colons and print in one piece of code so I could copy/paste</p>

<P>You only have to create the final code block with everything in it [NO VERBOSE]</p>

<cfloop query="x"><cfoutput>
<h3>ID: #x.id#</h3>
<p>qry_details: #x.qry_details#</p>
<p>qry_table: #x.qry_table#</p>
</cfoutput>
</cfloop>

<Cfelse>

<p>How can we consolidate these queries into the least amount of views needed?</p>

<p>If two or more queries have the same joins and only different fields, write one view that would work for both</p>

<p>Generate the sql to write the views</p>

<p>Ignore any conditions that include variables</p>

<p>Every column must be prefixed with its table alias to avoid ambiguity.</p>
<p>When joins are involved, all columns should be fully qualified with their corresponding table aliases.</p>

<p>Ignore the order by and don't include</p>

<p>Ensure that all columns used in the WHERE clause are included in the SELECT statement of the view. For example, if the query is SELECT id, name FROM table WHERE userid = #userid#, the view should be created as SELECT id, name, userid FROM table to allow filtering on userid in the future.</p>
<p>***IMPORTANT*** After generating the query, **automatically remove any duplicate columns** 
that are listed multiple times. For example, if `a.audroleid` and `ad.audroleid` are both in the 
SELECT statement, only keep one of them.
</p>

<p>come up with a name for the view making it "vm_" + qry_table + "_" + a secondary table name to make the view name unique</p>

<p>update the tao_files table</p>

<p>if the view already exits, first drop it</p>

<p>UPDATE TAO_FILES SET QRY_VIEW = `NAME OF VIEW` WHERE ID = `ID`</p>

<P>SEPARATE the queries with semi colons and print in one piece of code so I could copy/paste</p>

<P>You only have to create the final code block with everything in it [NO VERBOSE]</p>

<cfloop query="x"><cfoutput>
<h3>ID: #x.id#</h3>
<p>qry_details: #x.qry_details#</p>
<p>qry_table: #x.qry_table#</p>
</cfoutput>
</cfloop>
</cfif>

</cfloop>
