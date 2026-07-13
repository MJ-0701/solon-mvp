const cp = require('child_process');
const mysql = require('mysql');

// hardcoded secret (should flag high, redacted)
const API_KEY = "sk_live_abcd1234efgh5678ijkl";

// AWS key (should flag critical, redacted)
const AWS = "AKIAIOSFODNN7EXAMPLE";

function runReport(name) {
  // command injection sink (A03)
  cp.exec("generate-report " + name, (e, out) => out);
}

function findUser(db, id) {
  // SQL injection via concatenation (A03)
  return db.query("SELECT * FROM users WHERE id = " + id);
}

function render(el, data) {
  // XSS sink (A03)
  el.innerHTML = data.body;
}

module.exports = { runReport, findUser, render };
