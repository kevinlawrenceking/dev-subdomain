<!--- ALWAYS compute host and dsn -- never rely on stale application scope --->
<cfset host = ListFirst(cgi.server_name, ".") />
<cfif host EQ "app">
    <cfset envLabel = "PROD" />
<cfelseif host EQ "uat">
    <cfset envLabel = "UAT" />
<cfelse>
    <cfset envLabel = "DEV" />
</cfif>

<!--- App name MUST be set before writing to application scope --->
<cfapplication name="TAO_#envLabel#" sessionmanagement="true">

<cfif host EQ "app">
    <cfset application.dsn = "abo" />
<cfelse>
    <cfset application.dsn = "abod" />
</cfif>
<cfset application.baseMediaUrl = "/media-" & application.dsn />
<cfset dsn = application.dsn />

<!--- Clear any lingering auth cookies --->
<cfif structKeyExists(cookie, "userid")>
    <cfcookie name="userid" value="" expires="now">
    <cfset structDelete(cookie, "userid")>
</cfif>

<!--- Defaults --->
<cfparam name="pgaction" default="view">
<cfparam name="email" default="">
<cfset recoverLink = "" />

<!--- Merge form-submitted values (cfparam only sets Variables scope, which shadows Form scope) --->
<cfif structKeyExists(form, "pgaction")>
    <cfset pgaction = form.pgaction>
</cfif>
<cfif structKeyExists(form, "email")>
    <cfset email = trim(form.email)>
</cfif>

<!--- Process recovery request --->
<cfif pgaction IS "recover">

    <cfif NOT len(email)>
        <cfset pgaction = "view">

    <!--- Rate limit: 1 request per 60 seconds per session --->
    <cfelseif structKeyExists(session, "recoveryLastRequest")
             AND dateDiff("s", session.recoveryLastRequest, now()) LT 60>
        <cfset pgaction = "ratelimit">

    <cfelse>
        <cfset session.recoveryLastRequest = now() />

        <!--- Look up user (result is never revealed to the client) --->
        <cfquery name="find" datasource="#dsn#">
            SELECT userid, useremail, userfirstname
            FROM taousers
            WHERE useremail = <cfqueryparam value="#email#" cfsqltype="cf_sql_varchar">
            LIMIT 1
        </cfquery>

        <cfif find.recordcount IS 1>
            <cfset recover = CreateUUID() />

            <cfquery datasource="#dsn#">
                UPDATE taousers_tbl
                SET recover = <cfqueryparam value="#recover#" cfsqltype="cf_sql_varchar">,
                    recover_requested_at = NOW()
                WHERE userid = <cfqueryparam value="#find.userid#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfset recoverLink = "https://#cgi.server_name#/recover/?recover=#recover#" />

            <cftry>
                <cfmail from="support@theactorsoffice.com"
                        to="#find.useremail#"
                        subject="The Actor's Office - Password Recovery"
                        type="HTML">
<html>
<head><title>The Actor's Office</title></head>
<body style="background-color: white; font-family: 'Source Sans Pro', sans-serif; font-size: 14px; color: ##333;">
    <p>Hi #find.userfirstname#,</p>
    <p>We received a request to reset your password.</p>
    <p>Click the button below to create a new password. This link expires in 1 hour.</p>
    <p style="margin: 24px 0;">
        <a href="#recoverLink#"
           style="display:inline-block;padding:12px 28px;background-color:##406E8E;color:white;text-decoration:none;border-radius:4px;font-weight:600;">
            Reset My Password
        </a>
    </p>
    <p style="font-size:13px;color:##666;">If you did not request this, you can safely ignore this email.</p>
    <p>The Actor's Office Support Team</p>
</body>
</html>
                </cfmail>
            <cfcatch type="any">
                <cflog file="tao_errors" type="error"
                       text="Password recovery email failed for #find.useremail#: #cfcatch.message# #cfcatch.detail#">
            </cfcatch>
            </cftry>
        </cfif>

        <!--- Always show "sent" regardless of whether email was found (anti-enumeration) --->
        <cfset pgaction = "sent">
    </cfif>

</cfif>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>Password Recovery | The Actor's Office</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta content="The Actor's Office Application" name="description" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="robots" content="noindex" />
    <link rel="shortcut icon" href="/media/shared/images/favicon.ico" />

    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@400;500;600;700&family=DM+Sans:wght@400;500;600&display=swap" rel="stylesheet" />

    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --tao-navy:    #1B3A4B;
            --tao-blue:    #406E8E;
            --tao-blue-l:  #5A8EAE;
            --tao-gold:    #C8A951;
            --tao-gold-l:  #DBBF6A;
            --tao-white:   #FFFFFF;
            --tao-off:     #F7F8FA;
            --tao-gray:    #8B95A2;
            --tao-border:  #DDE1E7;
            --tao-danger:  #DC4F52;
            --tao-success: #2EAD6B;
            --tao-warning: #D97706;
            --tao-radius:  12px;
            --tao-shadow:  0 20px 60px rgba(27, 58, 75, 0.25),
                           0 8px 24px rgba(27, 58, 75, 0.12);
        }

        html { height: 100%; }

        body {
            min-height: 100%;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            font-family: 'DM Sans', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(160deg, var(--tao-navy) 0%, var(--tao-blue) 50%, var(--tao-blue-l) 100%);
            color: var(--tao-navy);
            padding: 24px 16px;
            -webkit-font-smoothing: antialiased;
        }

        body::before {
            content: '';
            position: fixed;
            inset: 0;
            background:
                radial-gradient(ellipse 80% 60% at 20% 80%, rgba(200,169,81,0.08) 0%, transparent 60%),
                radial-gradient(ellipse 60% 50% at 80% 20%, rgba(90,142,174,0.12) 0%, transparent 60%);
            pointer-events: none;
            z-index: 0;
        }

        .login-card {
            position: relative;
            z-index: 1;
            width: 100%;
            max-width: 420px;
            background: var(--tao-white);
            border-radius: var(--tao-radius);
            box-shadow: var(--tao-shadow);
            overflow: hidden;
            animation: cardIn 0.6s cubic-bezier(0.23, 1, 0.32, 1) both;
        }

        @keyframes cardIn {
            from { opacity: 0; transform: translateY(24px) scale(0.97); }
            to   { opacity: 1; transform: translateY(0) scale(1); }
        }

        .login-header {
            background: #0A0A0A;
            padding: 32px 32px 28px;
            text-align: center;
        }

        .login-header img {
            height: 48px;
            width: auto;
            display: inline-block;
        }

        .login-header .logo-text {
            font-family: 'Cinzel', 'Times New Roman', serif;
            font-size: 28px;
            font-weight: 400;
            color: var(--tao-white);
            letter-spacing: 3px;
            display: none;
        }
        .login-header .logo-text .cap { font-size: 34px; font-weight: 500; }
        .login-header .logo-text .gold { color: var(--tao-gold); }
        .login-header .logo-text .small { font-size: 22px; letter-spacing: 2.5px; }

        .login-body {
            padding: 36px 32px 32px;
        }

        .login-subtitle {
            text-align: center;
            color: var(--tao-gray);
            font-size: 14px;
            margin-bottom: 28px;
            line-height: 1.4;
        }

        /* ── Status Icons (sent / ratelimit states) ──── */
        .status-icon {
            width: 56px;
            height: 56px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 16px;
        }
        .status-icon svg { width: 28px; height: 28px; }

        .status-icon-success {
            background: #ECFDF5;
            color: var(--tao-success);
        }
        .status-icon-warning {
            background: #FFFBEB;
            color: var(--tao-warning);
        }

        .status-title {
            text-align: center;
            font-size: 18px;
            font-weight: 600;
            color: var(--tao-navy);
            margin-bottom: 8px;
        }

        /* ── Form Groups ─────────────────────────────── */
        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: var(--tao-navy);
            margin-bottom: 6px;
            letter-spacing: 0.2px;
        }

        .form-input-wrap {
            position: relative;
        }

        .form-input-wrap input {
            width: 100%;
            padding: 12px 16px;
            font-size: 15px;
            font-family: inherit;
            color: var(--tao-navy);
            background: var(--tao-off);
            border: 1.5px solid var(--tao-border);
            border-radius: 8px;
            outline: none;
            transition: border-color 0.2s ease, box-shadow 0.2s ease, background-color 0.2s ease;
        }

        .form-input-wrap input::placeholder {
            color: #B0B7C3;
        }

        .form-input-wrap input:focus {
            background: var(--tao-white);
            border-color: var(--tao-blue);
            box-shadow: 0 0 0 3px rgba(64, 110, 142, 0.12);
        }

        /* ── Submit Button ────────────────────────────── */
        .btn-login {
            display: block;
            width: 100%;
            padding: 13px 24px;
            margin-top: 28px;
            font-family: inherit;
            font-size: 15px;
            font-weight: 600;
            letter-spacing: 0.3px;
            color: var(--tao-white);
            background: linear-gradient(135deg, var(--tao-blue) 0%, var(--tao-navy) 100%);
            border: none;
            border-radius: 8px;
            cursor: pointer;
            position: relative;
            overflow: hidden;
            transition: transform 0.15s ease, box-shadow 0.2s ease;
        }

        .btn-login:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 20px rgba(27, 58, 75, 0.3);
        }

        .btn-login:active {
            transform: translateY(0);
            box-shadow: 0 2px 8px rgba(27, 58, 75, 0.2);
        }

        .btn-login::after {
            content: '';
            position: absolute;
            top: 0; left: -100%;
            width: 100%; height: 100%;
            background: linear-gradient(90deg, transparent, rgba(200,169,81,0.15), transparent);
            transition: left 0.5s ease;
        }
        .btn-login:hover::after {
            left: 100%;
        }

        .btn-login:disabled {
            transform: none;
            cursor: wait;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }
        .btn-spinner {
            display: inline-block;
            width: 16px;
            height: 16px;
            border: 2px solid rgba(255,255,255,0.3);
            border-top-color: white;
            border-radius: 50%;
            animation: spin 0.6s linear infinite;
            vertical-align: middle;
            margin-right: 8px;
        }

        /* ── Back Link ────────────────────────────────── */
        .back-link {
            display: block;
            text-align: center;
            margin-top: 20px;
            font-size: 13px;
            color: var(--tao-blue);
            text-decoration: none;
            transition: color 0.2s ease;
        }
        .back-link:hover {
            color: var(--tao-gold);
        }

        /* ── Dev Link ─────────────────────────────────── */
        .dev-link {
            margin-top: 16px;
            padding: 10px 14px;
            background: #EFF6FF;
            border: 1px solid #BFDBFE;
            border-radius: 8px;
            font-size: 12px;
            color: #1E40AF;
            word-break: break-all;
            line-height: 1.5;
        }
        .dev-link a { color: #1E40AF; text-decoration: underline; }
        .dev-link strong { font-weight: 600; }

        /* ── Footer ───────────────────────────────────── */
        .login-footer {
            position: relative;
            z-index: 1;
            margin-top: 24px;
            text-align: center;
            font-size: 12px;
            color: rgba(255, 255, 255, 0.45);
            letter-spacing: 0.3px;
        }

        @media (max-width: 480px) {
            .login-body { padding: 28px 20px 24px; }
            .login-header { padding: 28px 20px 22px; }
        }
    </style>
</head>

<body>

    <div class="login-card">

        <div class="login-header">
            <cfoutput>
                <img src="/media-#application.dsn#/images/logo-light.png"
                     alt="The Actor's Office"
                     onerror="this.style.display='none';this.nextElementSibling.style.display='block';" />
                <div class="logo-text">
                    <span class="cap gold">T</span><span class="small">HE</span>&nbsp;&nbsp;<span class="cap gold">A</span><span class="small">CTOR'S</span>&nbsp;&nbsp;<span class="cap gold">O</span><span class="small">FFICE</span>
                </div>
            </cfoutput>
        </div>

        <div class="login-body">

            <!--- ── Sent state ── --->
            <cfif pgaction IS "sent">
                <div class="status-icon status-icon-success">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M22 2L11 13"/><path d="M22 2L15 22l-4-9-9-4z"/>
                    </svg>
                </div>
                <h2 class="status-title">Check Your Email</h2>
                <p class="login-subtitle" style="margin-bottom: 0;">
                    If an account exists with that email address, we've sent instructions to reset your password.
                </p>

                <cfoutput>
                <cfif listFirst(cgi.server_name, ".") EQ "dev" AND len(recoverLink)>
                    <div class="dev-link">
                        <strong>Dev mode:</strong> <a href="#recoverLink#">#recoverLink#</a>
                    </div>
                </cfif>
                </cfoutput>

            <!--- ── Rate limit state ── --->
            <cfelseif pgaction IS "ratelimit">
                <div class="status-icon status-icon-warning">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>
                    </svg>
                </div>
                <h2 class="status-title">Please Wait</h2>
                <p class="login-subtitle" style="margin-bottom: 0;">
                    You recently requested a recovery email. Please wait a minute before trying again.
                </p>

            <!--- ── Form state ── --->
            <cfelse>
                <p class="login-subtitle">Enter your email and we'll send instructions to reset your password.</p>

                <form id="recovery-form" action="/auth-recoverpw.cfm" method="post" novalidate>
                    <input type="hidden" name="pgaction" value="recover" />

                    <div class="form-group">
                        <label for="email">Email Address</label>
                        <div class="form-input-wrap">
                            <input type="email" id="email" name="email"
                                   required placeholder="you@example.com"
                                   autocomplete="email" autofocus />
                        </div>
                    </div>

                    <button class="btn-login" type="submit" id="submitBtn">Reset Password</button>
                </form>
            </cfif>

            <a href="/loginform.cfm" class="back-link">Back to Login</a>

        </div>
    </div>

    <footer class="login-footer">
        <cfoutput>&copy; #year(now())# The Actor's Office&trade; &mdash; All Rights Reserved.</cfoutput>
    </footer>

    <script>
    (function() {
        var form = document.getElementById('recovery-form');
        if (form) {
            form.addEventListener('submit', function(e) {
                var email = document.getElementById('email');
                if (!email.value.trim()) { e.preventDefault(); email.focus(); return; }
                var btn = document.getElementById('submitBtn');
                btn.disabled = true;
                btn.innerHTML = '<span class="btn-spinner"></span>Sending...';
            });
        }
    })();
    </script>

</body>
</html>
