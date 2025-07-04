<?php

//fetch.php;

if(isset($_POST["email"]))
{
 $connect = new PDO("mysql:host=mysql1-p4.ezhostingserver.com; dbname=actorsbusinessoffice", "kingk436", "Rimshot323!");

 $query = "
SELECT * FROM taousers WHERE useremail = '".trim($_POST["email"])."'
 ";

 $statement = $connect->prepare($query);

 $statement->execute();

 $total_row = $statement->rowCount();

 if($total_row == 0)
 {
  $output = array(
   'success' => true
  );

  echo json_encode($output);
 }
}

?>
