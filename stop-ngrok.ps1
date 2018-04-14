$ngrokJobs = Get-Job -Name 'ngrok' -ErrorAction SilentlyContinue
Stop-Job $ngrokJobs
Remove-Job $ngrokJobs