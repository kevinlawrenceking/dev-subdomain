<cfcomponent displayname="CityService" hint="Handles operations for City table" >

<cffunction output="false" name="SELcities" access="public" returntype="query" >

<cfquery name="result">
            SELECT 
                id, 
                countryid, 
                region_id, 
                cityname 
            FROM 
                cities 
            ORDER BY 
                cityname
        </cfquery>

<cfreturn result>

</cffunction>

</cfcomponent>