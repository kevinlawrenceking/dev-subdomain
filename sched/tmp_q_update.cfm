<cfinclude template="remote_load.cfm" />

<cfquery result="result"  name="u"  >
        SELECT * from taousers 
    </cfquery>

    <cfloop query="u">

         <cfquery result="result"  name="x"  >
        SELECT * FROM audquestions_default where isdeleted = 0
        </cfquery>

<cfloop query="x">
            
             <cfquery result="result"  name="find"  >
            Select * from audquestions_user
            where isdeleted is false and qorder = #x.qorder# and userid = #u.userid#
            </cfquery>
            
            <cfif #find.recordcount# is "0">
                
                <cfoutput>
                  
                    INSERT INTO `audquestions_user   (`qtypeid`,  `qtext`, `qorder`, `userid`) 
                    VALUES (#x.qtypeid#,  '#x.qtext#', #x.qorder#, #u.userid#);
                </cfoutput><cfabort>
            
                 <cfquery result="result"  name="insert"  >
                    
                    INSERT INTO `audquestions_user   (`qtypeid`,  `qtext`, `qorder`, `userid`) 
                    VALUES (#x.qtypeid#,  '#x.qtext#', #x.qorder#, #u.userid#);
          
                </cfquery>
                <cfif #dbug# is "Y">
                <CFOUTPUT>tags_user: #x.qtext# added to #u.userfirstname#</CFOUTPUT><BR>
                </cfif>

</cfif>

        </cfloop>

</cfloop>
        
