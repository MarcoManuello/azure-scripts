#Requires -Version 5.1
<#
.SYNOPSIS
    Syncs the local Git repository with GitHub
.DESCRIPTION
    This script handles common Git sync operations:
    - When starting work: pulls latest changes from GitHub
    - When finishing work: commits and pushes changes to GitHub
.PARAMETER Start
    Pull latest changes from GitHub (use when starting work)
.PARAMETER Finish
    Commit and push changes to GitHub (use when finishing work)
.PARAMETER Message
    Commit message (optional, defaults to timestamp)
.EXAMPLE
    .\Sync-GitRepo.ps1 -Start
    Pulls latest changes from GitHub
.EXAMPLE
    .\Sync-GitRepo.ps1 -Finish -Message "Added user provisioning script"
    Commits all changes and pushes to GitHub
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, ParameterSetName='Start')]
    [switch]$Start,
    
    [Parameter(Mandatory=$true, ParameterSetName='Finish')]
    [switch]$Finish,
    
    [Parameter(ParameterSetName='Finish')]
    [string]$Message = "Updates from $(hostname) at $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
)

# Colors for output
function Write-Info { Write-Host $args[0] -ForegroundColor Cyan }
function Write-Success { Write-Host $args[0] -ForegroundColor Green }
function Write-Error { Write-Host $args[0] -ForegroundColor Red }

# Check if we're in a git repository
if (-not (Test-Path .git)) {
    Write-Error "Error: Not in a Git repository!"
    Write-Host "Please run this script from the azure-scripts directory"
    exit 1
}

try {
    if ($Start) {
        Write-Info "Starting work session - pulling latest changes..."
        
        # Check for uncommitted changes
        $status = git status --porcelain
        if ($status) {
            Write-Error "You have uncommitted changes!"
            Write-Host "Please commit or stash them first, or use -Finish to save them"
            exit 1
        }
        
        # Pull latest changes
        git pull origin main
        Write-Success "Successfully pulled latest changes"
        
        # Show recent commits
        Write-Info "`nRecent updates:"
        git log --oneline -5
        
    } elseif ($Finish) {
        Write-Info "Finishing work session - saving changes..."
        
        # Check for changes
        $status = git status --porcelain
        if (-not $status) {
            Write-Info "No changes to commit"
            exit 0
        }
        
        # Show what will be committed
        Write-Info "Changes to be committed:"
        git status --short
        
        # Add all changes
        git add .
        
        # Commit with message
        git commit -m $Message
        Write-Success "Changes committed"
        
        # Push to GitHub
        Write-Info "Pushing to GitHub..."
        git push origin main
        Write-Success "Successfully pushed to GitHub"
        
        # Update CLAUDE.md with last sync time
        $claudePath = ".\CLAUDE.md"
        if (Test-Path $claudePath) {
            $content = Get-Content $claudePath -Raw
            $newDate = Get-Date -Format "yyyy-MM-dd HH:mm"
            
            if ($content -match '## Recent Changes\r?\n(.*?)\r?\n\r?\n') {
                $existingChanges = $Matches[1]
                $newContent = $content -replace '## Recent Changes\r?\n.*?\r?\n\r?\n', "## Recent Changes`n$existingChanges`n- ${newDate}: $Message`n`n"
            } else {
                $newContent = $content -replace '## Recent Changes\r?\n', "## Recent Changes`n- ${newDate}: $Message`n"
            }
            
            Set-Content -Path $claudePath -Value $newContent -NoNewline
            git add $claudePath
            git commit -m "Update CLAUDE.md with sync timestamp" --quiet
            git push origin main --quiet
        }
    }
    
} catch {
    Write-Error "Git operation failed. Check your Git configuration and network connection."
    exit 1
}