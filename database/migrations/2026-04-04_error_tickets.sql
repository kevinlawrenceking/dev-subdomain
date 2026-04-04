-- TAO-SPEC-2026-005 Phase 1: error_tickets table
-- Centralized error ticket storage for the TAO Error Management System
-- Run against: new_development (dev), actorsbusinessoffice (prod)

CREATE TABLE IF NOT EXISTS error_tickets (
  id              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  ticket_id       VARCHAR(40) NOT NULL,
  created_at      DATETIME NOT NULL DEFAULT NOW(),
  resolved        TINYINT(1) NOT NULL DEFAULT 0,
  resolved_at     DATETIME NULL DEFAULT NULL,
  resolved_by     INT UNSIGNED NULL DEFAULT NULL,
  resolved_notes  TEXT NULL DEFAULT NULL,
  user_id         INT UNSIGNED NULL DEFAULT NULL,
  user_email      VARCHAR(255) NULL DEFAULT NULL,
  error_type      VARCHAR(255) NULL DEFAULT NULL,
  error_message   TEXT NULL DEFAULT NULL,
  error_detail    TEXT NULL DEFAULT NULL,
  stack_trace     MEDIUMTEXT NULL DEFAULT NULL,
  tag_context     MEDIUMTEXT NULL DEFAULT NULL,
  sql_statement   TEXT NULL DEFAULT NULL,
  script_name     VARCHAR(500) NULL DEFAULT NULL,
  query_string    TEXT NULL DEFAULT NULL,
  http_method     VARCHAR(10) NULL DEFAULT NULL,
  http_referer    VARCHAR(2000) NULL DEFAULT NULL,
  remote_ip       VARCHAR(45) NULL DEFAULT NULL,
  user_agent      TEXT NULL DEFAULT NULL,
  form_data       TEXT NULL DEFAULT NULL,
  cf_context      VARCHAR(20) NULL DEFAULT NULL,
  event_name      VARCHAR(100) NULL DEFAULT NULL,
  environment     VARCHAR(10) NULL DEFAULT NULL,
  cf_engine       VARCHAR(100) NULL DEFAULT NULL,
  server_name     VARCHAR(255) NULL DEFAULT NULL,
  email_sent      TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uq_ticket_id (ticket_id),
  KEY idx_created_at (created_at),
  KEY idx_user_id (user_id),
  KEY idx_resolved_created (resolved, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
