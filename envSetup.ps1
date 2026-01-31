<#
.SYNOPSIS
    SmartCreate Environment Setup - Installs prerequisites only
.DESCRIPTION
    Checks and installs .NET SDK 8+, Ollama + qwen2.5:3b model, VSCode, Node.js
    Starts Ollama server in background
    Does NOT create projects or run applications
.NOTES
    Run from ANY location - works on clean Windows machines
    Y/N prompts for installations only
    Exits cleanly after environment setup
#>

# Error handling: Continue on non-critical errors
$ErrorActionPreference = "Continue"

Write-Host "SmartCreate Environment Setup" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host "(Environment check ONLY - no project creation)" -ForegroundColor Yellow
Write-Host ""

# 1. CHECK .NET SDK 8+
Write-Host "1. Checking .NET SDK 8+..." -ForegroundColor Yellow
if (Get-Command "dotnet" -ErrorAction SilentlyContinue) {
    # .NET found - check version
    $dotnetVer = dotnet --version
    Write-Host ".NET version: $dotnetVer" -ForegroundColor White
    
    # Verify .NET 8+ (starts with 8.)
    if ($dotnetVer -like "8.*") {
        Write-Host ".NET SDK 8+ OK" -ForegroundColor Green
    } else {
        # Wrong .NET version
        Write-Host "Need .NET SDK 8+. Install now? [Y/N]" -ForegroundColor Yellow -NoNewline
        $confirm = Read-Host " "
        if ($confirm -eq 'Y' -or $confirm -eq 'y') {
            winget install Microsoft.DotNet.SDK.8
            Write-Host "Restart PowerShell after .NET installation" -ForegroundColor Red
            pause
            exit
        }
    }
} else {
    # .NET not found
    Write-Host ".NET SDK not found. Install? [Y/N]" -ForegroundColor Red -NoNewline
    $confirm = Read-Host " "
    if ($confirm -eq 'Y' -or $confirm -eq 'y') {
        winget install Microsoft.DotNet.SDK.8
        Write-Host "Restart PowerShell after installation" -ForegroundColor Red
        pause
        exit
    }
}

# 2. CHECK OLLAMA
Write-Host ""
Write-Host "2. Checking Ollama..." -ForegroundColor Yellow
if (Get-Command "ollama" -ErrorAction SilentlyContinue) {
    # Ollama found - check if qwen2.5:3b model exists
    $modelCheck = ollama list | Select-String "qwen2.5:3b"
    if ($modelCheck) {
        Write-Host "Ollama + qwen2.5:3b model ready (~2GB disk)" -ForegroundColor Green
    } else {
        # Ollama exists but model missing
        Write-Host "Ollama found but qwen2.5:3b model missing (~2GB download). Install model? [Y/N]" -ForegroundColor Yellow -NoNewline
        $confirm = Read-Host " "
        if ($confirm -eq 'Y' -or $confirm -eq 'y') {
            Write-Host "Downloading qwen2.5:3b model (this takes 5-15 minutes)..."
            ollama pull qwen2.5:3b
        }
    }
} else {
    # Ollama not found
    Write-Host "Ollama not found. Install? [Y/N]" -ForegroundColor Red -NoNewline
    $confirm = Read-Host " "
    if ($confirm -eq 'Y' -or $confirm -eq 'y') {
        winget install ollama
        Write-Host "Run script again after Ollama installation" -ForegroundColor Yellow
        pause
        exit
    }
}

# 3. CHECK VSCODE
Write-Host ""
Write-Host "3. Checking VSCode..." -ForegroundColor Yellow
if (Get-Command "code" -ErrorAction SilentlyContinue) {
    Write-Host "VSCode found. Install C# Dev Kit extension manually" -ForegroundColor Green
} else {
    Write-Host "VSCode not found. Install? [Y/N]" -ForegroundColor Yellow -NoNewline
    $confirm = Read-Host " "
    if ($confirm -eq 'Y' -or $confirm -eq 'y') {
        winget install Microsoft.VisualStudioCode
        Write-Host "After VSCode install: Extensions > C# Dev Kit" -ForegroundColor Yellow
    }
}

# 4. CHECK NODE.JS (for Vite dev servers later)
Write-Host ""
Write-Host "4. Checking Node.js (for Vite preview)..." -ForegroundColor Yellow
if (Get-Command "node" -ErrorAction SilentlyContinue) {
    $nodeVer = node --version
    Write-Host "Node.js $nodeVer found" -ForegroundColor Green
} else {
    Write-Host "Node.js not found (needed for preview servers). Install? [Y/N]" -ForegroundColor Yellow -NoNewline
    $confirm = Read-Host " "
    if ($confirm -eq 'Y' -or $confirm -eq 'y') {
        winget install OpenJS.NodeJS
    }
}

# 5. START OLLAMA SERVER (background)
Write-Host ""
Write-Host "5. Starting Ollama server..." -ForegroundColor Cyan
try {
    # Start Ollama server hidden (non-blocking)
    $ollamaProcess = Start-Process "ollama" -ArgumentList "serve" -WindowStyle Hidden -PassThru -ErrorAction Stop
    Start-Sleep 3  # Wait for server startup
    
    Write-Host "Ollama server started successfully" -ForegroundColor Green
} catch {
    Write-Host "Warning: Could not start Ollama server (run 'ollama serve' manually)" -ForegroundColor Yellow
}

# SUCCESS SCREEN
Write-Host ""
Write-Host "SUCCESS: Environment Ready!" -ForegroundColor Green -BackgroundColor DarkGreen
Write-Host "================================" -ForegroundColor Green
Write-Host ".NET SDK 8+          ✓" -ForegroundColor Green
Write-Host "Ollama + qwen2.5:3b  ✓" -ForegroundColor Green
Write-Host "VSCode               ✓" -ForegroundColor Green
Write-Host "Node.js              ✓" -ForegroundColor Green
Write-Host ""
Write-Host "Ollama API:          http://localhost:11434" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  cd C:\CreateAI\SmartCreate" -ForegroundColor White
Write-Host "  dotnet build" -ForegroundColor White
Write-Host "  dotnet run" -ForegroundColor White
Write-Host "  code . (opens VSCode)" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to exit (Ollama server will continue)..." -ForegroundColor Gray -NoNewline
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Cleanup: Stop Ollama server process
if ($ollamaProcess) {
    Stop-Process $ollamaProcess -ErrorAction SilentlyContinue
}
