"""Shared helpers for TAO regression tests.

Static checks read CFML source from the repo. Database checks connect with
credentials from the environment (TAO_DB_HOST, TAO_DB_USER, TAO_DB_PASSWORD);
no credential is stored in the repo. Database tests are skipped when the
variables are not set.

Safety rules enforced here:
  * prod_ro(): actorsbusinessoffice, READ ONLY transaction, SELECT/SHOW/EXPLAIN only.
  * dev_fixture(): new_development only, autocommit off, ALWAYS rolled back.
"""
import contextlib
import os
import re
import unittest

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))

PROD_SCHEMA = "actorsbusinessoffice"
DEV_SCHEMA = "new_development"


def src(relpath):
    with open(os.path.join(REPO, relpath), encoding="utf-8", errors="replace") as fh:
        return fh.read()


def head_src(relpath):
    """Return the file's content at git HEAD (used to prove a test fails pre-fix)."""
    import subprocess
    out = subprocess.run(["git", "-C", REPO, "show", "HEAD:" + relpath.replace("\\", "/")],
                         capture_output=True, check=True)
    return out.stdout.decode("utf-8", errors="replace")


def strip_cf_comments(text):
    """Remove <!--- ... ---> CFML comments (non-nested approximation)."""
    return re.sub(r"<!---.*?--->", "", text, flags=re.S)


def cf_function(text, name):
    """Return the body of <cffunction name="name"> ... </cffunction>."""
    m = re.search(r'<cffunction[^>]*name="%s"[^>]*>(.*?)</cffunction>' % re.escape(name),
                  text, flags=re.S | re.I)
    if not m:
        raise AssertionError("cffunction %s not found" % name)
    return m.group(1)


def cfqueries(text):
    """Yield (attrs, body) for each <cfquery> block."""
    for m in re.finditer(r"<cfquery([^>]*)>(.*?)</cfquery>", text, flags=re.S | re.I):
        yield m.group(1), m.group(2)


def unparameterized_hashes(sql_body):
    """Return #expr# occurrences in SQL that are not inside a cfqueryparam tag."""
    without_params = re.sub(r"<cfqueryparam[^>]*>", "", sql_body, flags=re.I)
    return re.findall(r"#[^#]+#", without_params)


def cfsql_to_driver(sql_body):
    """Turn <cfqueryparam value="#arguments.x#" ...> into %(x)s for pymysql.

    Supports list="true" (pass a tuple). Any other #expr# left in the SQL raises,
    so a test can never silently run unbound interpolation.
    """
    def repl(m):
        name = re.search(r'value="#\s*(?:arguments\.)?([\w.]+)\s*#"', m.group(0), re.I)
        if not name:
            raise AssertionError("cfqueryparam without a simple #arguments.x# value: " + m.group(0))
        key = name.group(1).split(".")[-1]
        if re.search(r'list\s*=\s*"(true|yes)"', m.group(0), re.I):
            return "%(" + key + ")s"
        return "%(" + key + ")s"
    out = re.sub(r"<cfqueryparam[^>]*>", repl, sql_body, flags=re.I)
    leftover = re.findall(r"#[^#]+#", out)
    if leftover:
        raise AssertionError("unbound CF interpolation in SQL: %s" % leftover)
    return out


def _creds():
    host = os.environ.get("TAO_DB_HOST")
    user = os.environ.get("TAO_DB_USER")
    pw = os.environ.get("TAO_DB_PASSWORD")
    if not (host and user and pw):
        return None
    return host, user, pw


def db_available():
    return _creds() is not None


skip_without_db = unittest.skipUnless(db_available(), "TAO_DB_* environment not set")


def _connect(schema):
    import pymysql
    host, user, pw = _creds()
    return pymysql.connect(host=host, port=int(os.environ.get("TAO_DB_PORT", "3306")),
                           user=user, password=pw, database=schema, autocommit=False,
                           connect_timeout=15, read_timeout=120,
                           cursorclass=pymysql.cursors.DictCursor)


_RO = re.compile(r"(?is)^\s*(select|show|explain|describe|with)\b")


class _ReadOnlyCursor:
    def __init__(self, cur):
        self._cur = cur

    def execute(self, sql, args=None):
        if not _RO.match(sql):
            raise PermissionError("prod_ro allows SELECT/SHOW/EXPLAIN only")
        return self._cur.execute(sql, args)

    def __getattr__(self, name):
        return getattr(self._cur, name)


@contextlib.contextmanager
def prod_ro():
    conn = _connect(PROD_SCHEMA)
    try:
        cur = conn.cursor()
        cur.execute("SET SESSION TRANSACTION READ ONLY")
        cur.execute("START TRANSACTION READ ONLY")
        yield _ReadOnlyCursor(cur)
    finally:
        conn.rollback()
        conn.close()


@contextlib.contextmanager
def dev_ro():
    """Read-only cursor on new_development (used for before/after evidence in HTTP tests)."""
    conn = _connect(DEV_SCHEMA)
    try:
        cur = conn.cursor()
        cur.execute("SET SESSION TRANSACTION READ ONLY")
        cur.execute("START TRANSACTION READ ONLY")
        yield _ReadOnlyCursor(cur)
    finally:
        conn.rollback()
        conn.close()


@contextlib.contextmanager
def dev_fixture():
    """Writable cursor on new_development; every change is rolled back."""
    conn = _connect(DEV_SCHEMA)
    try:
        cur = conn.cursor()
        cur.execute("SELECT DATABASE() AS db")
        if cur.fetchone()["db"] != DEV_SCHEMA:
            raise RuntimeError("dev_fixture is bound to the wrong schema")
        cur.execute("START TRANSACTION")
        yield cur
    finally:
        conn.rollback()
        conn.close()
