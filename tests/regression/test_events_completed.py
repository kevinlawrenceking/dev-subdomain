"""Regression tests for sched/events_completed.cfm (nightly JOB C timeout fix).

Static tests read the CFML source. Database tests build a synthetic fixture in
new_development inside one transaction that is always rolled back, then run the
queries taken verbatim from the source file (old query from git HEAD, new query
from the working tree) with cfqueryparam tags bound to Python values.
"""
import datetime
import re
import subprocess
import unittest

from _tao import REPO, cfqueries, dev_fixture, skip_without_db, src, strip_cf_comments

PATH = "sched/events_completed.cfm"


def _named_query(text, name):
    for attrs, body in cfqueries(strip_cf_comments(text)):
        if re.search(r'\bname="%s"' % re.escape(name), attrs, re.I):
            return body
    raise AssertionError("cfquery %s not found" % name)


def _lower(rows):
    return [{k.lower(): v for k, v in r.items()} for r in rows]


def _head_source():
    return subprocess.check_output(["git", "show", "HEAD:" + PATH], cwd=REPO).decode("utf-8")


def bind(body, values, cfif=None):
    """Turn a cfquery body into (sql, args).

    values maps the cfqueryparam value expression (e.g. '#eventIdList#') to a
    Python value; list="true" params expand to one %s per element.
    cfif maps a <cfif EXPR> condition string to True/False (kept or dropped).
    """
    cfif = cfif or {}

    def _cfif(m):
        cond = m.group(1).strip()
        if cond not in cfif:
            raise AssertionError("unbound cfif: %s" % cond)
        return m.group(2) if cfif[cond] else ""

    body = re.sub(r"<cfif\s+([^>]*)>(.*?)</cfif>", _cfif, body, flags=re.S | re.I)
    args = []

    def _param(m):
        tag = m.group(0)
        expr = re.search(r'value="([^"]*)"', tag).group(1)
        if expr not in values:
            raise AssertionError("unbound cfqueryparam %s" % expr)
        val = values[expr]
        if re.search(r'list="true"', tag, re.I):
            seq = list(val)
            args.extend(seq)
            return ",".join(["%s"] * len(seq))
        args.append(val)
        return "%s"

    sql = re.sub(r"<cfqueryparam[^>]*>", _param, body, flags=re.I)
    sql = sql.replace("%", "%%").replace("%%s", "%s")
    if "#" in sql:
        raise AssertionError("unbound CF expression left in SQL: %s" % sql)
    return sql, args


class StaticShape(unittest.TestCase):
    def setUp(self):
        self.text = src(PATH)
        self.code = strip_cf_comments(self.text)

    def test_allfollowups_drives_from_batch_events(self):
        body = _named_query(self.text, "allFollowups")
        arms = re.split(r"\bUNION\b", body)
        self.assertEqual(len(arms), 2)
        for arm in arms:
            self.assertIn("STRAIGHT_JOIN", arm)
            self.assertRegex(arm, r"FROM\s+events\s+e\s+INNER JOIN eventcontactsxref x ON x\.eventid = e\.eventid")
            self.assertIn("i.contactid = x.contactid", arm)
            self.assertIn("tu.userid = e.userid AND tu.tagname = i.valuetext", arm)
            self.assertIn("eu.userid = e.userid AND eu.eventtypename = e.eventtypename", arm)
            self.assertRegex(arm, r"e\.eventid IN \(<cfqueryparam[^>]*value=\"#eventIdList#\"[^>]*list=\"true\"")

    def test_driver_has_stale_cutoff(self):
        body = _named_query(self.text, "events")
        self.assertRegex(body, r"<cfif NOT includeStale>\s*AND e\.eventstop >= DATE_SUB\(CURDATE\(\), INTERVAL <cfqueryparam[^>]*value=\"#staleDays#\"")
        self.assertIn('<cfparam name="includeStale" default="0" />', self.code)
        self.assertIn('<cfparam name="staleDays" default="14" />', self.code)

    def test_time_budget_checked_before_each_event_transaction(self):
        self.assertRegex(
            self.code,
            r'(?s)<cfloop query="events">\s*<cfif \(getTickCount\(\) - runStartTick\) / 1000 GTE timeBudgetSec>.*?<cfbreak />\s*</cfif>\s*<cftransaction>',
        )
        self.assertIn("timeBudgetSec = min(540, max(30, int(val(timeBudgetSec))))", self.code)

    def test_enrollment_rechecked_before_insert(self):
        idx_check = self.code.find('name="enrolledNow"')
        idx_insert = self.code.find("INSERT INTO fuSystemUsers")
        self.assertGreater(idx_check, 0)
        self.assertLess(idx_check, idx_insert)

    def test_completion_only_flips_active_events(self):
        body = _named_query(self.text, "update")
        self.assertRegex(body, r"SET eventstatus = 'Completed'\s*WHERE eventid = <cfqueryparam[^>]*/>\s*AND eventstatus = 'Active'")

    def test_changed_queries_fully_parameterized(self):
        for name in ("events", "allFollowups", "enrolledNow", "update"):
            body = _named_query(self.text, name)
            stripped = re.sub(r"<cfqueryparam[^>]*>", "", body, flags=re.I)
            self.assertNotRegex(stripped, r"#[^#]+#", name)


@skip_without_db
class FixtureEquivalence(unittest.TestCase):
    """Old (HEAD) and new allFollowups return identical rows on a synthetic fixture."""

    TAG = "zzRegr%s" % datetime.datetime.now().strftime("%H%M%S")

    def _build(self, c):
        today = datetime.date.today()
        ids = {}

        def ins(sql, args):
            c.execute(sql, args)
            return c.lastrowid

        for u in ("u1", "u2"):
            ids[u] = ins("INSERT INTO taousers_tbl (userFirstName, userLastName, userEmail, IsDeleted) VALUES (%s,%s,%s,0)",
                         ("Regr", u, "%s.%s@example.invalid" % (self.TAG, u)))
        for u, names in (("u1", ("Audition", "Rehearsal", "CD Workshop")), ("u2", ("Audition",))):
            for n in names:
                ins("INSERT INTO eventtypes_user_tbl (eventTypeName, userid, IsDeleted) VALUES (%s,%s,0)", (n, ids[u]))
        cd, ind = self.TAG + " Casting", self.TAG + " Producer"
        agent = self.TAG + " Agent"
        for u, name, ttype in (("u1", cd, "C"), ("u1", ind, "I"), ("u2", cd, "I"), ("u2", agent, "C")):
            ins("INSERT INTO tags_user_tbl (tagname, tagtype, userid, IsDeleted) VALUES (%s,%s,%s,0)", (name, ttype, ids[u]))
        for k, owner in (("c1", "u1"), ("c2", "u1"), ("c3", "u2"), ("c4", "u1")):
            ids[k] = ins("INSERT INTO contactdetails_tbl (contactFullName, userID, contactStatus, IsDeleted) VALUES (%s,%s,'Active',0)",
                         ("%s %s" % (self.TAG, k), ids[owner]))
        for k, tag, status in (("c1", cd, "Active"), ("c2", ind, "Active"), ("c3", cd, "Active"),
                               ("c4", cd, "Inactive"), ("c1", agent, "Active")):
            ins("INSERT INTO contactitems_tbl (contactID, valueCategory, valueType, valueText, itemStatus, IsDeleted) VALUES (%s,'tag','Tags',%s,%s,0)",
                (ids[k], tag, status))
        past = today - datetime.timedelta(days=3)
        stale = today - datetime.timedelta(days=400)
        for k, owner, etype, stop in (("e1", "u1", "Audition", past), ("e2", "u1", "Rehearsal", past),
                                      ("e3", "u1", "CD Workshop", past), ("e4", "u2", "Audition", past),
                                      ("e5", "u1", "Audition", stale)):
            ids[k] = ins("INSERT INTO events_tbl (eventTitle, eventStatus, eventStart, eventStop, eventTypeName, userID, IsDeleted) VALUES (%s,'Active',%s,%s,%s,%s,0)",
                         ("%s %s" % (self.TAG, k), stop, stop, etype, ids[owner]))
        for e, cs in (("e1", ("c1", "c2", "c3", "c4")), ("e2", ("c1", "c2")), ("e3", ("c1", "c2")),
                      ("e4", ("c3",)), ("e5", ("c1",))):
            for k in cs:
                ins("INSERT INTO eventcontactsxref_tbl (eventID, contactID, IsDeleted) VALUES (%s,%s,0)", (ids[e], ids[k]))
        return ids

    def _rows(self, c, body, event_ids):
        sql, args = bind(body, {"#eventIdList#": event_ids})
        c.execute(sql, args)
        return sorted((r["eventid"], r["contactid"], int(r["new_systemid"])) for r in _lower(c.fetchall()))

    def test_old_and_new_followups_match_expected(self):
        old_body = _named_query(_head_source(), "allFollowups")
        new_body = _named_query(src(PATH), "allFollowups")
        self.assertNotEqual(old_body, new_body)
        with dev_fixture() as c:
            ids = self._build(c)
            batch = [ids[k] for k in ("e1", "e2", "e3", "e4", "e5")]
            old = self._rows(c, old_body, batch)
            new = self._rows(c, new_body, batch)
            expected = sorted([
                (ids["e1"], ids["c1"], 1),  # u1 C-tag
                (ids["e1"], ids["c2"], 2),  # u1 I-tag
                (ids["e1"], ids["c3"], 1),  # tag text matches u1's C-tag (existing semantics)
                (ids["e3"], ids["c1"], 1),  # CD Workshop excluded from arm 2 only
                (ids["e4"], ids["c3"], 2),  # u2 defines the same text as an I-tag
                (ids["e5"], ids["c1"], 1),
            ])
            self.assertEqual(old, expected)
            self.assertEqual(new, old)

    def test_driver_stale_cutoff(self):
        body = _named_query(src(PATH), "events")
        with dev_fixture() as c:
            ids = self._build(c)
            mine = {ids[k] for k in ("e1", "e2", "e3", "e4", "e5")}
            for include_stale, expect in ((False, {"e1", "e2", "e3", "e4"}), (True, {"e1", "e2", "e3", "e4", "e5"})):
                sql, args = bind(body, {"#staleDays#": 14, "#maxEvents#": 100000},
                                 cfif={"NOT includeStale": not include_stale})
                c.execute(sql, args)
                got = {r["eventid"] for r in _lower(c.fetchall())} & mine
                self.assertEqual(got, {ids[k] for k in expect}, "includeStale=%s" % include_stale)

    def test_enrollment_and_completion_are_idempotent(self):
        text = src(PATH)
        check = _named_query(text, "enrolledNow")
        update = _named_query(text, "update")
        with dev_fixture() as c:
            ids = self._build(c)
            binding = {"#new_userid#": ids["u1"], "#new_contactid#": ids["c1"], "#new_systemid#,3,4": [1, 3, 4]}
            sql, args = bind(check, binding)
            c.execute(sql, args)
            self.assertEqual(c.rowcount, 0)
            c.execute("INSERT INTO fusystemusers_tbl (systemID, contactID, userid, suStartDate, sustatus) VALUES (1,%s,%s,CURDATE(),'Active')",
                      (ids["c1"], ids["u1"]))
            c.execute(sql, args)
            self.assertEqual(c.rowcount, 1, "re-check must see the existing Active enrollment")
            import pymysql
            with self.assertRaises(pymysql.err.IntegrityError):
                c.execute("INSERT INTO fusystemusers_tbl (systemID, contactID, userid, suStartDate, sustatus) VALUES (1,%s,%s,CURDATE(),'Active')",
                          (ids["c1"], ids["u1"]))
            sql, args = bind(update, {"#new_eventid#": ids["e1"]})
            c.execute(sql, args)
            self.assertEqual(c.rowcount, 1)
            c.execute(sql, args)
            self.assertEqual(c.rowcount, 0, "second completion must be a no-op")


class WriteGate(unittest.TestCase):
    """JOB C writes and JOB D + ICS need an explicit ?enableWrites=1; the default only counts."""

    def setUp(self):
        self.t = strip_cf_comments(src("sched/events_completed.cfm"))

    def test_default_is_off_and_dryrun_wins(self):
        self.assertIn('<cfparam name="enableWrites" default="0" />', self.t)
        self.assertIn("<cfset enableWrites = (val(enableWrites) EQ 1) AND NOT dryRun />", self.t)

    def test_every_jobc_and_jobd_write_sits_behind_the_gate(self):
        t = self.t
        m = re.search(r'<cfif enableWrites>\s*<cfloop query="events">', t)
        self.assertIsNotNone(m, "JOB C loop must open with <cfif enableWrites>")
        loop_open = m.start()
        jobd = re.search(r"<cfif enableWrites>\s*<!---\s*JOB D", src("sched/events_completed.cfm"))
        self.assertIsNotNone(jobd, "JOB D + ICS must sit behind a second <cfif enableWrites>")
        for stmt in ("INSERT INTO fuSystemUsers", "INSERT INTO `notifications`",
                     "UPDATE fusystemusers SET sustatus = 'Completed'"):
            with self.subTest(stmt=stmt):
                self.assertGreater(t.find(stmt), loop_open, stmt + " must be inside the gated JOB C loop")
        complete = re.search(r"SET eventstatus = 'Completed'", t)
        self.assertIsNotNone(complete)
        self.assertGreater(complete.start(), loop_open)

    def test_count_pass_runs_without_writes_and_reports(self):
        t = self.t
        m = re.search(r"<cfif NOT enableWrites>(.*?)</cfloop>\s*</cfif>", t, re.S)
        self.assertIsNotNone(m)
        body = m.group(1)
        self.assertNotRegex(body, r"(?i)<cfquery")  # no SQL at all in the count pass
        for key in ("wouldEnroll", "wouldBellNotifications", "wouldRemindersMax", "wouldSkipAlreadyEnrolled"):
            self.assertIn(key, body)
            self.assertIn('"%s":#runStats.%s#' % (key, key), t)
        self.assertIn('"eligibleEvents":#runStats.eligibleEvents#', t)
        self.assertIn("jobc_count_only", t)

    def test_count_pass_uses_the_loops_skip_rules(self):
        t = self.t
        self.assertIn("(allFollowups.new_systemid EQ 1 OR allFollowups.new_systemid EQ 2)", t)
        self.assertIn("(listFind(cEnrolled, 3) OR listFind(cEnrolled, 4))", t)
        self.assertIn("(new_systemid EQ 1 OR new_systemid EQ 2) AND (listFind(enrolledSystems, 3) OR listFind(enrolledSystems, 4))", t)


if __name__ == "__main__":
    unittest.main()
