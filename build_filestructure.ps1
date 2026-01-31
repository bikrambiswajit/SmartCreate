$root = "C:\CreateAI"

$folders = @(
    "SmartCreate/src/Services",
    "SmartCreate/src/Models",
    "SmartCreate/src/ViewModels",
    "SmartCreate/src/Views",
    "resources/ollama",
    "docs",
    "projects",
    "exports"
)

foreach ($folder in $folders) {
    New-Item -ItemType Directory -Force -Path "$root\$folder"
}

"SmartCreate POC - VSCode Ready`nNext: cd SmartCreate && dotnet new wpf" | Out-File "$root\docs\README.md"

Write-Host "File structure created!"
