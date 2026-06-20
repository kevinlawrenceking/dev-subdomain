/*
 * TAO-ADMIN-ANALYTICS-01 -- Admin Activity Analytics page script.
 * Fetches ajax/stats.cfm and renders four stat tiles + four small-multiple line charts.
 * Read-only. No writes. Range selector drives a single re-fetch + re-render.
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
  var sel = document.getElementById("rangeSelect");
  var errBox = document.getElementById("analyticsError");

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

  function init() {
    if (sel) { sel.addEventListener("change", function () { load(sel.value); }); }
    load(sel ? sel.value : "90d");
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
