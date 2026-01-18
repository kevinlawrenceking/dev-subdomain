

<cfquery result="result"  name="x">
SELECT id FROM pgfiles WHERE id IN (SELECT distinct script_name  from bigbrother )
</cfquery>

<cfloop query="x">

<cfquery result="result"  name="insert">
      update pgfiles 
                set filestatus = 'Confirmed' where id = '#x.id#'
            </cfquery>

</cfloop>
                
   <cfquery result="result"  name="z">      
update pgfiles
SET filestatus = 'Confirmed'
WHERE id IN (SELECT distinct script_name  from bigbrother ) and filestatus = 'Found'
</cfquery>
