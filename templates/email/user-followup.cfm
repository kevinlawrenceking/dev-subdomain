<!--- TAO-SPEC-2026-005 (user-facing error mgmt flow): 3-day follow-up email. --->
<!--- Rendered via cfsavecontent in /sched/ticket_followup.cfm. --->
<!--- Reads request._userFollowupDiag = { reference, userName }. --->
<!--- ZERO diagnostics: no stack trace, SQL, file paths, error type, or server info. --->
<cfset d = request._userFollowupDiag />
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
        A few days ago we let you know that the issue on your account
        (reference <strong>#encodeForHtml(d.reference)#</strong>) had been resolved. We're
        following up to make sure everything is working as expected.
      </p>
      <p style="margin:0 0 14px 0; line-height:1.6; color:##334155;">
        If you're all set, no action is needed. If anything still isn't right, just reply to
        this email referencing <strong>#encodeForHtml(d.reference)#</strong> and we'll jump
        back in.
      </p>
      <p style="margin:0; color:##334155;">-- The Actors Office Support Team<br>support@theactorsoffice.com</p>
    </td>
  </tr>

  <tr>
    <td style="padding:14px 30px; background:##f8fafc; border-top:1px solid ##e2e8f0;">
      <p style="font-size:12px; color:##94A3B8; margin:0;">Reference #encodeForHtml(d.reference)# &bull; support@theactorsoffice.com</p>
    </td>
  </tr>

</table>
</td></tr>
</table>
</body>
</html>
</cfoutput>
