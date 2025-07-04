<!--- This ColdFusion page processes database table descriptions and inserts new records based on the structure of the specified table. --->

<cfset dbug="Y" />

<!--- Check if the table name is defined; if not, abort the process. --->
<cfif not #isdefined('tname')#>
    tname required! <cfabort>
</cfif>

<cfset new_userid=cookie.userid />

<!--- Query to describe the structure of the specified table. --->
<cfinclude template="/include/qry/allfields_536_2.cfm" />

<!--- Filter the fields to exclude primary keys and auto-increment fields. --->
<cfinclude template="/include/qry/x_464_2.cfm" />

<!--- Debugging output to display the table structure if debugging is enabled. --->
<cfif #dbug# is "Y">
    <cftable query="x" colheaders="true" border="true" htmltable="true">
        <cfcol header="Field" text="#field#" />
        <cfcol header="Type" text="#type#" />
        <cfcol header="Null" text="#Null#" />
        <cfcol header="Key" text="#Key#" />
        <cfcol header="Default" text="#default#" />
    </cftable>
</cfif>

<!--- Loop through the fields to set default values based on field types. --->
<cfloop query="x">
    <!--- Set default value for bit fields. --->
    <cfif x.type is "bit(1)">
        <Cfset new_default=0 />
    </cfif>

    <!--- Set default value for non-bit fields. --->
    <cfif x.type is not "bit(1)">
        <Cfset new_default=x.default />
    </cfif>

    <!--- Ensure a default value is set if the field cannot be null. --->
    <cfif new_default eq "" and x.Null eq "NO">
        <Cfset new_default="0" />
    </cfif>

    <!--- Create a new variable for each field with its default value. --->
    <cfparam name="new_#x.field#" default="#new_default#" />
</cfloop>

<!--- Prepare to insert a new record into the specified table. --->
<cfinclude template="/include/qry/tname_ins_464_3.cfm" />

<!--- Debugging output to display the result of the insert operation if debugging is enabled. --->
<cfif #dbug# is "Y">
    <Cfdump var="#result#" >
</cfif>

