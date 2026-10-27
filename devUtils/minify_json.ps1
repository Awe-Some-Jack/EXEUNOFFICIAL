param(
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$Paths
)

$ErrorActionPreference = "Stop"

function Get-JsonFiles {
    param([string[]]$InputPaths)

    $files = @()
    foreach ($inputPath in $InputPaths) {
        $path = (Resolve-Path -LiteralPath $inputPath).Path
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            if ([IO.Path]::GetExtension($path) -ine ".json") {
                throw "Not a .json file: $path"
            }
            $files += Get-Item -LiteralPath $path
        }
        elseif (Test-Path -LiteralPath $path -PathType Container) {
            $files += Get-ChildItem -LiteralPath $path -Filter "*.json" -File -Recurse -Force |
                Sort-Object -Property FullName
        }
        else {
            throw "Not a file or folder: $inputPath"
        }
    }

    if ($files.Count -eq 0) {
        throw "No JSON files found."
    }

    return $files
}

function ConvertTo-CompactJson {
    param([string]$Text)

    $builder = New-Object System.Text.StringBuilder
    $inString = $false
    $escaped = $false

    foreach ($character in $Text.ToCharArray()) {
        if ($inString) {
            [void]$builder.Append($character)
            if ($escaped) {
                $escaped = $false
            }
            elseif ($character -eq "\") {
                $escaped = $true
            }
            elseif ($character -eq '"') {
                $inString = $false
            }
        }
        elseif ($character -eq '"') {
            $inString = $true
            [void]$builder.Append($character)
        }
        elseif ($character -notin @(" ", "`t", "`r", "`n")) {
            [void]$builder.Append($character)
        }
    }

    if ($inString) {
        throw "JSON contains an unterminated string."
    }

    return $builder.ToString()
}

try {
    if (-not $Paths -or $Paths.Count -eq 0) {
        $enteredPath = Read-Host "Drop a JSON file or folder here, then press Enter"
        $Paths = @($enteredPath.Trim().Trim('"'))
    }

    Add-Type -AssemblyName System.Web.Extensions
    $jsonValidator = New-Object System.Web.Script.Serialization.JavaScriptSerializer
    $jsonValidator.MaxJsonLength = [int]::MaxValue
    $jsonValidator.RecursionLimit = 10000

    $files = @(Get-JsonFiles -InputPaths $Paths)
    foreach ($file in $files) {
        $original = [IO.File]::ReadAllBytes($file.FullName)
        $hasBom = $original.Length -ge 3 -and
            $original[0] -eq 0xEF -and $original[1] -eq 0xBB -and $original[2] -eq 0xBF
        $offset = if ($hasBom) { 3 } else { 0 }
        $utf8 = New-Object System.Text.UTF8Encoding($false, $true)
        $text = $utf8.GetString($original, $offset, $original.Length - $offset)

        $null = $jsonValidator.DeserializeObject($text)
        $compactText = ConvertTo-CompactJson -Text $text
        $compactBytes = $utf8.GetBytes($compactText)

        if ($hasBom) {
            $output = New-Object byte[] ($compactBytes.Length + 3)
            $output[0] = 0xEF
            $output[1] = 0xBB
            $output[2] = 0xBF
            [Array]::Copy($compactBytes, 0, $output, 3, $compactBytes.Length)
        }
        else {
            $output = $compactBytes
        }

        $saved = $original.Length - $output.Length
        if ($saved -gt 0) {
            $tempPath = Join-Path $file.DirectoryName (".{0}.{1}.tmp" -f $file.Name, [guid]::NewGuid())
            $backupPath = "$tempPath.bak"
            try {
                [IO.File]::WriteAllBytes($tempPath, $output)
                [IO.File]::Replace($tempPath, $file.FullName, $backupPath)
            }
            finally {
                Remove-Item -LiteralPath $tempPath, $backupPath -Force -ErrorAction SilentlyContinue
            }
        }

        Write-Host ("{0}: saved {1:N0} bytes" -f $file.FullName, [Math]::Max(0, $saved))
    }

    Write-Host ("Done. Processed {0} JSON file(s)." -f $files.Count)
    exit 0
}
catch {
    Write-Host ("Error: {0}" -f $_.Exception.GetBaseException().Message) -ForegroundColor Red
    exit 1
}
