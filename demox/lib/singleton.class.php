<?php

/**
 * Singleton base class for subclassing generic singleton pattern
 * classes
 */
class Singleton {

  // Single instance of class available.
  private static $instances = array();

  /**
   * Returns the single shared static instance variable
   * which facilitates the Singleton pattern
   *
   * @note  each subclass should implement an instance() method which
   * passes the class name to the parent::instance() function
   * @return object instance
   */
  static protected function instance ($class) {
    if (! isset(self::$instances[$class])) {
      self::$instances[$class] = new $class();
    }
    return self::$instances[$class];
  }

  /** Prevent instance construction and cloning (copying of object instance) */
  protected final function __construct () {}

  private final function __clone () {
    trigger_error('Cloning instances of this class is forbidden.', E_USER_ERROR);
  }
  
  private final function __wakeup() {
    trigger_error('Unserializing instances of this class is forbidden.', E_USER_ERROR);
  }

  public function __destruct() {
    // This is just here to remind you that the
    // destructor must be public even in the case
    // of a singleton.
  }

}