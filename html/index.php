<!doctype html>
<html lang="en">
<head>
  <meta http-equiv="refresh" content="25" charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="icon" type="image/png" href="https://raw.githubusercontent.com/tynor88/docker-templates/master/images/rclone_small.png">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js" integrity="sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy" crossorigin="anonymous"></script>
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js" integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49" crossorigin="anonymous"></script>
  <title>Docker-MOUNT</title>
  <link rel="stylesheet" href="style.css"
</head>
<body text="#FFFFFF">

	<div class="image">
	<table width="100%" align="center" cellpadding="5" cellspacing="0"><tbody><tr>
	<td width="auto" align="center">
	<h1>
	<strong style="color: #000000; font-family: Segoe, 'Segoe UI', 'DejaVu Sans', 'Trebuchet MS', Verdana, sans-serif; font-size: xx-large; font-weight: bolder;">DOCKER MOUNT<br><span style="color: #053F00; font-size: small">Auto-Refreshes Every 25 Seconds</span><br></strong></h1></td></tr></tbody></table></div>
	<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0"><tbody><tr>
	<td width="90%" height="30" style="color: #E11919; font-family: 'Lucida Grande', 'Lucida Sans Unicode', 'Lucida Sans', 'DejaVu Sans', Verdana, sans-serif; font-weight: bolder; font-size: large; text-align: left;"><br>   MOUNT LOGS</td></tr></tbody></table>
	<table width="100%" border="1" align="center" cellpadding="5" cellspacing="0"><tbody><tr><td colspan="6" bgcolor="#000000" style="color: #F7F6F6; font-family: Segoe, 'Segoe UI', 'DejaVu Sans', 'Trebuchet MS', Verdana, sans-serif; font-weight: bold; font-size: medium;">
	<span class="test" style="color: #FFFFFF; font-family: Segoe, 'Segoe UI', 'DejaVu Sans', 'Trebuchet MS', Verdana, sans-serif;"><?php $output = shell_exec('tail -n 20 /config/logs/rclone-*.log'); echo "<pre>$output</pre>"; ?></span></td></tr></tbody></table>

	<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0"><tbody><tr>
	<td width="90%" height="30" style="color: #E11919; font-family: 'Lucida Grande', 'Lucida Sans Unicode', 'Lucida Sans', 'DejaVu Sans', Verdana, sans-serif; font-weight: bolder; font-size: large; text-align: left;"><br>   MOUNT STATUS</td></tr></tbody></table>
	<table width="100%" border="1" align="center" cellpadding="5" cellspacing="0"><tbody><tr><td colspan="6" bgcolor="#000000" style="color: #F7F6F6; font-family: Segoe, 'Segoe UI', 'DejaVu Sans', 'Trebuchet MS', Verdana, sans-serif; font-weight: bold; font-size: medium;">
	<span class="test" style="color: #FFFFFF; font-family: Segoe, 'Segoe UI', 'DejaVu Sans', 'Trebuchet MS', Verdana, sans-serif;"><?php $output = shell_exec('tail -n 20 /config/check/*.mounted'); echo "<pre>$output</pre>"; ?></span></td></tr></tbody></table>

	<!--<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0"><tbody><tr>
	<td width="90%" height="30" style="color: #E11919; font-family: 'Lucida Grande', 'Lucida Sans Unicode', 'Lucida Sans', 'DejaVu Sans', Verdana, sans-serif; font-weight: bolder; font-size: large; text-align: left;"><br>   DRIVE USED</td></tr></tbody></table>
	<table width="100%" border="1" align="center" cellpadding="5" cellspacing="0"><tbody><tr><td colspan="6" bgcolor="#000000" style="color: #F7F6F6; font-family: Segoe, 'Segoe UI', 'DejaVu Sans', 'Trebuchet MS', Verdana, sans-serif; font-weight: bold; font-size: medium;">
	<span class="test" style="color: #FFFFFF; font-family: Segoe, 'Segoe UI', 'DejaVu Sans', 'Trebuchet MS', Verdana, sans-serif;">< ? php $output = shell_exec('tail -n 20 /config/logs/mountsize-*.log'); echo "<pre>$output</pre>"; ?></span></td></tr></tbody></table> -->
    </br></br></br>
    <footer class="site-footer"> <div class="container"><div class="row"><div class="col-md-8 col-sm-6 col-xs-12"><p class="copyright-text">Copyright &copy; 2020 All Rights Reserved by MrDoob/doob187 </p></div></footer>
</body>
</html>
