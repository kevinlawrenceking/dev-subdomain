<!--- TAO-SPEC-2026-005: Error ticket email template --->
<!--- Rendered via cfsavecontent in ErrorService.sendErrorEmail(). --->
<!--- Reads request._errorDiagnostics struct set by the caller. --->
<!--- WAF-safe: No script tags, no inline event handlers, no raw SQL keywords in HTML structure. --->
<!--- No cfmail tags in this file. --->
<cfset d = request._errorDiagnostics />
<cfoutput>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
</head>
<body style="margin:0; padding:0; background-color:##f4f4f7; font-family:Arial, Helvetica, sans-serif; font-size:14px; color:##1F2937;">
<table width="100%" cellpadding="0" cellspacing="0" style="background-color:##f4f4f7; padding:20px 0;">
<tr><td align="center">
<table width="600" cellpadding="0" cellspacing="0" style="background-color:##ffffff; border-radius:8px; overflow:hidden; border:1px solid ##e5e7eb;">

  <!--- ============================================================
        1. HEADER BANNER
        ============================================================ --->
  <tr>
    <td style="background-color:##406E8E; padding:28px 30px; text-align:center;">
      <p style="color:##ffffff; font-size:20px; margin:0 0 10px 0; font-weight:600; letter-spacing:0.5px;">Error Report</p>
      <p style="color:##d1e3f0; font-size:28px; font-family:'Courier New',Courier,monospace; margin:0 0 8px 0; font-weight:700; letter-spacing:2px;">#encodeForHtml(d.ticketId)#</p>
      <p style="color:##a8c8de; font-size:12px; margin:0;">#encodeForHtml(dateTimeFormat(now(), "yyyy-MM-dd HH:nn:ss"))#</p>
    </td>
  </tr>

  <!--- ============================================================
        2. ERROR SUMMARY
        ============================================================ --->
  <tr>
    <td style="background-color:##FEE2E2; padding:20px 30px; border-left:4px solid ##991B1B;">
      <p style="color:##991B1B; font-size:11px; text-transform:uppercase; font-weight:700; margin:0 0 8px 0; letter-spacing:1px;">Error Summary</p>
      <cfif len(d.errorType)>
        <p style="color:##7F1D1D; font-size:12px; margin:0 0 6px 0;"><strong>Type:</strong> #encodeForHtml(d.errorType)#</p>
      </cfif>
      <p style="color:##991B1B; font-size:14px; margin:0 0 6px 0; word-break:break-word;">
        <strong>Message:</strong> #encodeForHtml(Left(d.errorMessage, 500))#
      </p>
      <cfif len(d.errorDetail)>
        <p style="color:##7F1D1D; font-size:13px; margin:0; word-break:break-word;">
          <strong>Detail:</strong> #encodeForHtml(Left(d.errorDetail, 500))#
        </p>
      </cfif>
    </td>
  </tr>

  <!--- ============================================================
        3. USER CONTEXT
        ============================================================ --->
  <tr>
    <td style="padding:20px 30px; border-bottom:1px solid ##e5e7eb;">
      <p style="color:##374151; font-size:11px; text-transform:uppercase; font-weight:700; margin:0 0 10px 0; letter-spacing:1px;">User Context</p>
      <table width="100%" cellpadding="4" cellspacing="0" style="font-size:13px; color:##4B5563;">
        <tr>
          <td style="width:110px; font-weight:600; vertical-align:top;">User ID:</td>
          <td>#encodeForHtml(len(d.userId) ? d.userId : "(none)")#</td>
        </tr>
        <tr>
          <td style="font-weight:600; vertical-align:top;">Email:</td>
          <td>#encodeForHtml(len(d.userEmail) ? d.userEmail : "(none)")#</td>
        </tr>
        <tr>
          <td style="font-weight:600; vertical-align:top;">IP Address:</td>
          <td>#encodeForHtml(d.remoteIp)#</td>
        </tr>
        <tr>
          <td style="font-weight:600; vertical-align:top;">User Agent:</td>
          <td style="word-break:break-all; font-size:12px;">#encodeForHtml(d.userAgent)#</td>
        </tr>
      </table>
    </td>
  </tr>

  <!--- ============================================================
        4. REQUEST CONTEXT
        ============================================================ --->
  <tr>
    <td style="padding:20px 30px; border-bottom:1px solid ##e5e7eb;">
      <p style="color:##374151; font-size:11px; text-transform:uppercase; font-weight:700; margin:0 0 10px 0; letter-spacing:1px;">Request Context</p>
      <table width="100%" cellpadding="4" cellspacing="0" style="font-size:13px; color:##4B5563;">
        <tr>
          <td style="width:110px; font-weight:600; vertical-align:top;">Script:</td>
          <td style="word-break:break-all;">#encodeForHtml(d.scriptName)#</td>
        </tr>
        <tr>
          <td style="font-weight:600; vertical-align:top;">Query String:</td>
          <td style="word-break:break-all; font-size:12px;">#encodeForHtml(d.queryString)#</td>
        </tr>
        <tr>
          <td style="font-weight:600; vertical-align:top;">Method:</td>
          <td>#encodeForHtml(d.httpMethod)#</td>
        </tr>
        <tr>
          <td style="font-weight:600; vertical-align:top;">Referer:</td>
          <td style="word-break:break-all; font-size:12px;">#encodeForHtml(d.httpReferer)#</td>
        </tr>
        <cfif len(d.formData) AND d.formData NEQ "Error reading form scope" AND d.formData NEQ "{}">
        <tr>
          <td style="font-weight:600; vertical-align:top;">Form Data:</td>
          <td>
            <pre style="margin:0; font-size:11px; white-space:pre-wrap; word-break:break-all; background:##f9fafb; padding:8px; border:1px solid ##e5e7eb; border-radius:4px; font-family:'Courier New',Courier,monospace;">#encodeForHtml(d.formData)#</pre>
          </td>
        </tr>
        </cfif>
      </table>
    </td>
  </tr>

  <!--- ============================================================
        5. STACK TRACE
        ============================================================ --->
  <cfif len(d.stackTrace)>
  <tr>
    <td style="padding:20px 30px; border-bottom:1px solid ##e5e7eb;">
      <p style="color:##374151; font-size:11px; text-transform:uppercase; font-weight:700; margin:0 0 10px 0; letter-spacing:1px;">Stack Trace</p>
      <pre style="font-size:11px; color:##1F2937; background:##f3f4f6; border:1px solid ##d1d5db; border-radius:4px; padding:12px; white-space:pre-wrap; word-break:break-all; max-height:500px; overflow:auto; font-family:'Courier New',Courier,monospace;">#encodeForHtml(d.stackTrace)#</pre>
    </td>
  </tr>
  </cfif>

  <!--- ============================================================
        6. TAG CONTEXT
        ============================================================ --->
  <cfif structKeyExists(d, "exception") AND structKeyExists(d.exception, "tagContext") AND isArray(d.exception.tagContext) AND arrayLen(d.exception.tagContext)>
  <tr>
    <td style="padding:20px 30px; border-bottom:1px solid ##e5e7eb;">
      <p style="color:##374151; font-size:11px; text-transform:uppercase; font-weight:700; margin:0 0 10px 0; letter-spacing:1px;">Tag Context</p>
      <table width="100%" cellpadding="6" cellspacing="0" style="font-size:12px; border:1px solid ##d1d5db; border-collapse:collapse;">
        <tr style="background:##f3f4f6;">
          <th style="text-align:left; padding:8px; border:1px solid ##d1d5db; font-weight:700;">Template</th>
          <th style="text-align:left; padding:8px; border:1px solid ##d1d5db; font-weight:700; width:60px;">Line</th>
          <th style="text-align:left; padding:8px; border:1px solid ##d1d5db; font-weight:700; width:60px;">Column</th>
        </tr>
        <cfloop from="1" to="#arrayLen(d.exception.tagContext)#" index="i">
          <cfset tc = d.exception.tagContext[i] />
          <tr style="#(i EQ 1) ? 'background:##FFFBEB; font-weight:700;' : ''#">
            <td style="padding:6px 8px; border:1px solid ##d1d5db; word-break:break-all;">#encodeForHtml(structKeyExists(tc, "template") ? tc.template : "")#</td>
            <td style="padding:6px 8px; border:1px solid ##d1d5db;">#encodeForHtml(structKeyExists(tc, "line") ? tc.line : "")#</td>
            <td style="padding:6px 8px; border:1px solid ##d1d5db;">#encodeForHtml(structKeyExists(tc, "column") ? tc.column : "")#</td>
          </tr>
        </cfloop>
      </table>
    </td>
  </tr>
  </cfif>

  <!--- ============================================================
        7. SQL (conditional — only for database exceptions)
        ============================================================ --->
  <cfif len(d.sqlStatement)>
  <tr>
    <td style="padding:20px 30px; border-bottom:1px solid ##e5e7eb;">
      <p style="color:##374151; font-size:11px; text-transform:uppercase; font-weight:700; margin:0 0 10px 0; letter-spacing:1px;">Sanitized Query</p>
      <pre style="font-size:11px; color:##1F2937; background:##FEF3C7; border:1px solid ##F59E0B; border-radius:4px; padding:12px; white-space:pre-wrap; word-break:break-all; font-family:'Courier New',Courier,monospace;">#encodeForHtml(d.sqlStatement)#</pre>
    </td>
  </tr>
  </cfif>

  <!--- ============================================================
        8. FOOTER
        ============================================================ --->
  <tr>
    <td style="padding:16px 30px; background-color:##f9fafb; border-top:1px solid ##e5e7eb;">
      <table width="100%" cellpadding="2" cellspacing="0" style="font-size:11px; color:##9CA3AF;">
        <tr>
          <td><strong>Environment:</strong> #encodeForHtml(d.environment)#</td>
          <td><strong>Context:</strong> #encodeForHtml(d.cfContext)#</td>
        </tr>
        <tr>
          <td><strong>CF Engine:</strong> #encodeForHtml(d.cfEngine)#</td>
          <td><strong>Server:</strong> #encodeForHtml(d.serverName)#</td>
        </tr>
        <cfif len(d.eventName)>
        <tr>
          <td colspan="2"><strong>Event:</strong> #encodeForHtml(d.eventName)#</td>
        </tr>
        </cfif>
      </table>
    </td>
  </tr>

</table>
</td></tr>
</table>
</body>
</html>
</cfoutput>
