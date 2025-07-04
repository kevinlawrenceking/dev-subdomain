
<cfinclude template="/include/qry/eventtypes_user.cfm" />
 <style>   
<cfloop query="eventtypes_user">   
     <cfoutput>
 .colorkey-#eventtypes_user.id# {
  background-color: #eventtypes_user.eventtypecolor# !important; }
a.colorkey:hover,
a.colorkey:focus,
button.colorkey:hover,
button.colorkey:focus {
	background-color: ##343a40 !important;
}
</cfoutput>
</cfloop> 
</style>
