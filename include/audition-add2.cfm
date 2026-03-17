<!--- This ColdFusion page processes user input and manages audition-related data based on various conditions. --->

<!--- Safely setup form parameters with cfparam --->
<cfparam name="form.modalAnswer" default="No" />
<cfparam name="form.CustomPlatform" default="" />
<cfparam name="form.cdco" default="" />
<cfparam name="form.cdfullname" default="" />
<cfparam name="form.casting_info" default="casting_director_known" />
<cfparam name="form.new_contactid" default="0" />
<cfparam name="form.new_audStepID" default="1" />
<cfparam name="form.new_audcatid" default="1" />
<cfparam name="form.new_audsubcatid" default="6" />
<cfparam name="form.new_userid" default="#session.userid#" />
<cfparam name="form.isdirect" default="0" />
<cfparam name="form.new_projname" default="" />
<cfparam name="form.new_projDescription" default="" />
<cfparam name="form.new_audrolename" default="" />
<cfparam name="form.new_audroletypeid" default="1" />
<cfparam name="form.new_audtypeid" default="1" />
<cfparam name="form.new_eventStart" default="" />
<cfparam name="form.new_eventStartTime" default="" />
<cfparam name="form.new_durid" default="4" />
<cfparam name="form.new_audLocation" default="" />
<cfparam name="form.new_audplatformid" default="4" />
<cfparam name="form.new_eventLocation" default="" />
<cfparam name="form.new_audlocadd1" default="" />
<cfparam name="form.new_audlocadd2" default="" />
<cfparam name="form.new_audcity" default="" />
<cfparam name="form.new_audzip" default="" />
<cfparam name="form.countryid" default="US" />
<cfparam name="form.new_region_id" default="CA" />
<cfparam name="form.cdtype" default="" />

<!--- Set local variables from form scope --->
<cfset modalAnswer = form.modalAnswer />
<cfset CustomPlatform = form.CustomPlatform />
<cfset cdco = form.cdco />
<cfset cdfullname = form.cdfullname />
<cfset casting_info = form.casting_info />
<cfset new_contactid = form.new_contactid />
<cfset new_audStepID = form.new_audStepID />
<cfset new_audcatid = form.new_audcatid />
<cfset new_audsubcatid = form.new_audsubcatid />
<cfset new_userid = form.new_userid />
<cfset isdirect = form.isdirect />
<cfset new_projname = form.new_projname />
<cfset new_projDescription = form.new_projDescription />
<cfset new_audrolename = form.new_audrolename />
<cfset new_audroletypeid = form.new_audroletypeid />
<cfset new_audtypeid = form.new_audtypeid />
<cfset new_eventStart = form.new_eventStart />
<cfset new_eventStartTime = form.new_eventStartTime />
<cfset new_durid = form.new_durid />
<cfset new_audLocation = form.new_audLocation />
<cfset new_audplatformid = form.new_audplatformid />
<cfset new_eventLocation = form.new_eventLocation />
<cfset new_audlocadd1 = form.new_audlocadd1 />
<cfset new_audlocadd2 = form.new_audlocadd2 />
<cfset new_audcity = form.new_audcity />
<cfset new_audzip = form.new_audzip />
<cfset countryid = form.countryid />
<cfset new_region_id = form.new_region_id />
<cfset cdtype = form.cdtype />

<!--- Set additional variables --->
<cfparam name="isbooked" default="0" />
<cfset userid = session.userid />

<!--- Server-side validation: critical fields that affect DB writes --->
<cfset new_userid = session.userid><!--- Force to session user — never trust form-supplied userid --->
<cfif NOT isNumeric(new_audStepID)><cfset new_audStepID = 1></cfif>
<cfif NOT isNumeric(new_audcatid)><cfset new_audcatid = 1></cfif>
<cfif NOT isNumeric(new_audsubcatid)><cfset new_audsubcatid = 6></cfif>
<cfif NOT isNumeric(new_audtypeid)><cfset new_audtypeid = 1></cfif>
<cfif NOT isNumeric(new_audroletypeid)><cfset new_audroletypeid = 1></cfif>
<cfif NOT isNumeric(new_durid)><cfset new_durid = 4></cfif>
<cfif new_audplatformid NEQ "CustomPlatform" AND NOT isNumeric(new_audplatformid)><cfset new_audplatformid = 4></cfif>
<cfif len(trim(new_eventStart)) AND NOT isDate(new_eventStart)><cfset new_eventStart = ""></cfif>
<cfif isNumeric(new_contactid)><cfset new_contactid = int(new_contactid)><cfelse><cfset new_contactid = 0></cfif>
<cfset new_projname = left(trim(new_projname), 500)>
<cfset new_projDescription = left(trim(new_projDescription), 5000)>
<cfset new_audrolename = left(trim(new_audrolename), 500)>
<cfset cdfullname = left(trim(cdfullname), 500)>
<cfset cdco = left(trim(cdco), 500)>

<!--- Initialize new_contactid if not set --->
<cfif len(trim(new_contactid)) EQ 0 OR new_contactid EQ 0>
    <cfset new_contactid = 0 />
</cfif>

<!--- Transaction wraps all audition creation writes --->
<cftransaction>

<!--- Process new contact if new_contactid is 0 and cdfullname is not empty --->
<cfif new_contactid EQ 0 AND len(trim(cdfullname)) GT 0>
    <cfinclude template="/include/qry/inscontactdetails.cfm" />
    <cfset select_contactid = contactid />
    <cfset new_contactid = contactid />
    <cfinclude template="/include/folder_setup.cfm" />
    <cfinclude template="/include/qry/insert_28_2.cfm" />

    <!--- Insert additional data if cdco is not empty --->
    <cfif len(trim(cdco)) GT 0>
        <cfinclude template="/include/qry/insert_28_3.cfm" />
    </cfif>
</cfif>

<!--- Handle modal answer if it is "Yes" --->
<cfif modalAnswer EQ "Yes">
    <cfset new_contactid = new_contactid />
    <cfset new_userid = userid />
    <cfset new_systemid = 1 />
    <cfset new_suStartDate = new_eventStart />
    <cfinclude template="modalansweryes.cfm" />
</cfif>

<!--- Process new contact if new_contactid is 0 and cdfullname is not empty again --->
<cfif new_contactid EQ 0 AND len(trim(cdfullname)) GT 0>
    <cfinclude template="/include/qry/insContactDetails.cfm" />
    <cfinclude template="/include/qry/insert_28_5.cfm" />

    <!--- Insert additional data if cdco is not empty --->
    <cfif len(trim(cdco)) GT 0>
        <cfinclude template="/include/qry/insert_28_6.cfm" />
    </cfif>
</cfif>

<!--- Process new contact if new_contactid is 0 and cdco is not empty --->
<cfif new_contactid EQ 0 AND len(trim(cdco)) GT 0>
    <!--- If only company known, use company name as the contact name --->
    <cfif casting_info EQ "only_company_known">
        <cfset cdfullname = cdco />
    </cfif>
    <cfinclude template="/include/qry/insContactDetails.cfm" />
    <cfset new_contactid = contactid />
    <cfinclude template="/include/qry/insert_28_8.cfm" />
    <cfinclude template="/include/qry/insert_28_3.cfm" />
</cfif>

<cfinclude template="/include/qry/FIND_28_10.cfm" />

<!--- Handle custom platform logic --->
<cfif new_audPlatformid EQ "CustomPlatform" AND len(trim(CustomPlatform)) GT 0 AND find.recordcount EQ 0>
    <cfinclude template="/include/qry/insert_28_11.cfm" />
    <cfset new_audPlatformid = resultx />
<cfelseif new_audplatformid EQ "CustomPlatform" AND len(trim(CustomPlatform)) GT 0 AND find.recordcount EQ 1>
    <cfset new_audPlatformid = find.audplatformid />
<cfelseif new_audplatformid EQ "CustomPlatform" AND len(trim(CustomPlatform)) EQ 0>
    <cfset new_audPlatformid = old_audplatformid />
</cfif>

<cfinclude template="/include/qry/audprojects_ins.cfm" />
<cfinclude template="/include/qry/audroles_ins.cfm" />

<!--- Include auditions if not direct --->
<cfif isdirect NEQ 1>
    <cfinclude template="/include/qry/auditions_ins.cfm" />
</cfif>

<!--- Add contact data if new_contactid is not 0 --->
<cfif new_contactid NEQ 0>
    <cfinclude template="/include/qry/add_cd_28_12.cfm" />
</cfif>

</cftransaction>

<cflocation url="/app/audition/?audprojectid=#new_audprojectid#&isnew=1" />

