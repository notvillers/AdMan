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
$mainForm.Text = "AdMan"
$mainForm.Width = 300
$mainForm.Height = 300
$mainForm.StartPosition = "CenterScreen"

# Header Label
$headerLabel = New-Object System.Windows.Forms.Label
$headerLabel.Text = "AdMan"
$headerLabel.AutoSize = $true
$headerLabel.Location = New-Object System.Drawing.Point(110, 10)
$headerLabel.ForeColor = "White"
$headerLabel.BackColor = "Black"
$mainForm.Controls.Add($headerLabel)

# Kicker Header
$kickerLabel = New-Object System.Windows.Forms.Label
$kickerLabel.Text = "Kick by username:"
$kickerLabel.AutoSize = $true
$kickerLabel.Location = New-Object System.Drawing.Point(20, 40)
$mainForm.Controls.Add($kickerLabel)

# Kicker Textbox
$kickerTextBoxPlaceholder = "username"
$kickerTextBox = New-Object System.Windows.Forms.TextBox
$kickerTextBox.ForeColor = "Gray"
$kickerTextBox.Text = $kickerTextBoxPlaceholder
$kickerTextBox.Location = New-Object System.Drawing.Point(20, 60)
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
$kickerButton.Text = "Kick"
$kickerButton.Location = New-Object System.Drawing.Point(150, 60)
$kickerButton.Size = New-Object System.Drawing.Size(85, 20)
$mainForm.Controls.Add($kickerButton)

# Create a horizontal line using a Label
$line = New-Object System.Windows.Forms.Label
$line.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
$line.AutoSize = $false
$line.Width = 300
$line.Height = 2
$line.Location = New-Object System.Drawing.Point(0, 85)
$mainForm.Controls.Add($line)

# Hostname Lookup Header
$hostnameLookupLabel = New-Object System.Windows.Forms.Label
$hostnameLookupLabel.Text = "Get hostname for username:"
$hostnameLookupLabel.AutoSize = $true
$hostnameLookupLabel.Location = New-Object System.Drawing.Point(20, 95)
$mainForm.Controls.Add($hostnameLookupLabel)

# Hostname Lookup Textbox
$hostnameLookupTextboxPlaceholder = "username"
$hostnameLookupTextbox = New-Object System.Windows.Forms.TextBox
$hostnameLookupTextbox.ForeColor = "Gray"
$hostnameLookupTextbox.Text = $hostnameLookupTextboxPlaceholder
$hostnameLookupTextbox.Location = New-Object System.Drawing.Point(20, 115)
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
$hostnameLookupButton.Location = New-Object System.Drawing.Point(150, 115)
$hostnameLookupButton.Size = New-Object System.Drawing.Size(85, 20)
$mainForm.Controls.Add($hostnameLookupButton)

# Create a horizontal line using a Label
$line = New-Object System.Windows.Forms.Label
$line.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
$line.AutoSize = $false
$line.Width = 300
$line.Height = 2
$line.Location = New-Object System.Drawing.Point(0, 140)
$mainForm.Controls.Add($line)

# Info Label
$infoLabel = New-Object System.Windows.Forms.Label
$infoLabel.Text = ""
$infoLabel.Size = New-Object System.Drawing.Size(240, 40)
$infoLabel.Location = New-Object System.Drawing.Point(20, 200)
$infoLabel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$mainForm.Controls.Add($infoLabel)

function userKicker {
    $infoLabel.BackColor = ""
    $infoLabel.Text = ""
    # If username is given
    if (!($kickerTextBox.Text -eq $kickerTextBoxPlaceholder)) {
        $userToKick = $kickerTextBox.Text
        $userName = $userToKick
        # Get user query
        $userQuery = (query user | findstr "$userName")
        # If can not get user query
        if (!($userQuery)) {
            $infoLabel.BackColor = "Red"
            $infoLabel.Text = "'$userName' not found"
        #If user query got
        } else {
            $infoLabel.BackColor = "Green"
            $infoLabel.Text = "'$userName' found"
            # Get hostname
            $hostName = (hostname)
            # If can not get hostname
            if (!(hostname)) {
                $infoLabel.BackColor = "Red"
                $infoLabel.Text = "Can't get hostname"
            # If hostname got
            } else {
                $infoLabel.Text = "Hostname '$hostName'"
                $sessionId = ($userQuery -split '\s+')[2]
                $infoLabel.Text = "Kicking"
                # Kicking user
                logoff $sessionId /server:$hostName
                # Get user query
                $userQuery = (query user | findstr "$userName")
                $infoLabel.Text = "Rechecking"
                # If can not get user query
                if (!($userQuery)) {
                    $infoLabel.Text = "Kicked '$userName'"
                # If user query got
                } else {
                    $infoLabel.BackColor = "Red"
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
    $infoLabel.BackColor = ""
    $infoLabel.Text = ""
    $moduleName = "PSTerminalServices"
    # Check if module is installed
    if (Get-Module -Name $moduleName -ListAvailable) {
        $infoLabel.BackColor = "Orange"
        $infoLabel.Text = "$moduleName is installed."
        #if hostname is given
        if (!($hostnameLookupTextbox -eq $hostnameLookupTextboxPlaceholder)) {
            $userName = $hostnameLookupTextbox.Text
            # Get session
            $queryResult = (Get-TSSession -UserName $userName)
            # If session can not be found
            if (!($queryResult)) {
                $infoLabel.BackColor = "Red"
                $infoLabel.Text = "'$userName' not found"
            # If session found
            } else {
                $hostName = ($queryResult.ClientName)
                # If can not recover hostname
                if (!($hostName)) {
                    $infoLabel.BackColor = "Red"
                    $infoLabel.Text = "Hostname can not be recovered"
                # If hostname is recovered
                } else {
                    $infoLabel.BackColor = "Lime"
                    $infoLabel.Text = "Hostname for '$userName': $hostName"
                }
            }
        }
    # If not then try to install
    } else {
        $infoLabel.BackColor = "Yellow"
        $infoLabel.Text = "$moduleName is not installed, trying to install..."
        Start-Process powershell "Install-Module -Name PSTerminalServices" -Verb RunAs
        $infoLabel.Text = "Check if the installation of '$moduleName' succeeded"
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
 