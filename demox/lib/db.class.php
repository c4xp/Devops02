<?php

include_once APP_DIR.DIRECTORY_SEPARATOR.'lib'.DIRECTORY_SEPARATOR.'singleton.class.php';

/**
 * Singleton db connector
 * @example include 'db.class.php'; $cid = DB::connectPDO();
 * @example $rs = DB::query('SELECT `col` FROM `table`'); while ($a = $rs->fetch(PDO::FETCH_NUM)) { }
 * @example DB::beginTransaction(); DB::query('INSERT INTO `table` (`col`) VALUES(\'val\')'); DB::commit();
 */
class DB extends singleton {

    private $connection = null;
    public $sql = '';
    public $errors = array();

    static protected function instance($class = '') {
        if (empty($class)) { $class = get_class(); }
        return parent::instance($class);
    }

    /**
     * connect to a database
     * @return boolean
     */
    public static function connect($host, $username, $password, $world) {
        // check for an existing connection
        if (DB::instance()->connection) {
            return true;
        }

        DB::instance()->connection = new PDO('mysql:dbname='.$world.';host='.$host, $username, $password, array(PDO::ATTR_PERSISTENT => true, PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES 'utf8'"));
        DB::instance()->connection->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        // return true only on success
        if (DB::instance()->connection) {
            $stmt = DB::instance()->connection->query('SELECT connection_id()');
            $therow = $stmt->fetch(PDO::FETCH_NUM);
            $connectionid = $therow[0];
            return $connectionid;
        }

        return false;
    }

    public static function connectPDO() {
        // check for an existing connection
        if (DB::instance()->connection) {
            return true;
        }

        DB::instance()->connection = new PDO(DB_DSN, DB_USERNAME, DB_PASSWORD, array(PDO::ATTR_PERSISTENT => true));
        DB::instance()->connection->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        // return true only on success
        if (DB::instance()->connection) {
            $stmt = DB::instance()->connection->query('SELECT connection_id()');
            $therow = $stmt->fetch(PDO::FETCH_NUM);
            $connectionid = $therow[0];
            return $connectionid;
        }

        return false;
    }

    /**
     * execute a sql query
     *
     * @param string sql query
     * @return boolean
     */
    public static function query($sql) {
        $result = @DB::instance()->connection->query($sql);
        if ($result) {
            return $result;
        } else {
            DB::instance()->errors[] = 'DB::query() - ' . str_replace("'", '`', DB::instance()->connection->error);
        }
        return false;
    }

    public static function get_errors() {
        if (count(DB::instance()->errors)) {
            return DB::instance()->errors;
        }
        return false;
    }

    public static function __callStatic($name, $arguments = null) {
        call_user_func_array(array(DB::instance()->connection, $name), $arguments);
    }
    
    public static function last_insert_id() {
        $result = @DB::instance()->connection->lastInsertId();
        return $result;
    }

}