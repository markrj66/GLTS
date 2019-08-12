param (
    [string]$UpdateApp='true',
    [string]$Applications=''
)

if ([Environment]::GetEnvironmentVariable("UpdateApplications", "Process")) {
    $UpdateApp = [Environment]::GetEnvironmentVariable("UpdateApplications", "Process")
}

if ([Environment]::GetEnvironmentVariable("Applications", "Process")) {
    $Applications = [Environment]::GetEnvironmentVariable("Applications", "Process")
}

If(!$Applications){
    Write-Host '----------------------------------------------------------------------------------------------------------'`n
    Write-Host "Please add some applications to update" -BackgroundColor Red -ForegroundColor White
    Write-host 'e.g. .\InstallListofApps.ps1 -Applications "Firefox 7Zip VLC"'`n
    Write-Host '----------------------------------------------------------------------------------------------------------'`n
    exit 1
}

function Is-Installed( $program ) {
    #Write-Host -ForegroundColor Blue -BackgroundColor White "program is " $program
    $x86 = ((Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall") |
        Where-Object { $_.GetValue( "DisplayName" ) -like "*$program*" } ).Length -gt 0;

    $x64 = ((Get-ChildItem "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
        Where-Object { $_.GetValue( "DisplayName" ) -like "*$program*" } ).Length -gt 0;

    return $x86 -or $x64;
}

function InstallUpdateChoco {
    $bool = 0
    Try {
        if (!(Test-Path($env:ChocolateyInstall + "\choco.exe"))) {
            Write-Host '----------------------------------------------------------------------------------------------------------'`n
            iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
        }
    } Catch {
        Write-Host $($_.Exception.Message)
        exit 1
    }
}

InstallUpdateChoco

#Get a list of Apps already installed by Chocolatey

$chocoinstalled = & "$env:ChocolateyInstall\choco.exe" list --localonly

#if ($NewApp -like "true") {
    if ($Applications -ne " ") {
        $installedApps = $Applications.Split(" ") 
        Write-Host "-----------------------------For Each Application in the List Check if managed------------------------"`n
        foreach($app in $installedApps){
            
           # Write-Host "App Name is " $app
            if (!($app -like " ") -and $app.length -ne 0) {
                    
                if($app -eq "7zip"){
                    $app = "7-Zip"
                }

            $installed = Is-Installed($app)
        
            if ($installed -eq "True"){
               # Write-host "Installed is " $installed
                
                if($app -eq "7-Zip"){
                    $app = "7zip"
                }
                #Write-Host "Now Check if Managed by Choco"
                $choconumber = $chocoinstalled.Count
                #Write-Host 'Number of items in chocoinstalled ' $choconumber
                $chcoocount = 0
                foreach($chocoapp in $chocoinstalled){
                    #Write-Host "Choco App is " $chocoapp
                    #Write-Host "App is $app"
                    if($chocoapp -like "$app*"){
                        Write-Host -BackgroundColor red -ForegroundColor white $app " is already managed by Chocolatey"
                        Write-Host ""
                        Break
                    }
                    $chcoocount++
                }
                if ($choconumber -eq $chcoocount){
                    Write-Host '-------------------------------------Adding ' $app ' to Chocolatey------------------------------------------'`n
                    
                    & "$env:ChocolateyInstall\choco.exe" install $app -y
                    Write-Host `n
                }
            }#else{

                        
                        
                #    }
                }

        }
    } else {
        $VersionChoco = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($env:ChocolateyInstall + "\choco.exe").ProductVersion
        Write-Host '----------------------------------------------------------------------------------------------------------'`n
        Write-Host Installing
        Write-Host Chocolatey v$VersionChoco
        Write-Host Package name is required. Please pass at least one package name to install.`n
    }
#}
Write-Host '----------------------------------------Upgrade All Apps--------------------------------------------------'`n

    & "$env:ChocolateyInstall\choco.exe" upgrade all -y
    Write-Host `n


Write-Host `n'------------------------------------------Script End------------------------------------------------------'
exit 0