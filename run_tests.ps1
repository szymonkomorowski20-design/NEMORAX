param(
	[string]$GodotExecutable = "",
	[switch]$SkipImport
)

$projectRoot = Split-Path -Parent $PSCommandPath

if ([string]::IsNullOrWhiteSpace($GodotExecutable)) {
	$desktopConsole = Join-Path $env:USERPROFILE 'Desktop\Godot_v4.7.2-stable_win64_console.exe'
	if (Test-Path -LiteralPath $desktopConsole) {
		$GodotExecutable = $desktopConsole
	} else {
		$godotCommand = Get-Command godot, godot4 -ErrorAction SilentlyContinue | Select-Object -First 1
		if ($godotCommand) {
			$GodotExecutable = $godotCommand.Source
		}
	}
}

if ([string]::IsNullOrWhiteSpace($GodotExecutable) -or -not (Test-Path -LiteralPath $GodotExecutable)) {
	Write-Error 'Nie znaleziono Godot. Podaj pelna sciezke przez -GodotExecutable.'
	exit 2
}

if (-not $SkipImport) {
	Write-Output 'Godot: import zasobow projektu...'
	& $GodotExecutable --headless --path $projectRoot --editor --import
	if ($LASTEXITCODE -ne 0) {
		exit $LASTEXITCODE
	}
}

Write-Output 'Godot: uruchamianie testow NEMORAX...'
& $GodotExecutable --headless --path $projectRoot --script 'res://tests/test_runner.gd'
exit $LASTEXITCODE
