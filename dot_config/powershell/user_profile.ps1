# set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# Import-Module posh-git
Import-Module posh-git
oh-my-posh init pwsh --config 'robbyrussell' | Invoke-Expression

Import-Module -Name Terminal-Icons

# PSReadLine
Import-Module PSReadLine
Set-PSReadLineKeyHandler -Key Tab -Function Complete

# Autocompleteion for Arrow keys
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineOption -ShowToolTips
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar

Invoke-Expression (& { (zoxide init powershell | Out-String) })

Set-Alias g git
Set-Alias vi nvim

# Utility
function which($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

# make neovim regconize .config
$Env:XDG_CONFIG_HOME = "$env:USERPROFILE\.config"

# mise
(&mise activate pwsh) | Out-String | Invoke-Expression
