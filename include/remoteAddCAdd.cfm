<!--- This ColdFusion page processes item data, including custom types, country and region lookups, and URL formatting before updating the database and redirecting the user. --->

<cfparam name="deleteitem" default="0" /> 
<cfparam name="valuetext" default="" /> 
<cfparam name="itemdate" default="" /> 
<cfparam name="customtype" default="" /> 
<cfparam name="countryid" default="" /> 
<cfparam name="region_id" default="" /> 

<!--- Check if the value type is "Custom" and custom type is provided --->
<cfif #valuetype# is "Custom" and #customtype# is not "">
    <cfinclude template="/include/qry/insert_199_1.cfm" />
  
    <cfoutput>
        <cfset valuetype = "#customtype#" />
    </cfoutput>
    <cfinclude template="/include/qry/insertx_199_2.cfm" />
</cfif>

<cfinclude template="/include/qry/add_199_3.cfm" />

<cfparam name="new_countryname" default="" />`
<cfparam name="new_regionname" default="" />

<!--- Check if category ID is "2" for country and region lookup --->
<cfif #catid# is "2">
    <cfinclude template="/include/qry/findcountry_199_4.cfm" />
    
    <!--- If a country is found, set the country name and ID --->
    <cfif #findcountry.recordcount# is "1">
        <cfset new_countryname = findcountry.countryname />
        <cfset old_countryid = findcountry.countryid />
    </cfif>

    <cfinclude template="/include/qry/findregion_199_5.cfm" />
    
    <!--- If a region is found, set the region name --->
    <cfif #findregion.recordcount# is "1">
        <cfset new_regionname = findregion.regionname />
    </cfif>
</cfif>

<!--- Check if category ID is "4" for URL formatting --->
<cfif #catid# is "4">
    <cfset preurl = "https://" />
    
    <!--- Check if valuetext starts with "http" --->
    <cfif #left(valuetext,4)# is "http">
    <cfelse>
        <cfoutput>
            <cfset valuetext = "#preurl##valuetext#" /> 
        </cfoutput>
    </cfif>
</cfif>

<!--- Check if category ID is "5" for URL formatting --->
<cfif #catid# is "5">
    <cfset preurl = "https://" />
    
    <!--- Check if valuetext starts with "http" --->
    <cfif #left(valuetext,4)# is "http">
    <cfelse>
        <cfoutput>
            <cfset valuetext = "#preurl##valuetext#" /> 
        </cfoutput>
    </cfif>
</cfif>

<!--- Check if category ID is "9" for custom company value --->
<cfif #catid# is "9">
    <cfif #VALUECOMPANY# IS "custom">
        <cfset valuecompany = "#TRIM(custom)#" />
    </cfif>
</cfif>

<cfinclude template="/include/qry/update_199_6.cfm" /> 

<!--- Redirect to contact page with contact ID --->
<cflocation url="/app/contact/?contactid=#contactid#" />
