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

# Sync online files from GitHub into ./online and ./files — returns number of downloaded files
function Sync-OnlineFiles {
    param(
        [string]$ApiUrl = "https://api.github.com/repos/masterwebx/SSF2-Event-Vault/contents/compile/online",
        $LogTextBox = $null
    )

    $folders = @("online", "files")
    foreach ($folder in $folders) {
        if (!(Test-Path $folder)) { New-Item -ItemType Directory -Path $folder | Out-Null }
    }

    $logPath = Join-Path $exeDir "history.log"
    $downloaded = 0
    try {
        $headers = @{ 'User-Agent' = 'SSF2-Event-Vault-Sync' }
        $items = Invoke-RestMethod -Uri $ApiUrl -Headers $headers -ErrorAction Stop
        foreach ($it in $items | Where-Object { $_.type -eq 'file' }) {
            foreach ($folder in $folders) {
                $outPath = Join-Path $folder $it.name
                # If file exists and size matches GitHub's size, skip
                try {
                    $shouldDownload = $true
                    if ((Test-Path $outPath) -and ($it.size -ne $null)) {
                        try {
                            $existingSize = (Get-Item $outPath).Length
                            if ($existingSize -eq [int]$it.size) {
                                $shouldDownload = $false
                                $skipMsg = "Skipped $($it.name) in $folder (unchanged)"
                                if ($LogTextBox) { try { $LogTextBox.AppendText("$skipMsg`r`n") } catch { } }
                                elseif ($global:logTextBox) { try { $global:logTextBox.AppendText("$skipMsg`r`n") } catch { } }
                                else { Write-Host $skipMsg }
                                try { Add-Content -Path $logPath -Value "$(Get-Date): $skipMsg" } catch { }
                            }
                        } catch { }
                    }

                    if ($shouldDownload) {
                        Invoke-WebRequest -Uri $it.download_url -OutFile $outPath -UseBasicParsing -ErrorAction Stop
                        $downloaded++
                        $msg = "Downloaded $($it.name) to $folder"
                        if ($LogTextBox) {
                            try { $LogTextBox.AppendText("$msg`r`n") } catch { }
                        } elseif ($global:logTextBox) {
                            try { $global:logTextBox.AppendText("$msg`r`n") } catch { }
                        } else {
                            Write-Host $msg
                        }
                        try { Add-Content -Path $logPath -Value "$(Get-Date): $msg" } catch { }
                    }
                } catch {
                    $errMsg = "Failed to download $($it.name) to $folder" + ": $($_.Exception.Message)"
                    if ($LogTextBox) {
                        try { $LogTextBox.AppendText("$errMsg`r`n") } catch { }
                    } elseif ($global:logTextBox) {
                        try { $global:logTextBox.AppendText("$errMsg`r`n") } catch { }
                    } else {
                        Write-Host $errMsg
                    }
                    try { Add-Content -Path $logPath -Value "$(Get-Date): $errMsg" } catch { }
                }
            }
        }
        return $downloaded
    } catch {
        # If GitHub API fails, log and return 0
        $err = $_.Exception.Message
        $failMsg = "Sync-OnlineFiles failed: $err"
        if ($LogTextBox) {
            try { $LogTextBox.AppendText("$failMsg`r`n") } catch { }
        } elseif ($global:logTextBox) {
            try { $global:logTextBox.AppendText("$failMsg`r`n") } catch { }
        } else {
            Write-Host $failMsg
        }
        try { Add-Content -Path $logPath -Value "$(Get-Date): $failMsg" } catch { }
        return 0
    }
}

$syncedFiles = 0
# Only sync now in console mode (GUI will sync after log textbox exists)
if (-not $guiMode) {
    $syncedFiles = Sync-OnlineFiles
    # Report sync result to console and history.log
    try {
        if ($syncedFiles -eq 0) {
            $msg = "No files added from online"
        } elseif ($syncedFiles -eq 1) {
            $msg = "1 file added from online"
        } else {
            $msg = "$syncedFiles files added from online"
        }
        try { Write-Host $msg } catch { }
        try { Add-Content -Path (Join-Path $exeDir "history.log") -Value "$(Get-Date): $msg" } catch { }
    } catch { }
}

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
        function Parse-ObjectString($objStr) {
            $props = @{}
            $matches = [regex]::Matches($objStr, '"([^"]+)":\s*"([^"]*)"(?=,)')
            foreach ($m in $matches) {
                $key = $m.Groups[1].Value
                $value = $m.Groups[2].Value
                $props[$key] = $value
            }
            # Handle classAPI separately (no quotes)
            if ($objStr -match '"classAPI":\s*([^,]+)') {
                $props["classAPI"] = $matches[1].Trim()
            }
            return $props
        }

        # Process event files and update ExternalEvents.as
                # Determine main file and prepare mxmlc arguments
                $mainFile = $asFiles | Where-Object { [System.IO.Path]::GetFileName($_) -ieq "ExternalEvents.as" } | Select-Object -First 1
                if (-not $mainFile) { $asFiles = $asFiles | Sort-Object; $mainFile = $asFiles[0] }
                $mainName = [System.IO.Path]::GetFileName($mainFile)
                if ($mainFile -match "\\online\\") { $mainFolder = "online" } elseif ($mainFile -match "\\files\\") { $mainFolder = "files" } elseif ($mainFile -match "\\legacy\\") { $mainFolder = "legacy" } else { $mainFolder = "." }
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
                            # Update last line in WPF TextBox
                            $lines = $LogTextBox.Text -split "`r`n"
                            if ($lines.Length -gt 0) {
                                $lines[$lines.Length - 1] = $statusMsg
                                $LogTextBox.Text = $lines -join "`r`n"
                            } else {
                                $LogTextBox.Text = $statusMsg
                            }
                            $LogTextBox.ScrollToEnd()
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
                                $warningsCheckBox.IsChecked = $false
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
                                if ($warningCount -ge 20 -and $LogTextBox -and $warningsCheckBox.IsChecked) {
                                    $warningsCheckBox.IsChecked = $false
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

# Helper: parse object-like string into key/value hashtable
function Parse-ObjectString($objStr) {
    $props = @{}
    $matches = [regex]::Matches($objStr, '"([^"]+)":\s*"([^"]*)"(?=,)')
    foreach ($m in $matches) {
        $key = $m.Groups[1].Value
        $value = $m.Groups[2].Value
        $props[$key] = $value
    }
    # Handle classAPI separately (no quotes)
    if ($objStr -match '"classAPI":\s*([^,]+)') {
        $props["classAPI"] = $matches[1].Trim()
    }
    return $props
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
            $fileContent = Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue
            if ($fileContent -match 'eventinfo\s*:\s*Array\s*=\s*\[([^\]]*)\]') {
                $infoStr = $matches[1]
                $infoObj = $infoStr -replace '^\s*{\s*', '' -replace '\s*}\s*$', ''
                $eventInfo = Parse-ObjectString $infoObj
                if ($eventInfo) {
                    $event = [PSCustomObject]@{
                        Name = $eventInfo.name
                        Description = $eventInfo.description
                        File = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
                    }
                    $events += $event
                }
            }
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
    Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Xaml, System.Windows.Forms
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

$window = New-Object System.Windows.Window
$window.Title = "SSF2 Event Compiler"
$window.Width = 900
$window.Height = 550
$window.WindowStartupLocation = "CenterScreen"

$grid = New-Object System.Windows.Controls.Grid
$window.Content = $grid

# Define columns
$column1 = New-Object System.Windows.Controls.ColumnDefinition
$column1.Width = "1*"
$grid.ColumnDefinitions.Add($column1)
$column2 = New-Object System.Windows.Controls.ColumnDefinition
$column2.Width = "1*"
$grid.ColumnDefinitions.Add($column2)

# Define rows
$row1 = New-Object System.Windows.Controls.RowDefinition
$row1.Height = "1*"
$grid.RowDefinitions.Add($row1)
$row2 = New-Object System.Windows.Controls.RowDefinition
$row2.Height = "Auto"
$grid.RowDefinitions.Add($row2)

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

# Handle window closing to ensure proper cleanup
$window.Add_Closing({
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
$logTextBox = New-Object System.Windows.Controls.TextBox
[System.Windows.Controls.Grid]::SetColumn($logTextBox, 0)
[System.Windows.Controls.Grid]::SetRow($logTextBox, 0)
$logTextBox.Width = 430
$logTextBox.Height = 440
$logTextBox.IsReadOnly = $true
$logTextBox.TextWrapping = "Wrap"
$logTextBox.VerticalScrollBarVisibility = "Visible"
$logTextBox.Margin = "10,10,10,10"
$grid.Children.Add($logTextBox)

# If running GUI, sync online files and report into the GUI log
if ($guiMode) {
    try {
        $syncedFiles = Sync-OnlineFiles -LogTextBox $logTextBox
    } catch { $syncedFiles = 0 }
    try {
        if ($syncedFiles -eq 0) { $msg = "No files added from online" }
        elseif ($syncedFiles -eq 1) { $msg = "1 file added from online" }
        else { $msg = "$syncedFiles files added from online" }
        try { $logTextBox.AppendText("$msg`r`n") } catch { }
        try { Add-Content -Path (Join-Path $exeDir "history.log") -Value "$(Get-Date): $msg" } catch { }
    } catch { }
}

# Sort Panel (always visible)
$sortPanel = New-Object System.Windows.Controls.Canvas
[System.Windows.Controls.Grid]::SetColumn($sortPanel, 1)
[System.Windows.Controls.Grid]::SetRow($sortPanel, 0)
$sortPanel.Width = 430
$sortPanel.Height = 440
$sortPanel.Margin = "10,10,10,10"
$grid.Children.Add($sortPanel)

# Button Panel
$buttonPanel = New-Object System.Windows.Controls.Canvas
[System.Windows.Controls.Grid]::SetColumn($buttonPanel, 0)
[System.Windows.Controls.Grid]::SetRow($buttonPanel, 1)
[System.Windows.Controls.Grid]::SetColumnSpan($buttonPanel, 2)
$buttonPanel.Height = 50
$buttonPanel.Margin = "10,0,10,10"
$grid.Children.Add($buttonPanel)

$scrollViewer = New-Object System.Windows.Controls.ScrollViewer
[System.Windows.Controls.Canvas]::SetLeft($scrollViewer, 0)
[System.Windows.Controls.Canvas]::SetTop($scrollViewer, 0)
$scrollViewer.Width = 430
$scrollViewer.Height = 220
$scrollViewer.VerticalScrollBarVisibility = "Auto"
$scrollViewer.HorizontalScrollBarVisibility = "Disabled"
$sortPanel.Children.Add($scrollViewer)

$stackPanel = New-Object System.Windows.Controls.StackPanel
$scrollViewer.Content = $stackPanel

$checkBoxes = @()

$checkBoxes = @()

# Populate the sort list
for ($i = 0; $i -lt $events.Count; $i++) {
    $item = $events[$i]
    $checkBox = New-Object System.Windows.Controls.CheckBox
    $checkBox.Content = $item.Name
    $checkBox.Tag = $item.File
    if ($item.File -in $savedSelected) { $checkBox.IsChecked = $true }
    $stackPanel.Children.Add($checkBox)
    $checkBoxes += $checkBox
    # Add hover to show description
    $checkBox.Add_MouseEnter({
        $sender = $args[0]
        $index = $checkBoxes.IndexOf($sender)
        if ($index -ge 0) {
            $descriptionBox.Text = $events[$index].Description
        }
    })
}
try { Add-Content -Path (Join-Path $exeDir "history.log") -Value "$(Get-Date): Populated Sort list with $($events.Count) events; checked count=$($checkBoxes | Where-Object { $_.IsChecked } | Measure-Object).Count" } catch { }

# Add event handlers to checkboxes
for ($i = 0; $i -lt $checkBoxes.Count; $i++) {
    $cb = $checkBoxes[$i]
    $eventIndex = $i  # capture
    $cb.Add_Checked({
        $descriptionBox.Text = $events[$eventIndex].Description
        $checkedCount = ($checkBoxes | Where-Object { $_.IsChecked } | Measure-Object).Count
        if ($checkedCount -eq $checkBoxes.Count) {
            $selectAllButton.Content = "Deselect All"
        } else {
            $selectAllButton.Content = "Select All"
        }
    })
    $cb.Add_Unchecked({
        $checkedCount = ($checkBoxes | Where-Object { $_.IsChecked } | Measure-Object).Count
        if ($checkedCount -eq $checkBoxes.Count) {
            $selectAllButton.Content = "Deselect All"
        } else {
            $selectAllButton.Content = "Select All"
        }
    })
}

$descriptionBox = New-Object System.Windows.Controls.TextBox
[System.Windows.Controls.Canvas]::SetLeft($descriptionBox, 0)
[System.Windows.Controls.Canvas]::SetTop($descriptionBox, 225)
$descriptionBox.Width = 430
$descriptionBox.Height = 170
$descriptionBox.IsReadOnly = $true
$descriptionBox.TextWrapping = "Wrap"
$descriptionBox.VerticalScrollBarVisibility = "Visible"
$sortPanel.Children.Add($descriptionBox)

# Select All Button
$selectAllButton = New-Object System.Windows.Controls.Button
$selectAllButton.Content = "Select All"
[System.Windows.Controls.Canvas]::SetLeft($selectAllButton, 0)
[System.Windows.Controls.Canvas]::SetTop($selectAllButton, 400)
$selectAllButton.Width = 100
$selectAllButton.Height = 30
$sortPanel.Children.Add($selectAllButton)

$selectAllButton.Add_MouseEnter({ param($sender, $e) $sender.Background = [System.Windows.Media.Brushes]::Yellow })
$selectAllButton.Add_MouseLeave({ param($sender, $e) $sender.Background = [System.Windows.Media.Brushes]::LightGray })

# Set initial button text based on current selection
$checkedCount = ($checkBoxes | Where-Object { $_.IsChecked } | Measure-Object).Count
if ($checkedCount -eq $checkBoxes.Count) {
    $selectAllButton.Content = "Deselect All"
} else {
    $selectAllButton.Content = "Select All"
}

$selectAllButton.Add_Click({
    if ($selectAllButton.Content -eq "Select All") {
        foreach ($cb in $checkBoxes) { $cb.IsChecked = $true }
        $selectAllButton.Content = "Deselect All"
    } else {
        foreach ($cb in $checkBoxes) { $cb.IsChecked = $false }
        $selectAllButton.Content = "Select All"
    }
})

# Compile Button
$compileButton = New-Object System.Windows.Controls.Button
$compileButton.Content = "Compile"
[System.Windows.Controls.Canvas]::SetLeft($compileButton, 10)
[System.Windows.Controls.Canvas]::SetTop($compileButton, 10)
$compileButton.Width = 100
$compileButton.Height = 30
$buttonPanel.Children.Add($compileButton)

$compileButton.Add_MouseEnter({ param($sender, $e) $sender.Background = [System.Windows.Media.Brushes]::Yellow })
$compileButton.Add_MouseLeave({ param($sender, $e) $sender.Background = [System.Windows.Media.Brushes]::LightGray })

# Warnings Toggle
$warningsCheckBox = New-Object System.Windows.Controls.CheckBox
$warningsCheckBox.Content = "Show Warnings"
[System.Windows.Controls.Canvas]::SetLeft($warningsCheckBox, 120)
[System.Windows.Controls.Canvas]::SetTop($warningsCheckBox, 15)
$warningsCheckBox.Width = 120
$buttonPanel.Children.Add($warningsCheckBox)
$warningsCheckBox.Height = 20
$warningsCheckBox.IsChecked = $false

# Legacy Toggle
$legacyCheckBox = New-Object System.Windows.Controls.CheckBox
$legacyCheckBox.Content = "Legacy Mode"
[System.Windows.Controls.Canvas]::SetLeft($legacyCheckBox, 250)
[System.Windows.Controls.Canvas]::SetTop($legacyCheckBox, 15)
$legacyCheckBox.Width = 100
$legacyCheckBox.Height = 20
$legacyCheckBox.IsChecked = $false
$buttonPanel.Children.Add($legacyCheckBox)

# Apply initial theme
#Set-Theme $theme

# Cancel Button
$cancelButton = New-Object System.Windows.Controls.Button
$cancelButton.Content = "Cancel"
[System.Windows.Controls.Canvas]::SetLeft($cancelButton, 360)
[System.Windows.Controls.Canvas]::SetTop($cancelButton, 10)
$cancelButton.Width = 100
$cancelButton.Height = 30
$cancelButton.IsEnabled = $false
$buttonPanel.Children.Add($cancelButton)

$cancelButton.Add_MouseEnter({ param($sender, $e) $sender.Background = [System.Windows.Media.Brushes]::Yellow })
$cancelButton.Add_MouseLeave({ param($sender, $e) $sender.Background = [System.Windows.Media.Brushes]::LightGray })

# Sync Online Button
$syncButton = New-Object System.Windows.Controls.Button
$syncButton.Content = "Download new events"
[System.Windows.Controls.Canvas]::SetLeft($syncButton, 470)
[System.Windows.Controls.Canvas]::SetTop($syncButton, 10)
$syncButton.Width = 120
$syncButton.Height = 30
$buttonPanel.Children.Add($syncButton)

$syncButton.Add_MouseEnter({ param($sender, $e) $sender.Background = [System.Windows.Media.Brushes]::Yellow })
$syncButton.Add_MouseLeave({ param($sender, $e) $sender.Background = [System.Windows.Media.Brushes]::LightGray })

# Global variable to track if compilation should be cancelled
$script:cancelCompilation = $false

# Event handler for compile button
$compileButton.Add_Click({
    $compileButton.IsEnabled = $false
    $cancelButton.IsEnabled = $true
    $script:cancelCompilation = $false
    $logTextBox.Clear()

    try {
        if ($sortPanel.Visibility -eq "Visible") {
            # Gather selected files from the checked list
            $selected = @()
            foreach ($cb in $checkBoxes) {
                if ($cb.IsChecked) {
                    $selected += $cb.Tag
                }
            }
            # Persist selection
            $selected | Out-File -FilePath $selectedFile -Encoding utf8
            if ([bool]$legacyCheckBox.IsChecked) {
                $logTextBox.AppendText("Compiling from legacy folder`r`n")
            } else {
                $logTextBox.AppendText("Compiling selected events: $($selected.Count)`r`n")
            }

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

                $success = Start-Compilation -LogTextBox $logTextBox -ShowWarnings ([bool]$warningsCheckBox.IsChecked) -UseLegacy ([bool]$legacyCheckBox.IsChecked) -SelectedFiles $selected
            } finally {
                # Move files back
                foreach ($rec in $moved) {
                    try { Move-Item -Path $rec.Dest -Destination $rec.Src -Force } catch { }
                }
                # Clean up temp dir if empty
                try { if ((Get-ChildItem $tempDir -Force -ErrorAction SilentlyContinue).Count -eq 0) { Remove-Item $tempDir -Force } } catch { }
            }
                # Return to log view
                #$sortPanel.Visibility = "Hidden"
                #$logTextBox.Visibility = "Visible"
                #try { $sortButton.Content = "Sort" } catch { }
            #try { $sortButton.Content = "Sort" } catch { }
        } else {
            $success = Start-Compilation -LogTextBox $logTextBox -ShowWarnings ([bool]$warningsCheckBox.IsChecked) -UseLegacy ([bool]$legacyCheckBox.IsChecked)
        }
        if ($success) {
            $logTextBox.AppendText("Compilation completed successfully!`r`n")
        }
        # Uncheck legacy toggle after compilation
        $legacyCheckBox.IsChecked = $false
    } catch {
        $logTextBox.AppendText("ERROR: $($_.Exception.Message)`r`n")
    } finally {
        $compileButton.IsEnabled = $true
        $cancelButton.IsEnabled = $false
        $script:cancelCompilation = $false
    }
})

# Event handler for cancel button
$cancelButton.Add_Click({
    $script:cancelCompilation = $true
    $logTextBox.AppendText("Cancelling compilation...`r`n")
    $cancelButton.IsEnabled = $false
})

# Event handler for sync online button
$syncButton.Add_Click({
    $syncButton.IsEnabled = $false
    try {
        $synced = Sync-OnlineFiles -LogTextBox $logTextBox
        if ($synced -eq 0) { $msg = "No files added from online" }
        elseif ($synced -eq 1) { $msg = "1 file added from online" }
        else { $msg = "$synced files added from online" }
        $logTextBox.AppendText("$msg`r`n")
        try { Add-Content -Path (Join-Path $exeDir "history.log") -Value "$(Get-Date): $msg" } catch { }
    } catch {
        $logTextBox.AppendText("Sync failed: $($_.Exception.Message)`r`n")
    } finally {
        $syncButton.IsEnabled = $true
    }
})

# Show initial message
$logTextBox.AppendText("SSF2 Event Compiler ready.`r`n")
$logTextBox.AppendText("Click 'Compile' to start compilation.`r`n`r`n")

# Set light theme
$window.Background = [System.Windows.Media.Brushes]::LightGray
$window.Foreground = [System.Windows.Media.Brushes]::Black
$logTextBox.Background = [System.Windows.Media.Brushes]::LightGray
$logTextBox.Foreground = [System.Windows.Media.Brushes]::Black
$descriptionBox.Background = [System.Windows.Media.Brushes]::LightGray
$descriptionBox.Foreground = [System.Windows.Media.Brushes]::Black
$scrollViewer.Background = [System.Windows.Media.Brushes]::LightGray
$scrollViewer.Foreground = [System.Windows.Media.Brushes]::Black
$compileButton.Background = [System.Windows.Media.Brushes]::LightGray
$compileButton.Foreground = [System.Windows.Media.Brushes]::Black
$cancelButton.Background = [System.Windows.Media.Brushes]::LightGray
$cancelButton.Foreground = [System.Windows.Media.Brushes]::Black
$syncButton.Background = [System.Windows.Media.Brushes]::LightGray
$syncButton.Foreground = [System.Windows.Media.Brushes]::Black
$selectAllButton.Background = [System.Windows.Media.Brushes]::LightGray
$selectAllButton.Foreground = [System.Windows.Media.Brushes]::Black
$warningsCheckBox.Background = [System.Windows.Media.Brushes]::LightGray
$warningsCheckBox.Foreground = [System.Windows.Media.Brushes]::Black
$legacyCheckBox.Background = [System.Windows.Media.Brushes]::LightGray
$legacyCheckBox.Foreground = [System.Windows.Media.Brushes]::Black

# Show the window
$window.ShowDialog()