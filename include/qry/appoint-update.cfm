 

<cfinclude template="/include/qry/relationships_335_1.cfm" />

	 <cfinclude template="/include/qry/types_335_2.cfm" />
<cfinclude template="/include/qry/eventdetails_335_3.cfm" />

 <cfinclude template="/include/qry/findd_335_4.cfm" />
    
    <cfif #findd.recordcount# is "1">
        
        <cfset new_durid = findd.new_durid />
    
    </cfif>

<cfinclude template="/include/qry/contacts_335_5.cfm" />

