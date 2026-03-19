<!--- ALWAYS compute host and dsn -- never rely on stale application scope --->
<cfset host = ListFirst(cgi.server_name, ".") />
<cfif host EQ "app">
    <cfset application.dsn = "abo" />
    <cfset application.information_schema = "actorsbusinessoffice" />
    <cfset application.suffix = "_1.5" />
<cfelse>
    <cfset application.dsn = "abod" />
    <cfset application.information_schema = "new_development" />
    <cfset application.suffix = "" />
</cfif>

<!--- Host-specific app name prevents dev/prod cross-contamination --->
<cfapplication name="TAO_#host#" sessionmanagement="true">

<cfset dsn = application.dsn />

<!--- Clear session on login page view (acts as logout mechanism) --->
<!--- MIGRATE: Go auth will use stateless JWT — session wipe logic moves to token invalidation --->
<cfif structKeyExists(cookie, "userid")>
    <cfset structDelete(cookie, "userid")>
</cfif>
<cfif structKeyExists(session, "userid")>
    <cfset structDelete(session, "userid")>
</cfif>

<!--- Default parameters (from URL redirect after login attempt) --->
<cfparam name="pgrecover" default="N" />
<cfparam name="pwrong" default="N" />
<cfparam name="u" default="" />

<!--- Merge URL values explicitly (scope shadowing fix) --->
<cfif structKeyExists(url, "pgrecover")>
    <cfset pgrecover = url.pgrecover />
</cfif>
<cfif structKeyExists(url, "pwrong")>
    <cfset pwrong = url.pwrong />
</cfif>
<cfif structKeyExists(url, "u")>
    <cfset u = url.u />
</cfif>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>Log In | The Actor's Office</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta content="The Actor's Office Application" name="description" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="robots" content="noindex" />
    <link rel="shortcut icon" href="/media/shared/images/favicon.ico" />

    <!--- Google Fonts — Cinzel (matches Trajan Pro logo) + DM Sans (clean UI) --->
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@400;500;600;700&family=DM+Sans:wght@400;500;600&display=swap" rel="stylesheet" />

    <style>
        /* ── Reset & Base ─────────────────────────────────── */
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

        /* ── Subtle animated background texture ────────── */
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

        /* ── Card ──────────────────────────────────────── */
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

        /* ── Logo Header ───────────────────────────────── */
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

        /* Text fallback if image fails — matches Trajan Pro logo */
        .login-header .logo-text {
            font-family: 'Cinzel', 'Times New Roman', serif;
            font-size: 28px;
            font-weight: 400;
            color: var(--tao-white);
            letter-spacing: 3px;
            display: none;
        }

        .login-header .logo-text .cap {
            font-size: 34px;
            font-weight: 500;
        }

        .login-header .logo-text .gold {
            color: var(--tao-gold);
        }

        .login-header .logo-text .small {
            font-size: 22px;
            letter-spacing: 2.5px;
        }

        /* ── Form Body ─────────────────────────────────── */
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

        /* ── Form Groups ───────────────────────────────── */
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

        /* password field extra right padding for toggle */
        .form-input-wrap input[type="password"],
        .form-input-wrap input.pw-field {
            padding-right: 48px;
        }

        /* ── Eye Toggle (inline SVG — no Font Awesome dependency) ── */
        .pw-toggle {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            cursor: pointer;
            padding: 4px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--tao-gray);
            transition: color 0.2s ease;
        }
        .pw-toggle:hover { color: var(--tao-blue); }
        .pw-toggle svg { width: 20px; height: 20px; }

        /* ── Submit Button ─────────────────────────────── */
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

        /* gold shimmer accent on hover */
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

        /* ── Forgot Password Link ──────────────────────── */
        .forgot-link {
            display: block;
            text-align: center;
            margin-top: 20px;
            font-size: 13px;
            color: var(--tao-blue);
            text-decoration: none;
            transition: color 0.2s ease;
        }
        .forgot-link:hover {
            color: var(--tao-gold);
        }

        /* ── Divider ───────────────────────────────────── */
        .login-divider {
            display: flex;
            align-items: center;
            gap: 12px;
            margin: 20px 0 0;
        }
        .login-divider::before,
        .login-divider::after {
            content: '';
            flex: 1;
            height: 1px;
            background: var(--tao-border);
        }
        .login-divider span {
            font-size: 11px;
            color: var(--tao-gray);
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        /* ── Alerts (modern toast-style) ───────────────── */
        .tao-alert {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 12px 16px;
            border-radius: 8px;
            font-size: 13.5px;
            font-weight: 500;
            line-height: 1.4;
            margin-bottom: 20px;
            animation: alertIn 0.4s cubic-bezier(0.23, 1, 0.32, 1) both;
            position: relative;
        }

        @keyframes alertIn {
            from { opacity: 0; transform: translateY(-8px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .tao-alert-success {
            background: #ECFDF5;
            color: #065F46;
            border: 1px solid #A7F3D0;
        }
        .tao-alert-success .alert-icon { color: var(--tao-success); }

        .tao-alert-error {
            background: #FEF2F2;
            color: #991B1B;
            border: 1px solid #FECACA;
        }
        .tao-alert-error .alert-icon { color: var(--tao-danger); }

        .alert-icon {
            flex-shrink: 0;
            display: flex;
        }
        .alert-icon svg { width: 18px; height: 18px; }

        .alert-dismiss {
            margin-left: auto;
            flex-shrink: 0;
            background: none;
            border: none;
            cursor: pointer;
            padding: 2px;
            display: flex;
            opacity: 0.5;
            transition: opacity 0.2s;
            color: inherit;
        }
        .alert-dismiss:hover { opacity: 1; }
        .alert-dismiss svg { width: 16px; height: 16px; }

        .tao-alert.fade-out {
            opacity: 0;
            transform: translateY(-8px);
            transition: opacity 0.4s ease, transform 0.4s ease;
        }

        /* ── Footer ────────────────────────────────────── */
        .login-footer {
            position: relative;
            z-index: 1;
            margin-top: 24px;
            text-align: center;
            font-size: 12px;
            color: rgba(255, 255, 255, 0.45);
            letter-spacing: 0.3px;
        }

        /* ── Responsive ────────────────────────────────── */
        @media (max-width: 480px) {
            .login-body { padding: 28px 20px 24px; }
            .login-header { padding: 28px 20px 22px; }
        }
    </style>
</head>

<body>

    <div class="login-card">

        <!--- ── Logo Header (black bg to match logo image) ── --->
        <div class="login-header">
            <cfoutput>
                <img src="/media-#application.dsn#/images/logo-light.png"
                     alt="The Actor's Office"
                     onerror="this.style.display='none';this.nextElementSibling.style.display='block';" />
                <!--- Text fallback styled to match Trajan logo: gold caps T/A/O, white small-caps rest --->
                <div class="logo-text">
                    <span class="cap gold">T</span><span class="small">HE</span>&nbsp;&nbsp;<span class="cap gold">A</span><span class="small">CTOR'S</span>&nbsp;&nbsp;<span class="cap gold">O</span><span class="small">FFICE</span>
                </div>
            </cfoutput>
        </div>

        <!--- ── Form Body ── --->
        <div class="login-body">

            <p class="login-subtitle">Sign in to your account</p>

            <!--- Success alert: password was changed --->
            <cfif pgrecover EQ "Y">
                <div class="tao-alert tao-alert-success" role="alert" id="successAlert">
                    <span class="alert-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M20 6L9 17l-5-5"/>
                        </svg>
                    </span>
                    <span>Password changed successfully. Please log in.</span>
                    <button class="alert-dismiss" onclick="dismissAlert(this)" aria-label="Close">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M18 6L6 18M6 6l12 12"/></svg>
                    </button>
                </div>
            </cfif>

            <!--- Error alert: wrong credentials --->
            <cfif pwrong EQ "Y">
                <div class="tao-alert tao-alert-error" role="alert" id="errorAlert">
                    <span class="alert-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                            <circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/>
                        </svg>
                    </span>
                    <span>Incorrect email or password. Please try again.</span>
                    <button class="alert-dismiss" onclick="dismissAlert(this)" aria-label="Close">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M18 6L6 18M6 6l12 12"/></svg>
                    </button>
                </div>
            </cfif>

            <!--- Login Form --->
            <form id="login-form" action="/login/login2.cfm" method="post" novalidate>
                <input type="hidden" name="pwrong" value="N" />
                <input type="hidden" name="pwpass" value="Y" />
                <cfif structKeyExists(url, "xu")>
                    <cfoutput><input type="hidden" name="xu" value="#encodeForHTMLAttribute(url.xu)#" /></cfoutput>
                </cfif>

                <div class="form-group">
                    <label for="j_username">Email Address</label>
                    <div class="form-input-wrap">
                        <cfoutput>
                        <input type="email"
                               id="j_username"
                               name="j_username"
                               value="#encodeForHTMLAttribute(u)#"
                               required
                               placeholder="you@example.com"
                               autocomplete="email"
                               autofocus />
                        </cfoutput>
                    </div>
                </div>

                <div class="form-group">
                    <label for="j_password">Password</label>
                    <div class="form-input-wrap">
                        <input type="password"
                               id="j_password"
                               name="j_password"
                               class="pw-field"
                               required
                               placeholder="Enter your password"
                               autocomplete="current-password" />
                        <!--- Inline SVG eye toggle — no Font Awesome dependency --->
                        <button type="button" class="pw-toggle" onclick="togglePassword()" aria-label="Show password">
                            <svg id="eyeOpen" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                                <circle cx="12" cy="12" r="3"/>
                            </svg>
                            <svg id="eyeClosed" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="display:none;">
                                <path d="M17.94 17.94A10.07 10.07 0 0112 20c-7 0-11-8-11-8a18.45 18.45 0 015.06-5.94M9.9 4.24A9.12 9.12 0 0112 4c7 0 11 8 11 8a18.5 18.5 0 01-2.16 3.19m-6.72-1.07a3 3 0 11-4.24-4.24"/>
                                <line x1="1" y1="1" x2="23" y2="23"/>
                            </svg>
                        </button>
                    </div>
                </div>

                <button class="btn-login" type="submit">Log In</button>
            </form>

            <div class="login-divider"><span>or</span></div>

            <a href="/auth-recoverpw.cfm" class="forgot-link">Forgot your password?</a>

        </div>
    </div>

    <footer class="login-footer">
        <cfoutput>&copy; #year(now())# The Actor's Office&trade; &mdash; All Rights Reserved.</cfoutput>
    </footer>

    <script>
    function togglePassword() {
        var field = document.getElementById('j_password');
        var open  = document.getElementById('eyeOpen');
        var closed = document.getElementById('eyeClosed');
        if (field.type === 'password') {
            field.type = 'text';
            open.style.display = 'none';
            closed.style.display = 'block';
        } else {
            field.type = 'password';
            open.style.display = 'block';
            closed.style.display = 'none';
        }
    }

    function dismissAlert(btn) {
        var alert = btn.closest('.tao-alert');
        alert.classList.add('fade-out');
        setTimeout(function() { alert.remove(); }, 400);
    }

    // Auto-dismiss alerts after 6 seconds
    (function() {
        setTimeout(function() {
            var alerts = document.querySelectorAll('.tao-alert');
            for (var i = 0; i < alerts.length; i++) {
                alerts[i].classList.add('fade-out');
                (function(el) {
                    setTimeout(function() { el.remove(); }, 400);
                })(alerts[i]);
            }
        }, 6000);
    })();
    </script>

</body>
</html>
