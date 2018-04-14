$runningJobs = Get-Job -Name 'ngrok' -ErrorAction SilentlyContinue
if ($runningJobs) {
    Stop-Job $runningJobs -ErrorAction SilentlyContinue
    Remove-Job $runningJobs -ErrorAction SilentlyContinue
}

$job = Start-Job -Name 'ngrok' -ScriptBlock { ngrok.exe http 1313 }
$publicHttpsUrl = $null
while ($publicHttpsUrl -eq $null) {
    $res = Invoke-WebRequest 'http://127.0.0.1:4040/api/tunnels'
    $content = ConvertFrom-Json $res.Content
    $publicHttpsUrl = $content.tunnels[1].public_url
}
hugo server -D --appendPort=false --baseURL=$publicHttpsUrl
