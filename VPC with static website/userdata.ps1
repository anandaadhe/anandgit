<powershell>

Install-WindowsFeature -Name Web-Server -IncludeManagementTools

$html = @"

<!DOCTYPE html>

<html>

<head>

<title>AWS Website</title>

</head>

<body style='font-family:Arial;text-align:center;margin-top:100px;'>

<h1>Welcome to AWS</h1>

<h2>Website deployed using Terraform</h2>

<p>Windows Server + IIS</p>

</body>

</html>

"@

$html | Out-File C:\inetpub\wwwroot\index.html

</powershell>