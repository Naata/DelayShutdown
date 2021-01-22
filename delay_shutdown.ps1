Add-Type -AssemblyName System.Windows.Forms

[int] $global:seconds = 3600;

#region functions
function NewLeftToRightPanel() {
    $panel = New-Object System.Windows.Forms.FlowLayoutPanel
    $panel.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight
    $panel.AutoSize = $true
    return $panel
}

function OnDatePickerChange($s, [System.EventArgs] $e) {
    [datetime] $v = $datepicker.Value.Date + $timepicker.Value.TimeOfDay
    [timespan] $diff = $v - $(Get-Date)
    UpdateSecondsAndButton($diff)
}

function OnNumericInputChange($s, [System.EventArgs] $e) {
    $timespanInputError.Hide()
    try {
        [timespan] $ts = [TimeSpan]::ParseExact($timespanInput.Text, 'c', $null)
        UpdateSecondsAndButton($ts)
    } catch [System.Exception] {
        Write-Error $_
        $timespanInputError.Show()
    }    
}

function UpdateSecondsAndButton([timespan] $v) {
    if ($v -eq $null -or $v.TotalSeconds -lt 0) {
        return
    }
    $global:seconds = $v.TotalSeconds
    [string]$str = [timespan]::FromSeconds($global:seconds).ToString('c')
    $scheduleShutdown.Text = "Schedule shutdown in $str"
}

function ScheduleShutdown() {
    shutdown.exe /s /f /t "$seconds"
}

function CancelShutdown() {
    shutdown.exe /a
}
#endregion

#region datepicker
$datepickerLabel = New-Object System.Windows.Forms.Label
$datepickerLabel.Text = 'On specific time:'
$datepickerLabel.AutoSize = $true

$datepicker = New-Object System.Windows.Forms.DateTimePicker
$datepicker.Format = [System.Windows.Forms.DateTimePickerFormat]::Short
$datepicker.MaximumSize = '105,100'
$datepicker.Add_ValueChanged( { OnDatePickerChange })

$timepicker = New-Object System.Windows.Forms.DateTimePicker
$timepicker.Format = [System.Windows.Forms.DateTimePickerFormat]::Time
$timepicker.ShowUpDown = $true
$timepicker.MaximumSize = '90,100'
$timepicker.Add_ValueChanged( { OnDatePickerChange })

$datePickerPanel = NewLeftToRightPanel
$datePickerPanel.Controls.AddRange(@($datepickerLabel, $datepicker, $timepicker))
#endregion

#region numericinput
$timespanInputLabel = New-Object System.Windows.Forms.Label
$timespanInputLabel.Text = 'After seconds:'
$timespanInputLabel.AutoSize = $true

$timespanInput = New-Object System.Windows.Forms.TextBox
$timespanInput.Text = "1:00:00"
$timespanInput.Add_TextChanged( { OnNumericInputChange })

$timespanInputError = New-Object System.Windows.Forms.Label
$timespanInputError.Text = 'Please use format d.hh:mm:ss'
$timespanInputError.AutoSize = $true
$timespanInputError.ForeColor = [System.Drawing.Color]::Red
$timespanInputError.Hide()

$timespanInputPanel = NewLeftToRightPanel
$timespanInputPanel.Controls.AddRange(@($timespanInputLabel, $timespanInput, $timespanInputError))
#endregion

#region buttons
$scheduleShutdown = New-Object System.Windows.Forms.Button
$scheduleShutdown.AutoSize = $true
$scheduleShutdown.Add_Click( { ScheduleShutdown })

$cancelShutdown = New-Object System.Windows.Forms.Button
$cancelShutdown.Text = 'Cancel shutdown'
$cancelShutdown.AutoSize = $true
$cancelShutdown.Add_Click( { CancelShutdown })

$buttonsPanel = NewLeftToRightPanel
$buttonsPanel.Controls.AddRange($($cancelShutdown, $scheduleShutdown))
#endregion

#region mainpanel
$mainPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$mainPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$mainPanel.AutoSize = $true
$mainPanel.Controls.AddRange(@($datePickerPanel, $timespanInputPanel, $buttonsPanel))
#endregion

$window = New-Object System.Windows.Forms.Form
$window.Size = '0,0'
$window.Text = 'Delay shutdown'
$window.AutoSize = $true
$window.Controls.Add($mainPanel)

OnNumericInputChange
[void]$window.ShowDialog()