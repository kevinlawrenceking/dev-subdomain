<!--- This ColdFusion page processes form data for updating audition records and returns a JSON response. --->

<cfparam name="form.recordId" default="">
<cfparam name="form.projDate" default="">
<cfparam name="form.projName" default="">
<cfparam name="form.audRoleName" default="">
<cfparam name="form.audCatName" default="">
<cfparam name="form.audSubCatName" default="">
<cfparam name="form.audsource" default="">
<cfparam name="form.cdfirstname" default="">
<cfparam name="form.cdlastname" default="">
<cfparam name="form.callback_yn" default="N">
<cfparam name="form.redirect_yn" default="N">
<cfparam name="form.pin_yn" default="N">
<cfparam name="form.booked_yn" default="N">
<cfparam name="form.projDescription" default="">
<cfparam name="form.charDescription" default="">
<cfparam name="form.note" default="">
<cfparam name="form.status" default="">
<cfparam name="form.audsubcatid" default="0">

<cfset response = StructNew()>

<!--- Check if a record ID is provided --->
<cfif form.recordId neq "">

    <cfinclude template="/include/qry/find_313_1.cfm" />

    <!--- Check if the query returned a record --->
    <cfif find.recordCount gt 0>

        <cfinclude template="/include/qry/update_record_313_2.cfm" />

        <cfset isfix = "Y">
        <cfinclude template="/include/transfer_audition.cfm"/>
        <cfset response.success = true>
        <cfset response.message = "Record updated successfully.">

    <cfelse>
        <cfset response.success = false>
        <cfset response.message = "Category or Subcategory not found.">
    </cfif>

<cfelse>
    <cfset response.success = false>
    <cfset response.message = "No record ID provided.">
</cfif>

<cfheader name="Content-Type" value="application/json" charset="utf-8">
<cfoutput>#SerializeJSON(response)#</cfoutput>
