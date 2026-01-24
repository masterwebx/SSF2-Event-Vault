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

# Immediate startup log for debug
try {
    $startupLog = Join-Path $scriptDir "history.log"
    $entry = "$(Get-Date): Script started. PID=$PID, Args=$($args -join ' ')"
    Add-Content -Path $startupLog -Value $entry
} catch { }

# Argument parsing (console/GUI modes)
$guiMode = $true
$consoleLegacy = $false
$silentMode = $false
$listSort = $false
$exePath = $null
if ($args.Count -gt 0) {
    if ($args[0] -match "\.exe$") {
        $exePath = $args[0]
        if ($args.Count -gt 1) { $args = $args[1..($args.Count-1)] } else { $args = @() }
    }
    if ($args.Count -gt 0) {
        switch ($args[0]) {
            'console' { $guiMode = $false; if ($args.Count -gt 1 -and $args[1] -eq 'legacy') { $consoleLegacy = $true } }
            'listsort' { $guiMode = $false; $listSort = $true }
            'silent' { $guiMode = $false; $silentMode = $true }
        }
    }
}

# Set script/executable directories
$exeDir = $scriptDir
$flexHome = Join-Path $exeDir "..\aflex_lite"
Set-Location $exeDir

function Start-Compilation {
    param (
        $LogTextBox = $null,
        [bool]$ShowWarnings = $true,
        [bool]$UseLegacy = $false,
        [string[]]$SelectedFiles = $null
    )

    $logMessage = "$(Get-Date): Starting compilation..."
    if ($LogTextBox) { $LogTextBox.AppendText("$logMessage`r`n") } elseif (-not $silentMode) { Write-Host $logMessage }

    if (!(Test-Path "../compile/images")) { New-Item -ItemType Directory -Path "../compile/images" | Out-Null }

    # (log already opened earlier in this function)

    $sourceDirs = if ($UseLegacy) { @("legacy") } else { @("files","online") }
    $allFound = $sourceDirs | ForEach-Object { Get-ChildItem "$_\*.as" -ErrorAction SilentlyContinue } | Select-Object -ExpandProperty FullName

    # Locate ExternalEvents and source event files
    $externalEventsFile = $allFound | Where-Object { [System.IO.Path]::GetFileName($_) -ieq "ExternalEvents.as" }
    $eventSourceFiles = $allFound | Where-Object { [System.IO.Path]::GetFileNameWithoutExtension($_) -ine "ExternalEvents" }

    # Apply selection filter if provided (SelectedFiles contains basenames without extension)
    if ($SelectedFiles -and $SelectedFiles.Count -gt 0) {
        $sel = $SelectedFiles | ForEach-Object { $_ }
        $eventSourceFiles = $eventSourceFiles | Where-Object { $sel -contains [System.IO.Path]::GetFileNameWithoutExtension($_) }
    }

    # Ensure ExternalEvents.as exists (create in files/ if missing)
    if (-not $externalEventsFile) {
        $externalEventsFile = Join-Path $exeDir "files\ExternalEvents.as"
        if (-not (Test-Path $externalEventsFile)) {
            $template = "package {`n    public class ExternalEvents {`n        public static var eventList2:Array = [];`n    }`n}`n"
            Set-Content -Path $externalEventsFile -Value $template -Encoding UTF8
        }
    }

    # Final list of files to compile: selected event sources + ExternalEvents.as
    $asFiles = @()
    if ($eventSourceFiles) { $asFiles += $eventSourceFiles }
    if ($externalEventsFile) { $asFiles += $externalEventsFile }

    if ($asFiles.Count -eq 0) {
        $errorMsg = "No .as files found in source folders"
        if ($LogTextBox) { $LogTextBox.AppendText("$errorMsg`r`n") } elseif (-not $silentMode) { Write-Host $errorMsg }
        $log.WriteLine((Get-Date).ToString() + ": " + $errorMsg)
        $log.WriteLine((Get-Date).ToString() + ": Compilation complete")
        $log.Close()
        return
    }

    # Helper: parse object-like string into key/value hashtable
    function Parse-ObjectString($objStr) {
        $props = @{}
            $matches = [regex]::Matches($objStr, '"([^\"]+)":\s*(.+?)(?=,\s*"[^\"]+":|$)')
        foreach ($m in $matches) {
            $key = $m.Groups[1].Value
            $value = $m.Groups[2].Value.Trim()
            if ($key -ne "classAPI") { $value = $value.Trim('"') }
            $props[$key] = $value
        }
        return $props
    }

    # Build event info list from chosen event source files
    $allEventInfos = @()
    foreach ($f in $eventSourceFiles) {
        try {
            $fileContent = Get-Content $f -Raw -ErrorAction SilentlyContinue
            if ($fileContent -match 'eventinfo\s*:\s*Array\s*=\s*\[([^\]]*)\]') {
                $infoStr = $matches[1]
                $infoObj = $infoStr -replace '^\s*{\s*', '' -replace '\s*}\s*$', ''
                $eventInfo = Parse-ObjectString $infoObj
                if ($eventInfo -and $eventInfo.Count -gt 0) { $allEventInfos += $eventInfo }
            }
        } catch { }
    }

    # Update ExternalEvents.as only with the selected events
    if ($externalEventsFile -and $allEventInfos.Count -gt 0) {
        $content = Get-Content $externalEventsFile -Raw
        $eventStrs = $allEventInfos | ForEach-Object {
            $lines = @()
            $keys = $_.Keys | Sort-Object
            foreach ($key in $keys) {
                $value = $_[$key]
                if ($key -eq "classAPI") { $lines += "`"classAPI`":$value" } else { $lines += "`"$key`": `"$value`"" }
            }
            return "         {`n" + ($lines -join ",`n") + "`n         }"
        }
        $eventBlock = $eventStrs -join ",`n"
        if ($content -match '(\beventList2\s*=\s*\[)[^\]]*(\];)') {
            $content = $content -replace '(\beventList2\s*=\s*\[)[^\]]*(\];)', "`$1`n$eventBlock`n         `$2"
        } else {
            # Fallback: append an eventList2 block
            $content += "`n    public static var eventList2:Array = [`n$eventBlock`n    ];`n"
        }
        Set-Content -Path $externalEventsFile -Value $content -Encoding UTF8
        $msg = "Updated ExternalEvents.as with $($allEventInfos.Count) events from source files"
        if ($LogTextBox) { $LogTextBox.AppendText("$msg`r`n") } elseif (-not $silentMode) { Write-Host $msg }
    }

    # Continue with determining main file and running mxmlc (rest of original function continues)
    if (!(Test-Path "../compile/images")) {
        New-Item -ItemType Directory -Path "../compile/images"
        $msg = "Created ../compile/images directory"
        if ($LogTextBox) { $LogTextBox.AppendText("$msg`r`n") } elseif (-not $silentMode) { Write-Host $msg }
    }

    $logPath = "history.log"
    $log = [System.IO.StreamWriter]::new($logPath, $true)
    $log.WriteLine((Get-Date).ToString() + ": Starting compilation")

    $sourceDirs = if ($UseLegacy) { @("legacy") } else { @("files","online") }
    $asFiles = $sourceDirs | ForEach-Object { Get-ChildItem "$_\*.as" -ErrorAction SilentlyContinue } | Select-Object -ExpandProperty FullName
    if ($asFiles.Count -eq 0) {
        $errorMsg = "No .as files found in source folders"
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
                # Determine main file and prepare mxmlc arguments
                $mainFile = $asFiles | Where-Object { [System.IO.Path]::GetFileName($_) -ieq "ExternalEvents.as" } | Select-Object -First 1
                if (-not $mainFile) { $asFiles = $asFiles | Sort-Object; $mainFile = $asFiles[0] }
                $mainName = [System.IO.Path]::GetFileName($mainFile)
                if ($mainFile -match "\\online\\") { $mainFolder = "online" } elseif ($mainFile -match "\\files\\") { $mainFolder = "files" } else { $mainFolder = "." }
                $relativeMain = Join-Path $mainFolder $mainName

                $includeClasses = ""
                $linkageNames = @()

                $mxmlc = Join-Path $flexHome "bin\mxmlc.bat"
                $warningsFlag = if ($ShowWarnings) { "true" } else { "false" }
                $sourcePathArg = if ($UseLegacy) { "legacy,../compile/api" } else { "files,online,../compile/api" }
                $arguments = "-warnings=$warningsFlag -strict=true -source-path=$sourcePathArg -library-path=../aflex_lite/frameworks/libs/player/32.0/playerglobal.swc $includeClasses `"$relativeMain`" -output=../custom_events.swf"

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

# Prepare GUI event list and saved selections (used by Sort UI)
# Build `$events` so the GUI has the same parsed list as `listsort`
$selectedFile = Join-Path $exeDir "selected_events.txt"
$savedSelected = @()
if (Test-Path $selectedFile) {
    try { 
        $savedSelected = Get-Content -Path $selectedFile -ErrorAction SilentlyContinue | ForEach-Object { $_.Trim() } 
        try { Add-Content -Path (Join-Path $exeDir "history.log") -Value "$(Get-Date): Loaded saved selections count=$($savedSelected.Count): $([string]::Join(',', $savedSelected))" } catch { }
    } catch { $savedSelected = @() }
}

$events = @()
$sourceDirs = @("files","online")
foreach ($d in $sourceDirs) {
    $dirPath = Join-Path $exeDir $d
    try {
        $files = Get-ChildItem -Path $dirPath -Filter *.as -File -ErrorAction SilentlyContinue
    } catch { $files = @() }
    foreach ($f in $files) {
        if ($f.Name -ieq "ExternalEvents.as") { continue }
        try {
            $content = Get-Content -Path $f.FullName -Raw -ErrorAction SilentlyContinue
            $name = ""
            $desc = ""
            $patternName = @'
(?i)["']?name["']?\s*:\s*["']([^"']+)["']
'@
            $patternDesc = @'
(?i)["']?description["']?\s*:\s*["']([^"']+)["']
'@
            $m = [regex]::Match($content, $patternName)
            if ($m.Success) { $name = $m.Groups[1].Value.Trim() }
            $m2 = [regex]::Match($content, $patternDesc)
            if ($m2.Success) { $desc = $m2.Groups[1].Value.Trim() }
            if (-not $name) { $name = [System.IO.Path]::GetFileNameWithoutExtension($f.Name) }
            $events += [PSCustomObject]@{ Name = $name; Description = $desc; File = [System.IO.Path]::GetFileNameWithoutExtension($f.Name) }
        } catch { }
    }
}

# Debug log: GUI init and events count
try {
    $logPath = Join-Path $exeDir "history.log"
    $msg = "$(Get-Date): GUI init - loaded savedSelected count=$($savedSelected.Count)"
    Add-Content -Path $logPath -Value $msg
    $msg2 = "$(Get-Date): GUI init - built events count=$($events.Count)"
    Add-Content -Path $logPath -Value $msg2
} catch { }

# Create the GUI
if ($guiMode) {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    Add-Type -Name Window -Namespace ConsoleApp -MemberDefinition '
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    '
    try {
        $consolePtr = [ConsoleApp.Window]::GetConsoleWindow()
        [ConsoleApp.Window]::ShowWindow($consolePtr, 0)  # 0 = SW_HIDE
    } catch { }
}

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

# Sort Panel (hidden by default)
$sortPanel = New-Object System.Windows.Forms.Panel
$sortPanel.Location = New-Object System.Drawing.Point(10, 10)
$sortPanel.Size = New-Object System.Drawing.Size(560, 400)
$sortPanel.Visible = $false

$checkedListBox = New-Object System.Windows.Forms.CheckedListBox
$checkedListBox.Location = New-Object System.Drawing.Point(0, 0)
$checkedListBox.Size = New-Object System.Drawing.Size(560, 220)
$checkedListBox.CheckOnClick = $true
$sortPanel.Controls.Add($checkedListBox)

$descriptionBox = New-Object System.Windows.Forms.TextBox
$descriptionBox.Location = New-Object System.Drawing.Point(0, 225)
$descriptionBox.Size = New-Object System.Drawing.Size(560, 170)
$descriptionBox.Multiline = $true
$descriptionBox.ReadOnly = $true
$sortPanel.Controls.Add($descriptionBox)

$form.Controls.Add($sortPanel)

# Sort Button
$sortButton = New-Object System.Windows.Forms.Button
$sortButton.Text = "Sort"
$sortButton.Location = New-Object System.Drawing.Point(480, 420)
$sortButton.Size = New-Object System.Drawing.Size(80, 30)
$form.Controls.Add($sortButton)

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
        if ($sortPanel.Visible) {
            # Gather selected files from the checked list
            $selected = @()
            for ($i = 0; $i -lt $checkedListBox.Items.Count; $i++) {
                if ($checkedListBox.GetItemChecked($i)) {
                    $selected += $events[$i].File
                }
            }
            # Persist selection
            $selected | Out-File -FilePath $selectedFile -Encoding utf8
            $logTextBox.AppendText("Compiling selected events: $($selected.Count)`r`n")

            # Temporarily move unselected event .as files out of source folders so mxmlc only sees selected ones
            $moved = @()
            $tempDir = Join-Path $exeDir "disabled_events"
            if (!(Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir | Out-Null }
            try {
                $allEventFiles = @()
                $allEventFiles += (Get-ChildItem (Join-Path $exeDir "files") -Filter *.as -File -ErrorAction SilentlyContinue)
                $allEventFiles += (Get-ChildItem (Join-Path $exeDir "online") -Filter *.as -File -ErrorAction SilentlyContinue)
                foreach ($f in $allEventFiles) {
                    if ([System.IO.Path]::GetFileName($f) -ieq "ExternalEvents.as") { continue }
                    $base = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
                    if ($base -notin $selected) {
                        $dest = Join-Path $tempDir $f.Name
                        Move-Item -Path $f.FullName -Destination $dest -Force
                        $moved += @{ Src = $f.FullName; Dest = $dest }
                    }
                }

                $success = Start-Compilation -LogTextBox $logTextBox -ShowWarnings $warningsCheckBox.Checked -UseLegacy $false -SelectedFiles $selected
            } finally {
                # Move files back
                foreach ($rec in $moved) {
                    try { Move-Item -Path $rec.Dest -Destination $rec.Src -Force } catch { }
                }
                # Clean up temp dir if empty
                try { if ((Get-ChildItem $tempDir -Force -ErrorAction SilentlyContinue).Count -eq 0) { Remove-Item $tempDir -Force } } catch { }
            }
                # Return to log view
                $sortPanel.Visible = $false
                $logTextBox.Visible = $true
                try { $sortButton.Text = "Sort" } catch { }
            try { $sortButton.Text = "Sort" } catch { }
        } else {
            $success = Start-Compilation -LogTextBox $logTextBox -ShowWarnings $warningsCheckBox.Checked -UseLegacy $legacyCheckBox.Checked
        }
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

# Sort button handler: toggle selection UI
$sortButton.Add_Click({
    if ($sortPanel.Visible) {
        # Close the sort panel and return to log view
        # Save current checked selections
        try {
            $selectedToSave = @()
            for ($j = 0; $j -lt $checkedListBox.Items.Count; $j++) {
                if ($checkedListBox.GetItemChecked($j)) { $selectedToSave += $events[$j].File }
            }
            $selectedToSave | Out-File -FilePath $selectedFile -Encoding utf8
            $savedSelected = $selectedToSave
            try { Add-Content -Path (Join-Path $exeDir "history.log") -Value "$(Get-Date): Saved selections count=$($selectedToSave.Count): $([string]::Join(',', $selectedToSave))" } catch { }
        } catch { 
            try { Add-Content -Path (Join-Path $exeDir "history.log") -Value "$(Get-Date): Failed to save selections: $($_.Exception.Message)" } catch { }
        }

        $sortPanel.Visible = $false
        $logTextBox.Visible = $true
        $sortButton.Text = "Sort"
        $descriptionBox.Text = ""
    } else {
        # Open the sort panel and populate list
        $logTextBox.Visible = $false
        $sortPanel.Visible = $true
        # Reload saved selections from disk to reflect external changes or saves from other instances
        try {
            if (Test-Path $selectedFile) { $savedSelected = Get-Content -Path $selectedFile -ErrorAction SilentlyContinue | ForEach-Object { $_.Trim() } } else { $savedSelected = @() }
            try { Add-Content -Path (Join-Path $exeDir "history.log") -Value "$(Get-Date): Reloaded saved selections count=$($savedSelected.Count): $([string]::Join(',', $savedSelected))" } catch { }
        } catch { $savedSelected = @() }

        $checkedListBox.Items.Clear()
        for ($i = 0; $i -lt $events.Count; $i++) {
            $item = $events[$i]
            $checkedListBox.Items.Add($item.Name)
            if ($item.File -in $savedSelected) { $checkedListBox.SetItemChecked($i, $true) }
        }
        try { Add-Content -Path (Join-Path $exeDir "history.log") -Value "$(Get-Date): Populated Sort list with $($events.Count) events; checked count=$((0..($checkedListBox.Items.Count-1) | Where-Object { $checkedListBox.GetItemChecked($_) }).Count)" } catch { }
        $sortButton.Text = "Close"
    }
})

# Show description when selection changes
$checkedListBox.Add_SelectedIndexChanged({
    $idx = $checkedListBox.SelectedIndex
    if ($idx -ge 0 -and $idx -lt $events.Count) {
        $descriptionBox.Text = $events[$idx].Description
    }
})

# Show description on hover as well
$checkedListBox.Add_MouseMove({ param($s,$e)
    try {
        $pt = New-Object System.Drawing.Point($e.X, $e.Y)
        $idx = $checkedListBox.IndexFromPoint($pt)
        if ($idx -ge 0 -and $idx -lt $events.Count) {
            $descriptionBox.Text = $events[$idx].Description
        }
    } catch { }
})

# Show initial message
$logTextBox.AppendText("SSF2 Event Compiler ready.`r`n")
$logTextBox.AppendText("Click 'Compile' to start compilation.`r`n`r`n")

# Show the form
$form.ShowDialog()