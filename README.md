# Azure Scripts

PowerShell scripts for Azure and Office 365 administration.

## Getting Started

1. Install required PowerShell modules:
   ```powershell
   Install-Module -Name Az -Scope CurrentUser
   Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser
   Install-Module -Name MSOnline -Scope CurrentUser
   Install-Module -Name AzureAD -Scope CurrentUser
   ```

2. Clone this repository to your OneDrive folder for cross-machine access

3. See CLAUDE.md for detailed project information and context

## Project Structure

- `/scripts` - Individual PowerShell scripts
- `/modules` - Reusable PowerShell modules
- `/tests` - Pester test files
- `/docs` - Additional documentation