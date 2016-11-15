<?php
session_start();
?>
<html>

<head>
<title>Login</title>
</head>

<body>
<form name="loginform" method="post" action="userauthentication.php">

Username: <input type="text" name="username" /><br  /><br  />
Senha: <input type="password" name="password" /><br  /><br  />
<input type="submit" value="Entrar" />


</form>
</body>

</html> 
