<!---
    PURPOSE: Supporting queries for ThriveCart results page
    AUTHOR: Kevin King  
    DATE: 2025-09-12
    DEPENDENCIES: application.dsn
--->

<cfparam name="select_status" default="%" />
<cfparam name="select_plan" default="%" />
<cfparam name="select_product" default="%" />

<!--- Use datasource from Application.cfc --->
<cfset dsn = application.dsn>

<!--- Main results query --->
<cfquery name="results" datasource="#dsn#">
    SELECT 
        th.id,
        th.orderdate,
        th.CustomerFirst,
        th.CustomerLast,
        th.CustomerEmail,
        th.status,
        th.BaseProductLabel,
        pp.planName
    FROM thrivecart th 
    INNER JOIN paymentplans pp ON pp.BasePaymentPlanId = th.BasePaymentPlanId 
    INNER JOIN products pr ON pr.BaseProductId = th.BaseProductId 
    WHERE 1=1
    
    <!--- Dynamic filters using cfqueryparam for safety --->
    <cfif len(trim(select_status)) AND select_status NEQ "%">
        AND th.status = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_status#">
    </cfif>
    
    <cfif len(trim(select_plan)) AND select_plan NEQ "%">
        AND pp.planName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_plan#">
    </cfif>
    
    <cfif len(trim(select_product)) AND select_product NEQ "%">
        AND th.BaseProductLabel = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_product#">
    </cfif>
    
    ORDER BY th.status DESC, th.orderdate DESC
</cfquery>

<!--- Query for status filter dropdown --->
<cfquery name="statuses" datasource="#dsn#">
    SELECT DISTINCT th.status 
    FROM thrivecart th
    WHERE th.status IS NOT NULL
    ORDER BY th.status
</cfquery>

<!--- Query for payment plans filter dropdown --->
<cfquery name="plans" datasource="#dsn#">
    SELECT DISTINCT pp.planName
    FROM thrivecart th 
    INNER JOIN paymentplans pp ON pp.BasePaymentPlanId = th.BasePaymentPlanId
    WHERE pp.planName IS NOT NULL
    ORDER BY pp.planName
</cfquery>

<!--- Query for products filter dropdown --->
<cfquery name="products" datasource="#dsn#">
    SELECT DISTINCT th.BaseProductLabel
    FROM thrivecart th
    WHERE th.BaseProductLabel IS NOT NULL
    ORDER BY th.BaseProductLabel
</cfquery>

<!--- Store filter values in cookies for persistence --->
<cfoutput>
    <cfset cookie.select_status = "#select_status#" />
    <cfset cookie.select_plan = "#select_plan#" />
    <cfset cookie.select_product = "#select_product#" />
</cfoutput>

<!--- Retrieve cookie values if they exist --->
<cfif isDefined("cookie.select_status")>
    <cfset select_status = cookie.select_status />
</cfif>
<cfif isDefined("cookie.select_plan")>
    <cfset select_plan = cookie.select_plan />
</cfif>
<cfif isDefined("cookie.select_product")>
    <cfset select_product = cookie.select_product />
</cfif>
