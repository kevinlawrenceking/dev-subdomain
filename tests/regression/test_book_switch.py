"""2026-10-29: Book hidden behind one server-side switch (include/book_feature.cfm).

Static checks: the switch is off, every Book endpoint refuses before doing any work, and
contact_info.cfm (dev + PROD variant) forces masterBookEnabled off when the switch is off.
"""
import glob
import os
import re
import unittest

from _tao import REPO, src, strip_cf_comments

ENDPOINTS = sorted(
    os.path.relpath(p, REPO).replace("\\", "/")
    for p in glob.glob(os.path.join(REPO, "ajax", "master", "*.cfm"))
) + ["ajax/contact/updateprimary.cfm"]


class BookSwitch(unittest.TestCase):
    def test_switch_is_off(self):
        text = strip_cf_comments(src("include/book_feature.cfm"))
        self.assertEqual(re.findall(r"<cfset request\.bookFeatureEnabled\s*=\s*(\w+)\s*>", text), ["false"])

    def test_guard_aborts_with_json_envelope(self):
        text = strip_cf_comments(src("include/book_feature_guard.cfm"))
        # Relative include: "/include/..." can resolve to another site's folder via a server mapping.
        self.assertIn('<cfinclude template="book_feature.cfm">', text)
        self.assertIn("FEATURE_DISABLED", text)
        self.assertLess(text.index("NOT request.bookFeatureEnabled"), text.index("<cfabort>"))

    def test_every_book_endpoint_guarded_before_work(self):
        self.assertGreaterEqual(len(ENDPOINTS), 7)
        for rel in ENDPOINTS:
            with self.subTest(endpoint=rel):
                text = strip_cf_comments(src(rel))
                guard = text.find('<cfinclude template="../../include/book_feature_guard.cfm">')
                self.assertNotEqual(guard, -1)
                for work in ("request.svc(", "<cfquery", "createObject("):
                    pos = text.find(work)
                    if pos != -1:
                        self.assertLess(guard, pos, "%s runs before the guard" % work)

    def test_preview_modal_guarded_before_params(self):
        text = strip_cf_comments(src("include/master_link_preview.cfm"))
        guard = text.index("NOT request.bookFeatureEnabled")
        self.assertLess(guard, text.index("<cfparam"))
        self.assertLess(guard, text.index("request.svc("))

    def test_contact_info_honors_switch(self):
        for rel in ("include/contact_info.cfm", "include/contact_info_PROD.cfm"):
            path = os.path.join(REPO, rel)
            if not os.path.exists(path):
                continue
            with self.subTest(file=rel):
                text = strip_cf_comments(src(rel))
                inc = text.index('<cfinclude template="book_feature.cfm">')
                override = text.index("<cfif NOT request.bookFeatureEnabled><cfset masterBookEnabled = false></cfif>")
                first_use = text.index("<cfif masterBookEnabled")
                self.assertLess(inc, override)
                self.assertLess(override, first_use)


if __name__ == "__main__":
    unittest.main()
