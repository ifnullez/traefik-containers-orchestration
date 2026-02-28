<?php

/**
 * WordPress Configuration
 *
 * Reads all settings from environment variables (set via .env / Docker).
 * Mount this file as wp-config.php inside your container.
 *
 * @see https://developer.wordpress.org/advanced-administration/wordpress/wp-config/
 */

// ============================================================
// Helper: read an env var and cast it to the correct PHP type.
// All configuration below goes through this single function.
// ============================================================
function env(string $key, mixed $default = null): mixed
{
    $value = getenv($key);

    if ($value === false) {
        return $default;
    }

    return match (strtolower($value)) {
        'true',  '1', 'yes' => true,
        'false', '0', 'no'  => false,
        'null', ''           => null,
        default              => $value,
    };
}

// ═══════════════════════════════════════════════════════════════════════════
// SSL/HTTPS (behind reverse proxy like Traefik)
// ═══════════════════════════════════════════════════════════════════════════

if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    $_SERVER['HTTPS'] = 'on';
}

// ============================================================
// SSL constants
// ============================================================
// Force admin & login pages over HTTPS.
// Defaults to true when the request is already HTTPS; can be
// overridden explicitly via the env var.
define('FORCE_SSL_ADMIN', env('FORCE_SSL_ADMIN', true));
define('FORCE_SSL_LOGIN', env('FORCE_SSL_LOGIN', true));

// ============================================================
// Database
// ============================================================
// Prefer WORDPRESS_* prefixed vars (Docker official WP image),
// fall back to the bare DB_* names — both live in your .env.
define('DB_HOST',     env('WORDPRESS_DB_HOST')     ?? env('DB_HOST',     'localhost'));
define('DB_NAME',     env('WORDPRESS_DB_NAME')     ?? env('DB_NAME',     'wordpress'));
define('DB_USER',     env('WORDPRESS_DB_USER')     ?? env('DB_USER',     'root'));
define('DB_PASSWORD', env('WORDPRESS_DB_PASSWORD') ?? env('DB_PASSWORD', ''));
define('DB_CHARSET',  env('WORDPRESS_DB_CHARSET')  ?? env('DB_CHARSET',  'utf8mb4'));
define('DB_COLLATE',  env('WORDPRESS_DB_COLLATE')  ?? env('DB_COLLATE',  ''));

$table_prefix = env('WORDPRESS_TABLE_PREFIX') ?? env('TABLE_PREFIX', 'wp_');

// ============================================================
// URLs
// ============================================================
define('WP_HOME',    env('WP_HOME',    'https://localhost'));
define('WP_SITEURL', env('WP_SITEURL', 'https://localhost'));

// ============================================================
// Environment / Debug
// ============================================================
define('WP_ENVIRONMENT_TYPE', env('ENVIRONMENT_TYPE', 'production'));
define('WP_DEBUG',            env('DEBUG',            false));
define('WP_DEBUG_DISPLAY',    env('DEBUG_DISPLAY',    false));
define('WP_DEBUG_LOG',        env('DEBUG_LOG',        false));
define('SCRIPT_DEBUG',        env('SCRIPT_DEBUG',     false));
define('SAVEQUERIES',         env('SAVEQUERIES',      false));
define('DEVELOPMENT_MODE',    env('DEVELOPMENT_MODE', ''));

// ============================================================
// Performance / Cache
// ============================================================
define('WP_CACHE',            env('CACHE',              false));
define('WP_MEMORY_LIMIT',     env('WP_MEMORY_LIMIT',    '256M'));
define('WP_MAX_MEMORY_LIMIT', env('WP_MAX_MEMORY_LIMIT', '512M'));
define('COMPRESS_CSS',        env('COMPRESS_CSS',        false));
define('COMPRESS_SCRIPTS',    env('COMPRESS_SCRIPTS',    false));
define('CONCATENATE_SCRIPTS', env('CONCATENATE_SCRIPTS', false));
define('ENFORCE_GZIP',        env('ENFORCE_GZIP',        false));

// ============================================================
// cURL
// ============================================================
// Maps the human-readable env value ('v4', 'v6', 'whatever')
// to the PHP CURL_IPRESOLVE_* integer constant.
$_curl_map = [
    'v4'       => CURL_IPRESOLVE_V4,
    'v6'       => CURL_IPRESOLVE_V6,
    'whatever' => CURL_IPRESOLVE_WHATEVER,
];
define('CURL_IPRESOLVE', $_curl_map[strtolower(env('CURL_IPRESOLVE', 'v4'))] ?? CURL_IPRESOLVE_V4);

// ============================================================
// File System
// ============================================================
define('FS_METHOD',          env('FS_METHOD',          'direct'));
define('DISALLOW_FILE_EDIT', env('DISALLOW_FILE_EDIT', false));
define('DISALLOW_FILE_MODS', env('DISALLOW_FILE_MODS', false));

// ============================================================
// Updates
// ============================================================
define('AUTOMATIC_UPDATER_DISABLED', env('AUTOMATIC_UPDATER_DISABLED', true));
define('WP_AUTO_UPDATE_CORE',        env('WP_AUTO_UPDATE_CORE',        false));

// ============================================================
// Content Management
// ============================================================
define('WP_POST_REVISIONS', env('WP_POST_REVISIONS', 2));
define('AUTOSAVE_INTERVAL', env('AUTOSAVE_INTERVAL',  300));
define('EMPTY_TRASH_DAYS',  env('EMPTY_TRASH_DAYS',   30));

// ============================================================
// Multisite (only activated when MULTISITE=true)
// ============================================================
if (env('MULTISITE', false)) {
    define('WP_ALLOW_MULTISITE',   true);
    define('MULTISITE',            true);
    define('SUBDOMAIN_INSTALL',    env('SUBDOMAIN_INSTALL',  false));
    define('DOMAIN_CURRENT_SITE',  env('DOMAIN_CURRENT_SITE') ?? env('ROOT_URL', 'localhost'));
    define('PATH_CURRENT_SITE',    env('PATH_CURRENT_SITE',  '/'));
    define('SITE_ID_CURRENT_SITE', env('SITE_ID_CURRENT_SITE', 1));
    define('BLOG_ID_CURRENT_SITE', env('BLOG_ID_CURRENT_SITE', 1));
} elseif (env('WP_ALLOW_MULTISITE', false)) {
    define('WP_ALLOW_MULTISITE', true);
}

// ============================================================
// Cookie Domain (skip definition entirely when empty/null)
// ============================================================
$_cookie_domain = env('COOKIE_DOMAIN', null);
if ($_cookie_domain !== null && $_cookie_domain !== '') {
    define('COOKIE_DOMAIN', $_cookie_domain);
}

// ============================================================
// Authentication Keys & Salts
// Generate fresh ones at: https://api.wordpress.org/secret-key/1.1/salt/
// ============================================================
define('AUTH_KEY',         env('WORDPRESS_AUTH_KEY',         'put your unique phrase here'));
define('SECURE_AUTH_KEY',  env('WORDPRESS_SECURE_AUTH_KEY',  'put your unique phrase here'));
define('LOGGED_IN_KEY',    env('WORDPRESS_LOGGED_IN_KEY',    'put your unique phrase here'));
define('NONCE_KEY',        env('WORDPRESS_NONCE_KEY',        'put your unique phrase here'));
define('AUTH_SALT',        env('WORDPRESS_AUTH_SALT',        'put your unique phrase here'));
define('SECURE_AUTH_SALT', env('WORDPRESS_SECURE_AUTH_SALT', 'put your unique phrase here'));
define('LOGGED_IN_SALT',   env('WORDPRESS_LOGGED_IN_SALT',   'put your unique phrase here'));
define('NONCE_SALT',       env('WORDPRESS_NONCE_SALT',       'put your unique phrase here'));

// ============================================================
// Absolute path to the WordPress directory
// ============================================================
if (! defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}

// ============================================================
// Bootstrap WordPress settings
// ============================================================
require_once ABSPATH . 'wp-settings.php';
