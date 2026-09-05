<#
.SYNOPSIS
    Create a board ticket with the next free number, generated from _TEMPLATE.md.

.DESCRIPTION
    Filenames are the source of truth for ticket numbers -- there is no counter
    file to drift. The next number is derived by scanning every board folder
    (backlog, inbox, done, and maybeLater if the project has one) for the prefix.

    Why not a counter file: measured on a real 182-ticket board, a committed
    "last used number per prefix" file cost 1,068 tokens per ticket against
    1,045 for deriving from filenames -- a 2% saving in exchange for state that
    drifts and that two agents can both read before either writes. Scanning the
    whole board by hand costs ~4,600. This script costs ~90, because it also
    removes the _TEMPLATE.md round-trip, which is the larger half of the bill.

    Concurrency: the number is claimed by creating "backlog/{Prefix}{N}.md" --
    a name that depends on nothing but the number -- and only then checking
    whether a real "{Prefix}{N}-*.md" exists. Both halves are load-bearing:

      * Reserving the FINAL "{Prefix}{N}-{slug}.md" name does not work. Two runs
        with different titles are different filenames, so both CreateNew calls
        succeed and both get the same number (measured: 5 of 6 parallel runs
        took the same id).
      * Checking BEFORE taking the reservation does not work either, because
        renaming the reservation to its slug name releases it, so a later run
        re-acquires the same name and never sees the ticket that appeared in
        between.

    A crashed run leaves a visible, still-counted "B12.md" in backlog/ rather
    than an invisible stale lock -- delete it and the number frees up.

.EXAMPLE
    .\new-ticket.ps1 B "invite link does not open the app"
    Creates docs/workflow/backlog/B12-invite-link-does-not-open-the-app.md

.EXAMPLE
    .\new-ticket.ps1 F "offline map download" -Scope APP
    Feature ticket -- keeps the Design / Open questions / Phasing sections.

.EXAMPLE
    .\new-ticket.ps1 R "drop the v1 sync endpoint" -Bump major
    Overrides the prefix default (R = none) -- this refactor breaks callers.

.EXAMPLE
    .\new-ticket.ps1 S "rotate API tokens" -Assignee Human -Dest inbox

.EXAMPLE
    .\new-ticket.ps1 B "some bug" -DryRun
    Prints the path it would claim, without creating anything.
#>
param(
    # A Analysis, B Bug, D Draft, F Feature, R Refactor, S Security, T Test.
    [Parameter(Mandatory, Position = 0)]
    [ValidateSet('A', 'B', 'D', 'F', 'R', 'S', 'T')]
    [string]$Prefix,

    # Human title. Becomes both the H1 and the kebab-case filename slug.
    [Parameter(Mandatory, Position = 1)]
    [string]$Title,

    # Board folder to create in. New tickets normally start in backlog.
    [string]$Dest = 'backlog',

    # This project's component values, as set up in _TEMPLATE.md (e.g. APP,
    # BACKEND, BOTH). Left untouched when omitted, so the author picks.
    [string]$Scope = '',

    [ValidateSet('HIGH', 'MEDIUM', 'LOW')]
    [string]$Severity = 'MEDIUM',

    # How shipping this ticket moves the version, recorded in the ticket's
    # "Version" row and read back later by "bump-version.ps1 -Ticket <id>".
    # Defaults by prefix (see $bumpDefaults below); override when the default is
    # wrong -- a breaking refactor is 'major', a fix with no user-visible change
    # is 'none'.
    [ValidateSet('major', 'minor', 'patch', 'none')]
    [string]$Bump = '',

    # Human for anything needing credentials, production access, or secrets.
    [string]$Assignee = 'Agent',

    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$root     = $PSScriptRoot
$board    = Join-Path $root 'docs\workflow'
$template = Join-Path $board 'backlog\_TEMPLATE.md'
$em       = [char]0x2014  # em-dash for the H1; kept out of source so file encoding can't corrupt it

# Version impact per ticket type: features move the minor, fixes the patch,
# and analysis/drafts/refactors/tests ship nothing a user can see. A default
# that is wrong for a given ticket is meant to be overridden with -Bump, or
# edited in the file afterwards -- it is a starting guess, not a verdict.
$bumpDefaults = @{ A = 'none'; B = 'patch'; D = 'none'; F = 'minor'; R = 'none'; S = 'patch'; T = 'none' }
$bumpExplicit = $PSBoundParameters.ContainsKey('Bump')
if (-not $bumpExplicit) { $Bump = $bumpDefaults[$Prefix] }

# Scanned for existing numbers. Absent folders are skipped, so a project
# without maybeLater/ needs no edit here.
$folders = @('backlog', 'inbox', 'done', 'maybeLater') | ForEach-Object { Join-Path $board $_ }

if (-not (Test-Path $template))              { throw "Template not found: $template" }
if (-not (Test-Path (Join-Path $board $Dest))) { throw "-Dest '$Dest' is not a folder under docs/workflow/." }

# --- slug: ascii kebab-case
function ConvertTo-Slug([string]$Text) {
    $s = ($Text.Normalize([Text.NormalizationForm]::FormD).ToCharArray() |
          Where-Object { [Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne 'NonSpacingMark' }) -join ''
    $s = [regex]::Replace($s.ToLowerInvariant(), '[^a-z0-9]+', '-').Trim('-')
    if ($s.Length -gt 80) {
        $s = $s.Substring(0, 80)
        $s = $s.Substring(0, [Math]::Max($s.LastIndexOf('-'), 1)).Trim('-')   # don't cut mid-word
    }
    if (-not $s) { throw "Title '$Text' produced an empty slug -- give it some letters or digits." }
    return $s
}

# --- every number already claimed by this prefix, across the whole board
function Get-ClaimedNumbers([string]$P) {
    $claimed = @{}
    foreach ($f in $folders) {
        if (-not (Test-Path $f)) { continue }
        foreach ($file in Get-ChildItem $f -Filter '*.md' -File) {
            # "B12-some-title.md" (a real ticket) or "B12.md" (a reservation in flight)
            if ($file.Name -match "^$P(\d+)(-|\.md$)") { $claimed[[int]$Matches[1]] = $true }
        }
    }
    return $claimed
}

# --- is this number already a finished ticket? (not counting a live reservation)
function Test-NumberTaken([string]$P, [int]$N) {
    foreach ($f in $folders) {
        if (-not (Test-Path $f)) { continue }
        if (Get-ChildItem $f -Filter "$P$N-*.md" -File -ErrorAction SilentlyContinue) { return $true }
    }
    return $false
}

# --- metadata rows are matched on their field name, so the project's own Scope
# --- values (set during SETUP) don't have to be known here
function Get-MetaRowPattern([string]$Field) {
    return '(?m)^\|\s*' + [regex]::Escape($Field) + '\s*\|.*\|[ \t]*$'
}

function Test-MetaRow([string]$Text, [string]$Field) {
    return [regex]::Matches($Text, (Get-MetaRowPattern $Field)).Count -gt 0
}

# --- rewrite one row; a field that isn't there exactly once is drift, not a typo
function Set-MetaRow([string]$Text, [string]$Field, [string]$Value) {
    $pattern = Get-MetaRowPattern $Field
    $m = [regex]::Matches($Text, $pattern)
    if ($m.Count -ne 1) {
        throw "ABORT: expected exactly 1 '$Field' row in _TEMPLATE.md, found $($m.Count). Update new-ticket.ps1 to match the template."
    }
    $row = '| ' + $Field.PadRight(8) + ' | `' + $Value + '` |'
    return $Text.Substring(0, $m[0].Index) + $row + $Text.Substring($m[0].Index + $m[0].Length)
}

# --- body: set the H1, fill the metadata table, drop the Design block for non-features
function New-TicketBody([string]$Id, [string]$TitleText) {
    $bytes  = [IO.File]::ReadAllBytes($template)
    $hasBom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
    if ($hasBom) { $text = [Text.Encoding]::UTF8.GetString($bytes, 3, $bytes.Length - 3) }
    else         { $text = [Text.Encoding]::UTF8.GetString($bytes) }

    # The template marks its own optional tail. Features keep it; everything else drops it.
    $cut = $text.IndexOf('<!-- Delete everything below')
    if ($cut -lt 0) {
        throw "ABORT: _TEMPLATE.md no longer contains the 'Delete everything below' marker -- update new-ticket.ps1 to match the new template."
    }
    if ($Prefix -eq 'F') {
        $text = [regex]::Replace($text, '<!-- Delete everything below[^\n]*\n<!-- Keep it for features[^\n]*\n', '')
    } else {
        $sep = $text.LastIndexOf('---', $cut)   # the rule line introducing the optional tail
        if ($sep -ge 0) { $cut = $sep }
        $text = $text.Substring(0, $cut).TrimEnd() + "`n"
    }

    $headerPattern = '(?m)^# \{Prefix\}\{N\} .* \{Title\}[ \t]*$'
    if ([regex]::Matches($text, $headerPattern).Count -ne 1) {
        throw "ABORT: _TEMPLATE.md header is not the expected '# {Prefix}{N} $em {Title}' -- update new-ticket.ps1."
    }
    $text = [regex]::Replace($text, $headerPattern, "# $Id $em $TitleText")

    $text = Set-MetaRow $text 'Status'   $Dest
    $text = Set-MetaRow $text 'Assignee' $Assignee
    $text = Set-MetaRow $text 'Severity' $Severity
    if ($Scope) { $text = Set-MetaRow $text 'Scope' $Scope }   # else leave it for the author

    # Projects that don't version delete this row along with bump-version.ps1
    # (SETUP.md, 'Set up versioning'), so its absence is legal -- but asking for
    # a -Bump the board cannot record is not.
    if (Test-MetaRow $text 'Version') {
        $text = Set-MetaRow $text 'Version' $Bump
    } elseif ($bumpExplicit) {
        throw "ABORT: -Bump was passed but _TEMPLATE.md has no 'Version' row -- this project does not track version impact."
    }

    if ($text -match '\{Prefix\}|\{N\}|\{Title\}') {
        throw "ABORT: template placeholders survived substitution -- update new-ticket.ps1."
    }
    return $text
}

# --- claim a number, then write
$reserveDir = Join-Path $board 'backlog'   # always backlog, so runs with different -Dest still contend for one name
$destDir    = Join-Path $board $Dest
$slug       = ConvertTo-Slug $Title
$claimed    = Get-ClaimedNumbers $Prefix
$start      = 1
if ($claimed.Count -gt 0) { $start = (($claimed.Keys | Measure-Object -Maximum).Maximum) + 1 }

$created = $null
for ($n = $start; $n -lt $start + 50; $n++) {
    $id = "$Prefix$n"
    if ((Get-ClaimedNumbers $Prefix).ContainsKey($n)) { continue }   # re-scan: another agent may have landed one

    if ($DryRun) {
        Write-Output "docs/workflow/$Dest/$id-$slug.md"
        Write-Output "(dry run - nothing written)"
        return
    }

    $reserved = Join-Path $reserveDir "$id.md"
    try {
        $stream = [IO.File]::Open($reserved, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
    } catch [IO.IOException] {
        continue   # another run owns this number
    }

    # Verify only AFTER the reservation is held -- see the note in .DESCRIPTION.
    $lost  = Test-NumberTaken $Prefix $n
    $wrote = $false
    try {
        if (-not $lost) {
            $bytes = (New-Object Text.UTF8Encoding($false)).GetBytes((New-TicketBody $id $Title))
            $stream.Write($bytes, 0, $bytes.Length)
            $wrote = $true
        }
    } finally {
        $stream.Dispose()
        # Anything that threw above (drifted template, rejected -Bump) must give
        # the number back rather than leave an empty reservation holding it.
        if (-not $wrote) { Remove-Item -LiteralPath $reserved -Force -ErrorAction SilentlyContinue }
    }
    if ($lost) { continue }

    $path = Join-Path $destDir "$id-$slug.md"
    try {
        Move-Item -LiteralPath $reserved -Destination $path
    } catch {
        Remove-Item -LiteralPath $reserved -Force -ErrorAction SilentlyContinue
        throw
    }
    $created = $path
    break
}

if (-not $created) { throw "Could not claim a free $Prefix number after 50 attempts starting at $start." }

# Repo-relative, forward slashes: the one line the caller actually needs.
Write-Output $created.Substring($root.Length + 1).Replace('\', '/')
