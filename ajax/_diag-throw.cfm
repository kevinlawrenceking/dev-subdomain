<!--- TEMPORARY DIAGNOSTIC - DELETE AFTER TESTING.
      Forces an exception so ajax/Application.cfc onError -> ErrorService runs end to end
      (AJAX path: JSON with ticketId + initial user email). Reach it with a GET so the
      framework CSRF check (POST/PUT/DELETE only) does not block it. The ajax gate already
      requires an authenticated session, so userid/email are present. --->
<cfthrow type="TAO.Diag.Test" message="Controlled test error (ajax) - safe to ignore" detail="Triggered from /ajax/_diag-throw.cfm for error-flow QA." />
