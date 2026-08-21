<#
.SYNOPSIS
  One-command semantic version bump (x.y.z), config-driven and project-agnostic.

.DESCRIPTION
  Reads bump-version.config.json (same folder as this script = repo root).
  The config names one version source file plus any number of additional target
  files (doc headers etc.), each with a regex containing a (?<ver>...) group.

  Drift protection: every pattern must match its file EXACTLY ONCE. If a pattern
  matches 0 or 2+ times, the script aborts loudly BEFORE writing anything --
  a drifted file is a hard error, never silently skipped.

  Scheme x.y.z: z = patch/fix, y = minor feature, x = major milestone.

  -Ticket takes the level from the board instead: every ticket carries a
  "Version" metadata row (major/minor/patch/none) filled in when it was filed,
  so the decision is made once, with the change fresh, rather than re-argued at
  release time from a diff. A ticket marked 'none' writes nothing and says so.

  NOTE: keep this file ASCII-only. Windows PowerShell 5.1 reads BOM-less
  scripts as ANSI and chokes on multi-byte characters.

.EXAMPLE
  .\bump-version.ps1            # patch bump: 1.2.3 -> 1.2.4
  .\bump-version.ps1 -Minor     # 1.2.3 -> 1.3.0
  .\bump-version.ps1 -Major     # 1.2.3 -> 2.0.0
  .\bump-version.ps1 1.4.0      # explicit version
  .\bump-version.ps1 -DryRun    # preview without writing

.EXAMPLE
  .\bump-version.ps1 -Ticket F12
  Bumps by whatever F12's "Version" row says. Accepts a path too, for a ticket
  that lives outside the board folders.
#>
param(
    [Parameter(Position = 0)]
    [string]$NewVersion,
    [switch]$Minor,
    [switch]$Major,

    # Board ticket id ("F12") or path to a ticket file. Its "Version" metadata
    # row decides the bump level.
    [string]$Ticket,

    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

# --- Load config --------------------------------------------------------------
$configPath = Join-Path $root 'bump-version.config.json'
if (-not (Test-Path $configPath)) {
    throw "Config not found: $configPath"
}
$configRaw = [System.IO.File]::ReadAllText($configPath)
if ($configRaw -match '\{\{') {
    throw "bump-version.config.json still contains {{placeholders}} - it has not been configured yet (see SETUP.md, 'Set up versioning')."
}
$config = $configRaw | ConvertFrom-Json

function Get-SingleMatchValue {
    param([string]$Path, [string]$Pattern, [string]$Group)
    if (-not (Test-Path $Path)) {
        throw "File not found: $Path (check bump-version.config.json)"
    }
    $text = [System.IO.File]::ReadAllText($Path)
    $hits = [regex]::Matches($text, $Pattern)
    if ($hits.Count -ne 1) {
        throw "PATTERN DRIFT in '$Path': expected exactly 1 match for pattern [$Pattern], found $($hits.Count). Fix the file or the config, then retry. Nothing was written."
    }
    $g = $hits[0].Groups[$Group]
    if (-not $g.Success) {
        throw "Pattern for '$Path' is missing the required (?<$Group>...) named group."
    }
    return $g.Value
}

function Update-SingleMatch {
    param([string]$Path, [string]$Pattern, [string]$Group, [string]$NewValue)
    # Re-reads the file at write time so several patterns may share one file.
    $text = [System.IO.File]::ReadAllText($Path)
    $hits = [regex]::Matches($text, $Pattern)
    if ($hits.Count -ne 1) {
        throw "PATTERN DRIFT in '$Path' at write time: expected exactly 1 match, found $($hits.Count)."
    }
    $g = $hits[0].Groups[$Group]
    $newText = $text.Substring(0, $g.Index) + $NewValue + $text.Substring($g.Index + $g.Length)
    [System.IO.File]::WriteAllText($Path, $newText, (New-Object System.Text.UTF8Encoding($false)))
}

# --- Ticket lookup --------------------------------------------------------------
function Resolve-TicketPath {
    param([string]$Id)
    if (Test-Path -LiteralPath $Id -PathType Leaf) { return (Resolve-Path -LiteralPath $Id).Path }

    $board = Join-Path $root 'docs\workflow'
    $hits  = @()
    foreach ($f in @('inbox', 'backlog', 'done', 'maybeLater')) {
        $dir = Join-Path $board $f
        if (-not (Test-Path $dir)) { continue }
        $hits += Get-ChildItem $dir -Filter "$Id-*.md" -File -ErrorAction SilentlyContinue
    }
    if ($hits.Count -eq 0) {
        throw "Ticket '$Id' not found in docs/workflow/{inbox,backlog,done,maybeLater} and is not a path to an existing file."
    }
    if ($hits.Count -gt 1) {
        $where = ($hits | ForEach-Object { $_.FullName }) -join ', '
        throw "Ticket '$Id' is ambiguous - $($hits.Count) files match: $where. Pass a path instead."
    }
    return $hits[0].FullName
}

function Get-TicketBumpLevel {
    param([string]$Path)
    $text = [System.IO.File]::ReadAllText($Path)
    $hits = [regex]::Matches($text, '(?m)^\|\s*Version\s*\|(?<lvl>[^|]*)\|[ \t]*$')
    if ($hits.Count -ne 1) {
        throw "Expected exactly 1 'Version' metadata row in '$Path', found $($hits.Count). Add one (major/minor/patch/none), or pass -Minor/-Major instead."
    }
    $lvl = $hits[0].Groups['lvl'].Value.Trim().Trim('`').Trim().ToLowerInvariant()
    if ($lvl -notin @('major', 'minor', 'patch', 'none')) {
        throw "Ticket '$Path' says Version = '$lvl'; expected one of major, minor, patch, none. A ticket still listing all four has not had the call made yet - decide it in the ticket, then rerun."
    }
    return $lvl
}

# --- Current version ----------------------------------------------------------
$srcRel  = $config.versionSource.file
$srcPath = Join-Path $root $srcRel
$current = Get-SingleMatchValue -Path $srcPath -Pattern $config.versionSource.pattern -Group 'ver'
if ($current -notmatch '^(\d+)\.(\d+)\.(\d+)$') {
    throw "Current version '$current' in $srcRel is not in x.y.z form."
}
$x = [int]$Matches[1]; $y = [int]$Matches[2]; $z = [int]$Matches[3]

# --- Bump level from a ticket ---------------------------------------------------
$source = ''
if ($Ticket) {
    if ($NewVersion -or $Minor -or $Major) {
        throw 'Pass either -Ticket or an explicit version / -Minor / -Major, not both.'
    }
    $ticketPath = Resolve-TicketPath $Ticket
    $ticketRel  = $ticketPath
    if ($ticketRel.StartsWith($root, [StringComparison]::OrdinalIgnoreCase)) {
        $ticketRel = $ticketRel.Substring($root.Length + 1).Replace('\', '/')
    }

    $level = Get-TicketBumpLevel $ticketPath
    if ($level -eq 'none') {
        Write-Host "$ticketRel is marked Version: none - no version change. Nothing written."
        return
    }
    if ($level -eq 'major') { $Major = $true }
    if ($level -eq 'minor') { $Minor = $true }
    $source = "  ($level, per $ticketRel)"
}

# --- Compute new version --------------------------------------------------------
if ($NewVersion) {
    if ($Minor -or $Major) { throw 'Pass either an explicit version or -Minor/-Major, not both.' }
    if ($NewVersion -notmatch '^\d+\.\d+\.\d+$') { throw "New version '$NewVersion' must be x.y.z." }
    $new = $NewVersion
} elseif ($Major) {
    $new = "$($x + 1).0.0"
} elseif ($Minor) {
    $new = "$x.$($y + 1).0"
} else {
    $new = "$x.$y.$($z + 1)"
}

# --- Validate every file BEFORE writing anything --------------------------------
$plan = @()
$plan += [pscustomobject]@{ File = $srcRel; Path = $srcPath; Pattern = $config.versionSource.pattern; Group = 'ver'; Old = $current; New = $new }

foreach ($t in @($config.targets)) {
    if ($null -eq $t) { continue }
    $p = Join-Path $root $t.file
    $val = Get-SingleMatchValue -Path $p -Pattern $t.pattern -Group 'ver'
    if ($val -ne $current) {
        Write-Warning "$($t.file) currently says $val while the source says $current (drift) - it will be set to $new."
    }
    $plan += [pscustomobject]@{ File = $t.file; Path = $p; Pattern = $t.pattern; Group = 'ver'; Old = $val; New = $new }
}

if ($config.PSObject.Properties['buildNumber'] -and $null -ne $config.buildNumber) {
    $bp  = Join-Path $root $config.buildNumber.file
    $val = Get-SingleMatchValue -Path $bp -Pattern $config.buildNumber.pattern -Group 'num'
    $plan += [pscustomobject]@{ File = $config.buildNumber.file; Path = $bp; Pattern = $config.buildNumber.pattern; Group = 'num'; Old = $val; New = "$([int]$val + 1)" }
}

# --- Apply ----------------------------------------------------------------------
$mode = ''
if ($DryRun) { $mode = '  (dry run - no files written)' }
Write-Host "Version: $current -> $new$source$mode"
foreach ($step in $plan) {
    Write-Host ("  {0}  {1} -> {2}" -f $step.File, $step.Old, $step.New)
    if (-not $DryRun) {
        Update-SingleMatch -Path $step.Path -Pattern $step.Pattern -Group $step.Group -NewValue $step.New
    }
}
Write-Host 'Done.'
