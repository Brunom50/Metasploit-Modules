<?php
$host = "localhost";
$user = "root";
$pass= "toor";
$banco="xss";
$conn = mysql_connect($host, $user, $pass) or die(mysql_error());
mysql_select_db($banco) or die(mysql_error()); 

?>
<!DOCTYPE html>
<meta charset="UTF-8">
<title>Comment (XSS) </title>
</head>
<body>
<?php
session_start();
$comentario=htmlspecialchars($_GET['content']);
$user = $_SESSION['username'];

if($_GET['content']!=null){
$query="INSERT INTO comentarios (username,comentario) VALUES ('$user','$comentario')  ";
mysql_query($query,$conn) or die(mysql_error());
}

$result = mysql_query("SELECT * FROM comentarios",$conn);

    while($row = mysql_fetch_array($result))
      {
      echo $row['username'] . ":   " . $row['comentario']; 
      echo "<br />";
      }

?>
