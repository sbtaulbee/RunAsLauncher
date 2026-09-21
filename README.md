# RunAsLauncher

A lightweight PowerShell GUI for launching Windows applications
using alternate credentials or UAC elevation.

## Screenshot

![RunAsLauncher interface](screenshots/RunAsLauncher.png)

## Features

- Launch Windows applications using alternate credentials
- Switch between domain and local account credential modes
- Run applications with standard Windows UAC elevation
- Browse for applications through a graphical file picker
- Support for Windows executable (`.exe`) files
- Support for Microsoft Management Console (`.msc`) snap-ins
- Automatically launches MSC files through Microsoft Management Console
- Simple Windows Forms graphical interface
- Validates selected applications before attempting to launch them
- Provides user-friendly error messages when an application cannot be launched
- Uses the native Windows credential prompt through `Get-Credential`
- Does not store usernames, passwords, or credentials
- Designed for Windows PowerShell 5.1

## Requirements

- Windows 10 or Windows 11
- Windows PowerShell 5.1

## Usage

1. Download `RunAsLauncher.ps1`.
2. Launch the script using Windows PowerShell 5.1.
3. Select an EXE or MSC application.
4. Select Domain or Local when using alternate credentials.
5. Choose **Run as Different User** or **Run Elevated**.

### Domain Accounts

Use:

    DOMAIN\username

### Local Accounts

Use:

    .\username

## Security

RunAsLauncher does not store credentials.

**Run as Different User** uses PowerShell's `Get-Credential`
and `Start-Process -Credential`.

**Run Elevated** uses the standard Windows UAC mechanism through
`Start-Process -Verb RunAs`.

The Domain/Local selector applies only to **Run as Different User**.

## License

MIT
