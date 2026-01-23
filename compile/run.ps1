# SSF2 Event Compiler (GUI and Console modes)
# Single instance check - terminate older instances
$scriptName = "SSF2 Event Compiler"

# Get all running instances of this script/process
$existingProcesses = Get-Process | Where-Object { 
    $_.ProcessName -eq "powershell" -and 
    $_.MainWindowTitle -eq $scriptName -and 
    $_.Id -ne $PID 
}

# Terminate older instances
foreach ($proc in $existingProcesses) {
    try {
        $proc.Kill()
        $proc.WaitForExit(5000)  # Wait up to 5 seconds
    } catch {
        # Ignore errors when terminating processes
    }
}

# Set the working directory to the base directory (parent of script's directory)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$baseDir = Split-Path -Parent $scriptDir
Set-Location $baseDir

# Set the window title for this instance
$host.UI.RawUI.WindowTitle = $scriptName

# Check for command line arguments
$guiMode = $true
$consoleLegacy = $false
$silentMode = $false
$exePath = $null

if ($args.Count -gt 0) {
    # Check if first argument is a file path (exe path from launcher)
    if ($args[0] -match "\.exe$") {
        $exePath = $args[0]
        $args = $args[1..($args.Count-1)]  # Remove exe path from args
    }
    
    if ($args.Count -gt 0) {
        if ($args[0] -eq "console") {
            $guiMode = $false
            if ($args.Count -gt 1 -and $args[1] -eq "legacy") {
                $consoleLegacy = $true
            }
        } elseif ($args[0] -eq "silent") {
            $guiMode = $false
            $silentMode = $true
        }
    }
}

if ($guiMode) {
    # Load Windows Forms assembly
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    # Hide console window in GUI mode
    Add-Type -Name Window -Namespace ConsoleApp -MemberDefinition '
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    '
    $consolePtr = [ConsoleApp.Window]::GetConsoleWindow()
    [ConsoleApp.Window]::ShowWindow($consolePtr, 0)  # 0 = SW_HIDE
}

$exeDir = $PSScriptRoot
$flexHome = Join-Path $exeDir "../aflex_lite"
Set-Location $exeDir

# Function to perform compilation (legacy mode)
function Start-Compilation {
    param (
        $LogTextBox = $null,
        [bool]$ShowWarnings = $true,
        [bool]$UseLegacy = $false
    )

    $logMessage = "$(Get-Date): Starting compilation..."
    if ($LogTextBox) {
        $LogTextBox.AppendText("$logMessage`r`n")
    } elseif (-not $silentMode) {
        Write-Host $logMessage
    }

    # Directory setup
    if (!(Test-Path "../compile/images")) {
        New-Item -ItemType Directory -Path "../compile/images"
        $msg = "Created ../compile/images directory"
        if ($LogTextBox) { $LogTextBox.AppendText("$msg`r`n") } elseif (-not $silentMode) { Write-Host $msg }
    }

    $logPath = "history.log"
    $log = [System.IO.StreamWriter]::new($logPath, $true)
    $log.WriteLine((Get-Date).ToString() + ": Starting compilation")

    $sourceDir = if ($UseLegacy) { "legacy" } else { "files" }
    $asFiles = Get-ChildItem "$sourceDir\*.as" | Select-Object -ExpandProperty FullName
    if ($asFiles.Count -eq 0) {
        $errorMsg = "No .as files found in $sourceDir folder"
        if ($LogTextBox) { $LogTextBox.AppendText("$errorMsg`r`n") } elseif (-not $silentMode) { Write-Host $errorMsg }
        $log.WriteLine((Get-Date).ToString() + ": " + $errorMsg)
        $log.WriteLine((Get-Date).ToString() + ": Compilation complete")
        $log.Close()
        return
    } else {
        # Function to parse object string
        function Parse-ObjectString($objStr) {
            $props = @{}
            $matches = [regex]::Matches($objStr, '"([^"]+)":\s*(.+?)(?=,\s*"[^"]+":|$)')
            foreach ($m in $matches) {
                $key = $m.Groups[1].Value
                $value = $m.Groups[2].Value.Trim()
                if ($key -ne "classAPI") {
                    $value = $value.Trim('"')
                }
                $props[$key] = $value
            }
            return $props
        }

        # Process event files and update ExternalEvents.as
        $externalEventsFile = $asFiles | Where-Object { [System.IO.Path]::GetFileName($_) -eq "ExternalEvents.as" }
        if (!$externalEventsFile) {
            $externalEventsFile = Join-Path (Join-Path $exeDir $sourceDir) "ExternalEvents.as"
            $content = "package {`n"
            $content += "    public class ExternalEvents {`n"
            $content += "        public static var eventList2:Array = [];`n"
            $content += "    }`n"
            $content += "}`n"
            Set-Content $externalEventsFile $content
            $asFiles += $externalEventsFile
        }
        $content = Get-Content $externalEventsFile -Raw
        # Note: We now always rebuild eventList2 from source files, ignoring existing content

        $allEventInfos = @()
        foreach ($f in $asFiles) {
            $filename = [System.IO.Path]::GetFileNameWithoutExtension($f)
            if ($filename -eq "ExternalEvents") { continue }
            $fileContent = Get-Content $f -Raw

            # Parse eventinfo if present
            $eventInfo = $null
            if ($fileContent -match 'eventinfo\s*:\s*Array\s*=\s*\[([^\]]*)\]') {
                $infoStr = $matches[1]
                $infoObj = $infoStr -replace '^\s*{\s*', '' -replace '\s*}\s*$', ''
                $eventInfo = Parse-ObjectString $infoObj
            }

            if ($eventInfo -and $eventInfo.Count -gt 0) {
                $allEventInfos += $eventInfo
            }

            # Verify and update class and function names
            $updatedContent = $fileContent
            # Find public class
            if ($fileContent -match 'public class (\w+)') {
                $className = $matches[1]
                if ($className -ne $filename) {
                    $updatedContent = $updatedContent -replace "public class $className", "public class $filename"
                }
            }
            # Find constructor (function that calls super(api))
            if ($fileContent -match 'public function (\w+)\([^)]*\)\s*\{[^}]*super\(api\)[^}]*\}') {
                $funcName = $matches[1]
                if ($funcName -ne $filename) {
                    $updatedContent = $updatedContent -replace "public function $funcName\(", "public function $filename("
                }
            }
            if ($updatedContent -ne $fileContent) {
                Set-Content $f $updatedContent
                $msg = "Updated class/function names in $filename.as"
                if ($LogTextBox) { $LogTextBox.AppendText("$msg`r`n") } elseif (-not $silentMode) { Write-Host $msg }
            }
        }

        # Update ExternalEvents.as
        if ($allEventInfos.Count -gt 0 -and $externalEventsFile) {
            $content = Get-Content $externalEventsFile -Raw
            $eventStrs = $allEventInfos | ForEach-Object {
                $lines = @()
                $keys = $_.Keys | Sort-Object
                foreach ($key in $keys) {
                    $value = $_[$key]
                    if ($key -eq "classAPI") {
                        $lines += "`"classAPI`":$value"
                    } else {
                        $lines += "`"$key`": `"$value`""
                    }
                }
                "         {`n" + ($lines -join ",`n") + "`n         }"
            }
            $eventBlock = $eventStrs -join ",`n"
            $content = $content -replace '(\beventList2\s*=\s*\[)[^\]]*(\];)', "`$1`n$eventBlock`n         `$2"
            Set-Content $externalEventsFile $content
            $msg = "Updated ExternalEvents.as with $($allEventInfos.Count) events from source files"
            if ($LogTextBox) { $LogTextBox.AppendText("$msg`r`n") } elseif (-not $silentMode) { Write-Host $msg }
        }

        $mainFile = $null
        foreach ($f in $asFiles) {
            if ([System.IO.Path]::GetFileName($f) -eq "ExternalEvents.as") {
                $mainFile = $f
                break
            }
        }
        if ($null -eq $mainFile) {
            $asFiles = $asFiles | Sort-Object
            $mainFile = $asFiles[0]
        }
        $relativeMain = "$sourceDir\" + [System.IO.Path]::GetFileName($mainFile)
        $outputFile = "custom_events.swf"
        $msg = "Found $($asFiles.Count) .as files"
        if ($LogTextBox) { $LogTextBox.AppendText("$msg`r`n") } elseif (-not $silentMode) { Write-Host $msg }
        $msg = "Main file: $([System.IO.Path]::GetFileName($mainFile))"
        if ($LogTextBox) { $LogTextBox.AppendText("$msg`r`n") } elseif (-not $silentMode) { Write-Host $msg }
        $log.WriteLine((Get-Date).ToString() + ": Found " + $asFiles.Count + " .as files")
        $log.WriteLine((Get-Date).ToString() + ": Main file: " + [System.IO.Path]::GetFileName($mainFile))

        # Build include-file arguments for images
        $includeArgs = ""
        $linkageNames = @()
        if (Test-Path "../compile/images") {
            $imageFiles = Get-ChildItem "../compile/images/*.*" | Where-Object { $_.Extension -match '\.(png|jpg|jpeg|gif|bmp|svg)' }
            $msg = "Found $($imageFiles.Count) images to embed"
            if ($LogTextBox) { $LogTextBox.AppendText("$msg`r`n") } elseif (-not $silentMode) { Write-Host $msg }
            if ($imageFiles.Count -gt 0) {
                $linkageNames = @()
                foreach ($img in $imageFiles) {
                    $linkageName = "img_" + [System.IO.Path]::GetFileNameWithoutExtension($img.Name).Replace(" ", "_").Replace("-", "_")
                    $linkageNames += $linkageName
                    $msg = "Creating MovieClip class for $($img.Name) as $linkageName"
                    if ($LogTextBox) { $LogTextBox.AppendText("$msg`r`n") } elseif (-not $silentMode) { Write-Host $msg }
                    $classContent = "package {`n"
                    $classContent += "    [Embed(source=`"../images/$($img.Name)`")]`n"
                    $classContent += "    public class $linkageName {`n"
                    $classContent += "    }`n"
                    $classContent += "}`n"
                    $classPath = "$sourceDir\$linkageName.as"
                    $classContent | Out-File -FilePath $classPath -Encoding UTF8
                }
                $msg = "Created $($imageFiles.Count) MovieClip classes for images"
                if ($LogTextBox) { $LogTextBox.AppendText("$msg`r`n") } elseif (-not $silentMode) { Write-Host $msg }
                $log.WriteLine((Get-Date).ToString() + ": Created " + $imageFiles.Count + " MovieClip classes for images")
            }
        } else {
            $msg = "No images folder found"
            if ($LogTextBox) { $LogTextBox.AppendText("$msg`r`n") } elseif (-not $silentMode) { Write-Host $msg }
        }

        $includeClasses = ""
        if ($linkageNames) {
            $includeClasses = "-includes=" + ($linkageNames -join ",")
        }

        $mxmlc = Join-Path $flexHome "bin\mxmlc.bat"
        $warningsFlag = if ($ShowWarnings) { "true" } else { "false" }
        $arguments = "-warnings=$warningsFlag -strict=true -source-path=$sourceDir,../compile/api -library-path=../aflex_lite/frameworks/libs/player/32.0/playerglobal.swc $includeClasses ""$relativeMain"" -output=../custom_events.swf"

        # Validate mxmlc exists
        if (!(Test-Path $mxmlc)) {
            $errorMsg = "mxmlc.bat not found at: $mxmlc"
            if ($LogTextBox) { $LogTextBox.AppendText("$errorMsg`r`n") } elseif (-not $silentMode) { Write-Host $errorMsg }
            $log.WriteLine((Get-Date).ToString() + ": " + $errorMsg)
            $log.WriteLine((Get-Date).ToString() + ": Compilation complete")
            $log.Close()
            return
        }

        $msg = "Running mxmlc compilation..."
        if ($LogTextBox) { $LogTextBox.AppendText("$msg`r`n") } elseif (-not $silentMode) { Write-Host $msg }
        $msg = "Command: $mxmlc $arguments"
        if ($LogTextBox) { $LogTextBox.AppendText("$msg`r`n") } elseif (-not $silentMode) { Write-Host $msg }

        # Run process with optimized output handling
        try {
            $process = New-Object System.Diagnostics.Process
            $process.StartInfo.FileName = $mxmlc
            $process.StartInfo.Arguments = $arguments
            $process.StartInfo.WorkingDirectory = $exeDir
            $process.StartInfo.UseShellExecute = $false
            $process.StartInfo.RedirectStandardOutput = $true
            $process.StartInfo.RedirectStandardError = $true
            $process.StartInfo.CreateNoWindow = $true

            $process.Start() | Out-Null

            # For GUI mode with many files, use buffered output to prevent freezing
            $useBufferedOutput = $LogTextBox -and ($UseLegacy -or $asFiles.Count -gt 10)
            
            if ($useBufferedOutput) {
                $msg = "Compiling... (buffered output mode for performance)"
                if ($LogTextBox) { $LogTextBox.AppendText("$msg`r`n") }
                [System.Windows.Forms.Application]::DoEvents()  # Allow GUI to update
                
                # Wait for process to complete with timeout
                $timeout = 300000  # 5 minutes timeout
                $startTime = Get-Date
                $lastUpdate = Get-Date
                
                while (!$process.HasExited -and ((Get-Date) - $startTime).TotalMilliseconds -lt $timeout) {
                    [System.Windows.Forms.Application]::DoEvents()  # Keep GUI responsive
                    
                    # Check for cancellation
                    if ($script:cancelCompilation) {
                        $process.Kill()
                        $msg = "Compilation cancelled by user."
                        if ($LogTextBox) { $LogTextBox.AppendText("$msg`r`n") } elseif (-not $silentMode) { Write-Host $msg }
                        $log.WriteLine((Get-Date).ToString() + ": " + $msg)
                        $log.Close()
                        return $false
                    }
                    
                    # Update status every 2 seconds
                    if (((Get-Date) - $lastUpdate).TotalSeconds -ge 2) {
                        $elapsed = [math]::Round(((Get-Date) - $startTime).TotalSeconds)
                        $statusMsg = "Compiling... (${elapsed}s elapsed)"
                        if ($LogTextBox) { 
                            $LogTextBox.Lines[$LogTextBox.Lines.Length - 1] = $statusMsg
                            $LogTextBox.Refresh()
                        }
                        $lastUpdate = Get-Date
                    }
                    
                    Start-Sleep -Milliseconds 100
                }
                
                if (!$process.HasExited) {
                    $process.Kill()
                    $msg = "Compilation timed out after 5 minutes and was terminated."
                    if ($LogTextBox) { $LogTextBox.AppendText("$msg`r`n") } elseif (-not $silentMode) { Write-Host $msg }
                    $log.WriteLine((Get-Date).ToString() + ": " + $msg)
                    $log.Close()
                    return $false
                }
                
                # Read all output at once
                $output = $process.StandardOutput.ReadToEnd()
                $errorOutput = $process.StandardError.ReadToEnd()
                
                # Process and limit warnings
                $outputLines = $output -split "`r`n"
                $errorLines = $errorOutput -split "`r`n"
                
                $warningCount = 0
                $maxWarnings = 5
                $warningsSuppressed = 0
                
                # Show output
                foreach ($line in $outputLines) {
                    if ($line.Trim()) {
                        if ($LogTextBox) { $LogTextBox.AppendText("$line`r`n") } elseif (-not $silentMode) { Write-Host $line }
                    }
                }
                
                # Process errors with warning limiting
                foreach ($line in $errorLines) {
                    if ($line.Trim()) {
                        if ($line -match "Error:") {
                            $errorMsg = "ERROR: $line"
                            if ($LogTextBox) { $LogTextBox.AppendText("$errorMsg`r`n") } elseif (-not $silentMode) { Write-Host $errorMsg }
                        } elseif ($line -match "Warning:" -and $warningCount -lt $maxWarnings) {
                            $warningCount++
                            $errorMsg = "ERROR: $line"
                            if ($LogTextBox) { $LogTextBox.AppendText("$errorMsg`r`n") } elseif (-not $silentMode) { Write-Host $errorMsg }
                            
                            # Auto-disable warnings if too many (20+ warnings)
                            if ($warningCount -ge 20 -and $LogTextBox) {
                                $warningsCheckBox.Checked = $false
                                $LogTextBox.AppendText("WARNING: Too many warnings detected. Warning display disabled to prevent GUI freezing.`r`n")
                                $LogTextBox.AppendText("Uncheck 'Show Warnings' to re-enable or check it to show warnings again.`r`n")
                            }
                        } elseif ($line -match "Warning:") {
                            $warningsSuppressed++
                        } else {
                            $errorMsg = "ERROR: $line"
                            if ($LogTextBox) { $LogTextBox.AppendText("$errorMsg`r`n") } elseif (-not $silentMode) { Write-Host $errorMsg }
                        }
                    }
                }
            } else {
                # Real-time output for small compilations
                $errorDetected = $false
                $warningCount = 0
                $maxWarnings = 10
                $warningsSuppressed = 0
                
                while (!$process.HasExited -and !$errorDetected) {
                    # Check for cancellation
                    if ($script:cancelCompilation) {
                        $process.Kill()
                        $msg = "Compilation cancelled by user."
                        if ($LogTextBox) { $LogTextBox.AppendText("$msg`r`n") } elseif (-not $silentMode) { Write-Host $msg }
                        $log.WriteLine((Get-Date).ToString() + ": " + $msg)
                        $log.Close()
                        return $false
                    }
                    
                    # Read available output
                    while ($process.StandardOutput.Peek() -gt -1) {
                        $line = $process.StandardOutput.ReadLine()
                        if ($LogTextBox) { $LogTextBox.AppendText("$line`r`n") } elseif (-not $silentMode) { Write-Host $line }
                        
                        # Check for compilation errors and terminate immediately
                        if ($line -match "Error:") {
                            $errorDetected = $true
                            break
                        }
                    }

                    # Read available error output with warning limiting
                    while ($process.StandardError.Peek() -gt -1) {
                        $line = $process.StandardError.ReadLine()
                        
                        # Check for compilation errors and terminate immediately
                        if ($line -match "Error:") {
                            $errorDetected = $true
                            $errorMsg = "ERROR: $line"
                            if ($LogTextBox) { $LogTextBox.AppendText("$errorMsg`r`n") } else { Write-Host $errorMsg }
                            break
                        }
                        
                        # Limit warnings to prevent GUI freezing
                        if ($line -match "Warning:") {
                            if ($warningCount -ge $maxWarnings) {
                                $warningsSuppressed++
                                
                                # Auto-disable warnings if too many (20+ warnings)
                                if ($warningCount -ge 20 -and $LogTextBox -and $warningsCheckBox.Checked) {
                                    $warningsCheckBox.Checked = $false
                                    $LogTextBox.AppendText("WARNING: Too many warnings detected. Warning display disabled to prevent GUI freezing.`r`n")
                                    $LogTextBox.AppendText("Uncheck 'Show Warnings' to re-enable or check it to show warnings again.`r`n")
                                }
                            } else {
                                $warningCount++
                                $errorMsg = "ERROR: $line"
                                if ($LogTextBox) { $LogTextBox.AppendText("$errorMsg`r`n") } elseif (-not $silentMode) { Write-Host $errorMsg }
                            }
                        } else {
                            # Show non-warning errors immediately
                            $errorMsg = "ERROR: $line"
                            if ($LogTextBox) { $LogTextBox.AppendText("$errorMsg`r`n") } elseif (-not $silentMode) { Write-Host $errorMsg }
                        }
                    }

                    Start-Sleep -Milliseconds 50
                }
            }

            # If error was detected in real-time mode, kill the process immediately
            if ($errorDetected -and !$process.HasExited) {
                $process.Kill()
                $msg = "Compilation terminated due to error detection. See error above."
                if ($LogTextBox) { $LogTextBox.AppendText("$msg`r`n") } elseif (-not $silentMode) { Write-Host $msg }
                $log.WriteLine((Get-Date).ToString() + ": " + $msg)
                
                # Read any remaining error output
                Start-Sleep -Milliseconds 100  # Give process time to output remaining errors
                while ($process.StandardOutput.Peek() -gt -1) {
                    $line = $process.StandardOutput.ReadLine()
                    if ($LogTextBox) { $LogTextBox.AppendText("$line`r`n") } elseif (-not $silentMode) { Write-Host $line }
                }
                while ($process.StandardError.Peek() -gt -1) {
                    $line = $process.StandardError.ReadLine()
                    $errorMsg = "ERROR: $line"
                    if ($LogTextBox) { $LogTextBox.AppendText("$errorMsg`r`n") } else { Write-Host $errorMsg }
                }
                
                $log.Close()
                return $false
            }

            # Read any remaining output after process exits (for buffered mode)
            if (!$useBufferedOutput) {
                while ($process.StandardOutput.Peek() -gt -1) {
                    $line = $process.StandardOutput.ReadLine()
                    if ($LogTextBox) { $LogTextBox.AppendText("$line`r`n") } else { Write-Host $line }
                }

                while ($process.StandardError.Peek() -gt -1) {
                    $line = $process.StandardError.ReadLine()
                    $errorMsg = "ERROR: $line"
                    if ($LogTextBox) { $LogTextBox.AppendText("$errorMsg`r`n") } elseif (-not $silentMode) { Write-Host $errorMsg }
                }
            }

            $exitCode = $process.ExitCode
            $msg = "Compilation complete. Exit code: $exitCode"
            if ($LogTextBox) { $LogTextBox.AppendText("$msg`r`n") } elseif (-not $silentMode) { Write-Host $msg }
            $log.WriteLine((Get-Date).ToString() + ": Exit code: " + $exitCode)

            # Show warning suppression summary
            if ($warningsSuppressed -gt 0) {
                $msg = "... and $warningsSuppressed more warnings (suppressed to prevent GUI freezing)"
                if ($LogTextBox) { $LogTextBox.AppendText("$msg`r`n") } elseif (-not $silentMode) { Write-Host $msg }
            }

            # Check for compilation errors and exit immediately if failed
            if ($exitCode -ne 0) {
                $msg = "Compilation failed with exit code $exitCode. Check the error messages above."
                if ($LogTextBox) { $LogTextBox.AppendText("$msg`r`n") } elseif (-not $silentMode) { Write-Host $msg }
                $log.WriteLine((Get-Date).ToString() + ": Compilation failed")
                $log.Close()
                return $false
            }
        } catch {
            $errorMsg = "Failed to run compilation process: $($_.Exception.Message)"
            if ($LogTextBox) { $LogTextBox.AppendText("$errorMsg`r`n") } else { Write-Host $errorMsg }
            $log.WriteLine((Get-Date).ToString() + ": " + $errorMsg)
            $log.Close()
            return $false
        } finally {
            # Ensure process is disposed of properly
            if ($process -and !$process.HasExited) {
                try {
                    $process.Kill()
                    $process.WaitForExit(1000)  # Wait up to 1 second for clean exit
                } catch {
                    # Ignore errors in cleanup
                }
            }
            if ($process) {
                $process.Dispose()
            }
        }
    }
    $log.WriteLine((Get-Date).ToString() + ": Compilation complete")
    $log.Close()
    return $true
}

# Run in console mode if requested
if (!$guiMode) {
    if (-not $silentMode) {
        Write-Host "SSF2 Event Compiler - Console Mode"
        if ($consoleLegacy) {
            Write-Host "Using Legacy Mode"
        }
        Write-Host "=================================="
    }
    $success = Start-Compilation -ShowWarnings $true -UseLegacy $consoleLegacy
    if ($success) {
        if (-not $silentMode) {
            Write-Host "Compilation done! Check history.log"
        }
        # Ensure clean exit without waiting for input
        [Environment]::Exit(0)
    } else {
        [Environment]::Exit(1)
    }
}

# Create the GUI
$form = New-Object System.Windows.Forms.Form
$form.Text = "SSF2 Event Compiler"
$form.Size = New-Object System.Drawing.Size(600, 500)
$form.StartPosition = "CenterScreen"

# Set the form icon from the executable
try {
    $iconLoaded = $false
    
    # Try multiple methods to load the icon
    if ($exePath -and (Test-Path $exePath)) {
        try {
            $form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($exePath)
            $iconLoaded = $true
        } catch {
            # Ignore
        }
    }
    
    if (-not $iconLoaded) {
        # Try loading icon.ico with basic method
        $iconFile = Join-Path $flexHome "icon.ico"
        if (Test-Path $iconFile) {
            try {
                $form.Icon = New-Object System.Drawing.Icon($iconFile)
                $iconLoaded = $true
            } catch {
                # If all else fails, try to use a default icon or skip
                Write-Host "Could not load custom icon, using default"
            }
        }
    }
} catch {
    # Ignore icon errors - will use default
}

# Handle form closing to ensure proper cleanup
$form.Add_FormClosing({
    param($sender, $e)
    
    # Restore console window
    try {
        $consolePtr = [ConsoleApp.Window]::GetConsoleWindow()
        [ConsoleApp.Window]::ShowWindow($consolePtr, 5)  # 5 = SW_SHOW
    } catch {
        # Ignore console restore errors
    }
    
    # Force cleanup of any running processes
    try {
        $runningProcesses = Get-Process | Where-Object { $_.ProcessName -like "*mxmlc*" -or $_.ProcessName -like "*java*" }
        foreach ($proc in $runningProcesses) {
            try {
                $proc.Kill()
                $proc.WaitForExit(1000)
            } catch {
                # Ignore cleanup errors
            }
        }
    } catch {
        # Ignore cleanup errors
    }
})

# Log TextBox
$logTextBox = New-Object System.Windows.Forms.TextBox
$logTextBox.Location = New-Object System.Drawing.Point(10, 10)
$logTextBox.Size = New-Object System.Drawing.Size(560, 400)
$logTextBox.Multiline = $true
$logTextBox.ScrollBars = "Vertical"
$logTextBox.ReadOnly = $true
$form.Controls.Add($logTextBox)

# Compile Button
$compileButton = New-Object System.Windows.Forms.Button
$compileButton.Text = "Compile"
$compileButton.Location = New-Object System.Drawing.Point(10, 420)
$compileButton.Size = New-Object System.Drawing.Size(100, 30)
$form.Controls.Add($compileButton)

# Warnings Checkbox
$warningsCheckBox = New-Object System.Windows.Forms.CheckBox
$warningsCheckBox.Text = "Show Warnings"
$warningsCheckBox.Location = New-Object System.Drawing.Point(120, 425)
$warningsCheckBox.Size = New-Object System.Drawing.Size(120, 20)
$warningsCheckBox.Checked = $false
$form.Controls.Add($warningsCheckBox)

# Legacy Checkbox
$legacyCheckBox = New-Object System.Windows.Forms.CheckBox
$legacyCheckBox.Text = "Legacy Mode"
$legacyCheckBox.Location = New-Object System.Drawing.Point(250, 425)
$legacyCheckBox.Size = New-Object System.Drawing.Size(100, 20)
$legacyCheckBox.Checked = $false
$form.Controls.Add($legacyCheckBox)

# Cancel Button
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Text = "Cancel"
$cancelButton.Location = New-Object System.Drawing.Point(360, 420)
$cancelButton.Size = New-Object System.Drawing.Size(100, 30)
$cancelButton.Enabled = $false
$form.Controls.Add($cancelButton)

# Global variable to track if compilation should be cancelled
$script:cancelCompilation = $false

# Event handler for compile button
$compileButton.Add_Click({
    $compileButton.Enabled = $false
    $cancelButton.Enabled = $true
    $script:cancelCompilation = $false
    $logTextBox.Clear()

    try {
        $success = Start-Compilation -LogTextBox $logTextBox -ShowWarnings $warningsCheckBox.Checked -UseLegacy $legacyCheckBox.Checked
        if ($success) {
            $logTextBox.AppendText("Compilation completed successfully!`r`n")
        }
        # Uncheck legacy checkbox after compilation
        $legacyCheckBox.Checked = $false
    } catch {
        $logTextBox.AppendText("ERROR: $($_.Exception.Message)`r`n")
    } finally {
        $compileButton.Enabled = $true
        $cancelButton.Enabled = $false
        $script:cancelCompilation = $false
    }
})

# Event handler for cancel button
$cancelButton.Add_Click({
    $script:cancelCompilation = $true
    $logTextBox.AppendText("Cancelling compilation...`r`n")
    $cancelButton.Enabled = $false
})

# Show initial message
$logTextBox.AppendText("SSF2 Event Compiler ready.`r`n")
$logTextBox.AppendText("Click 'Compile' to start compilation.`r`n`r`n")

# Show the form
$form.ShowDialog()