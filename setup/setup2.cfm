<Cfparam name="pass1" default="" />

<cfset new_passwordSalt=hash(generateSecretKey("AES"),"SHA-512") />

<cfquery result="result" name="Del" >
UPDATE taousers_tbl set isdeleted = 1 where customerid =
<cfqueryparam value="#id#" cfsqltype="cf_sql_integer" />
</cfquery >

<cfquery name="insert"  result="result">
INSERT INTO taousers_tbl (customerid,userfirstName,userLastName,userEmail,avatarname,passwordHash,passwordSalt)
VALUES (
<cfqueryparam value="#id#" cfsqltype="cf_sql_integer" />

,
<cfqueryparam value="#customerfirst#" cfsqltype="cf_sql_varchar" />
,
<cfqueryparam value="#customerlast#" cfsqltype="cf_sql_varchar" />
,
<cfqueryparam value="#customeremail#" cfsqltype="cf_sql_varchar" />
,
<cfqueryparam value="#customerfirst#" cfsqltype="cf_sql_varchar" />
,
<cfqueryparam cfsqltype="char" value="#hash(pass1 & new_passwordSalt,'SHA-512')#" />
,
<cfqueryparam cfsqltype="char" value="#new_passwordSalt#" />
)

</cfquery>

<cfset select_userid=result.generatedkey />

<!--- Map billing address from Thrivecart purchase to user profile --->
<cftry>
    <cfquery name="tcBilling">
        SELECT BillingAddress, BillingCity, BillingState, BillingZip, BillingCountry
        FROM thrivecart
        WHERE id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer" />
    </cfquery>

    <cfif tcBilling.recordCount
          AND (len(trim(tcBilling.BillingAddress))
               OR len(trim(tcBilling.BillingCity))
               OR len(trim(tcBilling.BillingZip)))>
        <cfquery>
            UPDATE taousers_tbl
            SET add1 = <cfqueryparam value="#tcBilling.BillingAddress#" cfsqltype="cf_sql_varchar" null="#NOT len(trim(tcBilling.BillingAddress))#">,
                city = <cfqueryparam value="#tcBilling.BillingCity#" cfsqltype="cf_sql_varchar" null="#NOT len(trim(tcBilling.BillingCity))#">,
                defState = <cfqueryparam value="#tcBilling.BillingState#" cfsqltype="cf_sql_varchar" null="#NOT len(trim(tcBilling.BillingState))#">,
                zip = <cfqueryparam value="#tcBilling.BillingZip#" cfsqltype="cf_sql_varchar" null="#NOT len(trim(tcBilling.BillingZip))#">,
                defCountry = <cfqueryparam value="#tcBilling.BillingCountry#" cfsqltype="cf_sql_varchar" null="#NOT len(trim(tcBilling.BillingCountry))#">
            WHERE userid = <cfqueryparam value="#select_userid#" cfsqltype="cf_sql_integer" />
        </cfquery>
    </cfif>

    <cfcatch type="any">
        <cflog file="TAO_setup_errors" text="Address mapping error for userid #select_userid#: #cfcatch.message#" type="error" />
    </cfcatch>
</cftry>

    <cfinclude template="user_setup_core.cfm" />

<cfquery result="result" name="update" >
    UPDATE thrivecart
    set status =
    <cfqueryparam cfsqltype="cf_sql_varchar" value="Completed" />
    where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#id#" />
</cfquery>

<cflocation url="setup-complete.cfm?userid=#select_userid#" />
