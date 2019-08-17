<?php
$_SERVER[DOCUMENT_ROOT] = '/home/wilpol10/billpollock.com';

require_once("$_SERVER[DOCUMENT_ROOT]/eathappy/php/Connection.php");

$record = new Recipe();
$yieldUnit = new YieldUnit();

$yield = YieldUnit::find_or_create_by_yield_unit_name("servings");
$record->recipe_name = 'Broiled Manager Fuggety';
$record->yield_quant = 25;
//$record->yield_unit_id = $yield->yield_unit_id;
//$record->yield_unit->yield_unit_name = 'Zorks';
$record->yield_unit = $yield;
$record->prep_time = "Eighteen Months";
$record->notes = "THESE ARE SOME MOTHERLOVING NOTES";
$record->preparation = "Give a sucker some rope.";
//$record->source_id= -1; // KLUDGE
$record->source_page = 999;
$record->source_date = '2015-01-01';
$record->save();

//$record->created = "2016-01-01";
//$record->lastUpdate = "2016-09-26";

?>
