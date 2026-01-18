  <h3>Auddialects</h3>
    
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
            SELECT auddialectid,
auddialect,
audcatid,
isDeleted
 FROM auddialects
        </cfquery>

        <cfloop query="x">
            
             <cfquery result="result"  name="find"  >
            Select * from auddialects_user
            where auddialect = '#x.auddialect#' and userid = #u.userid#
            </cfquery>
            
            <cfif #find.recordcount# is "0">
            
                 <cfquery result="result"  name="insert"  >
                    
                    INSERT INTO `auddialects_user` (`auddialect`, `audcatid`, `userid`) 
                    VALUES ('#x.auddialect#','#x.audcatid#',#u.userid#);
          
                </cfquery>
                
                <cfoutput>           
                 auddialects added: #x.auddialect# (user #u.userid#)<BR>
                </cfoutput>
            </cfif>

        </cfloop>

</cfloop>
