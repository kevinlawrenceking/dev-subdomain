

<cfquery result="result"  name="na">
    UPDATE thrivecart_cancel SET STATUS = 'N/A' WHERE basepaymentplanid NOT IN (SELECT basepaymentplanid FROM paymentplans)
</cfquery>

<cfquery result="result"  name="x">
    SELECT * from thrivecart_cancel where status = 'Pending'
</cfquery>
<cfoutput>#x.recordcount#</cfoutput>
<cfloop query="x">

    <cfset thrivecart_cancel_id=x.id />
    <cfset thrivecart_cancel_invoiceid=x.invoiceid />
    <cfset thrivecart_cancel_canceldate=x.canceldate />

<cfquery result="result"  name="Find">
        SELECT * from thrivecart where invoiceid = '#thrivecart_cancel_invoiceid#'
    </cfquery>

    <cfif #find.recordcount# is "0">
        No record found!<BR>

    </cfif>

    <cfif #find.recordcount# is "1">
        <cfset thrivecart_id=find.id />
        <cfset thrivecart_invoiceid=find.invoiceid />

        <h2>
            <Cfoutput>#find.customerfirst# #find.customerlast#</Cfoutput>
        </h2>
        <cfoutput>
        
        <P>Thrivecart cancel id: #thrivecart_cancel_id#</P>
 <P>Thrivecart cancel invoice id: #thrivecart_cancel_invoiceid#</P>
        <P>Thrivecart id: #thrivecart_id#</P>
 <P>Thrivecart invoice id: #thrivecart_invoiceid#</P>
           
            </cfoutput>

<cfquery result="result"  name="FindUser" maxrows="1">
            SELECT * from taousers where customerid = #thrivecart_id#
        </cfquery>

        <cfif #finduser.recordcount# is "1">

            <cfset new_userid=finduser.userid />

            <cfset thrivecart_id_=find.id />
            
            <cfset customerid=find.id />
            
            <cfset thrivecart_invoiceid=find.invoiceid />

            <cfquery result="result"  name="update_thrivecart">
            UPDATE thrivecart
            SET STATUS = 'Cancelled'
            ,canceldate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#thrivecart_cancel_canceldate#" />
            WHERE id = #thrivecart_id#
            </cfquery>
            <cfoutput>
            <p>[#thrivecart_id#] Thrivecart status set to CANCELLED, canceldate set to #thrivecart_cancel_canceldate#</p>
            </cfoutput>
            
            <cfquery result="result"  name="update_thrivecart_cancel">
            UPDATE thrivecart_cancel
            SET STATUS = 'Cancelled'
            WHERE id = #thrivecart_cancel_id#
            </cfquery>
            
                     <cfoutput>
            <p>[#thrivecart_cancel_id#] Thrivecart Cancel status set to CANCELLED</p>
            </cfoutput>

<cfquery result="result"  name="update_user">
            update taousers
            set userstatus = 'Cancelling'
            where userid = #new_userid#
            </cfquery>
                             <cfoutput>
            <p>[#new_userid#] User status set to CANCELLING</p>
            </cfoutput>

</cfif>

<cfif #find.recordcount# is not "0" and #find.recordcount# is not "1">

            More than one record!<BR>
        </cfif>

</cfif>

</cfloop>

<cfquery result="result"  name="Y">       
SELECT u.userid as new_userid,u.*,t.canceldate FROM thrivecart t INNER JOIN thrivecart_cancel c ON t.InvoiceID = c.invoiceid
INNER JOIN taousers u ON u.customerid = t.id
WHERE c.canceldate <= CURRENT_DATE()  AND u.userstatus <> 'Cancelled'
        </cfquery>
        
        <cfloop query="Y">
        
           <cfquery result="result"  name="update">    
               
               update taousers
               set userstatus = 'Cancelled',
               isdeleted = 1
               where userid = #Y.new_userid#
            </cfquery>

<cfoutput>
            #Y.userfirstname# #y.userlastname# had a cancel date of #dateformat(Y.canceldate)# and was cancelled today.<BR>
            </cfoutput>
            
            </Cfloop>

