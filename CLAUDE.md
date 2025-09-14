# Azure Scripts Project

## Project Overview
Collection of PowerShell scripts for managing Azure resources and Office 365 tenants.

## Environment Setup
- **Required PowerShell Modules**: Az, ExchangeOnlineManagement, MSOnline, AzureAD
- **PowerShell Version**: 5.1 or PowerShell 7+ recommended
- **Authentication Method**: To be configured based on environment

## Project Structure
```
azure-scripts/
├── scripts/           # Individual PowerShell scripts
├── modules/           # Reusable PowerShell modules
├── tests/            # Pester tests
└── docs/             # Documentation
```

## Common Commands
```powershell
# Connect to Azure
Connect-AzAccount

# Connect to Exchange Online
Connect-ExchangeOnline

# Connect to Azure AD
Connect-AzureAD
```

## Git Sync Commands
```powershell
# When starting work on any machine:
.\Sync-GitRepo.ps1 -Start

# When finishing work on any machine:
.\Sync-GitRepo.ps1 -Finish -Message "Description of changes"

# Quick finish with auto-generated message:
.\Sync-GitRepo.ps1 -Finish
```

## Git Configuration
- **Repository**: https://github.com/MarcoManuello/azure-scripts
- **Branch**: main
- **Author**: Marco Manuello (marco@manuello.com)

## Recent Changes
- 2025-09-14: Initial project setup and Git repository created

## Notes for Claude
- This project focuses on Azure and O365 administration tasks
- Scripts should follow PowerShell best practices
- Always use approved verbs for function names
- Include proper error handling and logging