 

<!--- Query to fetch all components from the database --->
<cfquery result="result" name="x" datasource="abod" >
    SELECT function_name,function_code_final
    FROM functions where function_code_final is not null
</cfquery>

<Cfoutput query="x">
<h3>#x.function_name#</h3>

<pre>#xmlformat(x.function_code_final)#</pre>

</cfoutput>
