-- ============================================================================
-- update_tickets_implemented_2026-04-02.sql
-- Marks fixed Tested-Bug tickets as Implemented after code/DB fixes applied.
-- Run against abo (production) ONLY.
--
-- SAFE: ticketResponse uses CONCAT(COALESCE(...)) to APPEND only.
-- ============================================================================

-- ============================================================
-- #2191 - Relationship views rebuilt with correct systemtype values
-- ============================================================
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[IMPLEMENTED 2026-04-02] Rebuilt contacts_ss_target, contacts_ss_followup, and contacts_ss_maint views with correct systemtype filter values (Targeted List, Follow Up, Maintenance List). Switching a relationship from Targeted to Follow-up now correctly shows the contact in the Follow-up filtered list.'
    ),
    ticketStatus = 'Implemented'
WHERE ticketid = 2191;

-- ============================================================
-- #2192 - Reminder completion transaction error handling
-- ============================================================
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[IMPLEMENTED 2026-04-02] Added try-catch around the completion transaction in complete_not_ajax.cfm. Previously, if any downstream query in the transaction failed, the entire transaction rolled back silently but the endpoint still returned success:true, making the reminder reappear on refresh. Now returns success:false with error message so the UI does not falsely remove the reminder.'
    ),
    ticketStatus = 'Implemented'
WHERE ticketid = 2192;

-- ============================================================
-- #2161 - charDescription column expanded from VARCHAR(500) to TEXT
-- ============================================================
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[IMPLEMENTED 2026-04-02] Altered audroles.charDescription and auditionsimport.charDescription from VARCHAR(500) to TEXT (65,535 chars). The ColdFusion code was already using cf_sql_longvarchar with no maxlength, so the only truncation point was the database column size.'
    ),
    ticketStatus = 'Implemented'
WHERE ticketid = 2161;

-- ============================================================
-- #1615 - Login blank Whoops screens
-- ============================================================
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[IMPLEMENTED 2026-04-02] Fixed login redirect in login/login2.cfm: changed addtoken="true" to addtoken="false" and removed userid from query string. The addtoken=true was injecting a ColdFusion session token from an unauthenticated context, which could cause CSRF validation failures or blank error screens on the post-login landing page.'
    ),
    ticketStatus = 'Implemented'
WHERE ticketid = 1615;

-- ============================================================
-- #1646 - Login redirecting to wrong page
-- ============================================================
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[IMPLEMENTED 2026-04-02] Same fix as #1615 - login redirect in login/login2.cfm changed addtoken="true" to addtoken="false" and removed userid from query string. This eliminates the stale token that could cause wrong-page redirects after authentication.'
    ),
    ticketStatus = 'Implemented'
WHERE ticketid = 1646;
