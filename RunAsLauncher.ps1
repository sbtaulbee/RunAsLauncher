<#
.SYNOPSIS
    Graphical launcher for running Windows applications using alternate
    credentials or UAC elevation.

.DESCRIPTION
    RunAsLauncher provides a Windows Forms interface for launching EXE
    and MSC applications using alternate domain or local credentials,
    or standard Windows UAC elevation.

.VERSION
    1.0.0

.REQUIREMENTS
    Windows PowerShell 5.1
    Windows 10 or Windows 11

.NOTES
    Credentials are not stored by this script.

    The Domain/Local account selector applies only to
    "Run as Different User".

    "Run Elevated" uses the current Windows user's security context
    and the standard Windows UAC elevation mechanism.
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ============================================================
# Main Window
# ============================================================

$form = New-Object System.Windows.Forms.Form
$form.Text = "Run as Different User"
$form.Size = New-Object System.Drawing.Size(660, 410)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.BackColor = [System.Drawing.Color]::FromArgb(245, 246, 248)

$normalFont = New-Object System.Drawing.Font("Segoe UI", 10)
$titleFont = New-Object System.Drawing.Font(
    "Segoe UI",
    19,
    [System.Drawing.FontStyle]::Regular
)

$form.Font = $normalFont

# ============================================================
# Title
# ============================================================

$title = New-Object System.Windows.Forms.Label
$title.Text = "Run as Different User"
$title.Font = $titleFont
$title.ForeColor = [System.Drawing.Color]::FromArgb(35, 35, 35)
$title.Location = New-Object System.Drawing.Point(30, 25)
$title.Size = New-Object System.Drawing.Size(550, 40)
$form.Controls.Add($title)

$description = New-Object System.Windows.Forms.Label
$description.Text = "Launch an application using alternate Windows credentials."
$description.ForeColor = [System.Drawing.Color]::FromArgb(100, 100, 100)
$description.Location = New-Object System.Drawing.Point(33, 68)
$description.Size = New-Object System.Drawing.Size(560, 25)
$form.Controls.Add($description)

# ============================================================
# Application Label
# ============================================================

$appLabel = New-Object System.Windows.Forms.Label
$appLabel.Text = "Application"
$appLabel.Font = New-Object System.Drawing.Font(
    "Segoe UI",
    9,
    [System.Drawing.FontStyle]::Bold
)
$appLabel.Location = New-Object System.Drawing.Point(33, 110)
$appLabel.AutoSize = $true
$form.Controls.Add($appLabel)

# ============================================================
# Application Path Box
# ============================================================

$appPath = New-Object System.Windows.Forms.TextBox
$appPath.Location = New-Object System.Drawing.Point(35, 135)
$appPath.Size = New-Object System.Drawing.Size(455, 30)
$appPath.BorderStyle = "FixedSingle"
$form.Controls.Add($appPath)

# ============================================================
# Browse Button
# ============================================================

$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Text = "Browse..."
$browseButton.Location = New-Object System.Drawing.Point(505, 132)
$browseButton.Size = New-Object System.Drawing.Size(105, 34)
$browseButton.FlatStyle = "Flat"
$browseButton.BackColor = [System.Drawing.Color]::White
$browseButton.ForeColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
$browseButton.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(200, 200, 200)
$form.Controls.Add($browseButton)

# ============================================================
# Account Type Label
# ============================================================

$accountLabel = New-Object System.Windows.Forms.Label
$accountLabel.Text = "Account Type"
$accountLabel.Font = New-Object System.Drawing.Font(
    "Segoe UI",
    9,
    [System.Drawing.FontStyle]::Bold
)
$accountLabel.Location = New-Object System.Drawing.Point(33, 180)
$accountLabel.AutoSize = $true
$form.Controls.Add($accountLabel)

# ============================================================
# Account Type Toggle State
# ============================================================

$script:AccountType = "Domain"

# ============================================================
# Domain Toggle Button
# ============================================================

$domainButton = New-Object System.Windows.Forms.Button
$domainButton.Text = "Domain"
$domainButton.Location = New-Object System.Drawing.Point(35, 207)
$domainButton.Size = New-Object System.Drawing.Size(110, 34)
$domainButton.FlatStyle = "Flat"
$domainButton.FlatAppearance.BorderSize = 0
$domainButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 212)
$domainButton.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($domainButton)

# ============================================================
# Local Toggle Button
# ============================================================

$localButton = New-Object System.Windows.Forms.Button
$localButton.Text = "Local"
$localButton.Location = New-Object System.Drawing.Point(145, 207)
$localButton.Size = New-Object System.Drawing.Size(110, 34)
$localButton.FlatStyle = "Flat"
$localButton.FlatAppearance.BorderSize = 0
$localButton.BackColor = [System.Drawing.Color]::White
$localButton.ForeColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
$form.Controls.Add($localButton)

# ============================================================
# Account Hint
# ============================================================

$accountHint = New-Object System.Windows.Forms.Label
$accountHint.Text = "Domain format: DOMAIN\username or username@domain.com"
$accountHint.ForeColor = [System.Drawing.Color]::FromArgb(110, 110, 110)
$accountHint.Location = New-Object System.Drawing.Point(35, 247)
$accountHint.Size = New-Object System.Drawing.Size(520, 22)
$form.Controls.Add($accountHint)

# ============================================================
# Status Label
# ============================================================

$status = New-Object System.Windows.Forms.Label
$status.Location = New-Object System.Drawing.Point(35, 285)
$status.Size = New-Object System.Drawing.Size(575, 25)
$status.ForeColor = [System.Drawing.Color]::Firebrick
$form.Controls.Add($status)

# ============================================================
# Run as Different User Button
# ============================================================

$runDifferentButton = New-Object System.Windows.Forms.Button
$runDifferentButton.Text = "Run as Different User"
$runDifferentButton.Location = New-Object System.Drawing.Point(235, 325)
$runDifferentButton.Size = New-Object System.Drawing.Size(185, 40)
$runDifferentButton.FlatStyle = "Flat"
$runDifferentButton.BackColor = [System.Drawing.Color]::White
$runDifferentButton.ForeColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
$runDifferentButton.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(180, 180, 180)
$form.Controls.Add($runDifferentButton)

# ============================================================
# Run Elevated Button
# ============================================================

$runElevatedButton = New-Object System.Windows.Forms.Button
$runElevatedButton.Text = "Run Elevated"
$runElevatedButton.Location = New-Object System.Drawing.Point(435, 325)
$runElevatedButton.Size = New-Object System.Drawing.Size(175, 40)
$runElevatedButton.FlatStyle = "Flat"
$runElevatedButton.FlatAppearance.BorderSize = 0
$runElevatedButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 212)
$runElevatedButton.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($runElevatedButton)

# ============================================================
# Domain Toggle Event
# ============================================================

$domainButton.Add_Click({

    $script:AccountType = "Domain"

    $domainButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 212)
    $domainButton.ForeColor = [System.Drawing.Color]::White

    $localButton.BackColor = [System.Drawing.Color]::White
    $localButton.ForeColor = [System.Drawing.Color]::FromArgb(40, 40, 40)

    $accountHint.Text = "Domain format: DOMAIN\username or username@domain.com"
})

# ============================================================
# Local Toggle Event
# ============================================================

$localButton.Add_Click({

    $script:AccountType = "Local"

    $localButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 212)
    $localButton.ForeColor = [System.Drawing.Color]::White

    $domainButton.BackColor = [System.Drawing.Color]::White
    $domainButton.ForeColor = [System.Drawing.Color]::FromArgb(40, 40, 40)

    $accountHint.Text = "Local format: .\username or $env:COMPUTERNAME\username"
})

# ============================================================
# Browse Button Event
# ============================================================

$browseButton.Add_Click({

    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Title = "Select an application"

    $dialog.Filter = `
        "Applications and Management Consoles (*.exe;*.msc)|*.exe;*.msc|" +
        "Executable Files (*.exe)|*.exe|" +
        "Management Consoles (*.msc)|*.msc|" +
        "All Files (*.*)|*.*"

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {

        $appPath.Text = $dialog.FileName
        $status.Text = ""
    }
})

# ============================================================
# Validate Selected Application
# ============================================================

function Test-SelectedApplication {

    $program = $appPath.Text.Trim()

    if ([string]::IsNullOrWhiteSpace($program)) {

        $status.ForeColor = [System.Drawing.Color]::Firebrick
        $status.Text = "Please select an application."

        return $false
    }

    if (-not (Test-Path $program)) {

        $status.ForeColor = [System.Drawing.Color]::Firebrick
        $status.Text = "The selected file could not be found."

        return $false
    }

    $extension = [System.IO.Path]::GetExtension($program).ToLower()

    if (($extension -ne ".exe") -and ($extension -ne ".msc")) {

        $status.ForeColor = [System.Drawing.Color]::Firebrick
        $status.Text = "Please select an EXE or MSC file."

        return $false
    }

    return $true
}

# ============================================================
# Credential Prompt Helper
# ============================================================

function Get-SelectedCredential {

    if ($script:AccountType -eq "Domain") {

        return Get-Credential `
            -Message "Enter your domain credentials.`nExample: DOMAIN\username"
    }

    else {

        return Get-Credential `
            -Message "Enter your local credentials.`nExample: .\username"
    }
}

# ============================================================
# Run as Different User
# ============================================================

$runDifferentButton.Add_Click({

    $status.Text = ""

    if (-not (Test-SelectedApplication)) {
        return
    }

    $program = $appPath.Text.Trim()

    $Credential = Get-SelectedCredential

    if ($null -eq $Credential) {
        return
    }

    try {

        $extension = [System.IO.Path]::GetExtension($program).ToLower()

        if ($extension -eq ".msc") {

            Start-Process `
                -FilePath "mmc.exe" `
                -ArgumentList "`"$program`"" `
                -Credential $Credential
        }

        elseif ($extension -eq ".exe") {

            Start-Process `
                -FilePath $program `
                -Credential $Credential
        }

        $form.Close()
    }

    catch {

        [System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            "Unable to Launch Application",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
    }
})

# ============================================================
# Run Elevated
# ============================================================

$runElevatedButton.Add_Click({

    $status.Text = ""

    if (-not (Test-SelectedApplication)) {
        return
    }

    $program = $appPath.Text.Trim()

    try {

        $extension = [System.IO.Path]::GetExtension($program).ToLower()

        if ($extension -eq ".msc") {

            Start-Process `
                -FilePath "mmc.exe" `
                -ArgumentList "`"$program`"" `
                -Verb RunAs
        }

        elseif ($extension -eq ".exe") {

            Start-Process `
                -FilePath $program `
                -Verb RunAs
        }

        $form.Close()
    }

    catch {

        [System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            "Unable to Launch Elevated Application",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
    }
})

# ============================================================
# Show Window
# ============================================================

[void]$form.ShowDialog()
