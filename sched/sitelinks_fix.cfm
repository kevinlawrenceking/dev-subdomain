
        xx

<cfquery result="result"  name="u"  >
      select * from taousers
        </cfquery>

    <cfloop query="u">

        <cfquery result="result"  name="xs"  >
   SELECT * 

FROM pgpanels pn inner join pgpanels_user_xref x on x.pnid = pn.pnid inner join taousers u on u.userid = x.userid 
 
WHERE u.userid = #u.userid#
 
 AND pnfilename = 'mylinks_user.cfm' 
 AND pn.pntitle NOT IN (SELECT pntitle FROM sitetypes_user WHERE userid = #u.userid#)
        </cfquery>

 <cfif #xs.recordcount# is not "0">
        <cfoutput>
        <h2>#u.recordname#: #xs.recordcount# orphans</h2></cfoutput>
        </cfif>
        
      <cfloop query="xs">
        
        <cfoutput>#xs.pntitle#-#xs.pnfilename#-#xs.userid#xxxx<br></cfoutput>
        
        </cfloop>  

</cfloop>

