If ($env:APPDATA) {

    If (-Not (Test-Path $env:LOCALAPPDATA\nvim)) {
        New-Item -Path $env:LOCALAPPDATA\nvim -ItemType Junction -Value $env:USERPROFILE\.config\nvim
    }

    If (-Not (Test-Path $env:USERPROFILE\.local\share\nvim)) {
        If (Test-Path $env:LOCALAPPDATA\nvim-data) {
            Move-Item -Path $env:LOCALAPPDATA\nvim-data -Destination $env:USERPROFILE\.local\share\nvim
        } else {
            New-Item -Path $env:USERPROFILE\.local\share\nvim -ItemType Directory
        }
        New-Item -Path $env:LOCALAPPDATA\nvim-data -ItemType Junction -Value $env:USERPROFILE\.local\share\nvim
    }

    If (-Not (Test-Path $env:APPDATA\kanata)) {
        New-Item -Path $env:APPDATA\kanata -ItemType Junction -Value $env:USERPROFILE\.config\kanata
    }

    If (-Not (Test-Path $env:APPDATA\kanata-tray)) {
        New-Item -Path $env:APPDATA\kanata-tray -ItemType Junction -Value $env:USERPROFILE\.config\kanata-tray
    }

}
