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

    <cfinclude template="/sched/user_setup_core.cfm" />

<cfquery result="result" name="update" >
    UPDATE thrivecart
    set status =
    <cfqueryparam cfsqltype="cf_sql_varchar" value="Completed" />
    where id = #id#
</cfquery>

<cflocation url="setup-complete.cfm?userid=#select_userid#" />
