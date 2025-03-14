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
# Horizontal Line
# Horizontal line size
$global:lineSizeWidth = 320
$global:lineSizeHeight = 2
# Horizontal line default location
$global:lineDefaultLocationX = 0
$global:lineDefaultLocationY = 85
# Info label
# Info label size
$infoLabelSizeWidth = $formSizeWidth - 60
$infoLabelSizeHeight = 40
# Info label default location
$infoLabelDefaultLocationX = 20
$infoLabelDefaultLocationY = $formSizeHeight - 100
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
$headerLabel.Text = " AdMan "
$headerLabel.AutoSize = $true
$headerLabel.Location = New-Object System.Drawing.Point(130, 10)
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
    $x = $global:labelDefaultLocationX
    $y = $global:labelDefaultLocationY + ($global:count * $global:xIncreaser)
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
    $x = $global:textBoxDefaultLocationX
    $y = $global:textBoxDefaultLocationY + ($global:count * $global:xIncreaser)
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
    $x = $global:buttonDefaultLocationX
    $y = $global:buttonDefaultLocationY + ($global:count * $global:xIncreaser)
    $button.Location = New-Object System.Drawing.Point($x, $y)
    $button.Size = New-Object System.Drawing.Size($global:buttonSizeWidth, $global:buttonSizeHeight)
    return $button
}

function Add-Horline {
    $line = New-Object System.Windows.Forms.Label
    $line.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
    $line.AutoSize = $false
    $line.Width = $global:lineSizeWidth
    $line.Height = $global:lineSizeHeight
    $x = $global:lineDefaultLocationX
    $y = $global:lineDefaultLocationY + ($global:count * $global:xIncreaser)
    $line.Location = New-Object System.Drawing.Point($x, $y)
    return $line
}

function Count-Increase {
    param (
        [int]$increment
    )
    $global:count = $global:count + $increment
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
$kickerButton = Add-Button -text "Kick user"
$mainForm.Controls.Add($kickerButton)

# Create a horizontal line using a Label
$line = Add-Horline
$mainForm.Controls.Add($line)

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
# Enter key press for kicker textbox
$kickerTextBox.Add_KeyDown({TextBox-KeyPress -textbox $kickerTextBox -key "Enter" -action ${Function:UserKicker}})
# Kicker Button Add Click
$kickerButton.Add_Click({
    userKicker
})

Count-Increase -increment 1

# Hostname Lookup Header
$hostnameLookupLabel = Add-Label -text "Get hostname for username:"
$mainForm.Controls.Add($hostnameLookupLabel)

# Hostname Lookup Textbox
$hostnameLookupTextboxPlaceholder = "username"
$hostnameLookupTextbox = Add-Textbox -placeholder $hostnameLookupTextboxPlaceholder
$mainForm.Controls.Add($hostnameLookupTextbox)
$hostnameLookupTextbox.Add_GotFocus({TextBox-OnFocus -textbox $hostnameLookupTextbox -placeholder $hostnameLookupTextboxPlaceholder})
$hostnameLookupTextbox.Add_LostFocus({TextBox-LostFocus -textbox $hostnameLookupTextbox -placeholder $hostnameLookupTextboxPlaceholder})

# Hostname Lookup Button
$hostnameLookupButton = Add-Button -text "Get hostname"
$mainForm.Controls.Add($hostnameLookupButton)

# Create a horizontal line using a Label
$line = Add-Horline
$mainForm.Controls.Add($line)

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
# Hostname Lookup Textbox Enter
$hostnameLookupTextbox.Add_KeyDown({TextBox-KeyPress -textbox $hostnameLookupTextbox -key "Enter" -action ${Function:HostnameLookup}})
# Hostname Lookup Button Add Click
$hostnameLookupButton.Add_Click({
    hostnameLookup
})

Count-Increase -increment 1

# Get process id for port header
$hostnameLookupLabel = Add-Label -text "Get process ID for port:"
$mainForm.Controls.Add($hostnameLookupLabel)

# Get process id for port textbox
$portProcessTextboxPlaceholder = "port"
$portProcessTextbox = Add-Textbox -placeholder $portProcessTextboxPlaceholder
$mainForm.Controls.Add($portProcessTextbox)
$portProcessTextbox.Add_GotFocus({TextBox-OnFocus -textbox $portProcessTextbox -placeholder $portProcessTextboxPlaceholder})
$portProcessTextbox.Add_LostFocus({TextBox-LostFocus -textbox $portProcessTextbox -placeholder $portProcessTextboxPlaceholder})

# Get process id for port button
$portProcessButton = Add-Button -text "Get process ID"
$mainForm.Controls.Add($portProcessButton)

# Info Label
$infoLabel = New-Object System.Windows.Forms.Label
$infoLabel.Text = ""
$infoLabel.Size = New-Object System.Drawing.Size($infoLabelSizeWidth, $infoLabelSizeHeight)
$infoLabel.Location = New-Object System.Drawing.Point($infoLabelDefaultLocationX, $infoLabelDefaultLocationY)
$infoLabel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$mainForm.Controls.Add($infoLabel)

# Check process id for port
function get_process_id_for_port{
    $infoLabel.BackColor = ""
    $infoLabel.Text = ""
    $port = $portProcessTextbox.Text
    if (!($port)) {
        $infoLabel.BackColor = "Red"
        $infoLabel.Text = "Port is not given"
    } else {
        if ($port.Length -lt 4) {
            $infoLabel.BackColor = "Red"
            $infoLabel.Text = "Port is not valid"
            return
        } else {
            if ($port -notlike ":*") {
                $port = ":" + $port
            }
            $result = (netstat -ano | findstr $port)
            if (!($result)) {
                $infoLabel.BackColor = "Yellow"
                $infoLabel.Text = "Port '$port' is not found"
            } else {
                $infoLabel.BackColor = "Yellow"
                $infoLabel.Text = "Port '$port' is found"
                $processId = ($result -split '\s+')[5]
                $infoLabel.Text = "Process ID for port '$port': '$processId'"
            }
        }
    }
}
$portProcessTextbox.Add_KeyDown({TextBox-KeyPress -textbox $portProcessTextbox -key "Enter" -action ${Function:get_process_id_for_port}})
$portProcessButton.Add_Click({
    get_process_id_for_port
})

# Icon
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
$iconPath = Join-Path -Path $scriptDirectory -ChildPath "adman.ico"
if (Test-Path $iconPath) {
    $mainForm.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath)
}

# Show Form
$mainForm.ShowDialog()
 