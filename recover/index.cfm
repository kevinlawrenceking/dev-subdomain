<!--- Password Reset Form
     Validates the recovery token from URL, checks expiration, and shows the new password form.
     Token is stored in session for setup2.cfm to verify. --->

<!--- dsn is set by Application.cfm --->
<cfif NOT isDefined("dsn") OR NOT len(dsn)>
    <cfset dsn = listFirst(cgi.server_name, ".") EQ "app" ? "abo" : "abod" />
</cfif>

<cfset tokenValid = false />
<cfset tokenError = "" />

<!--- Only accept token-based recovery (no userid bypass) --->
<cfif structKeyExists(url, "recover") AND len(trim(url.recover))>

    <cfquery name="u" datasource="#dsn#">
        SELECT userid, userfirstname, userlastname, recover_requested_at
        FROM taousers
        WHERE recover = <cfqueryparam value="#trim(url.recover)#" cfsqltype="cf_sql_varchar">
        LIMIT 1
    </cfquery>

    <cfif u.recordcount IS 1>
        <!--- Check token expiration (1 hour) --->
        <cfif isDate(u.recover_requested_at)
              AND dateDiff("n", u.recover_requested_at, now()) LT 60>
            <cfset tokenValid = true />
            <cfset session.recoverToken = trim(url.recover) />
        <cfelse>
            <cfset tokenError = "This recovery link has expired. Please request a new one." />
        </cfif>
    <cfelse>
        <cfset tokenError = "This recovery link is invalid or has already been used." />
    </cfif>

<cfelse>
    <cflocation url="/loginform.cfm" addtoken="false" />
</cfif>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>Create New Password | The Actor's Office</title>
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

        /* ── Status Icons (expired state) ────────────── */
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

        .form-group label .req {
            color: var(--tao-danger);
            margin-left: 2px;
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

        .form-input-wrap input.input-error {
            border-color: var(--tao-danger);
            box-shadow: 0 0 0 3px rgba(220, 79, 82, 0.1);
        }

        .field-error {
            font-size: 12px;
            color: var(--tao-danger);
            margin-top: 5px;
            display: none;
        }

        .pw-hint {
            font-size: 12px;
            color: var(--tao-gray);
            margin-top: 4px;
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
        .btn-login:hover::after { left: 100%; }

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

        /* ── Outline button for secondary actions ───── */
        .btn-outline {
            display: inline-block;
            padding: 11px 28px;
            font-family: inherit;
            font-size: 14px;
            font-weight: 600;
            color: var(--tao-blue);
            background: transparent;
            border: 1.5px solid var(--tao-blue);
            border-radius: 8px;
            cursor: pointer;
            text-decoration: none;
            transition: background 0.2s ease, color 0.2s ease;
        }
        .btn-outline:hover {
            background: var(--tao-blue);
            color: var(--tao-white);
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
        .back-link:hover { color: var(--tao-gold); }

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
                <img src="/media-#dsn#/images/logo-light.png"
                     alt="The Actor's Office"
                     onerror="this.style.display='none';this.nextElementSibling.style.display='block';" />
                <div class="logo-text">
                    <span class="cap gold">T</span><span class="small">HE</span>&nbsp;&nbsp;<span class="cap gold">A</span><span class="small">CTOR'S</span>&nbsp;&nbsp;<span class="cap gold">O</span><span class="small">FFICE</span>
                </div>
            </cfoutput>
        </div>

        <div class="login-body">

            <cfif tokenValid>
                <p class="login-subtitle">
                    <cfoutput>Hi #encodeForHTML(u.userfirstname)#,</cfoutput> enter your new password below.
                </p>

                <form id="reset-form" action="setup2.cfm" method="post" autocomplete="off" novalidate>

                    <div class="form-group">
                        <label for="pass1">New Password <span class="req">*</span></label>
                        <div class="form-input-wrap">
                            <input id="pass1" type="password" name="pass1"
                                   placeholder="Minimum 8 characters"
                                   required minlength="8"
                                   autocomplete="new-password" />
                        </div>
                        <div class="pw-hint">Must be at least 8 characters</div>
                        <div class="field-error" id="err-pass1">Password must be at least 8 characters.</div>
                    </div>

                    <div class="form-group">
                        <label for="pass2">Confirm Password <span class="req">*</span></label>
                        <div class="form-input-wrap">
                            <input id="pass2" type="password" name="pass2"
                                   placeholder="Re-enter password"
                                   required minlength="8"
                                   autocomplete="new-password" />
                        </div>
                        <div class="field-error" id="err-pass2">Passwords do not match.</div>
                    </div>

                    <button class="btn-login" type="submit" id="submitBtn">Update Password</button>
                </form>

            <cfelse>
                <div class="status-icon status-icon-warning">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
                    </svg>
                </div>
                <h2 class="status-title">Link Expired</h2>
                <p class="login-subtitle" style="margin-bottom: 24px;">
                    <cfoutput>#encodeForHTML(tokenError)#</cfoutput>
                </p>
                <div style="text-align: center;">
                    <a href="/auth-recoverpw.cfm" class="btn-outline">Request New Link</a>
                </div>
            </cfif>

            <a href="/loginform.cfm" class="back-link">Back to Login</a>

        </div>
    </div>

    <footer class="login-footer">
        <cfoutput>&copy; #year(now())# The Actor's Office&trade; &mdash; All Rights Reserved.</cfoutput>
    </footer>

    <cfif tokenValid>
    <script>
    (function() {
        var form = document.getElementById('reset-form');
        var pass1 = document.getElementById('pass1');
        var pass2 = document.getElementById('pass2');
        var errPass1 = document.getElementById('err-pass1');
        var errPass2 = document.getElementById('err-pass2');

        function clearError(input, errEl) {
            input.classList.remove('input-error');
            errEl.style.display = 'none';
        }

        pass1.addEventListener('input', function() { clearError(pass1, errPass1); });
        pass2.addEventListener('input', function() { clearError(pass2, errPass2); });

        form.addEventListener('submit', function(e) {
            var valid = true;

            if (pass1.value.length < 8) {
                pass1.classList.add('input-error');
                errPass1.style.display = 'block';
                valid = false;
            }

            if (pass2.value !== pass1.value || pass2.value.length < 8) {
                pass2.classList.add('input-error');
                errPass2.style.display = 'block';
                valid = false;
            }

            if (!valid) {
                e.preventDefault();
                return;
            }

            var btn = document.getElementById('submitBtn');
            btn.disabled = true;
            btn.innerHTML = '<span class="btn-spinner"></span>Updating...';
        });
    })();
    </script>
    </cfif>

</body>
</html>
