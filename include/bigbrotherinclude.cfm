<!--- This ColdFusion page handles the inclusion of a query template and manages potential errors. --->
<cftry>
    <!--- Set default value for contact ID if not provided --->
    <cfparam name="contactid" default="0" />
    
    <!--- Include the query template for adding a record --->
    <cfinclude template="/include/qry/bro_add_53_1.cfm" />
    
    <!--- Catch any errors that occur during the try block --->
    <cfcatch type="any">
        
    </cfcatch>
</cftry>
