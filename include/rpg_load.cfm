<!--- This ColdFusion page includes various query templates and processes data related to RPG records. --->
<cfinclude template="/include/qry/RPG_288_1.cfm" />
<cfinclude template="/include/qry/RPGFields_288_2.cfm" />
<cfinclude template="/include/qry/RPGResults_288_3.cfm" />
<cfinclude template="/include/qry/RPGkey_288_4.cfm" />
<cfinclude template="/include/qry/RPGAdd_288_5.cfm" />
<cfinclude template="/include/qry/RPGUpdate_288_6.cfm" />

<cfset fid = RPGKey.fname />
<cfset fidtype = RPGKey.ftype />

<!--- Determine SQL type based on field type --->
<cfif #fidtype# is "integer">
    <cfset fidsqltype = "CF_SQL_INTEGER" />
<cfelseif #fidtype# is "text">
    <cfset fidsqltype = "CF_SQL_VARCHAR" />
<cfelseif #fidtype# is "date">
    <cfset fidsqltype = "CF_SQL_DATE" />
<cfelseif #fidtype# is "datetime">
    <cfset fidsqltype = "CF_SQL_TIMESTAMP" />
<cfelseif #fidtype# is "time">
    <cfset fidsqltype = "CF_SQL_TIME" />
</cfif>

<!--- Check if there is exactly one RPG record --->
<cfif #RPG.RecordCount# is "1">
    <cfset rpg_compid = RPG.compid />
    <cfset rpg_compname = RPG.compname /> 
    <cfset rpg_compDir = RPG.compDir />
    <cfset rpg_compTable = RPG.compTable />
    <cfset rpg_compowner = RPG.compowner />
    
    <!--- Page variables --->    
    <cfset rpg_pgid = RPG.pgid />
    <cfset rpg_pgname = RPG.pgname />    
    <cfset rpg_pgDir = RPG.pgDir />
    <cfset rpg_pgTitle = RPG.pgTitle />
    <cfset rpg_pgHeading = RPG.pgHeading />
    <cfset rpg_pgFilename = RPG.pgFilename />

    <cfoutput>
        <cfset rpgTitle = "#rpg_pgTitle#" />
    </cfoutput>
</cfif>
