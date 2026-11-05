"""Ticket 2547: headshot rename persists and is owner-scoped (Oct-8 repair)."""
import re
import unittest

from _tao import cfqueries, cfsql_to_driver, dev_fixture, head_src, skip_without_db, src, strip_cf_comments

EP = "include/update_media_name.cfm"
CARD = "include/card_photo.cfm"


def endpoint_owner_scoped(text):
    t = strip_cf_comments(text)
    update = next((q for _, q in cfqueries(t) if "UPDATE audmedia" in q), "")
    return ('structKeyExists(session, "userid")' in t and "AND userid" in update
            and "#session.userid#" in update and "form.mediaid" in update)


def card_sends_csrf_and_reverts(text):
    return ('"X-CSRF-Token"' in text and "element.innerText = previousText" in text
            and 'res.txt === "success"' in text)


class MediaRenameStatic(unittest.TestCase):
    def test_fixed_in_tree(self):
        self.assertTrue(endpoint_owner_scoped(src(EP)))
        self.assertTrue(card_sends_csrf_and_reverts(src(CARD)))

    def test_detects_defect_at_head(self):
        self.assertFalse(endpoint_owner_scoped(head_src(EP)))
        self.assertFalse(card_sends_csrf_and_reverts(head_src(CARD)))


@skip_without_db
class MediaRenameSql(unittest.TestCase):
    def _sql(self, kind):
        t = strip_cf_comments(src(EP))
        return next(cfsql_to_driver(q) for _, q in cfqueries(t) if kind in q)

    def _fixture(self, cur):
        ids = {}
        for key in ("A", "B"):
            cur.execute("INSERT INTO taousers_tbl (userfirstname, userlastname, userEmail, recover) "
                        "VALUES ('Fixture', %s, %s, 'setup')", (key, "fixture-media-%s@example.invalid" % key))
            ids["user" + key] = cur.lastrowid
            cur.execute("SELECT mediaTypeID FROM audmedia LIMIT 1")
            row = cur.fetchone()
            mtype = row["mediaTypeID"] if row else 1
            cur.execute("INSERT INTO audmedia (userid, mediaName, mediaTypeID, isDeleted) VALUES (%s, %s, %s, 0)",
                        (ids["user" + key], "headshot 1", mtype))
            ids["media" + key] = cur.lastrowid
        return ids

    def _name(self, cur, mediaid):
        cur.execute("SELECT mediaName FROM audmedia WHERE mediaID=%s", (mediaid,))
        return cur.fetchone()["mediaName"]

    def test_owner_rename_persists(self):
        with dev_fixture() as cur:
            ids = self._fixture(cur)
            n = cur.execute(self._sql("UPDATE audmedia"),
                            {"newName": "headshot 7", "mediaid": ids["mediaA"], "userid": ids["userA"]})
            self.assertEqual(n, 1)
            self.assertEqual(self._name(cur, ids["mediaA"]), "headshot 7")

    def test_cannot_rename_other_users_media(self):
        with dev_fixture() as cur:
            ids = self._fixture(cur)
            n = cur.execute(self._sql("UPDATE audmedia"),
                            {"newName": "pwned", "mediaid": ids["mediaB"], "userid": ids["userA"]})
            self.assertEqual(n, 0)
            self.assertEqual(self._name(cur, ids["mediaB"]), "headshot 1")
            # the endpoint's fallback ownership probe must also say "not ours" -> "error"
            cur.execute(self._sql("SELECT mediaid FROM audmedia"), {"mediaid": ids["mediaB"], "userid": ids["userA"]})
            self.assertEqual(len(cur.fetchall()), 0)

    def test_unchanged_name_reports_success(self):
        with dev_fixture() as cur:
            ids = self._fixture(cur)
            cur.execute(self._sql("UPDATE audmedia"),
                        {"newName": "headshot 1", "mediaid": ids["mediaA"], "userid": ids["userA"]})
            cur.execute(self._sql("SELECT mediaid FROM audmedia"), {"mediaid": ids["mediaA"], "userid": ids["userA"]})
            self.assertEqual(len(cur.fetchall()), 1)


if __name__ == "__main__":
    unittest.main()
