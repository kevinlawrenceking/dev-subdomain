#!/usr/bin/env node
// =============================================================================
// TAO audit migration runner (writable). Reads a .sql file, handles DELIMITER
// blocks for stored procedures, runs statements one at a time against a
// writable mysql2 session. Prints PRE-EXEC banner per statement and the result
// rows after. --dry prints planned statements without executing.
//
// Usage:
//   node run.cjs --host H --port P --user U --password P --db D --file F [--dry]
// =============================================================================
'use strict';
const fs = require('fs');
const path = require('path');

function parseArgs() {
  const args = {};
  const argv = process.argv.slice(2);
  for (let i = 0; i < argv.length; i++) {
    const k = argv[i];
    if (k === '--dry') { args.dry = true; continue; }
    if (k.startsWith('--')) {
      args[k.slice(2)] = argv[++i];
    }
  }
  for (const r of ['host', 'port', 'user', 'password', 'db', 'file']) {
    if (!args[r]) { console.error('Missing required arg: --' + r); process.exit(2); }
  }
  return args;
}

// Split a .sql file into statements, honoring `DELIMITER` directives.
// Strips comments only insofar as they sit on their own lines; preserves
// inline comments so PRE-EXEC output is readable.
function splitSqlStatements(text) {
  const out = [];
  let delim = ';';
  let buf = '';
  // Strip trailing line comments so the delimiter detector sees the real
  // statement terminator. (None of our migration files have `--` inside
  // string literals.) Preserve comment-only lines so they still get scanned.
  const lines = text.split(/\r?\n/).map(l => l.replace(/(^|\s)--[^\n]*$/, '$1'));
  for (const raw of lines) {
    const line = raw.replace(/\s+$/, '');
    const m = /^\s*DELIMITER\s+(\S+)\s*$/i.exec(line);
    if (m) {
      // Flush any pending buffer before changing delimiter (shouldn't normally happen).
      if (buf.trim()) { out.push(buf.trim()); buf = ''; }
      delim = m[1];
      continue;
    }
    buf += raw + '\n';
    // Check whether buf ends with the current delimiter on its own (allow trailing whitespace).
    const trimmed = buf.replace(/\s+$/, '');
    if (trimmed.endsWith(delim)) {
      const stmt = trimmed.slice(0, -delim.length).trim();
      if (stmt) out.push(stmt);
      buf = '';
    }
  }
  if (buf.trim()) out.push(buf.trim());
  return out;
}

function summarize(stmt) {
  // First non-comment line, truncated.
  const firstLine = stmt.split(/\r?\n/).find(l => l.trim() && !l.trim().startsWith('--')) || stmt.split(/\r?\n/)[0];
  return firstLine.trim().slice(0, 120);
}

async function main() {
  const args = parseArgs();
  const filePath = path.resolve(args.file);
  if (!fs.existsSync(filePath)) { console.error('File not found: ' + filePath); process.exit(2); }
  const sqlText = fs.readFileSync(filePath, 'utf8');
  const stmts = splitSqlStatements(sqlText);

  console.log('FILE   : ' + filePath);
  console.log('TARGET : ' + args.user + '@' + args.host + ':' + args.port + '/' + args.db);
  console.log('MODE   : ' + (args.dry ? 'DRY-RUN (no statements will execute)' : 'LIVE'));
  console.log('STMTS  : ' + stmts.length);
  console.log('');

  if (args.dry) {
    stmts.forEach((s, i) => {
      console.log('--- [' + (i + 1) + '/' + stmts.length + '] ' + summarize(s));
      console.log(s);
      console.log('');
    });
    console.log('DRY-RUN complete. ' + stmts.length + ' statements would have executed.');
    return;
  }

  const mysql = require('mysql2/promise');
  const conn = await mysql.createConnection({
    host: args.host,
    port: parseInt(args.port, 10),
    user: args.user,
    password: args.password,
    database: args.db,
    multipleStatements: false
  });

  let failed = false;
  for (let i = 0; i < stmts.length; i++) {
    const stmt = stmts[i];
    const label = '[' + (i + 1) + '/' + stmts.length + ']';
    console.log('--- ' + label + ' ' + summarize(stmt));
    try {
      const [rows, fields] = await conn.query(stmt);
      if (Array.isArray(rows) && rows.length && typeof rows[0] === 'object' && !Array.isArray(rows[0])) {
        // Single result set of rows.
        rows.forEach(r => console.log('  ' + JSON.stringify(r)));
      } else if (Array.isArray(rows) && rows.length && Array.isArray(rows[0])) {
        // Multiple result sets (stored procedure with multiple SELECTs).
        rows.forEach((rs, idx) => {
          if (Array.isArray(rs)) {
            console.log('  --- result set ' + (idx + 1) + ' ---');
            rs.forEach(r => console.log('  ' + JSON.stringify(r)));
          } else if (rs && typeof rs === 'object' && 'affectedRows' in rs) {
            console.log('  OK affectedRows=' + rs.affectedRows);
          }
        });
      } else if (rows && typeof rows === 'object' && 'affectedRows' in rows) {
        console.log('  OK affectedRows=' + rows.affectedRows);
      } else {
        console.log('  (no rows)');
      }
    } catch (err) {
      console.error('  ERROR: ' + (err.code || '') + ' ' + err.message);
      failed = true;
      break;
    }
  }
  await conn.end();
  if (failed) { console.error('\nABORTED on error.'); process.exit(1); }
  console.log('\nDONE. ' + stmts.length + ' statements executed successfully.');
}

main().catch(e => { console.error(e); process.exit(1); });
