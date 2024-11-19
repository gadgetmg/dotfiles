If ($env:APPDATA) {

    If (-Not (Test-Path $env:LOCALAPPDATA\nvim)) {
        New-Item -Path $env:LOCALAPPDATA\nvim -ItemType Junction -Value $env:USERPROFILE\.config\nvim
    }

    If (-Not (Test-Path $env:APPDATA\kanata)) {
        New-Item -Path $env:APPDATA\kanata -ItemType Junction -Value $env:USERPROFILE\.config\kanata
    }

    If (-Not (Test-Path $env:APPDATA\kanata-tray)) {
        New-Item -Path $env:APPDATA\kanata-tray -ItemType Junction -Value $env:USERPROFILE\.config\kanata-tray
    }

}
