<!--- This ColdFusion page handles the creation of a new contact and redirects to the contact view page. --->
<cfparam name="refer_contact_id" default="" />

<!--- TAO-E002: require a live server session BEFORE inserting. Bare `userid` used to resolve from
      the browser-session cookie.userid (include/pgload.cfm) after the CF session expired, so the
      contact was inserted and then folder_setup.cfm threw on session.userMediaUrl - a half-done
      create the user retried. Pin userid to the session so the cookie can never select the owner. --->
<cfif NOT structKeyExists(session, "userid") OR NOT isNumeric(session.userid)>
    <cflocation url="/loginform.cfm" addtoken="false" />
</cfif>
<cfset userid = session.userid />

<!--- TAO-CONTACT-SUBMIT-TOKEN (2026-10-17): identify the SUBMISSION, not the name. Each
      rendering of remoteAddName.cfm carries a random submissionToken; a double click or browser
      retry resends it. The first request to finish the insert records token -> contactid in the
      session; a retry with the same token gets that contact back and inserts nothing. Two real
      contacts with the same name come from two renderings, so they carry different tokens and
      are both created. A request without a valid token (a form cached before this change) is
      inserted as before. The session lock serializes same-session requests so a same-second
      double click cannot pass the lookup twice; folder_setup.cfm below is idempotent, so a
      reused contact still gets any folders a failed first pass missed. --->
<cfparam name="form.submissionToken" default="" />
<cfset submissionToken = reFind("^[a-f0-9]{64}$", trim(form.submissionToken)) ? trim(form.submissionToken) : "" />

<cflock scope="session" type="exclusive" timeout="15" throwontimeout="true">
    <cfset currentid = 0 />
    <cfif NOT structKeyExists(session, "contactSubmitResults") OR NOT isStruct(session.contactSubmitResults)>
        <cfset session.contactSubmitResults = {} />
    </cfif>

    <cfif len(submissionToken) AND structKeyExists(session.contactSubmitResults, submissionToken)>
        <cfset currentid = session.contactSubmitResults[submissionToken].contactid />
        <cflog file="tao_contact_create" type="information"
               text="remoteAddNameAdd: retry of submission reused contactid=#currentid# for userid=#userid#">
    <cfelse>
        <!--- Include the query to add a new contact --->
        <cfinclude template="/include/qry/add_211_1.cfm" />

        <cfif len(submissionToken) AND val(currentid) GT 0>
            <!--- Keep the map small: drop results older than 30 minutes before recording this one. --->
            <cfloop array="#structKeyArray(session.contactSubmitResults)#" index="oldToken">
                <cfif dateDiff("n", session.contactSubmitResults[oldToken].at, now()) GT 30>
                    <cfset structDelete(session.contactSubmitResults, oldToken) />
                </cfif>
            </cfloop>
            <cfset session.contactSubmitResults[submissionToken] = { contactid = currentid, at = now() } />
        </cfif>
    </cfif>
</cflock>

<!--- Set the contact ID for further processing --->
<cfset contactid = currentid />

<!--- Retrieve the user ID from the session --->
<cfset select_userid = userid />
<!--- Set the current contact ID for reference --->
<cfset select_contactid = currentid />

<!--- Include the folder setup for the contact --->
<cfinclude template="/include/folder_setup.cfm" />

<!--- Redirect to the contact view page with the newly created contact ID --->
<cflocation url="/app/contact/?contactid=#contactid#&ctaction=view" />
