"""2026-11-12: Calendar > Add Appointment threw "Variable RETURNURL is undefined"
(ERR-39622F34, include/appoint-add.cfm:81). The page read returnurl/rcontactid unscoped
while only url.returnurl was param'd.

Static checks: both values come from the URL scope with defaults, returnurl is limited to
an /app/ page slug before it is written into the form, and rcontactid is numeric.
"""
import re
import unittest

from _tao import src, strip_cf_comments

PAGE = "include/appoint-add.cfm"


class AppointAddReturnUrl(unittest.TestCase):
    def setUp(self):
        self.text = strip_cf_comments(src(PAGE))

    def test_url_params_have_defaults(self):
        self.assertRegex(self.text, r'<cfparam name="url\.returnurl" default="calendar-appoint"')
        self.assertRegex(self.text, r'<cfparam name="url\.rcontactid" default="0"')

    def test_no_unscoped_param(self):
        # An unscoped cfparam on rcontactid silently ignored url.rcontactid when implicit
        # scope search was not in effect.
        self.assertNotRegex(self.text, r'<cfparam name="rcontactid"')
        self.assertNotRegex(self.text, r'<cfparam name="returnurl"')

    def test_locals_set_before_hidden_field(self):
        set_ret = self.text.index("<cfset returnurl =")
        set_rc = self.text.index("<cfset rcontactid = val(url.rcontactid)")
        field = self.text.index('name="returnurl" value="#returnurl#"')
        self.assertLess(set_ret, field)
        self.assertLess(set_rc, field)

    def test_returnurl_restricted_to_slug(self):
        line = re.search(r"<cfset returnurl = (.+?) />", self.text).group(1)
        self.assertIn('reFindNoCase("^[a-z0-9-]+$"', line)
        self.assertIn('"calendar-appoint"', line)


if __name__ == "__main__":
    unittest.main()
