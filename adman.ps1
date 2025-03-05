If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting administrative privileges..."
    Start-Process powershell "-File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# Hide PowerShell Console
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0)

# Main Form
Add-Type -AssemblyName System.Windows.Forms
$mainForm = New-Object System.Windows.Forms.Form
$mainForm.Text = “AdMan”
$mainForm.Width = 300
$mainForm.Height = 200
$mainForm.StartPosition = “CenterScreen”

# Header Label
$headerLabel = New-Object System.Windows.Forms.Label
$headerLabel.Text = “AdMan”
$headerLabel.AutoSize = $true
$headerLabel.Location = New-Object System.Drawing.Point(110, 10)
$headerLabel.ForeColor = "White"
$headerLabel.BackColor = "Black"
$mainForm.Controls.Add($headerLabel)

# Kicker Textbox
$kickerTextBoxPlaceholder = "username"
$kickerTextBox = New-Object System.Windows.Forms.TextBox
$kickerTextBox.ForeColor = "Gray"
$kickerTextBox.Text = $kickerTextBoxPlaceholder
$kickerTextBox.Location = New-Object System.Drawing.Point(20, 50)
$kickerTextBox.Size = New-Object System.Drawing.Size(105, 20)
$mainForm.Controls.Add($kickerTextBox)
$kickerTextBox.Add_GotFocus({
    if ($kickerTextBox.Text -eq $kickerTextBoxPlaceholder) {
        $kickerTextBox.Text = ""
        $kickerTextBox.ForeColor = "Black"
    }
})
$kickerTextBox.Add_LostFocus({
    if ($kickerTextBox.Text -eq "") {
        $kickerTextBox.Text = $kickerTextBoxPlaceholder
        $kickerTextBox.ForeColor = "Gray"
    }
})

# Kicker Button
$kickerButton = New-Object System.Windows.Forms.Button
$kickerButton.Text = “Kick”
$kickerButton.Location = New-Object System.Drawing.Point(150, 50)
$kickerButton.Size = New-Object System.Drawing.Size(85, 20)
$mainForm.Controls.Add($kickerButton)

# Create a horizontal line using a Label
$line = New-Object System.Windows.Forms.Label
$line.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
$line.AutoSize = $false
$line.Width = 300
$line.Height = 2
$line.Location = New-Object System.Drawing.Point(0, 75)
$mainForm.Controls.Add($line)

# Hostname Lookup Textbox
$hostnameLookupTextboxPlaceholder = "username"
$hostnameLookupTextbox = New-Object System.Windows.Forms.TextBox
$hostnameLookupTextbox.ForeColor = "Gray"
$hostnameLookupTextbox.Text = $hostnameLookupTextboxPlaceholder
$hostnameLookupTextbox.Location = New-Object System.Drawing.Point(20, 80)
$hostnameLookupTextbox.Size = New-Object System.Drawing.Size(105, 20)
$mainForm.Controls.Add($hostnameLookupTextbox)
$hostnameLookupTextbox.Add_GotFocus({
    if ($hostnameLookupTextbox.Text -eq $hostnameLookupTextboxPlaceholder) {
        $hostnameLookupTextbox.Text = ""
        $hostnameLookupTextbox.ForeColor = "Black"
    }
})
$hostnameLookupTextbox.Add_LostFocus({
    if ($hostnameLookupTextbox.Text -eq "") {
        $hostnameLookupTextbox.Text = $hostnameLookupTextboxPlaceholder
        $hostnameLookupTextbox.ForeColor = "Gray"
    }
})

# Hostname Lookup Button
$hostnameLookupButton = New-Object System.Windows.Forms.Button
$hostnameLookupButton.Text = "Get hostname"
$hostnameLookupButton.Size = New-Object System.Drawing.Size(85, 20)
$hostnameLookupButton.Location = New-Object System.Drawing.Point(150, 80)
$mainForm.Controls.Add($hostnameLookupButton)

# Create a horizontal line using a Label
$line = New-Object System.Windows.Forms.Label
$line.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
$line.AutoSize = $false
$line.Width = 300
$line.Height = 2
$line.Location = New-Object System.Drawing.Point(0, 105)
$mainForm.Controls.Add($line)

# Info Label
$infoLabel = New-Object System.Windows.Forms.Label
$infoLabel.Text = ""
$infoLabel.AutoSize = $true
$infoLabel.Location = New-Object System.Drawing.Point(10, 130)
$mainForm.Controls.Add($infoLabel)

function userKicker {
    $infoLabel.ForeColor = "Black"
    $infoLabel.Text = ""
    if (!($kickerTextBox.Text -eq $kickerTextBoxPlaceholder)) {
        $userToKick = $kickerTextBox.Text
        $userName = $userToKick
        $userQuery = (query user | findstr "$userName")
        if (!($userQuery)) {
            $infoLabel.ForeColor = "Red"
            $infoLabel.Text = "'$userName' not found"
        } else {
            $infoLabel.ForeColor = "Green"
            $infoLabel.Text = "'$userName' found"
            $hostName = (hostname)
            if (!(hostname)) {
                $infoLabel.ForeColor = "Red"
                $infoLabel.Text = "Can't get hostname"
            } else {
                $infoLabel.Text = "Hostname '$hostName'"
                $sessionId = ($userQuery -split '\s+')[2]
                $infoLabel.Text = "Kicking"
                logoff $sessionId /server:$hostName
                $userQuery = (query user | findstr "$userName")
                $infoLabel.Text = "Rechecking"
                if (!($userQuery)) {
                    $infoLabel.Text = "Kicked '$userName'"
                } else {
                    $infoLabel.ForeColor = "Red"
                    $infoLabel.Text = "Recheck shows '$userName' still logged in"
                }
            }
        }
    }
}

# Kicker Button Add Click
$kickerButton.Add_Click({
    userKicker
})

# Kicker Textbox Enter
$kickerTextBox.Add_KeyDown({
    if ($_.KeyCode -eq "Enter") {
        userKicker
    }
})

# Hostname Lookup Function
function hostnameLookup {
    $infoLabel.ForeColor = "Black"
    $infoLabel.Text = ""
    $moduleName = "PSTerminalServices"
    if (Get-Module -Name $moduleName -ListAvailable) {
        $infoLabel.Text = "$moduleName is installed."
        if (!($hostnameLookupTextbox -eq $hostnameLookupTextboxPlaceholder)) {
            $userName = $hostnameLookupTextbox.Text
            $queryResult = (Get-TSSession -UserName $userName)
            if (!($queryResult)) {
                $infoLabel.ForeColor = "Red"
                $infoLabel.Text = "'$userName' not found"
            } else {
                $hostName = ($queryResult.ClientName)
                if (!($hostName)) {
                    $infoLabel.ForeColor = "Red"
                    $infoLabel.Text = "Hostname can not be recovered"
                } else {
                    $infoLabel.ForeColor = "Green"
                    $infoLabel.Text = "Hostname for '$userName': $hostName"
                }
            }
        }
    } else {
        $infoLabel.BackColor = "Yellow"
        $infoLabel.Text = "$moduleName is not installed, install it first..."
    }
}

# Hostname Lookup Button Add Click
$hostnameLookupButton.Add_Click({
    hostnameLookup
})

# Hostname Lookup Textbox Enter
$hostnameLookupTextbox.Add_KeyDown({
    if ($_.KeyCode -eq "Enter") {
        hostnameLookup
    }
})

# Icon
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
$iconPath = Join-Path -Path $scriptDirectory -ChildPath "adman.ico"
if (Test-Path $iconPath) {
    $mainForm.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath)
    $notifyIcon = New-Object System.Windows.Forms.NotifyIcon
}

# Show Form
$mainForm.ShowDialog() 
