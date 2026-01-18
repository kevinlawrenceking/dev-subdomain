  <h3>audgenres</h3>
    
<!--- Use datasource from Application.cfc --->
<cfset dsn = application.dsn />
<cfset rev = application.rev />
<cfset suffix = application.suffix />
<cfset information_schema = application.information_schema />

<cfset rev = rand() />

<cfquery result="result"    name="u"  >
        SELECT * from taousers     
    </cfquery>

    <cfloop query="u">

         <cfquery result="result"  name="x"  >
            SELECT audgenreid,
audgenre,
audcatid,
isDeleted
 FROM audgenres
        </cfquery>

        <cfloop query="x">
            
             <cfquery result="result"  name="find"  >
            Select * from audgenres_user
            where audgenre = '#x.audgenre#' and audcatid = #x.audcatid# and userid = #u.userid#
            </cfquery>
            
            <cfif #find.recordcount# is "0">
            
                 <cfquery result="result"  name="insert"  >
                    
                    INSERT INTO `audgenres_user` (`audgenre`, `audcatid`, `userid`) 
                    VALUES ('#x.audgenre#','#x.audcatid#',#u.userid#);
          
                </cfquery>
                
                <cfoutput>           
                 audgenres added: #x.audgenre# (user #u.userid#)<BR>
                </cfoutput>
            </cfif>

        </cfloop>

</cfloop>

<cfquery result="result"  name="z"  >
        
        SELECT g.audgenre,u.audgenre,x.audroleid,x.audgenreid AS old_audgenreid, u.audgenreid AS NEW_audgenreid

FROM audgenres_audition_xref x INNER JOIN audgenres g ON g.audgenreid = x.audgenreid

INNER JOIN audgenres_user u ON u.audgenre = g.audgenre

WHERE g.audgenre = u.audgenre
        </cfquery>
        
        <cfloop query="z">

<cfquery result="result"  name="update"  >
                  UPDATE audgenres_audition_xref set audgenreid = #z.new_audgenreid# where audroleid = #z.audroleid# and audgenreid = #z.old_audgenreid#
            </cfquery>
        
        </cfloop>

