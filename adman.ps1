#If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
#    Write-Host "Requesting administrative privileges..."
#    Start-Process powershell "-File `"$PSCommandPath`"" -Verb RunAs
#    Exit
#}

# Hide PowerShell Console
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0)

# Config
# Form
# Form size
$formSizeWidth = 320
$formSizeHeight = 360
# Label
# Label default location
$global:labelDefaultLocationX = 20
$global:labelDefaultLocationY = 40
# Textbox
# Textbox size
$global:textboxSizeWidth = 105
$global:textboxSizeHeight = 20
# Textbox default location
$global:textBoxDefaultLocationX = 20
$global:textBoxDefaultLocationY = 60
# Button
# Button size
$global:buttonSizeWidth = 95
$global:buttonSizeHeight = 20
# Button default location
$global:buttonDefaultLocationX = 150
$global:buttonDefaultLocationY = 60

# Location increaser
$global:xIncreaser = 55
$global:count = 0

# Main Form
Add-Type -AssemblyName System.Windows.Forms
$mainForm = New-Object System.Windows.Forms.Form
$mainForm.Text = "AdMan"
$mainForm.Width = $formSizeWidth
$mainForm.Height = $formSizeHeight
$mainForm.StartPosition = "CenterScreen"

# Header Label
$headerLabel = New-Object System.Windows.Forms.Label
$headerLabel.Text = "AdMan"
$headerLabel.AutoSize = $true
$headerLabel.Location = New-Object System.Drawing.Point(110, 10)
$headerLabel.ForeColor = "White"
$headerLabel.BackColor = "Black"
$mainForm.Controls.Add($headerLabel)

function Add-Label {
    param (
        [string]$text
    )
    $header = New-Object System.Windows.Forms.Label
    $header.Text = $text
    $header.AutoSize = $true
    $x = ($global:labelDefaultLocationX + ($global:count * $global:xIncreaser))
    $y = $global:labelDefaultLocationY
    $header.Location = New-Object System.Drawing.Point($x, $y)
    return $header
}

function Add-Textbox {
    param (
        [string]$placeholder
    )
    $textbox = New-Object System.Windows.Forms.TextBox
    $textbox.ForeColor = "Gray"
    $textbox.Text = $placeholder
    $x = $global:textBoxDefaultLocationX + ($global:count * $global:xIncreaser)
    $y = $global:textBoxDefaultLocationY
    $textbox.Location = New-Object System.Drawing.Point($x, $y)
    $textbox.Size = New-Object System.Drawing.Size($global:textboxSizeWidth, $global:textboxSizeHeight)
    return $textbox
}

function TextBox-OnFocus {
    param (
        [System.Windows.Forms.TextBox]$textbox,
        [string]$placeholder
    )
    if ($textbox.Text -eq $placeholder) {
        $textbox.Text = ""
        $textbox.ForeColor = "Black"
    }
}

function TextBox-LostFocus {
    param (
        [System.Windows.Forms.TextBox]$textbox,
        [string]$placeholder
    )
    if ($textbox.Text -eq "") {
        $textbox.Text = $placeholder
        $textbox.ForeColor = "Gray"
    }
}

function TextBox-KeyPress {
    param (
        [System.Windows.Forms.TextBox]$textbox,
        [string]$key,
        [scriptblock]$action
    )
    if ($_.KeyCode -eq "Enter") {
        Write-Host "Enter key pressed"
        & $action
    }
}

function Add-Button {
    param (
        [string]$text
    )
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $text
    $x = $global:buttonDefaultLocationX + ($global:count * $global:xIncreaser)
    $y = $global:buttonDefaultLocationY
    $button.Location = New-Object System.Drawing.Point($x, $y)
    $button.Size = New-Object System.Drawing.Size($global:buttonSizeWidth, $global:buttonSizeHeight)
    return $button
}

# Kicker Header
$kickerLabel = Add-Label -text "Kick user by username:"
$mainForm.Controls.Add($kickerLabel)

# Kicker Textbox
$kickerTextBoxPlaceholder = "username"
$kickerTextBox = Add-Textbox -placeholder $kickerTextBoxPlaceholder
$mainForm.Controls.Add($kickerTextBox)
$kickerTextBox.Add_GotFocus({TextBox-OnFocus -textbox $kickerTextBox -placeholder $kickerTextBoxPlaceholder})
$kickerTextBox.Add_LostFocus({TextBox-LostFocus -textbox $kickerTextBox -placeholder $kickerTextBoxPlaceholder})

# Kicker Button
$kickerButton = New-Object System.Windows.Forms.Button
$kickerButton.Text = "Kick"
$kickerButton.Location = New-Object System.Drawing.Point(150, 60)
$kickerButton.Size = New-Object System.Drawing.Size($buttonSizeWidth, $buttonSizeHeight)
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
$hostnameLookupTextbox.Size = New-Object System.Drawing.Size($textboxSizeWidth, $textboxSizeHeight)
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
$hostnameLookupButton.Size = New-Object System.Drawing.Size($buttonSizeWidth, $buttonSizeHeight)
$mainForm.Controls.Add($hostnameLookupButton)

# Create a horizontal line using a Label
$line = New-Object System.Windows.Forms.Label
$line.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
$line.AutoSize = $false
$line.Width = 300
$line.Height = 2
$line.Location = New-Object System.Drawing.Point(0, 140)
$mainForm.Controls.Add($line)

# Get process id for port header
$hostnameLookupLabel = New-Object System.Windows.Forms.Label
$hostnameLookupLabel.Text = "Get process ID for port:"
$hostnameLookupLabel.AutoSize = $true
$hostnameLookupLabel.Location = New-Object System.Drawing.Point(20, 145)
$mainForm.Controls.Add($hostnameLookupLabel)

# Get process id for port textbox
$portProcessTextboxPlaceholder = "port"
$portProcessTextbox = New-Object System.Windows.Forms.TextBox
$portProcessTextbox.ForeColor = "Gray"
$portProcessTextbox.Text = $portProcessTextboxPlaceholder
$portProcessTextbox.Location = New-Object System.Drawing.Point(20, 165)
$portProcessTextbox.Size = New-Object System.Drawing.Size($textboxSizeWidth, $textboxSizeHeight)
$mainForm.Controls.Add($portProcessTextbox)
$portProcessTextbox.Add_GotFocus({
    if ($portProcessTextbox.Text -eq $portProcessTextboxPlaceholder) {
        $portProcessTextbox.Text = ""
        $portProcessTextbox.ForeColor = "Black"
    }
})
$portProcessTextbox.Add_LostFocus({
    if ($portProcessTextbox.Text -eq "") {
        $portProcessTextbox.Text = $portProcessTextboxPlaceholder
        $portProcessTextbox.ForeColor = "Gray"
    }
})

# Get process id for port button
$portProcessButton = New-Object System.Windows.Forms.Button
$portProcessButton.Text = "Get process ID"
$portProcessButton.Location = New-Object System.Drawing.Point(150, 165)
$portProcessButton.Size = New-Object System.Drawing.Size($buttonSizeWidth, $buttonSizeHeight)
$mainForm.Controls.Add($portProcessButton)

# Info Label
$infoLabel = New-Object System.Windows.Forms.Label
$infoLabel.Text = ""
$infoLabel.Size = New-Object System.Drawing.Size(260, 40)
$infoLabel.Location = New-Object System.Drawing.Point(20, 260)
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
$kickerTextBox.Add_KeyDown({TextBox-KeyPress -textbox $kickerTextBox -key "Enter" -action ${Function:UserKicker}})

# Kicker Button Add Click
$kickerButton.Add_Click({
    userKicker
})

# here

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

# Check process id for port

# Icon
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
$iconPath = Join-Path -Path $scriptDirectory -ChildPath "adman.ico"
if (Test-Path $iconPath) {
    $mainForm.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath)
    $notifyIcon = New-Object System.Windows.Forms.NotifyIcon
}

# Show Form
$mainForm.ShowDialog()
 