# SSF2 Event Compiler Documentation

## Overview

The SSF2 Event Compiler is a PowerShell script (`run.ps1`) designed to compile ActionScript (AS) files for the Super Smash Flash 2 (SSF2) modding community. It automates the process of building custom event SWFs using Apache Flex SDK, with support for both graphical user interface (GUI) and console modes.

The script handles:
- Parsing and updating event metadata in `ExternalEvents.as`
- Verifying event files and their dependencies
- Embedding images as MovieClip classes
- Compiling AS files into SWF using mxmlc
- Providing real-time feedback and error handling

## Features

- **Dual Mode Operation**: GUI for interactive use, console for automation/scripting
- **Legacy Mode Support**: Switch between "files" and "legacy" source directories
- **Event Auto-Discovery**: Scans for event files with `eventinfo` variables or generates basic metadata
- **Image Embedding**: Automatically creates AS classes for PNG/JPG/GIF images
- **Warning Management**: Limits warning output to prevent GUI freezing
- **Single Instance**: Prevents multiple concurrent compilations
- **Comprehensive Logging**: Maintains `history.log` for build history

## Prerequisites

- Windows PowerShell 5.1+
- Apache Flex SDK (configured in `../aflex_lite/`)
- Source AS files in `files/` or `legacy/` subdirectories
- Optional: Images in `../compile/images/` for embedding

## Directory Structure

```
compile/
├── run.ps1                 # Main script
├── history.log             # Build log (auto-generated)
├── files/                  # Source AS files (default mode)
│   ├── ExternalEvents.as   # Event registry
│   ├── EventMode1.as       # Individual event files
│   └── ...
├── legacy/                 # Alternative source directory
└── ../aflex_lite/          # Flex SDK installation
    └── bin/mxmlc.bat       # Compiler executable
```

## Usage

### Console Mode

Run from command line for automated builds:

```powershell
# Basic compilation
.\run.ps1 console

# Legacy mode
.\run.ps1 console legacy

# Silent mode (no output)
.\run.ps1 silent
```

### GUI Mode

Double-click `run.ps1` or run without arguments:

```powershell
.\run.ps1
```

The GUI provides:
- Real-time compilation log
- Warning toggle
- Legacy mode checkbox
- Cancel button for long compilations

## How It Works

### 1. Initialization
- Checks for running instances and terminates duplicates
- Sets working directory and loads Flex SDK path
- Parses command-line arguments for mode selection

### 2. Source Discovery
- Scans `files/` or `legacy/` for `.as` files
- Identifies `ExternalEvents.as` as the main registry file
- Parses existing `eventList2` array for known events

### 3. Event Processing
For each AS file:
- Checks if event already exists in registry (skips duplicates)
- Parses `eventinfo` variable for metadata (id, name, description, etc.)
- Falls back to filename-based generation if no `eventinfo` (removed in optimized version)
- Updates class/function names to match filename
- Verifies corresponding files exist for registered events

### 4. Image Embedding (Optional)
- Scans `../compile/images/` for supported formats
- Generates AS classes with `[Embed]` metadata
- Adds linkage names to compilation arguments

### 5. Compilation
- Constructs mxmlc command with:
  - Source paths: current dir + API directory
  - Library paths: playerglobal.swc
  - Include classes for embedded images
  - Output: `../custom_events.swf`
- Runs compilation with output buffering for GUI responsiveness
- Handles errors, warnings, and timeouts

### 6. Output Handling
- **Real-time mode**: Streams output for small compilations
- **Buffered mode**: Collects output for large compilations to prevent GUI freezing
- Limits warnings (max 10-20) with suppression counters
- Auto-disables warning display if too many occur

## Event Metadata Format

Events are defined in `ExternalEvents.as` as an array of objects:

```actionscript
eventList2 = [
    {
        "classAPI": "EventMode1_TroubledKing",
        "id": "TroubledKing",
        "name": "1. Troubled King",
        "description": "Fight Mario in a classic Mushroom Kingdom clash!"
    },
    // ... more events
];
```

Individual event files can override with `eventinfo`:

```actionscript
public var eventinfo: Array = [
    {
        id: "CustomEvent",
        name: "My Custom Event",
        description: "A custom event description",
        chooseCharacter: true
    }
];
```

## Configuration

### Flex SDK Path
Modify `$flexHome` in the script:
```powershell
$flexHome = Join-Path $exeDir "../aflex_lite"
```

### Source Directories
- `files/`: Default modern mode
- `legacy/`: Alternative directory for older setups

### Compilation Flags
- `-warnings=true/false`: Enable/disable compiler warnings
- `-strict=true`: Enforces strict type checking
- `-source-path`: Additional AS source directories
- `-library-path`: SWC libraries
- `-includes`: Classes to force-include

## Troubleshooting

### Common Issues

**"mxmlc.bat not found"**
- Verify Flex SDK installation in `../aflex_lite/`
- Check `$flexHome` path in script

**"No .as files found"**
- Ensure files exist in `files/` or `legacy/` directory
- Check read permissions

**Compilation Errors**
- Check `history.log` for detailed error messages
- Verify AS syntax and imports
- Ensure all dependencies are present

**GUI Freezing**
- Use "Show Warnings" toggle to reduce output
- Switch to console mode for large compilations

### Debug Mode
Add debug output by modifying Write-Host statements in the script.

## Performance Notes

- Optimized for 50+ event files
- Uses hashtables for O(1) event lookups
- Buffered output prevents GUI lag during compilation
- Single-instance check prevents resource conflicts

## Contributing

To modify the script:
1. Edit `run.ps1` with PowerShell-aware editor
2. Test in both GUI and console modes
3. Update this documentation for any new features

## Version History

- **Current**: Optimized version with hashtable lookups, removed redundant code
- **Previous**: Included filename-based event generation (now removed for simplicity)</content>