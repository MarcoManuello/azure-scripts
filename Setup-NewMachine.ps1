#Requires -Version 5.1
<#
.SYNOPSIS
    Sets up Git and clones repositories on a new machine
.DESCRIPTION
    This script automates the setup process for new machines:
    - Checks and installs Git if needed
    - Configures Git with your user information
    - Clones your repositories from GitHub
    - Sets up the folder structure
.EXAMPLE
    .\Setup-NewMachine.ps1
    Runs the complete setup process
#>

[CmdletBinding()]
param()

# Colors for output
function Write-Info { Write-Host $args[0] -ForegroundColor Cyan }
function Write-Success { Write-Host $args[0] -ForegroundColor Green }
function Write-Warning { Write-Host $args[0] -ForegroundColor Yellow }
function Write-Error { Write-Host $args[0] -ForegroundColor Red }

Write-Info "=== Git and Repository Setup for New Machine ==="

# Check if Git is installed
Write-Info "`nChecking Git installation..."
try {
    $gitVersion = git --version 2>$null
    if ($gitVersion) {
        Write-Success "✓ Git is already installed: $gitVersion"
    }
} catch {
    Write-Warning "Git is not installed. Installing Git..."
    
    # Check if winget is available
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install Git.Git
        Write-Success "✓ Git installed successfully"
        Write-Warning "Please restart PowerShell and run this script again"
        exit 0
    } else {
        Write-Error "Please install Git manually from https://git-scm.com/download/win"
        Write-Error "Then run this script again"
        exit 1
    }
}

# Configure Git
Write-Info "`nConfiguring Git..."
$currentName = git config --global user.name
$currentEmail = git config --global user.email

if ($currentName -and $currentEmail) {
    Write-Info "Git is already configured:"
    Write-Info "  Name: $currentName"
    Write-Info "  Email: $currentEmail"
    
    $response = Read-Host "Keep these settings? (Y/n)"
    if ($response -eq 'n') {
        $currentName = $null
        $currentEmail = $null
    }
}

if (-not $currentName) {
    git config --global user.name "Marco Manuello"
    git config --global user.email "marco@manuello.com"
    Write-Success "✓ Git user configured"
}

# Set other Git configurations
git config --global init.defaultBranch main
git config --global core.autocrlf true
git config --global credential.helper manager
Write-Success "✓ Git settings configured"

# Create project structure
Write-Info "`nSetting up project directories..."
$projectBase = "C:\Users\$env:USERNAME\OneDrive\Documents\Projects"

if (-not (Test-Path $projectBase)) {
    New-Item -ItemType Directory -Path $projectBase -Force | Out-Null
    Write-Success "✓ Created Projects directory"
}

# Clone repositories
Write-Info "`nCloning repositories..."
$repositories = @(
    @{
        Name = "azure-scripts"
        Url = "https://github.com/MarcoManuello/azure-scripts.git"
    }
    # Add more repositories here as needed:
    # @{
    #     Name = "o365-automation"
    #     Url = "https://github.com/MarcoManuello/o365-automation.git"
    # }
)

Set-Location $projectBase

foreach ($repo in $repositories) {
    if (Test-Path $repo.Name) {
        Write-Warning "Repository $($repo.Name) already exists, skipping..."
    } else {
        Write-Info "Cloning $($repo.Name)..."
        git clone $repo.Url
        if ($LASTEXITCODE -eq 0) {
            Write-Success "✓ Cloned $($repo.Name)"
        } else {
            Write-Error "Failed to clone $($repo.Name)"
        }
    }
}

# Create desktop shortcut to Projects folder
Write-Info "`nCreating desktop shortcut..."
$desktop = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktop "Azure Projects.lnk"

if (-not (Test-Path $shortcutPath)) {
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = $projectBase
    $Shortcut.Save()
    Write-Success "✓ Created desktop shortcut to Projects folder"
}

# Final instructions
Write-Success "`n=== Setup Complete! ==="
Write-Info "`nYour repositories are in:"
Write-Info "  $projectBase"
Write-Info "`nTo start working:"
Write-Info "  1. Open PowerShell"
Write-Info "  2. cd to azure-scripts folder"
Write-Info "  3. Run: .\Sync-GitRepo.ps1 -Start"
Write-Info "`nA desktop shortcut 'Azure Projects' has been created for easy access."

# Test Git access
Write-Info "`nTesting GitHub access..."
Set-Location "$projectBase\azure-scripts"
$remoteTest = git ls-remote 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Success "✓ GitHub access confirmed"
} else {
    Write-Warning "GitHub access may require authentication on first use"
    Write-Info "You'll be prompted for credentials when you first push/pull"
}

Write-Info "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")