<!--- This ColdFusion page handles the insertion of data into a specified table and includes various setup processes based on conditions. --->

<cfinclude template="rpg_load.cfm" />

<cfparam name="dbug" default="Y" />
<cfparam name="t1" default="0" />
<cfparam name="t2" default="0" />
<cfparam name="t3" default="0" />
<cfparam name="t4" default="0" />
<cfparam name="contactid" default="0" />

<cfscript>

    new_tablename = rpg.comptable;
    newformfields = valuelist(RPGAdd.fname);
</cfscript>

<cfoutput>
    <!--- Output the new table name and form fields for debugging purposes --->
    new_tablename: #new_tablename#<BR>
    newformfields: #valuelist(RPGAdd.fname)#
    /app/#pgDir#/?contactid=#contactid#&t1=#t1#&t2=#t2#&t3=#t3#&t4=#t4# 
</cfoutput>

<CFINSERT 
    TABLENAME="#new_tablename#" 
    formfields="#newformfields#">


<!--- Check if rpgid is equal to "8" and include necessary templates --->
<cfif #rpgid# is "8">
    <cfinclude template="/include/qry/find_246_1.cfm" />
    
    <!--- Set the selected user ID from the find query --->
    <cfset select_userid = find.userid />
    
    <cfinclude template="/include/user_setup.cfm" />
</cfif>

<!--- Redirect to the specified URL after processing --->
<cflocation url="/app/#pgDir#/?contactid=#contactid#&t1=#t1#&t2=#t2#&t3=#t3#&t4=#t4#" />
