<?php
define('PHPLIB', $_SERVER[DOCUMENT_ROOT] ."/Common/Phplib/");

require_once(PHPLIB . "php-activerecord/ActiveRecord.php");
 
 ActiveRecord\Config::initialize(function($cfg)
 {
     $cfg->set_model_directory('models');
     $cfg->set_connectionS(array('production' =>
      'mysql://eathappy:XvT2msZv89bM9nu8@mysql.billpollock.com/eathappy'));
     $cfg->set_default_connection('production');
 })

?>
