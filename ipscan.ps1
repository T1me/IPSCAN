# IPSCAN PowerShell
# version: 0.1

Param(
    [string]$ipGroup
)


Function scan {
    Param(
        [string]$ipGroup
    )

    $logPath = $PSScriptRoot + "\ipscan.txt"
    $workArray = @()
    $fullResult = @()
    $fullLog = @()

    $threadLimit = 30
    $SessionState = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
    $threadPool = [runspacefactory]::CreateRunspacePool(1, $threadLimit, $SessionState, $Host)
    $threadPool.Open()

    $ping = {
        Param(
            [string]$ip
        )
        Start-Sleep -Seconds 1
        $verboseResult = ping -n 1 $ip
        $result = switch ($LASTEXITCODE) {
            1 {"Error"}
            0 {"Received"}
            Default {"Error"}
        }
        $log = $verboseResult.Split("`n")[1..3]
        Return @{Result = $result; Log = $log}
    }

    $beginTime = Get-Date
    for ($d=1; $d -le 254; $d++) {
        $ip = $ipGroup + $d.ToString()
        $thread = [powershell]::Create().AddScript($ping).AddArgument($ip)
        $thread.RunspacePool = $threadPool
        try {
            $work = @{}
            $work.IP = $ip
            $work.Pipe = $thread
            $work.Handler = $thread.BeginInvoke()
            $workArray += $work
        } catch {
            Write-Output $_
            Write-Warning Error in ping $work.IP
            exit
        }
    }

    Do {
       Start-Sleep -Seconds 1
    } While ($workArray.Handle.IsCompleted -contains $false)
    $endTime = Get-Date
    $spendTime = $endTime - $beginTime
    $spendSec = $spendTime.TotalSeconds
    Write-Output `r
    Write-Output "All Pings Completed in $spendSec seconds."
    Write-Output "Getting Result. . ."
    foreach ($w in $workArray) {
        if ($VerbosePreference -eq "Continue") {
            $fullResult += $w.IP + "..." + $w.Pipe.EndInvoke($w.Handler).Result
        }
        $fullLog += $w.Pipe.EndInvoke($w.Handler).Log
    }
    foreach ($r in $fullResult) {
        Write-Verbose `r$r
    }
    [Io.file]::WriteAllLines($logPath, $fullLog,[text.encoding]::Unicode)
    Write-Output "Ping result log saved to ipscan.txt."
    Write-Output -----------------------------------
}

Function wrongUsage {
    Write-Warning "`rUsage: `".\ipscan 192.168.1. [-s silent]`""
    exit
}

Function invalidOption {
    Param(
        [string]$option
    )
    Write-Warning "`rInvalid Option: $option"
    wrongUsage
}


# exec options
if ($ipGroup -notmatch '^\d{1,3}\.\d{1,3}\.\d{1,3}\.$') {
    wrongUsage
}
$VerbosePreference = "Continue"
foreach ($a in $args) {
    switch ($a) {
        {($_ -eq '-s') -or ($_ -eq '-silent') } {$VerbosePreference = "SilentlyContinue"}
        Default {invalidOption $a}
    }
}


# main
try {
    scan($ipGroup)
} catch {
    Write-Output $_
    Write-Warning "Error in scanning"
    exit
}
$exit = Read-Host Press Enter to Exit. . .
Write-Output `r
