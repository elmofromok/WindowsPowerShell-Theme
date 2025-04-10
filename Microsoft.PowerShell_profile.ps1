# Function to ensure modules are installed and loaded
function Ensure-Module {
    param (
        [string]$ModuleName
    )
    
    if (!(Get-Module -ListAvailable -Name $ModuleName)) {
        Write-Host "Module $ModuleName not found. Attempting to install..."
        try {
            Install-Module -Name $ModuleName -Scope CurrentUser -Force
            Write-Host "Module $ModuleName installed successfully."
        }
        catch {
            Write-Warning "Failed to install module $ModuleName. Some functions may not work correctly."
        }
    }
    
    try {
        Import-Module -Name $ModuleName -ErrorAction Stop
        Write-Host "Module $ModuleName loaded successfully." -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to import module $ModuleName. Some functions may not work correctly."
    }
}

# Ensure required modules are available and loaded
Ensure-Module "Get-ChildItemColor"
Ensure-Module "posh-git"

# Set l and ls alias to use the Get-ChildItemColor cmdlets
if (Get-Command "Get-ChildItemColor" -ErrorAction SilentlyContinue) {
    Set-Alias ll Get-ChildItemColor -Option AllScope
    Set-Alias ls Get-ChildItemColorFormatWide -Option AllScope
}

# Helper function to change directory to your development workspace
function workspace { 
    $workspacePath = "C:\Users\Chad\OneDrive\Documents\workspace"
    if (Test-Path $workspacePath) {
        Set-Location $workspacePath 
    } else {
        Write-Warning "Workspace path not found: $workspacePath"
        Write-Host "Would you like to create this directory? (Y/N)" -ForegroundColor Yellow
        $response = Read-Host
        if ($response -eq 'Y' -or $response -eq 'y') {
            New-Item -ItemType Directory -Path $workspacePath -Force
            Set-Location $workspacePath
            Write-Host "Workspace directory created and set as current location." -ForegroundColor Green
        }
    }
}

# Helper function to set location to the User Profile directory
function cuserprofile { Set-Location ~ }
Set-Alias ~ cuserprofile -Option AllScope

# Helper function to show Unicode character
function U {
    param (
        [int] $Code
    )
 
    if ((0 -le $Code) -and ($Code -le 0xFFFF)) {
        return [char] $Code
    }
 
    if ((0x10000 -le $Code) -and ($Code -le 0x10FFFF)) {
        return [char]::ConvertFromUtf32($Code)
    }
 
    throw "Invalid character code $Code"
}

# Start SshAgent if not already running
if (Get-Command "Start-SshAgent" -ErrorAction SilentlyContinue) {
    if (!(Get-Process -Name 'ssh-agent' -ErrorAction SilentlyContinue)) {
        Start-SshAgent
        Write-Host "SSH Agent started successfully." -ForegroundColor Green
    } else {
        Write-Host "SSH Agent is already running." -ForegroundColor Green
    }
}

# Define the path to your custom theme file
$customThemePath = "$HOME\OneDrive\Documents\WindowsPowerShell\Themes\alien.omp.json"

# Create the themes directory if it doesn't exist
if (-not (Test-Path "$HOME\OneDrive\Documents\WindowsPowerShell\Themes")) {
    New-Item -ItemType Directory -Path "$HOME\OneDrive\Documents\WindowsPowerShell\Themes" -Force
    Write-Host "Created custom themes directory." -ForegroundColor Green
}

# Check if the custom theme file exists
if (-not (Test-Path $customThemePath)) {
    Write-Host "Custom theme file not found at $customThemePath." -ForegroundColor Yellow
    Write-Host "Please save the Alien theme JSON to this location." -ForegroundColor Yellow
} else {
    # Initialize Oh My Posh with the custom theme
    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
        oh-my-posh init pwsh --config $customThemePath | Invoke-Expression
        Write-Host "Oh My Posh initialized with Alien theme" -ForegroundColor Green
    } else {
        Write-Host "Oh My Posh executable not found. Please install it with: winget install JanDeDobbeleer.OhMyPosh" -ForegroundColor Red
    }
}

# Additional helpful aliases and functions
function uptime {
    Get-CimInstance Win32_OperatingSystem | Select-Object LastBootUpTime, LocalDateTime | 
    ForEach-Object { [PSCustomObject]@{
        StartTime = $_.LastBootUpTime
        Uptime = New-TimeSpan -Start $_.LastBootUpTime -End $_.LocalDateTime
    }}
}

# Quick navigation to common folders
function docs { Set-Location "$HOME\OneDrive\Documents" }
function desktop { Set-Location "$HOME\OneDrive\Desktop" }
function downloads { Set-Location "$HOME\Downloads" }

# Git shortcuts
function gs { git status }
function ga { git add $args }
function gc { git commit -m $args }
function gl { git log --oneline --graph --decorate --all }

# Show welcome message
Write-Host "PowerShell Profile loaded successfully!" -ForegroundColor Cyan
Write-Host "Custom commands available: workspace, docs, desktop, downloads, uptime" -ForegroundColor Yellow
Write-Host "Git shortcuts: gs (status), ga (add), gc (commit), gl (log)" -ForegroundColor Yellow