/*
 * TAO-ADMIN-ANALYTICS-01 -- Admin Activity Analytics page script.
 * Fetches ajax/stats.cfm and renders four stat tiles + four small-multiple line charts.
 * Read-only. Range selector drives a single re-fetch + re-render. CSV export is client-side.
 */
(function () {
  "use strict";

  var METRICS = [
    { key: "auditions",          label: "Auditions logged",     color: "#4e73df" },
    { key: "relationships",      label: "Relationships added",  color: "#1cc88a" },
    { key: "remindersCompleted", label: "Reminders completed",  color: "#36b9cc" },
    { key: "bookings",           label: "Bookings logged",      color: "#f6c23e" }
  ];

  var charts = {};
  var lastData = null;
  var sel = document.getElementById("rangeSelect");
  var errBox = document.getElementById("analyticsError");
  var exportBtn = document.getElementById("exportCsv");

  function setError(msg) {
    if (!errBox) { return; }
    if (!msg) { errBox.classList.add("d-none"); errBox.textContent = ""; return; }
    errBox.textContent = msg;
    errBox.classList.remove("d-none");
  }

  function setTiles(text) {
    METRICS.forEach(function (m) {
      var el = document.getElementById("tile-" + m.key);
      if (el) { el.textContent = text; }
    });
  }

  function fmt(n) {
    var v = (n === null || n === undefined) ? 0 : n;
    try { return Number(v).toLocaleString(); } catch (e) { return String(v); }
  }

  function render(data) {
    lastData = data;
    setError(null);
    METRICS.forEach(function (m) {
      var el = document.getElementById("tile-" + m.key);
      if (el) { el.textContent = fmt(data.totals ? data.totals[m.key] : 0); }
    });

    var labels = (data.series && data.series.labels) || [];
    METRICS.forEach(function (m) {
      var ctx = document.getElementById("chart-" + m.key);
      if (!ctx || typeof Chart === "undefined") { return; }
      var values = (data.series && data.series[m.key]) || [];
      if (charts[m.key]) { charts[m.key].destroy(); }
      charts[m.key] = new Chart(ctx, {
        type: "line",
        data: {
          labels: labels,
          datasets: [{
            label: m.label, data: values,
            borderColor: m.color, backgroundColor: m.color,
            tension: 0.3, fill: false, pointRadius: 2, borderWidth: 2
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: { legend: { display: false } },
          scales: { y: { beginAtZero: true, ticks: { precision: 0 } } }
        }
      });
    });
  }

  function load(range) {
    setError(null);
    setTiles("...");
    fetch("ajax/stats.cfm?range=" + encodeURIComponent(range), {
      headers: { "X-Requested-With": "XMLHttpRequest" },
      credentials: "same-origin"
    })
      .then(function (r) {
        return r.json().catch(function () { throw new Error("Unexpected server response (HTTP " + r.status + ")."); });
      })
      .then(function (json) {
        if (!json || json.success !== true) {
          throw new Error((json && json.message) || "Request failed.");
        }
        render(json.data);
      })
      .catch(function (e) {
        setError("Unable to load analytics: " + e.message);
        setTiles("--");
      });
  }

  // ---- CSV export (current loaded range) ----
  function csvCell(v) {
    var s = (v === null || v === undefined) ? "" : String(v);
    if (/[",\r\n]/.test(s)) { s = '"' + s.replace(/"/g, '""') + '"'; }
    return s;
  }

  function buildCsv() {
    if (!lastData) { return ""; }
    var d = lastData;
    var rng = d.range || {};
    var rows = [];
    rows.push(["The Actor's Office - Activity Analytics"]);
    rows.push(["Range", rng.label || "", rng.from ? (rng.from + " to " + rng.to) : ("through " + (rng.to || ""))]);
    rows.push([]);
    rows.push(["Month", "Auditions", "Relationships added", "Reminders completed", "Bookings"]);
    var labels = (d.series && d.series.labels) || [];
    labels.forEach(function (lbl, i) {
      rows.push([
        lbl,
        d.series.auditions[i], d.series.relationships[i],
        d.series.remindersCompleted[i], d.series.bookings[i]
      ]);
    });
    rows.push([]);
    rows.push([
      "Total (" + (rng.label || "") + ")",
      d.totals.auditions, d.totals.relationships,
      d.totals.remindersCompleted, d.totals.bookings
    ]);
    return rows.map(function (r) { return r.map(csvCell).join(","); }).join("\r\n");
  }

  function downloadCsv() {
    var csv = buildCsv();
    if (!csv) { return; }
    var blob = new Blob(["﻿" + csv], { type: "text/csv;charset=utf-8;" });
    var url = URL.createObjectURL(blob);
    var a = document.createElement("a");
    var key = (lastData.range && lastData.range.key) || "report";
    var to = (lastData.range && lastData.range.to) || "";
    a.href = url;
    a.download = "tao-activity-analytics-" + key + (to ? "-" + to : "") + ".csv";
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  }

  function init() {
    if (sel) { sel.addEventListener("change", function () { load(sel.value); }); }
    if (exportBtn) { exportBtn.addEventListener("click", downloadCsv); }
    load(sel ? sel.value : "90d");
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
