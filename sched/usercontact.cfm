    <cfset currentURL=cgi.server_name />
    <cfset host=ListFirst(currentURL, "." ) />

    <cfif #host# is "app">
        <cfset dsn="ABO">
       
            
        <cfelse>
    <cfset dsn = "abod" >
                
    </cfif>

<cfquery result="result" name="loginQuery" datasource="#dsn#" >
  SELECT * FROM taousers where contactid is null
</cfquery> 
 
<cfloop query="loginQuery">
<cfif #loginQuery.contactid# is "">

            <cfquery name="InsertContact"  datasource="#dsn#"  result="result">  
                INSERT INTO contactdetails (contactfullname,userid,user_yn)
                values ('#loginQuery.userfirstname# #loginQuery.userlastname#',#loginQuery.userid#,'Y')
            </cfquery>
    
            <cfset new_contactid = result.generatedkey />
    
            <cfquery result="result" name="InsertContact"  datasource="#dsn#" >  
            update taousers
            set contactid = #new_contactid#
            where userid = #loginQuery.userid#
            </cfquery>     
        
        </cfif> 

</cfloop>
