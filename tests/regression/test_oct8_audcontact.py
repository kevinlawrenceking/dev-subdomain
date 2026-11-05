"""Ticket 2751: remove a contact from ONE audition, owner-scoped (Oct-8 repair).

Static checks cover the endpoint and JS; the SQL checks run the exact statements from
services/ContactItemService.cfc deleteAudContact() against synthetic rows in
new_development inside a transaction that is always rolled back.
"""
import re
import unittest

from _tao import (cf_function, cfqueries, cfsql_to_driver, dev_fixture, head_src,
                  skip_without_db, src, strip_cf_comments)

SVC = "services/ContactItemService.cfc"
EP = "include/delete_audcontact.cfm"
PANE = "include/aud_rel_pane.cfm"


def endpoint_is_session_scoped(text):
    t = strip_cf_comments(text)
    return ('structKeyExists(session, "userid")' in t and "userid       = int(session.userid)" in t
            and "form.userid" not in t and "url.userid" not in t)


def pane_sends_csrf(text):
    m = re.search(r"function confirmRemove\(.*?\n}\n", text, re.S)
    return bool(m) and "X-CSRF-Token" in m.group(0) and "credentials: 'same-origin'" in m.group(0)


def delete_is_owner_scoped(text):
    body = cf_function(text, "deleteAudContact")
    return all("p.userid" in q for _, q in cfqueries(body)) and len(list(cfqueries(body))) == 2


class AudContactStatic(unittest.TestCase):
    def test_fixed_in_tree(self):
        self.assertTrue(endpoint_is_session_scoped(src(EP)))
        self.assertTrue(pane_sends_csrf(src(PANE)))
        self.assertTrue(delete_is_owner_scoped(src(SVC)))

    def test_detects_defect_at_head(self):
        self.assertFalse(endpoint_is_session_scoped(head_src(EP)))
        self.assertFalse(pane_sends_csrf(head_src(PANE)))
        self.assertFalse(delete_is_owner_scoped(head_src(SVC)))

    def test_no_unbound_sql(self):
        for _, q in cfqueries(cf_function(src(SVC), "deleteAudContact")):
            cfsql_to_driver(q)  # raises on any unbound #expr#


@skip_without_db
class AudContactSql(unittest.TestCase):
    def _fixture(self, cur):
        ids = {}
        for key in ("A", "B"):
            cur.execute("INSERT INTO taousers_tbl (userfirstname, userlastname, userEmail, recover) "
                        "VALUES ('Fixture', %s, %s, 'setup')", (key, "fixture-%s@example.invalid" % key))
            ids["user" + key] = cur.lastrowid
        for key in ("A", "B"):
            cur.execute("INSERT INTO audprojects (userid, projName, isDeleted) VALUES (%s, %s, 0)",
                        (ids["user" + key], "fixture project " + key))
            ids["proj" + key] = cur.lastrowid
            cur.execute("INSERT INTO audroles (audprojectID, userid, isDeleted) VALUES (%s, %s, 0)",
                        (ids["proj" + key], ids["user" + key]))
            ids["role" + key] = cur.lastrowid
            cur.execute("INSERT INTO events_tbl (userID, audRoleID, eventTitle, IsDeleted) VALUES (%s, %s, 'fixture', 0)",
                        (ids["user" + key], ids["role" + key]))
            ids["event" + key] = cur.lastrowid
        ids["c1"], ids["c2"] = 991000001, 991000002  # synthetic contact ids, no FK on the xref tables
        for proj in ("projA", "projB"):
            for c in ("c1", "c2"):
                cur.execute("INSERT INTO audcontacts_auditions_xref (contactid, audprojectid) VALUES (%s, %s)",
                            (ids[c], ids[proj]))
        for ev in ("eventA", "eventB"):
            for c in ("c1", "c2"):
                cur.execute("INSERT INTO eventcontactsxref_tbl (eventID, contactID, IsDeleted) VALUES (%s, %s, 0)",
                            (ids[ev], ids[c]))
        return ids

    def _run_delete(self, cur, contactid, audprojectid, userid):
        params = {"contactid": contactid, "audprojectid": audprojectid, "userid": userid}
        deleted = None
        for _, q in cfqueries(cf_function(src(SVC), "deleteAudContact")):
            n = cur.execute(cfsql_to_driver(q), params)
            deleted = n if deleted is None else deleted
        return deleted

    def _links(self, cur, ids):
        cur.execute("SELECT contactid, audprojectid FROM audcontacts_auditions_xref WHERE audprojectid IN (%s, %s)",
                    (ids["projA"], ids["projB"]))
        return {(r["contactid"], r["audprojectid"]) for r in cur.fetchall()}

    def _attendance(self, cur, ids):
        cur.execute("SELECT eventID, contactID, IsDeleted+0 AS IsDeleted FROM eventcontactsxref_tbl WHERE eventID IN (%s, %s)",
                    (ids["eventA"], ids["eventB"]))
        return {(r["eventID"], r["contactID"]): int(r["IsDeleted"] or 0) for r in cur.fetchall()}

    def test_owner_removes_only_that_link(self):
        with dev_fixture() as cur:
            ids = self._fixture(cur)
            n = self._run_delete(cur, ids["c1"], ids["projA"], ids["userA"])
            self.assertEqual(n, 1)
            links = self._links(cur, ids)
            self.assertNotIn((ids["c1"], ids["projA"]), links)
            self.assertIn((ids["c2"], ids["projA"]), links, "other contact on same audition must stay")
            self.assertIn((ids["c1"], ids["projB"]), links, "same contact on another audition must stay")
            att = self._attendance(cur, ids)
            self.assertEqual(att[(ids["eventA"], ids["c1"])], 1)
            self.assertEqual(att[(ids["eventA"], ids["c2"])], 0)
            self.assertEqual(att[(ids["eventB"], ids["c1"])], 0)

    def test_cross_user_request_changes_nothing(self):
        with dev_fixture() as cur:
            ids = self._fixture(cur)
            before_links, before_att = self._links(cur, ids), self._attendance(cur, ids)
            n = self._run_delete(cur, ids["c1"], ids["projB"], ids["userA"])  # A targets B's audition
            self.assertEqual(n, 0)
            self.assertEqual(self._links(cur, ids), before_links)
            self.assertEqual(self._attendance(cur, ids), before_att)

    def test_double_submit_is_noop(self):
        with dev_fixture() as cur:
            ids = self._fixture(cur)
            self.assertEqual(self._run_delete(cur, ids["c1"], ids["projA"], ids["userA"]), 1)
            self.assertEqual(self._run_delete(cur, ids["c1"], ids["projA"], ids["userA"]), 0)


if __name__ == "__main__":
    unittest.main()
