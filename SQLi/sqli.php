<?php

$con = mysql_connect('localhost','root','toor');
$db=mysql_select_db('sqli',$con);

if (isset($_REQUEST['submit'])){
    $user = $_REQUEST['user'];
    $sql = ("SELECT * FROM users WHERE username = '$user';");
    $result = mysql_query($sql) or die (mysql_error());
    $num = mysql_numrows( $result );
    $rst= mysql_fetch_array($result);
    if ($num > 0){
    $i   = 0;
    while( $i < $num ) {

        $first = mysql_result( $result,$i, "nome" );

        echo '<div id="test">' . $first . '</div>';

        $i++;
    }
    }else{
        $ola = "Inseriu um valor errado";
        echo '<div id="test">' . $ola . '</div>';
    }
    mysql_close();
}

?>
<div id="test"> </div> 

  
<form method="post">
User: <input type="text" name="user"/></br>
<input type="submit" value="submit" name="submit"/>
</form>
