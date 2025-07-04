

<cfset cancel_total = 0 />
  <cfset move_total = 0 />  
    
<cfquery result="result"  name="x">
    SELECT * from taousers where userstatus = 'Cancelling'
</cfquery>
<cfoutput><h2>Total Cancellations: #x.recordcount#</h2></cfoutput>

<cfloop query="x">
<cfset new_userid = x.userid />
<cfset new_username = x.recordname />
<cfset new_useremail = x.useremail />
    <cfset new_userfirstname = x.userfirstname />
    <cfset new_userlastname = x.userlastname />
<h3><cfoutput>#new_username#</cfoutput></h3>

<cfquery result="result"  name="findemail" maxrows="1">
        SELECT p.planname, t.* FROM thrivecart t  
        inner join paymentplans p on p.basepaymentplanid = t.basepaymentplanid
        
        WHERE baseproductname = 'The actor''s office' AND STATUS <> 'Cancelled'
        and customeremail = '#new_useremail#' 

order by t.id desc
 
</cfquery>

<cfif #findemail.recordcount# is "1">
    
    <cfset new_id = findemail.id />
    <cfset new_planname = findemail.planname />
     <cfset new_status = findemail.status />

      <p><cfoutput>
          <cfset move_total = #move_total# + 1 />
          
          Moved to plan: #new_planname# (#new_status#)</cfoutput></p>
    
               <cfquery result="result"  name="update_user">
            update taousers
            set userstatus = 'Active'
                   ,customerid = #new_id#
            where userid = #new_userid#
            </cfquery>
                             <cfoutput>
            <p>[#new_userid#] User status set to CANCELLING</p>
            </cfoutput>

<cfelse>
        <p style="color:red;">No plan found. <cfoutput>
              <cfset cancel_total = #cancel_total# + 1 />

#new_username# Cancelled</cfoutput></p>
        
                  <cfquery result="result"  name="update_user">
            update taousers_tbl
            set userstatus = 'Cancelled'
                  
            where userid = #new_userid#
            </cfquery>

</cfif>

</cfloop>
<cfoutput>
        
        <h4>Total moved to other plan: #move_total#</h4>
     <h4>Total cancelled: #cancel_total#</h4>
        </cfoutput>
