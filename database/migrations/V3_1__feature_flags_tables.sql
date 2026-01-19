-- ============================================================
-- V3_1 Feature Flags Tables
-- Enables DB-driven rollout control without deploys
--
-- Schema: new_development (dev) / actorsbusinessoffice (prod)
-- Date: 2026-01-19
-- ============================================================

-- ============================================================
-- GLOBAL FEATURE FLAGS
-- Stores application-wide feature toggles
-- ============================================================

CREATE TABLE IF NOT EXISTS feature_flags (
    flag_key VARCHAR(50) NOT NULL PRIMARY KEY,
    is_enabled TINYINT(1) NOT NULL DEFAULT 0,
    description VARCHAR(255) DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX IX_feature_flags_enabled (is_enabled)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- PER-USER FEATURE FLAG OVERRIDES
-- Allows specific users to access features before global rollout
-- When global flag is OFF, users in this table with is_enabled=1 still get access
-- ============================================================

CREATE TABLE IF NOT EXISTS feature_flag_users (
    flag_key VARCHAR(50) NOT NULL,
    userid INT NOT NULL,
    is_enabled TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    notes VARCHAR(255) DEFAULT NULL,

    PRIMARY KEY (flag_key, userid),
    INDEX IX_feature_flag_users_userid (userid),
    INDEX IX_feature_flag_users_flag (flag_key),

    CONSTRAINT FK_feature_flag_users_flag
        FOREIGN KEY (flag_key) REFERENCES feature_flags(flag_key)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- INSERT DEFAULT FLAGS
-- import_v3_enabled starts as FALSE (safe rollout)
-- ============================================================

INSERT INTO feature_flags (flag_key, is_enabled, description)
VALUES ('import_v3_enabled', 0, 'Contact Import V3 - new multi-format importer with staging and review')
ON DUPLICATE KEY UPDATE updated_at = NOW();

-- ============================================================
-- VERIFICATION QUERIES (run after migration)
-- ============================================================
-- SELECT * FROM feature_flags;
-- SELECT * FROM feature_flag_users;
-- Expected: import_v3_enabled = 0 (OFF by default)
