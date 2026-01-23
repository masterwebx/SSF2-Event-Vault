$code = @"
using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Threading;

class Program {
    static void Main() {
        // Single instance check
        string processName = "SSF2 Event Compiler";
        Process currentProcess = Process.GetCurrentProcess();
        
        // Kill existing instances
        Process[] existingProcesses = Process.GetProcessesByName(processName);
        foreach (Process proc in existingProcesses) {
            if (proc.Id != currentProcess.Id) {
                try {
                    proc.Kill();
                    proc.WaitForExit(5000);
                } catch {
                    // Ignore errors
                }
            }
        }
        
        // Small delay to ensure cleanup
        Thread.Sleep(500);
        
        string exePath = Assembly.GetExecutingAssembly().Location;
        string exeDir = Path.GetDirectoryName(exePath);
        string parentDir = Path.GetDirectoryName(exeDir);
        string debugScriptPath = Path.Combine(exeDir, "compile", "run.ps1");
        
        Process.Start(new ProcessStartInfo {
            FileName = "powershell.exe",
            Arguments = "-ExecutionPolicy Bypass -File \"" + debugScriptPath + "\" \"" + exePath + "\"",
            UseShellExecute = false,
            CreateNoWindow = true
        });
    }
}
"@

# Write the code to a temporary .cs file
$tempCsFile = "temp_compiler.cs"
$code | Out-File -FilePath $tempCsFile -Encoding UTF8

# Try to compile with icon using Add-Type instead
try {
    Add-Type -TypeDefinition $code -OutputAssembly "..\SSF2 Event Compiler.exe" -OutputType WindowsApplication -ReferencedAssemblies "System.dll" -Icon "icon.ico" -ErrorAction Stop
    Write-Host "EXE built successfully with icon."
} catch {
    Write-Host "Add-Type failed, trying csc.exe with icon..."
    # Fallback to csc.exe with icon
    $cscPath = "C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe"
    if (Test-Path $cscPath) {
        & $cscPath "/target:winexe" "/win32icon:icon.ico" "/out:..\SSF2 Event Compiler.exe" $tempCsFile
        Write-Host "EXE built with csc.exe and embedded icon."
    } else {
        Write-Host "Compilation failed."
        exit 1
    }
}

# Clean up temporary file
Remove-Item $tempCsFile -ErrorAction SilentlyContinue