"""Signup / recovery link regressions (2026-10-17).

Each check is a function of file text so it can be run against both the working
tree (must pass) and git HEAD (must fail, proving the test detects the defect).
"""
import re
import unittest

from _tao import head_src, skip_without_db, prod_ro, src, strip_cf_comments


def welcome_refuses_before_writes(text):
    body = strip_cf_comments(text)
    m = re.search(r'<cfif variables\.templateName eq "welcome">(.*?)<cfelseif', body, re.S)
    if not m:
        return False
    branch = m.group(1)
    abort_at = branch.find("<cfabort>")
    first_write = min([i for i in (branch.find("queryExecute"), branch.find("<cfmail")) if i >= 0] or [len(branch)])
    return 0 <= abort_at < first_write and "password_reset" in branch[:abort_at]


def setup_rejects_short_uuid_before_lookup(text):
    body = strip_cf_comments(text)
    guard = re.search(r"<cfif len\(trim\(uuid\)\) LT 32>", body)
    lookup = body.find("WHERE th.uuid")
    return bool(guard) and lookup > guard.start()


def setup_explains_lost_session(text):
    return 'listFindNoCase("expired,invalid", trim(error))' in strip_cf_comments(text)


def recover_rejects_short_token(text):
    return re.search(r'len\(trim\(url\.recover\)\) GTE 32', strip_cf_comments(text)) is not None


def recover_submit_rejects_short_token(text):
    return re.search(r'len\(trim\(session\.recoverToken\)\) LT 32', strip_cf_comments(text)) is not None


CASES = [
    ("app/admin-users/ajax/send-email.cfm", welcome_refuses_before_writes),
    ("setup/index.cfm", setup_rejects_short_uuid_before_lookup),
    ("setup/index.cfm", setup_explains_lost_session),
    ("recover/index.cfm", recover_rejects_short_token),
    ("recover/setup2.cfm", recover_submit_rejects_short_token),
]


class SignupTokenTests(unittest.TestCase):
    def test_fixed_in_tree(self):
        for path, check in CASES:
            with self.subTest(path=path, check=check.__name__):
                self.assertTrue(check(src(path)))

    def test_detects_defect_at_head(self):
        for path, check in CASES:
            with self.subTest(path=path, check=check.__name__):
                self.assertFalse(check(head_src(path)), "check passes on HEAD, so it proves nothing")

    def test_recover_lookup_still_requires_fresh_timestamp(self):
        # The 60-minute TTL is the second barrier; the length guard must not replace it.
        for path in ("recover/index.cfm", "recover/setup2.cfm"):
            with self.subTest(path=path):
                self.assertIn('dateDiff("n", u.recover_requested_at, now())', src(path))


@skip_without_db
class SignupTokenProdEvidence(unittest.TestCase):
    """Read-only facts the guards rely on (no customer data is returned)."""

    def test_recover_default_is_short_literal(self):
        with prod_ro() as cur:
            cur.execute("SELECT column_default AS d FROM information_schema.columns "
                        "WHERE table_schema='actorsbusinessoffice' AND table_name='taousers_tbl' "
                        "AND column_name='recover'")
            self.assertLess(len(cur.fetchone()["d"] or ""), 32)

    def test_no_live_setup_token_is_short(self):
        with prod_ro() as cur:
            cur.execute("SELECT COUNT(*) AS n FROM thrivecart_tbl WHERE status='Emailed' "
                        "AND (uuid IS NULL OR LENGTH(uuid) < 32)")
            self.assertEqual(cur.fetchone()["n"], 0, "a live Emailed link would be blocked by the guard")


if __name__ == "__main__":
    unittest.main()
