# The Actors Office Claude Code Agents

This folder contains TAO specific Claude Code agents.

Agents:
- tao-manager: coordinator, discovery first, delegates to implementers and gatekeeper
- tao-gatekeeper: ship gate, reviews proof and invariants, outputs SHIP or NOT SHIP
- tao-cfml: ColdFusion (CFML) implementer for pages and AJAX endpoints
- tao-db: database implementer for schema, indexes, and safe data fixes
- tao-python: Python implementer for scripts, imports, jobs, and integrations
- tao-ui: UI implementer for JS, AJAX flows, and small UX fixes
- tao-test-runner: runs checks and fixes failures with minimal diffs

Usage pattern:
1) Start with tao-manager.
2) tao-manager delegates implementation to tao-cfml, tao-db, tao-python, tao-ui as needed.
3) tao-test-runner runs proof commands and fixes failures.
4) tao-gatekeeper reviews and decides SHIP or NOT SHIP.
