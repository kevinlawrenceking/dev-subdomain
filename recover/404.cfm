<cfinclude template="/Application.cfm" runonce="yes">

<!---
	
<cfparam name="new_browser" default="" />
<cfparam name="new_datetime" default="" />
<cfparam name="new_diagnostics" default="" />
<cfparam name="new_generatedContent" default="" />
<cfparam name="new_httpReferrer" default="" />
<cfparam name="new_mailTo" default="" />
<cfparam name="new_message" default="" />
<cfparam name="new_queryString" default="" />
<cfparam name="new_remoteAddress" default="" />
<cfparam name="new_rootCauseColumn" default="" />
<cfparam name="new_rootCauseDetail" default="" />
<cfparam name="new_rootCauseKnownColumn" default="" />
<cfparam name="new_rootCauseKnownLine" default="" />
<cfparam name="new_rootCauseKnownText" default="" />
<cfparam name="new_rootCauseLine" default="" />
<cfparam name="new_rootCauseMessage" default="" />
<cfparam name="new_rootCauseStackTrace" default="" />
<cfparam name="new_rootCauseSuppressed" default="" />
<cfparam name="new_rootCauseTokenText" default="" />
<cfparam name="new_rootCauseType" default="" />
<cfparam name="new_rootCauseTagName" default="" />
<cfparam name="new_template" default="" />
<cfparam name="new_type" default="" />
<cfparam name="new_errorid" default="00" />

<cfif #structKeyExists(error, "browser")#><Cfset new_browser = error.browser ><cfelse><Cfset new_browser = ""></Cfif>
<cfif #structKeyExists(error, "datetime")#><Cfset new_datetime = error.datetime ><cfelse><Cfset new_datetime = ""></Cfif>
<cfif #structKeyExists(error, "diagnostics")#><Cfset new_diagnostics = error.diagnostics ><cfelse><Cfset new_diagnostics = ""></Cfif>
<cfif #structKeyExists(error, "generatedcontent")#><Cfset new_generatedcontent = error.generatedcontent ><cfelse><Cfset new_generatedcontent = ""></Cfif>
<cfif #structKeyExists(error, "httpReferrer")#><Cfset new_httpReferrer = error.httpReferrer ><cfelse><Cfset new_httpReferrer = ""></Cfif>
<cfif #structKeyExists(error, "mailto")#><Cfset new_mailto = error.mailto ><cfelse><Cfset new_mailto = ""></Cfif>
<cfif #structKeyExists(error, "message")#><Cfset new_message = error.message ><cfelse><Cfset new_message = ""></Cfif>
<cfif #structKeyExists(error, "querystring")#><Cfset new_querystring = error.querystring ><cfelse><Cfset new_querystring = ""></Cfif>
<cfif #structKeyExists(error, "remoteaddress")#><Cfset new_remoteaddress = error.remoteaddress ><cfelse><Cfset new_remoteaddress = ""></Cfif>
<cfif #structKeyExists(error, "column")#><Cfset new_rootcausecolumn = error.rootcause.column ><cfelse><Cfset new_rootcausecolumn = ""></Cfif>
<cfif #structKeyExists(error, "ErrNumber")#><Cfset new_rootcauseErrNumber = error.rootcause.ErrNumber ><cfelse><Cfset new_rootcauseErrNumber = ""></Cfif>
<cfif #structKeyExists(error, "Detail")#><Cfset new_rootcauseDetail = error.rootcause.Detail ><cfelse><Cfset new_rootcauseDetail = ""></Cfif>
<cfif #structKeyExists(error, "KnownColumn")#><Cfset new_rootcauseKnownColumn = error.rootcause.KnownColumn ><cfelse><Cfset new_rootcauseKnownColumn = ""></Cfif>
<cfif #structKeyExists(error, "knownline")#><Cfset new_rootcauseknownline = error.rootcause.knownline ><cfelse><Cfset new_rootcauseknownline = ""></Cfif>
<cfif #structKeyExists(error, "knowntext")#><Cfset new_rootcauseknowntext = error.rootcause.knowntext ><cfelse><Cfset new_rootcauseknowntext = ""></Cfif>
<cfif #structKeyExists(error, "Line")#><Cfset new_rootcauseLine = error.rootcause.Line ><cfelse><Cfset new_rootcauseLine = ""></Cfif>
<cfif #structKeyExists(error, "message")#><Cfset new_rootcausemessage = error.rootcause.message ><cfelse><Cfset new_rootcausemessage = ""></Cfif>
<cfif #structKeyExists(error, "stacktrace")#><Cfset new_rootcausestacktrace = error.rootcause.stacktrace ><cfelse><Cfset new_rootcausestacktrace = ""></Cfif>
<cfif #structKeyExists(error, "Suppressed")#><Cfset new_rootcauseSuppressed = error.rootcause.Suppressed ><cfelse><Cfset new_rootcauseSuppressed = ""></Cfif>
<cfif #structKeyExists(error, "tokentext")#><Cfset new_rootcausetokentext = error.rootcause.tokentext ><cfelse><Cfset new_rootcausetokentext = ""></Cfif>
<cfif #structKeyExists(error, "type")#><Cfset new_rootcausetype = error.rootcause.type ><cfelse><Cfset new_rootcausetype = ""></Cfif>
<cfif #structKeyExists(error, "TagName")#><Cfset new_rootcauseTagName = error.rootcause.TagName ><cfelse><Cfset new_rootcauseTagName = ""></Cfif>
<cfif #structKeyExists(error, "template")#><Cfset new_template = error.template ><cfelse><Cfset new_template = ""></Cfif>
<cfif #structKeyExists(error, "type")#><Cfset new_type = error.type ><cfelse><Cfset new_type = ""></Cfif>

<HR>
	
<cfsavecontent variable="qry"><cfoutput>
INSERT INTO [dbo].[errors]<BR>
	   ([browser]<BR>
	   ,[diagnostics]<BR>
	   ,[generatedContent]<BR>
	   ,[httpReferrer]<BR>
	   ,[mailTo]<BR>
	   ,[message]<BR>
	   ,[queryString]<BR>
	   ,[remoteAddress]<BR>
	   ,[rootCauseColumn]<BR>
	   ,[rootCauseDetail]<BR>
	   ,[rootCauseKnownColumn]<BR>
	   ,[rootCauseKnownLine]<BR>
	   ,[rootCauseKnownText]<BR>
	   ,[rootCauseLine]<BR>
	   ,[rootCauseMessage]<BR>
	   ,[rootCauseStackTrace]<BR>
	   ,[rootCauseSuppressed]<BR>
	   ,[rootCauseTokenText]<BR>
	   ,[rootCauseType]<BR>
	   ,[rootCauseTagName]<BR>
	   ,[template]<BR>
	   ,[type] <BR>
	 <BR>
)
 VALUES<BR>
	   ('#new_browser#'<BR>
	   ,'#new_diagnostics#'<BR>
	   ,'#new_generatedContent#'<BR>
	   ,'#new_httpReferrer#'<BR>
	   ,'#new_mailTo#'<BR>
	   ,'#new_message#'<BR>
	   ,'#new_queryString#'<BR>
	   ,'#new_remoteAddress#'<BR>
	   ,'#new_rootCauseColumn#'<BR>
	   ,'#new_rootCauseDetail#'<BR>
	   ,'#new_rootCauseKnownColumn#'<BR>
	   ,'#new_rootCauseKnownLine#'<BR>
	   ,'#new_rootCauseKnownText#'<BR>
	   ,'#new_rootCauseLine#'<BR>
	   ,'#new_rootCauseMessage#'<BR>
	   ,'#new_rootCauseStackTrace#'<BR>
	   ,'#new_rootCauseSuppressed#'<BR>
	   ,'#new_rootCauseTokenText#'<BR>
	   ,'#new_rootCauseType#'<BR>
	   ,'#new_rootCauseTagName#'<BR>
	   ,'#new_template#'<BR>
	   ,'#new_type#'<BR>
	   )</cfoutput>
</cfsavecontent>

		 
		 
<CFTRY>   
     
      <CFQUERY name="UPDATE" datasource="Reach" result="emp_id"  >   
    INSERT INTO [dbo].[errors]
           ([browser]
           ,[diagnostics]
           ,[generatedContent]
           ,[httpReferrer]
           ,[mailTo]
           ,[message]
           ,[queryString]
           ,[remoteAddress]
           ,[rootCauseColumn]
           ,[rootCauseDetail]
           ,[rootCauseKnownColumn]
           ,[rootCauseKnownLine]
           ,[rootCauseKnownText]
           ,[rootCauseLine]
           ,[rootCauseMessage]
           ,[rootCauseStackTrace]
           ,[rootCauseSuppressed]
           ,[rootCauseTokenText]
           ,[rootCauseType]
           ,[rootCauseTagName]
           ,[template]
           ,[type] 
         
   )
     VALUES
           (<Cfqueryparam value="#new_browser#" cfsqltype="CF_SQL_VARCHAR" />
           ,<Cfqueryparam value="#new_diagnostics#" cfsqltype="CF_SQL_VARCHAR" />
           ,<Cfqueryparam value="#new_generatedContent#" cfsqltype="CF_SQL_VARCHAR" />
           ,<Cfqueryparam value="#new_httpReferrer#" cfsqltype="CF_SQL_VARCHAR" />
           ,<Cfqueryparam value="#new_mailTo#" cfsqltype="CF_SQL_VARCHAR" />
           ,<Cfqueryparam value="#new_message#" cfsqltype="CF_SQL_VARCHAR" />
           ,<Cfqueryparam value="#new_queryString#" cfsqltype="CF_SQL_VARCHAR" />
           ,<Cfqueryparam value="#new_remoteAddress#" cfsqltype="CF_SQL_VARCHAR" />
           ,<Cfqueryparam value="#new_rootCauseColumn#" cfsqltype="CF_SQL_VARCHAR" />
           ,<Cfqueryparam value="#new_rootCauseDetail#" cfsqltype="CF_SQL_VARCHAR" />
           ,<Cfqueryparam value="#new_rootCauseKnownColumn#" cfsqltype="CF_SQL_VARCHAR" />
           ,<Cfqueryparam value="#new_rootCauseKnownLine#" cfsqltype="CF_SQL_VARCHAR" />
           ,<Cfqueryparam value="#new_rootCauseKnownText#" cfsqltype="CF_SQL_VARCHAR" />
           ,<Cfqueryparam value="#new_rootCauseLine#" cfsqltype="CF_SQL_VARCHAR" />
           ,<Cfqueryparam value="#new_rootCauseMessage#" cfsqltype="CF_SQL_VARCHAR" />
           ,<Cfqueryparam value="#new_rootCauseStackTrace#" cfsqltype="CF_SQL_VARCHAR" />
           ,<Cfqueryparam value="#new_rootCauseSuppressed#" cfsqltype="CF_SQL_VARCHAR" />
           ,<Cfqueryparam value="#new_rootCauseTokenText#" cfsqltype="CF_SQL_VARCHAR" />
           ,<Cfqueryparam value="#new_rootCauseType#" cfsqltype="CF_SQL_VARCHAR" />
           ,<Cfqueryparam value="#new_rootCauseTagName#" cfsqltype="CF_SQL_VARCHAR" />
           ,<Cfqueryparam value="#new_template#" cfsqltype="CF_SQL_VARCHAR" />
           ,<Cfqueryparam value="#new_type#" cfsqltype="CF_SQL_VARCHAR" />

           )
    </cfquery>  

	<CFCATCH TYPE="Any"></CFCATCH>
    
</CFTRY>

<cfset new_errorid= emp_id.generatedkey>

--->

<cfset inet = createObject("java", "java.net.InetAddress") />
<cfset hostName = inet.getLocalHost().getHostName() />
			 


<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>TMZTools Error Occurred</title>
<link href="/includes/main.css" rel="stylesheet" type="text/css">
<link href="/includes/jQueryAssets/jquery.ui.core.min.css" rel="stylesheet" type="text/css">
<link href="/includes/jQueryAssets/jquery.ui.theme.min.css" rel="stylesheet" type="text/css">
<script src="/includes/jQueryAssets/jquery-3.1.1.min.js" type="text/javascript"></script>
</head>

<body leftmargin="4" topmargin="4" rightmargin="4" bottommargin="4" marginwidth="4" marginheight="4">

<cfinclude template="/top_navigation.cfm">

<CFIF Trim(GetAuthUser()) neq "">

	<CFIF Trim(GetAuthUser()) eq "xmbuchhe">
        <CFSET To_Email = "Mark.Buchheim@tmz.com">
    <cfelseif Trim(GetAuthUser()) eq "xkking">
		<CFSET To_Email = "kevin.king@tmz.com">
	<CFELSE>
		<CFSET To_Email = "it@tmz.com">
	</CFIF>

	<cfmail to="#To_Email#" from="it@tmz.com" subject="TMZTools Error - http://#cgi.server_name##cgi.script_name#" type="html">

	<CFOUTPUT>

	<B>ERROR PAGE:</B> http://#cgi.server_name##cgi.script_name#?#cgi.query_string#<P>

	<B>HOSTNAME:</B> #hostName#<P>

	<CFTRY><B>USERNAME:</B> #GetAuthUser()#<P><CFCATCH type="Any"></CFCATCH></CFTRY>

	<B>ERROR DATE / TIME:</B> #DateFormat( Now(), "mmm d, yyyy" )# at #TimeFormat( Now(), "hh:mm TT" )#<P>

	<!--- <B>ID:</B> E323#new_errorid#<BR> --->

	<HR><BR><BR>

	<cfdump var="#error#" label="Error">
	<cfdump var="#form#" label="Form">
	<cfdump var="#url#" label="URL">

	</CFOUTPUT>

	</cfmail>

</CFIF>

<table width="99%" border="1" cellpadding="2" cellspacing="0" bordercolor="#000000" bgcolor="#FFFFFF" style="margin-top: 65px;" align="center">

	<TR>

		<TD>

		<h1>
		TMZTools Error Occurred
		</h1>

		<p>
		An internal server error has occurred, but our squad of IT Ninjas are looking into it!<P>

		An email has been sent to <a href="mailto:it@tmz.com">it@tmz.com</A> with all the error details.<P>
		<UL>
		<LI>We ask you to try what you were doing once again, because maybe you will detect that you were doing something wrong.<P>
		<LI>If you still get an error, clear your broswer cache, close the browser, and try again.<P>
		<LI>If you still get an error, try a different browser.<P>
		<LI>If you still get an error, try a different computer (we know...it's not your regular computer be we are trying to isolate the issue and your doing this helps track down these errors).<P>
		<LI>If you think it will help, send <a href="mailto:it@tmz.com">it@tmz.com</A> an email describing what you did to cause the error and what you did to try to troubleshoot it.<P>
		</UL>

		THANKS!

		</p>

		</TD>
			
	</TR>

</TABLE> 
       
            <cfoutput>
          	<cfdump var="#error#" label="Error">
	<cfdump var="#form#" label="Form">
	<cfdump var="#url#" label="URL">  
            </cfoutput>
        
            
</body>
</html>