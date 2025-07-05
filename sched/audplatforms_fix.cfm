  <h3>Audaudplatforms</h3>
    
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
            SELECT audplatformid,
audplatform,
isDeleted
 FROM audplatforms
        </cfquery>

        <cfloop query="x">
            
             <cfquery result="result"  name="find"  >
            Select * from audplatforms_user
            where audplatform = '#x.audplatform#' and userid = #u.userid#
            </cfquery>
            
            <cfif #find.recordcount# is "0">
            
                 <cfquery result="result"  name="insert"  >
                    
                    INSERT INTO `audplatforms_user` (`audplatform`, `userid`) 
                    VALUES ('#x.audplatform#',#u.userid#);
          
                </cfquery>
                
                <cfoutput>           
                 audplatforms added: #x.audplatform# (user #u.userid#)<BR>
                </cfoutput>
            </cfif>

        </cfloop>

</cfloop>
