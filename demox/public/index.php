<?php
include '../cfg.php';
include_once(APP_DIR.DIRECTORY_SEPARATOR.'lib'.DIRECTORY_SEPARATOR.'db.class.php');

DB::connectPDO();
echo "Hello, ".getenv('APP_NAME')."!<br>\n";
$rs = DB::query("SHOW DATABASES;");
while ($r = $rs->fetch(PDO::FETCH_ASSOC)) {
    var_export($r);
}