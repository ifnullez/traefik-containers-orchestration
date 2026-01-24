<?php

/**
 * WordPress Extra Configuration
 *
 * This file is included via WORDPRESS_CONFIG_EXTRA
 * All values are read from environment variables
 */

// ═══════════════════════════════════════════════════════════════════════════
// HELPER FUNCTION
// ═══════════════════════════════════════════════════════════════════════════

if (!function_exists('env')) {
    /**
     * Get environment variable with default value
     * Handles string booleans ('true'/'false') conversion
     */
    function env(string $key, $default = null)
    {
        $value = getenv($key);

        if ($value === false) {
            return $default;
        }

        // Convert string booleans
        $lowered = strtolower($value);
        if ($lowered === 'true') return true;
        if ($lowered === 'false') return false;

        // Convert numeric strings
        if (is_numeric($value)) {
            return strpos($value, '.') !== false ? (float) $value : (int) $value;
        }

        return $value;
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// SITE URLS
// ═══════════════════════════════════════════════════════════════════════════

if (env('WP_HOME') && !defined('WP_HOME')) {
    define('WP_HOME', env('WP_HOME'));
}

if (env('WP_SITEURL') && !defined('WP_SITEURL')) {
    define('WP_SITEURL', env('WP_SITEURL'));
}

// ═══════════════════════════════════════════════════════════════════════════
// DATABASE CHARSET & COLLATION
// ═══════════════════════════════════════════════════════════════════════════

if (!defined('DB_CHARSET')) {
    define('DB_CHARSET', env('DB_CHARSET', 'utf8mb4'));
}

if (!defined('DB_COLLATE')) {
    define('DB_COLLATE', env('DB_COLLATE', ''));
}

// ═══════════════════════════════════════════════════════════════════════════
// DEBUGGING
// ═══════════════════════════════════════════════════════════════════════════

$debug = env('DEBUG', true);
$debug_display = env('DEBUG_DISPLAY', false);
$debug_log = env('DEBUG_LOG', true);

@ini_set('display_errors', $debug_display ? '1' : '0');

if (!defined('WP_DEBUG')) {
    define('WP_DEBUG', $debug);
}

if (!defined('WP_DEBUG_DISPLAY')) {
    define('WP_DEBUG_DISPLAY', $debug_display);
}

if (!defined('WP_DEBUG_LOG')) {
    define('WP_DEBUG_LOG', $debug_log);
}

if (!defined('SCRIPT_DEBUG')) {
    define('SCRIPT_DEBUG', env('SCRIPT_DEBUG', false));
}

if (!defined('SAVEQUERIES')) {
    define('SAVEQUERIES', env('SAVEQUERIES', false));
}

// ═══════════════════════════════════════════════════════════════════════════
// PERFORMANCE
// ═══════════════════════════════════════════════════════════════════════════

if (!defined('WP_CACHE')) {
    define('WP_CACHE', env('CACHE', true));
}

if (!defined('COMPRESS_CSS')) {
    define('COMPRESS_CSS', env('COMPRESS_CSS', true));
}

if (!defined('COMPRESS_SCRIPTS')) {
    define('COMPRESS_SCRIPTS', env('COMPRESS_SCRIPTS', true));
}

if (!defined('CONCATENATE_SCRIPTS')) {
    define('CONCATENATE_SCRIPTS', env('CONCATENATE_SCRIPTS', true));
}

if (!defined('ENFORCE_GZIP')) {
    define('ENFORCE_GZIP', env('ENFORCE_GZIP', true));
}

// ═══════════════════════════════════════════════════════════════════════════
// ENVIRONMENT
// ═══════════════════════════════════════════════════════════════════════════

if (!defined('WP_ENVIRONMENT_TYPE')) {
    define('WP_ENVIRONMENT_TYPE', env('ENVIRONMENT_TYPE', 'production'));
}

$dev_mode = env('DEVELOPMENT_MODE', '');
if (!empty($dev_mode) && !defined('WP_DEVELOPMENT_MODE')) {
    define('WP_DEVELOPMENT_MODE', $dev_mode);
}

// ═══════════════════════════════════════════════════════════════════════════
// MEMORY LIMITS
// ═══════════════════════════════════════════════════════════════════════════

if (!defined('WP_MEMORY_LIMIT')) {
    define('WP_MEMORY_LIMIT', env('WP_MEMORY_LIMIT', '256M'));
}

if (!defined('WP_MAX_MEMORY_LIMIT')) {
    define('WP_MAX_MEMORY_LIMIT', env('WP_MAX_MEMORY_LIMIT', '512M'));
}

// ═══════════════════════════════════════════════════════════════════════════
// FILE SYSTEM
// ═══════════════════════════════════════════════════════════════════════════

if (!defined('FS_METHOD')) {
    define('FS_METHOD', env('FS_METHOD', 'direct'));
}

if (!defined('DISALLOW_FILE_EDIT')) {
    define('DISALLOW_FILE_EDIT', env('DISALLOW_FILE_EDIT', true));
}

if (!defined('DISALLOW_FILE_MODS')) {
    define('DISALLOW_FILE_MODS', env('DISALLOW_FILE_MODS', false));
}

// ═══════════════════════════════════════════════════════════════════════════
// AUTO-UPDATES
// ═══════════════════════════════════════════════════════════════════════════

if (!defined('AUTOMATIC_UPDATER_DISABLED')) {
    define('AUTOMATIC_UPDATER_DISABLED', env('AUTOMATIC_UPDATER_DISABLED', false));
}

if (!defined('WP_AUTO_UPDATE_CORE')) {
    define('WP_AUTO_UPDATE_CORE', env('WP_AUTO_UPDATE_CORE', 'minor'));
}

// ═══════════════════════════════════════════════════════════════════════════
// REVISIONS & AUTOSAVE
// ═══════════════════════════════════════════════════════════════════════════

if (!defined('WP_POST_REVISIONS')) {
    define('WP_POST_REVISIONS', env('WP_POST_REVISIONS', 5));
}

if (!defined('AUTOSAVE_INTERVAL')) {
    define('AUTOSAVE_INTERVAL', env('AUTOSAVE_INTERVAL', 60));
}

// ═══════════════════════════════════════════════════════════════════════════
// TRASH
// ═══════════════════════════════════════════════════════════════════════════

if (!defined('EMPTY_TRASH_DAYS')) {
    define('EMPTY_TRASH_DAYS', env('EMPTY_TRASH_DAYS', 30));
}

// ═══════════════════════════════════════════════════════════════════════════
// COOKIE DOMAIN
// ═══════════════════════════════════════════════════════════════════════════

$cookie_domain = env('COOKIE_DOMAIN', '');
if (!empty($cookie_domain) && !defined('COOKIE_DOMAIN')) {
    define('COOKIE_DOMAIN', $cookie_domain);
}

// ═══════════════════════════════════════════════════════════════════════════
// SSL/HTTPS (behind reverse proxy like Traefik)
// ═══════════════════════════════════════════════════════════════════════════

if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    $_SERVER['HTTPS'] = 'on';
}

// ═══════════════════════════════════════════════════════════════════════════
// MULTISITE
// ═══════════════════════════════════════════════════════════════════════════

if (env('WP_ALLOW_MULTISITE', false) && !defined('WP_ALLOW_MULTISITE')) {
    define('WP_ALLOW_MULTISITE', true);
}

if (env('MULTISITE', false) && !defined('MULTISITE')) {
    define('MULTISITE', true);

    if (!defined('SUBDOMAIN_INSTALL')) {
        define('SUBDOMAIN_INSTALL', env('SUBDOMAIN_INSTALL', false));
    }

    if (!defined('DOMAIN_CURRENT_SITE')) {
        define('DOMAIN_CURRENT_SITE', env('DOMAIN_CURRENT_SITE', ''));
    }

    if (!defined('PATH_CURRENT_SITE')) {
        define('PATH_CURRENT_SITE', env('PATH_CURRENT_SITE', '/'));
    }

    if (!defined('SITE_ID_CURRENT_SITE')) {
        define('SITE_ID_CURRENT_SITE', env('SITE_ID_CURRENT_SITE', 1));
    }

    if (!defined('BLOG_ID_CURRENT_SITE')) {
        define('BLOG_ID_CURRENT_SITE', env('BLOG_ID_CURRENT_SITE', 1));
    }
}
