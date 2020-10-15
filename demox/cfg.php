<?php
//set_time_limit(0); error_reporting(E_ALL); ini_set('error_reporting', E_ALL); ini_set('display_errors', 1); ini_set('display_startup_errors', 1);

define('LOCALHOST',     (getenv('LOCALHOST')===false?'localhost':getenv('LOCALHOST')));
define('DB_HOSTNAME',   getenv('DATABASE_URL'));
define('DB_USERNAME',   getenv('MYSQL_USER'));
define('DB_PASSWORD',   getenv('MYSQL_PASSWORD'));
define('DB_DATABASE',   getenv('MYSQL_DATABASE'));
if (!defined('APP_DIR')) { define('APP_DIR', (getenv('APP_DIR')===false?'/var/www/html/demox':getenv('APP_DIR'))); }
define('LIB_DIR',       APP_DIR.'/lib');
define('PUBLIC_DIR',    APP_DIR.'/public');
define('ERROR_LOG',     APP_DIR.'/error.log');
define('DB_DSN',        'mysql:host='.DB_HOSTNAME.';dbname='.DB_DATABASE);
