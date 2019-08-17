#!/usr/bin/php

<?php

$_SERVER[DOCUMENT_ROOT] = '/home/wilpol10/billpollock.com';
require_once("$_SERVER[DOCUMENT_ROOT]/eathappy/php/Connection.php");


$data_sources = 
    array(
	  array(collection_name => 'Fourth Edition',
		collection_label  => "4th-edition",
		path => '/home/wilpol10/billpollock.com/eathappy/data/4th-edition'
),
	  array(collection_name => "Leta Jackson's Encarta on Cooking",
		collection_label => 'gramma',
		path => '/home/wilpol10/billpollock.com/eathappy/data/gramma'
),
	  );

foreach ($data_sources as $datasource) {
  echo "Processing ", $datasource{collection_name}, "\n";
  var_dump($datasource);
  $collection = Collection::find_or_create_by_collection_label_and_collection_name($datasource{collection_label}, $datasource{collection_name});
  proccess_categories($datasource, $collection, 'p', 'categories');
  proccess_categories($datasource, $collection, 's', 'secondary_categories');

  //  process_dir($datasource);
  

}


function process_dir($datasource) {
  if ($dh = opendir($datasource{path})) {
    while (($file = readdir($dh)) !== false) {
      if (preg_match('/^,/', $file)) continue; 
      //      if (!preg_match('/xml$/', $file)) continue; 
      if (preg_match('/xml$/', $file)) continue; 

      echo "filename: $file\n";

    }
  } else {
    echo "SHIT -- could not process.\n";
  }

}

function proccess_categories($datasource, $collection, $category_type, $filename) {
  $path = $datasource{path} . '/' . $filename;
  $myfile = fopen($path, "r") or die("Unable to open $path!");
  $position = 0;
  // Output one line until end-of-file
  while(!feof($myfile)) {
    $category_name = rtrim(fgets($myfile));
    if (!$category_name) continue;
    echo "$filename: $category_name\n";
    $position += 10;
    $category = Category::find_or_create_by_category_name($category_name);
    // STILL N?EED TO SAVE collection label?  Maybe this is WTF?

//    $collectionCategory = CollectionCategory::find_or_create_by_collection_id_and_category_id($collection->collection_id, $category->category_id);
    $collectionCategory = CollectionCategory::find_or_create_by_collection_id_and_category_id(array('collection_id' => $collection->collection_id, 
    'category_id' => $category->category_id,
    'cagtegory_type' => $category_type));

    // 
  }
  fclose($myfile);
}

?>
