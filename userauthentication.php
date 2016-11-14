<?php
$host = "localhost";
$user = "root";
$pass= "toor";
$banco="xss";
$conn = mysql_connect($host, $user, $pass) or die(mysql_error());
mysql_select_db($banco) or die(mysql_error()); 

?>


<?php
$username=$_POST['username'];
$password=$_POST['password'];
$query="select username,password from users where username='$username' and password='$password' limit 0,1";
$result=mysql_query($query);
$rows = mysql_fetch_array($result);
if($rows)
{
echo "Login correto" ;
session_start();
$_SESSION['username'] = $username;
header("Location: index.php");
}
else
{
Echo "Login incorreto";
}

?>
