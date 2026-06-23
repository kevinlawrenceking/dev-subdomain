<!--- TAO-SPEC-2026-005 (user-facing error mgmt flow): user "we're on it" email. --->
<!--- Rendered via cfsavecontent in ErrorService.sendInitialUserEmail(). --->
<!--- Reads request._userInitialDiag = { ticketId, userName }. --->
<!--- ZERO diagnostics: no stack trace, SQL, file paths, error type, or server info. --->
<cfset d = request._userInitialDiag />
<cfset greetName = (structKeyExists(d, "userName") AND len(trim(d.userName))) ? trim(listFirst(d.userName, " ")) : "there" />
<cfoutput>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
</head>
<body style="margin:0; padding:0; background-color:##f1f5f9; font-family:Arial, Helvetica, sans-serif; font-size:14px; color:##1E293B;">
<table width="100%" cellpadding="0" cellspacing="0" style="background-color:##f1f5f9; padding:20px 0;">
<tr><td align="center">
<table width="600" cellpadding="0" cellspacing="0" style="background-color:##ffffff; border-radius:8px; overflow:hidden; border:1px solid ##e2e8f0;">

  <tr>
    <td style="background-color:##406E8E; padding:26px 30px; text-align:center;">
      <p style="color:##ffffff; font-size:18px; margin:0; font-weight:700; letter-spacing:0.5px;">The Actors Office</p>
      <p style="color:##a8c8de; font-size:12px; margin:4px 0 0 0;">Support</p>
    </td>
  </tr>

  <tr>
    <td style="padding:30px;">
      <p style="margin:0 0 14px 0;">Hi #encodeForHtml(greetName)#,</p>
      <p style="margin:0 0 14px 0; line-height:1.6; color:##334155;">
        Thanks for your patience. Our system flagged an issue on your account and our team has
        been automatically notified. We're already looking into it and will follow up if we need
        anything from you.
      </p>

      <table cellpadding="0" cellspacing="0" align="center" style="margin:8px auto 18px auto;">
        <tr><td style="background:##f1f5f9; border:2px solid ##e2e8f0; border-radius:8px; padding:12px 26px; text-align:center;">
          <div style="font-size:11px; text-transform:uppercase; letter-spacing:1.5px; color:##94A3B8; font-weight:600; margin-bottom:4px;">Your Reference</div>
          <div style="font-size:20px; font-weight:700; font-family:'Courier New',Courier,monospace; color:##1E293B; letter-spacing:1px;">#encodeForHtml(d.ticketId)#</div>
        </td></tr>
      </table>

      <p style="margin:0 0 14px 0; line-height:1.6; color:##334155;">
        Please reference <strong>#encodeForHtml(d.ticketId)#</strong> if you reply to this email
        or contact support.
      </p>
      <p style="margin:0; color:##334155;">-- The Actors Office Support Team<br>support@theactorsoffice.com</p>
    </td>
  </tr>

  <tr>
    <td style="padding:14px 30px; background:##f8fafc; border-top:1px solid ##e2e8f0;">
      <p style="font-size:12px; color:##94A3B8; margin:0;">If this issue persists, email support@theactorsoffice.com with your reference number.</p>
    </td>
  </tr>

</table>
</td></tr>
</table>
</body>
</html>
</cfoutput>
