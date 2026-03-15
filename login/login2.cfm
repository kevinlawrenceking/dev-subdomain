

<cfapplication name="TAO" sessionmanagement="true">

<!--- Ensure required application variables exist --->
<cfif NOT structKeyExists(application, "dsn")>
    <cfset host = ListFirst(cgi.server_name, ".") />
    <cfif host EQ "app">
        <cfset application.dsn = "abo" />
    <cfelse>
        <cfset application.dsn = "abod" />
    </cfif>
</cfif>

<cfif NOT structKeyExists(application, "information_schema")>
    <cfset application.information_schema = "actorsbusinessoffice" />
</cfif>

<cfif NOT structKeyExists(application, "suffix")>
    <cfset application.suffix = "_1.5" />
</cfif>

<cfscript>
    // Use datasource configured by Application.cfc
    dsn = application.dsn;
    datasourceName = application.dsn;
</cfscript>

<!--- ============================================================
      TEMPORARY DEBUG FLAG — set to false when done troubleshooting
      ============================================================ --->
<cfset debugLogin = true />

<!--- 1) Main login query (with userstatuses join) --->
<cfquery name="loginQuery" datasource="#dsn#" maxrows="1">
    SELECT
        u.userid,
        u.passwordHash,
        u.passwordSalt,
        us.status_url
    FROM
        taousers u
    INNER JOIN
        userstatuses us ON us.userstatus = u.userstatus
    WHERE
        u.userEmail = <cfqueryparam value="#form.j_username#" cfsqltype="cf_sql_varchar">
</cfquery>

<!--- 2) Debug queries — isolate each possible failure --->
<cfif debugLogin>
    <!--- Raw user lookup without the join --->
    <cfquery name="debugUserRaw" datasource="#dsn#" maxrows="1">
        SELECT userid, userEmail, userstatus, passwordHash, passwordSalt, userPassword
        FROM taousers
        WHERE userEmail = <cfqueryparam value="#form.j_username#" cfsqltype="cf_sql_varchar">
    </cfquery>

    <!--- All valid statuses in the join table --->
    <cfquery name="debugStatuses" datasource="#dsn#">
        SELECT userstatus, status_url FROM userstatuses ORDER BY userstatus
    </cfquery>
</cfif>

<!--- 3) Compute hash and determine outcome --->
<cfset loginSuccess = false />
<cfset userpassword2 = "" />
<cfset hashMatch = false />

<cfif loginQuery.recordcount eq 1>
    <cfset userpassword2 = Hash(form.j_password & loginQuery.passwordSalt, "SHA-512")>
    <cfif userpassword2 EQ loginQuery.passwordHash>
        <cfset loginSuccess = true />
        <cfset hashMatch = true />
    </cfif>
</cfif>

<!--- ============================================================
      DEBUG OUTPUT — shows full diagnostic page then stops
      ============================================================ --->
<cfif debugLogin>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>Login Debug | TAO</title>
    <style>
        * { box-sizing: border-box; }
        body { font-family: 'Courier New', monospace; padding: 24px; background: #0f1923; color: #c8d6e5; line-height: 1.5; }
        h1 { color: #00b4d8; border-bottom: 2px solid #00b4d8; padding-bottom: 8px; }
        h2 { color: #48cae4; margin-top: 28px; }
        table { border-collapse: collapse; margin: 8px 0 16px 0; width: 100%; max-width: 900px; }
        td, th { border: 1px solid #334155; padding: 8px 12px; text-align: left; vertical-align: top; }
        th { background: #1e293b; color: #94a3b8; font-weight: bold; width: 280px; }
        .pass { color: #22c55e; font-weight: bold; }
        .fail { color: #ef4444; font-weight: bold; }
        .warn { color: #f59e0b; font-weight: bold; }
        .hash { word-break: break-all; font-size: 11px; font-family: monospace; color: #e2e8f0; }
        .section { background: #1e293b; border: 1px solid #334155; border-radius: 6px; padding: 16px; margin: 12px 0; }
        .verdict { font-size: 18px; padding: 16px; border-radius: 6px; margin: 20px 0; }
        .verdict.ok { background: #14532d; border: 1px solid #22c55e; }
        .verdict.bad { background: #450a0a; border: 1px solid #ef4444; }
        a.btn { display: inline-block; padding: 10px 24px; background: #0284c7; color: #fff; text-decoration: none; border-radius: 4px; margin: 4px 4px 4px 0; }
        a.btn:hover { background: #0369a1; }
        .muted { color: #64748b; }
    </style>
</head>
<body>
<cfoutput>

<h1>TAO Login Debug</h1>
<p class="muted">Temporary diagnostic page. Set debugLogin = false in login/login2.cfm to disable.</p>

<!--- ===================== SECTION 1: Form Input ===================== --->
<h2>1. Form Input Received</h2>
<div class="section">
<table>
    <tr><th>j_username (email)</th><td>#htmlEditFormat(form.j_username)#</td></tr>
    <tr><th>j_password length</th><td>#len(form.j_password)# characters</td></tr>
    <tr><th>j_password empty?</th><td class="#len(form.j_password) eq 0 ? 'fail' : 'pass'#">#yesNoFormat(len(form.j_password) eq 0)#</td></tr>
</table>
</div>

<!--- ===================== SECTION 2: User Lookup (raw) ===================== --->
<h2>2. User Lookup — Raw (no join)</h2>
<div class="section">
<table>
    <tr><th>Record found?</th><td class="#debugUserRaw.recordcount eq 1 ? 'pass' : 'fail'#">#yesNoFormat(debugUserRaw.recordcount eq 1)# (#debugUserRaw.recordcount# row<cfif debugUserRaw.recordcount neq 1>s</cfif>)</td></tr>
</table>

<cfif debugUserRaw.recordcount eq 1>
<table>
    <tr><th>userid</th><td>#debugUserRaw.userid#</td></tr>
    <tr><th>userEmail</th><td>#htmlEditFormat(debugUserRaw.userEmail)#</td></tr>
    <tr><th>userstatus</th><td>#htmlEditFormat(debugUserRaw.userstatus)#</td></tr>
    <tr><th>passwordHash</th><td class="hash">#htmlEditFormat(debugUserRaw.passwordHash)#</td></tr>
    <tr><th>passwordHash length</th><td>#len(debugUserRaw.passwordHash)# | trimmed: #len(trim(debugUserRaw.passwordHash))#</td></tr>
    <tr><th>passwordSalt</th><td class="hash">#htmlEditFormat(debugUserRaw.passwordSalt)#</td></tr>
    <tr><th>passwordSalt length</th><td>#len(debugUserRaw.passwordSalt)# | trimmed: #len(trim(debugUserRaw.passwordSalt))#</td></tr>
    <tr><th>userPassword (legacy plaintext col)</th>
        <td>
            <cfif len(debugUserRaw.userPassword)>
                <span class="warn">PRESENT (#len(debugUserRaw.userPassword)# chars)</span>
            <cfelse>
                <span class="pass">Empty (good)</span>
            </cfif>
        </td>
    </tr>
</table>
<cfelse>
<p class="fail">No user found with email: #htmlEditFormat(form.j_username)#</p>
<p>Check: Is the email spelled correctly? Is the user in the taousers table?</p>
</cfif>
</div>

<!--- ===================== SECTION 3: userstatuses join check ===================== --->
<h2>3. User Status Join Check</h2>
<div class="section">
<p>The login query uses INNER JOIN userstatuses. If the user's <code>userstatus</code> value does not exist in the <code>userstatuses</code> table, the query returns 0 rows even though the user exists.</p>

<table>
    <tr><th>userstatus</th><th>status_url</th></tr>
    <cfloop query="debugStatuses">
    <tr>
        <td>#htmlEditFormat(debugStatuses.userstatus)#</td>
        <td>#htmlEditFormat(debugStatuses.status_url)#</td>
    </tr>
    </cfloop>
</table>

<cfif debugUserRaw.recordcount eq 1>
    <cfset statusMatched = false />
    <cfloop query="debugStatuses">
        <cfif debugStatuses.userstatus EQ debugUserRaw.userstatus>
            <cfset statusMatched = true />
        </cfif>
    </cfloop>
    <p>User's userstatus = "<strong>#htmlEditFormat(debugUserRaw.userstatus)#</strong>"
    <cfif statusMatched>
        <span class="pass">-- FOUND in userstatuses table</span>
    <cfelse>
        <span class="fail">-- NOT FOUND in userstatuses table. The INNER JOIN fails silently. This would prevent login even with a correct password.</span>
    </cfif>
    </p>
</cfif>

<table>
    <tr><th>Login query (with join) record count</th>
        <td class="#loginQuery.recordcount eq 1 ? 'pass' : 'fail'#">#loginQuery.recordcount#</td>
    </tr>
</table>
</div>

<!--- ===================== SECTION 4: Hash Comparison ===================== --->
<h2>4. Password Hash Comparison</h2>
<div class="section">
<cfif loginQuery.recordcount eq 1>
    <cfset storedHash = loginQuery.passwordHash />
    <cfset storedSalt = loginQuery.passwordSalt />
    <cfset computedHash = userpassword2 />

    <table>
        <tr><th>Algorithm used</th><td>SHA-512(password + salt)</td></tr>
        <tr><th>Salt value</th><td class="hash">#htmlEditFormat(storedSalt)#</td></tr>
        <tr><th>Salt length (raw / trimmed)</th><td>#len(storedSalt)# / #len(trim(storedSalt))#</td></tr>
        <tr><th>Stored hash</th><td class="hash">#htmlEditFormat(storedHash)#</td></tr>
        <tr><th>Stored hash length (raw / trimmed)</th><td>#len(storedHash)# / #len(trim(storedHash))#</td></tr>
        <tr><th>Computed hash</th><td class="hash">#htmlEditFormat(computedHash)#</td></tr>
        <tr><th>Computed hash length</th><td>#len(computedHash)#</td></tr>
        <tr><th>EQ match (case-insensitive)</th>
            <td class="#hashMatch ? 'pass' : 'fail'#">#hashMatch#</td>
        </tr>
        <tr><th>Compare match (case-sensitive)</th>
            <td class="#(Compare(computedHash, storedHash) eq 0) ? 'pass' : 'fail'#">#(Compare(computedHash, storedHash) eq 0)#</td>
        </tr>
        <tr><th>Trimmed EQ match</th>
            <td class="#(trim(computedHash) EQ trim(storedHash)) ? 'pass' : 'fail'#">#(trim(computedHash) EQ trim(storedHash))#</td>
        </tr>
    </table>

    <!--- ===================== SECTION 5: Mismatch Diagnostics ===================== --->
    <cfif NOT hashMatch>
    <h2>5. Mismatch Diagnostics</h2>
    <p>Testing alternative hash algorithms to find what was used to store this password:</p>
    <table>
        <tr><th>Algorithm</th><th>Match?</th><th>Computed Value</th></tr>

        <cfset testSHA = Hash(form.j_password, "SHA") />
        <tr><td>SHA(password) — no salt</td>
            <td class="#(testSHA EQ storedHash) ? 'pass' : 'fail'#">#yesNoFormat(testSHA EQ storedHash)#</td>
            <td class="hash">#testSHA#</td></tr>

        <cfset testSHA = Hash(form.j_password, "SHA") />
        <cfset testSHATrimmed = Hash(form.j_password, "SHA") />
        <tr><td>SHA(password) vs trimmed stored</td>
            <td class="#(testSHATrimmed EQ trim(storedHash)) ? 'pass' : 'fail'#">#yesNoFormat(testSHATrimmed EQ trim(storedHash))#</td>
            <td class="hash">#testSHATrimmed#</td></tr>

        <cfset testSHA256 = Hash(form.j_password, "SHA-256") />
        <tr><td>SHA-256(password) — no salt</td>
            <td class="#(testSHA256 EQ storedHash) ? 'pass' : 'fail'#">#yesNoFormat(testSHA256 EQ storedHash)#</td>
            <td class="hash">#testSHA256#</td></tr>

        <cfset testSHA512 = Hash(form.j_password, "SHA-512") />
        <tr><td>SHA-512(password) — no salt</td>
            <td class="#(testSHA512 EQ storedHash) ? 'pass' : 'fail'#">#yesNoFormat(testSHA512 EQ storedHash)#</td>
            <td class="hash">#testSHA512#</td></tr>

        <cfset testMD5 = Hash(form.j_password, "MD5") />
        <tr><td>MD5(password) — no salt</td>
            <td class="#(testMD5 EQ storedHash) ? 'pass' : 'fail'#">#yesNoFormat(testMD5 EQ storedHash)#</td>
            <td class="hash">#testMD5#</td></tr>

        <cfset testTrimSalt = Hash(form.j_password & trim(storedSalt), "SHA-512") />
        <tr><td>SHA-512(password + TRIMMED salt)</td>
            <td class="#(testTrimSalt EQ storedHash) ? 'pass' : 'fail'#">#yesNoFormat(testTrimSalt EQ storedHash)#</td>
            <td class="hash">#testTrimSalt#</td></tr>

        <tr><td>SHA-512(password + TRIMMED salt) vs TRIMMED stored</td>
            <td class="#(testTrimSalt EQ trim(storedHash)) ? 'pass' : 'fail'#">#yesNoFormat(testTrimSalt EQ trim(storedHash))#</td>
            <td class="muted">(same computed, trimmed comparison)</td></tr>
    </table>

    <h3>Character-level comparison (first difference)</h3>
    <cfset diffPos = 0 />
    <cfset compA = computedHash />
    <cfset compB = storedHash />
    <cfloop from="1" to="#min(len(compA), len(compB))#" index="i">
        <cfif mid(compA, i, 1) NEQ mid(compB, i, 1)>
            <cfset diffPos = i />
            <cfbreak />
        </cfif>
    </cfloop>
    <cfif diffPos gt 0>
        <p>First difference at position <strong>#diffPos#</strong>:
           computed[#diffPos#] = "<strong>#mid(compA, diffPos, 1)#</strong>" (ASCII #asc(mid(compA, diffPos, 1))#)
           vs stored[#diffPos#] = "<strong>#mid(compB, diffPos, 1)#</strong>" (ASCII #asc(mid(compB, diffPos, 1))#)</p>
    <cfelseif len(compA) neq len(compB)>
        <p class="warn">Hashes match in content but differ in length: computed=#len(compA)# vs stored=#len(compB)#. Likely trailing whitespace from CHAR column padding.</p>
    <cfelse>
        <p>No character differences found (lengths identical). This should not happen if EQ returned false.</p>
    </cfif>
    </cfif>

<cfelse>
    <p class="fail">Login query returned 0 rows — cannot compare password hash.</p>
    <cfif debugUserRaw.recordcount eq 1>
        <p class="warn">The user EXISTS in taousers but the INNER JOIN on userstatuses failed. Fix the user's userstatus value first.</p>
    <cfelse>
        <p>No user found with that email address.</p>
    </cfif>
</cfif>
</div>

<!--- ===================== SECTION 6: Verdict ===================== --->
<h2>6. Login Verdict</h2>
<cfif loginSuccess>
    <div class="verdict ok">
        <span class="pass">LOGIN WOULD SUCCEED</span><br/>
        Redirect target: #htmlEditFormat(loginQuery.status_url)#?u=#loginQuery.userid#
    </div>
    <a class="btn" href="#htmlEditFormat(loginQuery.status_url)#?u=#loginQuery.userid#">Continue to App (without setting session)</a>
<cfelse>
    <div class="verdict bad">
        <span class="fail">LOGIN FAILED</span><br/>
        <cfif debugUserRaw.recordcount eq 0>
            Reason: No user found with that email
        <cfelseif loginQuery.recordcount eq 0>
            Reason: User exists but userstatus join failed (status "#htmlEditFormat(debugUserRaw.userstatus)#" not in userstatuses table)
        <cfelseif NOT hashMatch>
            Reason: Password hash mismatch
        </cfif>
    </div>
</cfif>
<a class="btn" href="/loginform.cfm">Back to Login</a>
<a class="btn" href="/auth-recoverpw.cfm">Reset Password</a>

<!--- ===================== Console Output ===================== --->
<script>
console.group('%cTAO Login Debug', 'color: ##00b4d8; font-weight: bold; font-size: 14px');

console.group('Form Input');
console.log('Email:', '#jsStringFormat(form.j_username)#');
console.log('Password length:', #len(form.j_password)#);
console.groupEnd();

console.group('User Lookup (raw, no join)');
console.log('Found:', #debugUserRaw.recordcount eq 1 ? 'true' : 'false'#);
<cfif debugUserRaw.recordcount eq 1>
console.log('userid:', #debugUserRaw.userid#);
console.log('userstatus:', '#jsStringFormat(debugUserRaw.userstatus)#');
console.log('passwordHash length:', #len(debugUserRaw.passwordHash)#, '(trimmed:', #len(trim(debugUserRaw.passwordHash))#, ')');
console.log('passwordSalt length:', #len(debugUserRaw.passwordSalt)#, '(trimmed:', #len(trim(debugUserRaw.passwordSalt))#, ')');
console.log('Legacy userPassword present:', #len(debugUserRaw.userPassword) gt 0 ? 'true' : 'false'#);
</cfif>
console.groupEnd();

console.group('Status Join');
console.log('Login query (with join) rows:', #loginQuery.recordcount#);
<cfif debugUserRaw.recordcount eq 1>
console.log('User userstatus:', '#jsStringFormat(debugUserRaw.userstatus)#');
console.log('Valid statuses:', [<cfloop query="debugStatuses">'#jsStringFormat(debugStatuses.userstatus)#'<cfif debugStatuses.currentRow lt debugStatuses.recordCount>,</cfif></cfloop>]);
</cfif>
console.groupEnd();

<cfif loginQuery.recordcount eq 1>
console.group('Hash Comparison');
console.log('Stored hash:', '#jsStringFormat(storedHash)#');
console.log('Stored hash length:', #len(storedHash)#);
console.log('Computed hash:', '#jsStringFormat(computedHash)#');
console.log('Computed hash length:', #len(computedHash)#);
console.log('EQ match:', #hashMatch ? 'true' : 'false'#);
console.log('Trimmed match:', #(trim(computedHash) EQ trim(storedHash)) ? 'true' : 'false'#);
<cfif NOT hashMatch>
console.warn('MISMATCH — running algorithm tests:');
console.log('SHA(pw, no salt):', #(testSHA EQ storedHash) ? 'true' : 'false'#);
console.log('SHA-256(pw, no salt):', #(testSHA256 EQ storedHash) ? 'true' : 'false'#);
console.log('SHA-512(pw, no salt):', #(testSHA512 EQ storedHash) ? 'true' : 'false'#);
console.log('MD5(pw, no salt):', #(testMD5 EQ storedHash) ? 'true' : 'false'#);
console.log('SHA-512(pw, trimmed salt):', #(testTrimSalt EQ storedHash) ? 'true' : 'false'#);
console.log('SHA-512(pw, trimmed salt) vs trimmed stored:', #(testTrimSalt EQ trim(storedHash)) ? 'true' : 'false'#);
</cfif>
console.groupEnd();
</cfif>

console.log('%cVerdict: #loginSuccess ? "SUCCESS" : "FAILED"#', '#loginSuccess ? "color: ##22c55e" : "color: ##ef4444"#; font-weight: bold; font-size: 14px');
console.groupEnd();
</script>

</cfoutput>
</body>
</html>
<cfabort>
</cfif>

<!--- ============================================================
      NORMAL LOGIN FLOW (only reached when debugLogin = false)
      ============================================================ --->
<cfif loginQuery.recordcount eq 1>
    <cfset userpassword2 = Hash(form.j_password & loginQuery.passwordSalt, "SHA-512")>

    <!--- Validate password hash before granting session --->
    <cfif userpassword2 EQ loginQuery.passwordHash>
        <cfset session.userid = loginQuery.userid>
        <cfset session.userLoggedIn = true>

        <cflocation url="#loginQuery.status_url#?u=#loginquery.userid#" addtoken="true">
    </cfif>

</cfif>

<cflocation url="/loginform.cfm?pwrong=Y" addtoken="false">
