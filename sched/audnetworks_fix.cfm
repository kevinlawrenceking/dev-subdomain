  <h3>Audnetworks</h3>
    
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
            SELECT networkid,
network,
audcatid,
isDeleted
 FROM audnetworks
        </cfquery>

        <cfloop query="x">
            
             <cfquery result="result"  name="find"  >
            Select * from audnetworks_user
            where network = '#x.network#' and userid = #u.userid#
            </cfquery>
            
            <cfif #find.recordcount# is "0">
            
                 <cfquery result="result"  name="insert"  >
                    
                    INSERT INTO `audnetworks_user` (`network`, `audcatid`, `userid`) 
                    VALUES ('#x.network#','#x.audcatid#',#u.userid#);
          
                </cfquery>
                
                <cfoutput>           
                 audnetworks added: #x.network# (user #u.userid#)<BR>
                </cfoutput>
            </cfif>

        </cfloop>

</cfloop>
