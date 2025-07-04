<cfset z = 0>
     <cfset currentURL = cgi.server_name />
    <cfset host = ListFirst(currentURL, ".") />
<cfoutput>
<cfdirectory action="list" directory="D:\home\theactorsoffice.com\wwwroot\#host#-subdomain\include\" name="listRoot">
</cfoutput>
<h2>Files not used</h2>
<cfloop query="listRoot">

<cfset FileExt=ListLast(#name#,".")>            

<cfif #fileext# is "cfm">

<CFQUERY RESULT="RESULT" name="bro_add" datasource="abo" >
		select * from bigbrother where script_name = '/include/#name#'
          </CFQUERY>
          
    <Cfif #bro_add.recordcount# is "0">   

 <cfoutput>
    #name#<BR> 
<cfset z = #z# + 1 >
    
    </cfoutput>
    </Cfif>   
    </cfif>
   
</cfloop>
          <cfoutput>
          <h2>Total: #z#</h2>

            </cfoutput>
