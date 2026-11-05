"""Security regressions: cross-user reminder read, panel-visibility SQL injection,
and the orphaned ICS writer (E032).

Static tests read the working-tree source; each also runs against the HEAD version
(via git show) to prove the check detects the original defect. Database tests use
synthetic rows in new_development inside a transaction that is always rolled back.
"""
import re
import subprocess
import unittest

from _tao import (REPO, cf_function, cfqueries, dev_fixture, skip_without_db, src,
                  strip_cf_comments, unparameterized_hashes)

GET_REMINDERS = "include/get_reminders.cfm"
PANEL_SVC = "services/PanelUserService.cfc"
ICSMAKER = "include/icsmaker.cfm"

# Synthetic ids far above anything in new_development (max userid ~219, suID ~3547).
USER_A, USER_B = 990000001, 990000002
CONTACT_B = 990000101


def head_src(relpath):
    return subprocess.check_output(["git", "show", "HEAD:" + relpath], cwd=REPO).decode(
        "utf-8", "replace")


# ---------------------------------------------------------------- static checks

def reminders_userid_is_session_only(text):
    """True when get_reminders never takes the user scope from the client."""
    code = strip_cf_comments(text)
    if re.search(r"url\.userid|form\.userid", code, re.I):
        return False
    # Must require a logged-in session before any query runs.
    guard = re.search(r'structKeyExists\(\s*session\s*,\s*"userid"\s*\)', code, re.I)
    first_query = re.search(r"<cfquery", code, re.I)
    return bool(guard and first_query and guard.start() < first_query.start())


def panel_update_is_bound(text):
    body = cf_function(text, "UPDpgpanels_user_23858")
    queries = list(cfqueries(body))
    return bool(queries) and all(not unparameterized_hashes(b) for _, b in queries) and \
        re.search(r'list="true"', body, re.I) is not None


def ics_is_scoped_and_bound(text):
    code = strip_cf_comments(text)
    unbound = [h for _, body in cfqueries(code) for h in unparameterized_hashes(body)]
    guard = re.search(r'structKeyExists\(\s*session\s*,\s*"userid"\s*\)', code, re.I)
    forced = re.search(r'<cfset\s+target_userid\s*=\s*val\(\s*session\.userid\s*\)', code, re.I)
    # The user loop must always be filtered (no conditional "all users" branch).
    loop_q = re.search(r'<cfquery[^>]*name="U">(.*?)</cfquery>', code, re.S | re.I)
    always_filtered = loop_q and "<cfif" not in loop_q.group(1).lower() and \
        re.search(r"WHERE\s+u\.userid\s*=\s*<cfqueryparam", loop_q.group(1), re.I)
    return not unbound and bool(guard) and bool(forced) and bool(always_filtered)


class StaticSecurity(unittest.TestCase):
    def test_reminders_scope_from_session_only(self):
        self.assertTrue(reminders_userid_is_session_only(src(GET_REMINDERS)))

    def test_reminders_check_detects_head_defect(self):
        self.assertFalse(reminders_userid_is_session_only(head_src(GET_REMINDERS)))

    def test_reminders_queries_bound(self):
        for _, body in cfqueries(src(GET_REMINDERS)):
            self.assertEqual(unparameterized_hashes(body), [])

    def test_panel_visibility_update_bound(self):
        self.assertTrue(panel_update_is_bound(src(PANEL_SVC)))

    def test_panel_check_detects_head_defect(self):
        self.assertFalse(panel_update_is_bound(head_src(PANEL_SVC)))

    def test_panel_service_has_no_unbound_sql(self):
        for _, body in cfqueries(src(PANEL_SVC)):
            self.assertEqual(unparameterized_hashes(body), [], body[:120])

    def test_ics_scoped_and_bound(self):
        self.assertTrue(ics_is_scoped_and_bound(src(ICSMAKER)))

    def test_ics_check_detects_head_defect(self):
        self.assertFalse(ics_is_scoped_and_bound(head_src(ICSMAKER)))

    def test_ics_has_no_callers(self):
        """E032: nothing includes or links the page; it is URL-reachable only."""
        out = subprocess.run(["git", "grep", "-n", "icsmaker", "--", "*.cfm", "*.cfc", "*.js"],
                             cwd=REPO, capture_output=True, text=True)
        refs = []
        for line in out.stdout.splitlines():
            path, _, text = line.split(":", 2)
            if path.startswith("sched/") or path == ICSMAKER:
                continue  # the separate scheduled generator / the page itself
            if re.match(r"\s*(\*|//|<!---)", text):
                continue  # comments (IcsService header documents the port)
            refs.append(line)
        self.assertEqual(refs, [])


# ------------------------------------------------- SQL behaviour (dev fixtures)

def sanitize_pnids(value):
    """Python mirror of the CFML filter in UPDpgpanels_user_23858."""
    keep = []
    for item in value.split(","):
        if re.fullmatch(r"\s*[0-9]+\s*", item) and int(item) > 0:
            keep.append(int(item))
    return keep


@skip_without_db
class FixtureSecurity(unittest.TestCase):
    REMINDER_SU_SQL = ("SELECT suid FROM fusystemusers WHERE contactid = %s "
                       "AND userid = %s AND sustatus = 'Active'")

    def test_reminder_suid_lookup_is_owner_scoped(self):
        with dev_fixture() as cur:
            cur.execute(
                "INSERT INTO fusystemusers_tbl (systemID, contactID, userid, suStartDate, sustatus)"
                " VALUES (1, %s, %s, CURDATE(), 'Active')", (CONTACT_B, USER_B))
            # Fixed code binds the session user (A): B's enrollment is invisible.
            cur.execute(self.REMINDER_SU_SQL, (CONTACT_B, USER_A))
            self.assertEqual(cur.fetchall(), ())
            # The pre-fix code bound url.userid; supplying B's id exposed B's suid.
            cur.execute(self.REMINDER_SU_SQL, (CONTACT_B, USER_B))
            self.assertEqual(len(cur.fetchall()), 1)

    def _panels(self, cur):
        for uid in (USER_A, USER_B):
            cur.execute("INSERT INTO pgpanels_user_tbl (pnTitle, pnFilename, pnOrderNo, IsVisible,"
                        " IsDeleted, userid) VALUES ('t', 'f', 1, 0, 0, %s)", (uid,))
        cur.execute("SELECT pnID, userid FROM pgpanels_user_tbl WHERE userid IN (%s, %s)",
                    (USER_A, USER_B))
        return {r["userid"]: r["pnID"] for r in cur.fetchall()}

    def _visible(self, cur, uid):
        cur.execute("SELECT CAST(IsVisible AS UNSIGNED) v FROM pgpanels_user_tbl WHERE userid=%s",
                    (uid,))
        return cur.fetchone()["v"]

    def test_panel_injection_reaches_other_user_before_fix(self):
        payload = "0) OR (userid=%d" % USER_B
        with dev_fixture() as cur:
            self._panels(cur)
            # HEAD: the list was interpolated verbatim.
            cur.execute("UPDATE pgpanels_user SET isvisible = 1 WHERE userid = %%s "
                        "AND pnid IN (%s)" % payload, (USER_A,))
            self.assertEqual(self._visible(cur, USER_B), 1)

    def test_panel_injection_blocked_after_fix(self):
        payload = "0) OR (userid=%d" % USER_B
        with dev_fixture() as cur:
            ids = self._panels(cur)
            keep = sanitize_pnids(payload + "," + str(ids[USER_A]))
            self.assertEqual(keep, [ids[USER_A]])
            marks = ",".join(["%s"] * len(keep))
            cur.execute("UPDATE pgpanels_user SET isvisible = 1 WHERE userid = %%s "
                        "AND pnid IN (%s)" % marks, [USER_A] + keep)
            self.assertEqual(self._visible(cur, USER_A), 1)
            self.assertEqual(self._visible(cur, USER_B), 0)

    def test_panel_update_cannot_cross_owner_with_valid_ids(self):
        with dev_fixture() as cur:
            ids = self._panels(cur)
            cur.execute("UPDATE pgpanels_user SET isvisible = 1 WHERE userid = %s "
                        "AND pnid IN (%s)", (USER_A, ids[USER_B]))
            self.assertEqual(self._visible(cur, USER_B), 0)



class DashboardPanelOwner(unittest.TestCase):
    """include/dashboardupdate2.cfm must pin userid to the session before the panel writes."""

    @staticmethod
    def pinned(text):
        t = strip_cf_comments(text)
        guard = t.find('NOT structKeyExists(session, "userid")')
        pin = t.find("<cfset userid = val(session.userid) />")
        first_write = t.find("qry/x_94_1.cfm")
        return 0 <= guard < pin < first_write

    def test_fixed_in_tree(self):
        self.assertTrue(self.pinned(src("include/dashboardupdate2.cfm")))

    def test_detects_defect_at_head(self):
        from _tao import head_src
        self.assertFalse(self.pinned(head_src("include/dashboardupdate2.cfm")))


if __name__ == "__main__":
    unittest.main()
