

<cfquery result="result"  name="ParentFolder">
select * from pgdirs order by length(id) ASC
</cfquery>

<cfloop query="ParentFolder">
    <cfoutput>
 <h2>#ParentFolder.ID#</h2>
    </cfoutput>

<cfquery result="result"  name="Files">
    select * from pgfiles where parentid = '#ParentFolder.id#' and fileext = 'cfm'
    </cfquery>

<cfloop query="Files">
        
        <cfoutput><h5><cfif  #files.filestatus# is "COnfirmed"><span style="color:blue;">#files.filename#</span><cfelsE>#files.filename#</cfif></h5></cfoutput>
        
        </cfloop>
    
    </CFLOOP>
    
SELECT id FROM pgfiles WHERE id IN (SELECT distinct script_name  from bigbrother )
