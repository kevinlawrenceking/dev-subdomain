<!--- TAO-SPEC-2026-005: User-facing error page --->
<!--- Fully self-contained. All CSS inline. No external dependencies. --->
<!--- Reads request.errorTicketId set by the caller before cfinclude. --->
<!--- ZERO diagnostic data: no stack traces, file paths, SQL, error types, or server info. --->
<cfparam name="request.errorTicketId" default="UNKNOWN" />
<cfoutput>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>The Actors Office</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;700&display=swap');

    * { margin:0; padding:0; box-sizing:border-box; }

    body {
      font-family: 'DM Sans', system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;
      background-color: ##F1F5F9;
      color: ##1E293B;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 24px;
    }

    .error-card {
      background: ##ffffff;
      border-radius: 16px;
      box-shadow: 0 4px 24px rgba(0,0,0,0.08);
      max-width: 520px;
      width: 100%;
      overflow: hidden;
      text-align: center;
    }

    .error-header {
      background-color: ##406E8E;
      padding: 32px 30px 28px;
    }

    .error-header .brand {
      color: ##ffffff;
      font-size: 18px;
      font-weight: 700;
      letter-spacing: 0.5px;
      margin-bottom: 4px;
    }

    .error-header .brand-sub {
      color: ##a8c8de;
      font-size: 12px;
      font-weight: 400;
    }

    .error-body {
      padding: 36px 30px;
    }

    .error-body h1 {
      font-size: 22px;
      font-weight: 700;
      color: ##1E293B;
      margin-bottom: 12px;
    }

    .error-body p {
      font-size: 15px;
      color: ##64748B;
      line-height: 1.6;
      margin-bottom: 24px;
    }

    .ticket-box {
      display: inline-block;
      background: ##F1F5F9;
      border: 2px solid ##E2E8F0;
      border-radius: 8px;
      padding: 14px 28px;
      margin-bottom: 28px;
    }

    .ticket-label {
      font-size: 11px;
      text-transform: uppercase;
      letter-spacing: 1.5px;
      color: ##94A3B8;
      font-weight: 600;
      margin-bottom: 4px;
    }

    .ticket-id {
      font-size: 22px;
      font-weight: 700;
      font-family: 'Courier New', Courier, monospace;
      color: ##1E293B;
      letter-spacing: 1px;
    }

    .actions {
      display: flex;
      flex-direction: column;
      gap: 12px;
      align-items: center;
    }

    .btn-primary {
      display: inline-block;
      background-color: ##406E8E;
      color: ##ffffff;
      text-decoration: none;
      padding: 12px 32px;
      border-radius: 8px;
      font-size: 14px;
      font-weight: 600;
      transition: background-color 0.2s;
    }

    .btn-primary:hover {
      background-color: ##345A74;
    }

    .link-support {
      font-size: 13px;
      color: ##406E8E;
      text-decoration: none;
      font-weight: 500;
    }

    .link-support:hover {
      text-decoration: underline;
    }

    .error-footer {
      padding: 16px 30px;
      background: ##F8FAFC;
      border-top: 1px solid ##E2E8F0;
    }

    .error-footer p {
      font-size: 12px;
      color: ##94A3B8;
      margin: 0;
    }
  </style>
</head>
<body>
  <div class="error-card">
    <div class="error-header">
      <div class="brand">The Actors Office</div>
      <div class="brand-sub">Career Management Platform</div>
    </div>
    <div class="error-body">
      <h1>Something went wrong</h1>
      <p>Our system encountered an issue. Our team has been automatically notified and is looking into it.</p>
      <div class="ticket-box">
        <div class="ticket-label">Ticket ID</div>
        <div class="ticket-id">#encodeForHtml(request.errorTicketId)#</div>
      </div>
      <p>Please reference this ticket ID if you contact support.</p>
      <div class="actions">
        <a href="/app/dashboard/" class="btn-primary">Return to Dashboard</a>
        <a href="mailto:support@theactorsoffice.com?subject=#urlEncodedFormat('Support Request ' & chr(8212) & ' ' & request.errorTicketId)#" class="link-support">Contact Support</a>
      </div>
    </div>
    <div class="error-footer">
      <p>If this issue persists, please email support@theactorsoffice.com with your ticket ID.</p>
    </div>
  </div>
</body>
</html>
</cfoutput>
