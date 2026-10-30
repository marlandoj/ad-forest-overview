<#
.SYNOPSIS
    Populates the AD Forest Overview template (.docx) from live Active Directory data.

.DESCRIPTION
    Populate-ADForestOverview.ps1
    Companion to: AD Forest Overview Template (ad-forest-overview-template.docx)

    The script does three things:
      1. COLLECT  - reads the forest with the ActiveDirectory PowerShell module.
                    Domain controllers, trusts, object counts, password and
                    Kerberos policy, FGPP, gMSA, top-level OUs, GPOs and
                    protected groups are read PER DOMAIN (every domain in
                    Get-ADForest .Domains); a domain that fails is warned about
                    by name and the affected sections are marked partial.
                    Sites / subnets / site links, optional features, KDS root
                    keys and schema data are forest-level reads. DNS zones and
                    forwarders are read where the DnsServer module can reach a
                    DC.
      2. EXPORT   - writes the collected data to a timestamped data folder as
                    JSON (AD-Forest-Data.json) plus one CSV per template table,
                    Warnings.csv and SectionStatus.csv. The JSON carries the
                    collection warnings and a per-section ok / partial /
                    failed / skipped status, so -DataFile mode reports the
                    same gaps as the live run.
      3. POPULATE - copies the template to a temporary file next to the output
                    path, fills it in place by editing word/document.xml inside
                    the .docx (no Microsoft Word required), and only then moves
                    it to -OutputPath. Tables are found by their header text,
                    key/value tables by their row label, exactly as laid out in
                    the template. Section 4 (Domain Overview) is cloned once per
                    additional domain.

    WHAT IT FILLS AUTOMATICALLY
      Cover date and forest root domain; scope table; executive summary
      counts; forest overview (functional levels, schema version, tombstone
      and deleted-object lifetimes, Recycle Bin); forest FSMO table; the
      domains-in-forest table; per-domain section (SID, functional level,
      FSMO holders, counts, default password/lockout policy, Kerberos
      policy from the Default Domain Policy GPO report, FGPP table, gMSA
      table); trusts tables; sites, subnets and site-link tables; DC
      inventory (all five matched tables, hostname-ordered); the DC FQDN,
      Global Catalog and port columns of the services matrix; top-level OU
      table; GPO register; DNS zones / forwarders / conditional forwarders
      (when the DnsServer module can reach a DC); protected-group member
      counts; Appendix C validation run details; four generated vector figures
      (logical topology, schematic sites, replication and top-level OUs).

    WHAT IT DELIBERATELY LEAVES FOR A HUMAN
      Business purpose, risks, dependencies narrative, OU delegation
      rights, tiering rules, figure authorship, backup tooling, Entra ID
      tenant details, any "notes / owner" judgement fields, and SERVICE
      STATES (AD DS running, KDC, checked-on dates): the script does not
      probe DC services, so it does not write them. These cells keep the
      template placeholder. Where collection was partial the affected
      table gets a "PARTIAL COVERAGE" row and the validation table lists
      the warnings.

    MODES
      Default       Collect, export, and populate in one run.
      -ExportOnly   Collect and export only (run this on a DC or admin
                    workstation, then populate elsewhere with -DataFile).
      -DataFile     Populate from a previously exported AD-Forest-Data.json
                    without contacting AD.

    EXIT CODES
      0  Completed with no warnings and no partial or skipped sections.
      2  Completed, but warnings / partial or skipped coverage / fill failures
         exist (read the report). Also returned in -DataFile mode when the
         data file carries warnings or predates v1.1 (no warning record).
      1  Failed or refused (bad paths, template = output, existing output
         without -Overwrite, AD unreachable). No output document is left.

.NOTES
    Requirements : Windows PowerShell 5.1 or PowerShell 7, RSAT
                   ActiveDirectory module (GroupPolicy and DnsServer are
                   used opportunistically if present). Run as an account
                   with read rights in every domain you want documented.
                   -Credential applies to the ActiveDirectory cmdlets only;
                   GroupPolicy and DnsServer cmdlets run as the logged-on
                   user (the run report and the JSON record both identities).
                   To use alternate network credentials for all three modules,
                   start a separate shell with runas /netonly, for example:
                   runas /netonly /user:CORP\reader "powershell.exe -NoProfile"
                   Then run the script there without -Credential. /netonly
                   keeps the local identity; test remote access first. Identity
                   labels describe the local token, not the /netonly identity.
    Safety       : Read-only against AD (Get-* cmdlets only). The template
                   is never opened for writing: the script refuses an
                   -OutputPath that resolves to the -TemplatePath, refuses
                   an existing -OutputPath or a non-empty -OutputFolder
                   unless -Overwrite is given, and fills a temporary copy
                   that is deleted on failure.
    Load         : Full enumerations land on whichever DC the locator
                   picks per domain. Run outside peak hours, or pin a DC
                   for the bound domain with -Server. -SkipDnsForwarders
                   disables the per-DC forwarder sweep (not zone collection).
    Version      : 1.5.2 - 2026-10-30
    Change note  : 1.5.2 (2026-10-30) - accept fully resolved one-member site
                   links in Figure 6-2; preserve fail-closed validation and
                   conservative design classification.
                   1.5.1 (2026-10-29) - scoped analyzer remediation; reserved
                   xml:space serialization fix; abort publication on diagram
                   package-commit failure.
                   1.5 (2026-10-29) - generated vector topology figures; all
                   optional-feature scopes; five typed FGPP comparisons; query
                   execution diagnostics. Template v1.1.1 remains unchanged.
                   1.4.1 (2026-10-28) - publication-aware failure reporting;
                   disclose normalization count before run-evidence writes.
                   1.4 (2026-10-28) - DEF-05: normalize duplicate cell shading
                   before live/replay fills; disclose count in console and run
                   evidence. Normalization alone does not change the exit code.
                   1.3 (2026-10-27) - lab defects DEF-01 through DEF-04:
                   replay folder refusal; real-template automatic fields with
                   named fill failures; unknown-parent trust honesty; numbered
                   domain subheadings.
                   1.2 (2026-10-27) - residual review fixes R1-R5, Q3 and P3:
                   ACL-hidden empty reads are unverified; missing data tables
                   fail the fill; optional DNS forwarder sweep; hash-based
                   overwrite guard; tree-root labels; exact-first/longest-prefix
                   KV matching with ambiguity failures; skipped-count disclosure.
                   1.1 (2026-10-27) - implements the PowerShell Expert review
                   (factory task t_91200028) P0 items 1-6 and every P1 item:
                   per-domain DC and trust collection; fabricated service
                   states removed; warnings and section status saved to the
                   JSON and honoured in -DataFile mode; -ErrorAction Stop on
                   collection calls; non-zero exit codes; paths resolved up
                   front with template/overwrite guards (-Overwrite added);
                   per-domain splats (Windows PowerShell 5.1 safe); Kerberos
                   read from GPO report Account elements; KDS root keys read
                   from the configuration partition; strict row/cell
                   validation; content-control-aware cell writes; cloned
                   Section 4 IDs made unique. See the delivery change log.
                   1.0 (2026-10-26) - initial version.

.EXAMPLE
    .\Populate-ADForestOverview.ps1 -TemplatePath .\ad-forest-overview-template.docx -OutputPath .\AD-Forest-Overview-corp.docx

.EXAMPLE
    .\Populate-ADForestOverview.ps1 -ExportOnly -OutputFolder .\evidence

.EXAMPLE
    .\Populate-ADForestOverview.ps1 -TemplatePath .\ad-forest-overview-template.docx -OutputPath .\AD-Forest-Overview-corp.docx -DataFile .\evidence\AD-Forest-Data.json -Overwrite
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$TemplatePath,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath,

    # Evidence folder. Default is a new timestamped folder under the current
    # location; an existing non-empty folder is refused unless -Overwrite.
    [Parameter(Mandatory = $false)]
    [string]$OutputFolder = (Join-Path (Get-Location) ('AD-Forest-Overview-Data-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))),

    [Parameter(Mandatory = $false)]
    [string]$DataFile,

    [switch]$ExportOnly,

    # Allow replacing an existing -OutputPath document and reusing a non-empty
    # -OutputFolder (this script's own previous evidence files are removed first).
    [switch]$Overwrite,

    # Optional: pin a DC for the bound domain and alternate credentials.
    # Other domains are reached through their DNS name (DC locator).
    [string]$Server,
    [System.Management.Automation.PSCredential]$Credential,

    # Object counts (users/computers/groups per domain) are streamed with a
    # minimal property set, but can still be slow in very large domains.
    [switch]$SkipObjectCounts,

    # GPO link resolution reads gPLink from domain, OU and site objects.
    # Skip it if you only need the register itself.
    [switch]$SkipGpoLinks,

    # One RPC/CIM read per DC; opt out on large or firewalled forests.
    [switch]$SkipDnsForwarders
)

$ErrorActionPreference = 'Continue'
$script:ScriptVersion   = '1.5.2'
$script:NormalizedShadingCells = 0
$script:DiagramResults = @()
$script:DiagramStatus = [ordered]@{}
$script:Warnings        = New-Object System.Collections.ArrayList   # raised in this process
$script:Notes           = New-Object System.Collections.ArrayList   # informational, not warnings
$script:Filled          = New-Object System.Collections.ArrayList
$script:PartialFills    = New-Object System.Collections.ArrayList
$script:FillFailures    = New-Object System.Collections.ArrayList
$script:Skipped         = New-Object System.Collections.ArrayList
$script:SectionStatus   = [ordered]@{}
$script:Coverage        = [ordered]@{}
$script:CollectionDiagnostics = New-Object System.Collections.ArrayList
$script:LiveCollection  = $false
$script:DataCollectedAt = ''
$script:IdState         = $null   # id counters for cloned XML (set per document)
# Sentinel for "leave the template placeholder in this cell" (human-only fields).
$script:KeepPlaceholder = New-Object psobject

function Add-Warn([string]$Message) {
    [void]$script:Warnings.Add($Message)
    Write-Warning $Message
}
function Add-Note([string]$Message) { [void]$script:Notes.Add($Message) }
function Add-Filled([string]$Message) { [void]$script:Filled.Add($Message) }
function Add-PartialFill([string]$Message) { [void]$script:PartialFills.Add($Message) }
function Add-FillFailure([string]$Message) {
    [void]$script:FillFailures.Add($Message)
    Write-Warning "Table fill FAILED: $Message"
}
function Add-Skipped([string]$Message) { [void]$script:Skipped.Add($Message) }

function Test-Keep($Value) { return [object]::ReferenceEquals($Value, $script:KeepPlaceholder) }

function Set-SectionStatus([string]$Section, [string]$Status, [string]$Detail = '') {
    $script:SectionStatus[$Section] = [pscustomobject]@{ Status = $Status; Detail = $Detail }
}

function Register-Coverage([string]$Section, [string]$Scope, [bool]$Ok) {
    if (-not $script:Coverage.Contains($Section)) {
        $script:Coverage[$Section] = [pscustomobject]@{ Ok = 0; Failed = (New-Object System.Collections.ArrayList) }
    }
    $c = $script:Coverage[$Section]
    if ($Ok) { $c.Ok = $c.Ok + 1 } else { [void]$c.Failed.Add($Scope) }
}

function Complete-Coverage {
    foreach ($key in @($script:Coverage.Keys)) {
        $c = $script:Coverage[$key]
        $status = 'ok'
        if ($c.Failed.Count -gt 0) { if ($c.Ok -gt 0) { $status = 'partial' } else { $status = 'failed' } }
        $detail = ''
        if ($c.Failed.Count -gt 0) { $detail = 'not collected for: ' + (@($c.Failed) -join ', ') }
        $outcomes = @($script:CollectionDiagnostics | Where-Object { $_.Section -eq $key -and $_.Outcome -ne 'successful-nonempty' })
        if ($outcomes.Count -gt 0) {
            $diagnosticText = (@($outcomes | ForEach-Object { "$($_.Scope): $($_.Outcome) - $($_.Detail)" }) -join '; ')
            if ($detail -ne '') { $detail += '; ' }
            $detail += $diagnosticText
        }
        Set-SectionStatus $key $status $detail
    }
}

function Get-Prop($Object, [string]$Name) {
    if ($null -eq $Object) { return $null }
    $p = $Object.PSObject.Properties[$Name]
    if ($null -eq $p) { return $null }
    return $p.Value
}

function Join-List($Values, [string]$Separator = '; ') {
    if ($null -eq $Values) { return '' }
    $items = @($Values) | Where-Object { $null -ne $_ -and "$_".Trim() -ne '' }
    return ($items -join $Separator)
}

function Get-DnName([string]$Dn) {
    # 'CN=SiteA,CN=Sites,CN=Configuration,...' -> 'SiteA'  (honours escaped commas: 'CN=Smith\, J,OU=..')
    if ([string]::IsNullOrEmpty($Dn)) { return '' }
    if ($Dn -match '^[^=]+=((?:\\.|[^,\\])*)') { return ($Matches[1] -replace '\\(.)', '$1') }
    return $Dn
}

function Get-NtdsServerName([string]$NtdsSettingsDn) {
    # 'CN=NTDS Settings,CN=DC01,CN=Servers,...' -> 'DC01'
    if ([string]::IsNullOrEmpty($NtdsSettingsDn)) { return '' }
    if ($NtdsSettingsDn -match '^[^=]+=(?:\\.|[^,\\])*,[^=]+=((?:\\.|[^,\\])*)') { return ($Matches[1] -replace '\\(.)', '$1') }
    return ''
}

function ConvertFrom-DomainDn([string]$Value) {
    # 'DC=emea,DC=corp,DC=example' -> 'emea.corp.example'; DNS names pass through.
    if ($Value -match '^(?i)\s*DC=') {
        return ((@($Value -split ',') | Where-Object { $_ -match '^(?i)\s*DC=' } | ForEach-Object { ($_ -replace '^(?i)\s*DC=', '') }) -join '.')
    }
    return $Value
}

function ConvertTo-LdapFilterValue([string]$Value) {
    return ($Value -replace '\\', '\5c' -replace '\*', '\2a' -replace '\(', '\28' -replace '\)', '\29' -replace "`0", '\00')
}

function Get-ChildText($Node, [string]$LocalName) {
    $n = $Node.SelectSingleNode("*[local-name()='$LocalName']")
    if ($n) { return $n.InnerText }
    return ''
}

# ---------------------------------------------------------------------------
# COLLECTION
# ---------------------------------------------------------------------------

function New-DomainParams([string]$DomainDns, [string]$BoundDomain) {
    # Built fresh for every domain so -Server appears exactly once. Windows
    # PowerShell 5.1 rejects an explicit -Server next to a splat that already
    # contains Server ("specified more than once"), so callers must never add
    # an explicit -Server to a call that uses this splat.
    $p = @{}
    if ($Server -and $BoundDomain -and $DomainDns -eq $BoundDomain) { $p['Server'] = $Server } else { $p['Server'] = $DomainDns }
    if ($Credential) { $p['Credential'] = $Credential }
    return $p
}

function Get-KerberosPolicy([string]$DomainDns) {
    # Kerberos policy lives in the Default Domain Policy GPO (well-known GUID, so
    # localized GPO names do not matter). GPO XML reports carry it as Account
    # elements: Name = MaxTicketAge / MaxRenewAge / MaxClockSkew, Type = Kerberos.
    # Throws on failure; the caller warns.
    $result = @{ MaxTicketAge = ''; MaxRenewalAge = ''; MaxClockSkew = ''; Found = 0 }
    [xml]$report = Get-GPOReport -Guid '31B2F340-016D-11D2-945F-00C04FB984F9' -Domain $DomainDns -ReportType Xml -ErrorAction Stop
    foreach ($account in @($report.SelectNodes("//*[local-name()='Account']"))) {
        if ((Get-ChildText $account 'Type') -ne 'Kerberos') { continue }
        $value = Get-ChildText $account 'SettingNumber'
        switch (Get-ChildText $account 'Name') {
            'MaxTicketAge' { $result.MaxTicketAge  = "$value hours (Default Domain Policy)"; $result.Found++ }
            'MaxRenewAge'  { $result.MaxRenewalAge = "$value days (Default Domain Policy)"; $result.Found++ }
            'MaxClockSkew' { $result.MaxClockSkew  = "$value minutes (Default Domain Policy)"; $result.Found++ }
        }
    }
    return $result
}

function Get-ScheduleText($Schedule) {
    if ($null -eq $Schedule) { return 'Always available (no schedule set)' }
    try {
        $raw = $Schedule.RawSchedule
        if ($null -ne $raw) {
            $total = 0; $on = 0
            foreach ($slot in $raw) { $total++; if ($slot) { $on++ } }
            if ($total -gt 0) {
                if ($on -eq $total) { return 'Schedule set - available at all times' }
                return "Custom schedule - available $([math]::Round(100 * $on / $total))% of the week (see Sites and Services)"
            }
        }
    } catch {
        Write-Verbose "Schedule object not decoded: $($_.Exception.Message)"
    }
    return 'Custom schedule - see Sites and Services'
}

function Get-TrustRow($Trust, [string]$ReadFrom, $DomainParents, [string]$RootDomain) {
    $src = ConvertFrom-DomainDn "$($Trust.Source)"
    $tgt = "$($Trust.Target)"
    $attr = 0
    try { $attr = [int](Get-Prop $Trust 'TrustAttributes') } catch { $attr = 0 }
    $intra   = [bool](Get-Prop $Trust 'IntraForest') -or (($attr -band 0x20) -ne 0)
    $forestT = [bool](Get-Prop $Trust 'ForestTransitive') -or (($attr -band 0x8) -ne 0)
    $tt = "$($Trust.TrustType)"
    if ($tt -eq 'MIT') { $kind = 'Realm (MIT Kerberos)' }
    elseif ($intra) {
        $srcParent = "$($DomainParents[$src.ToLower()])"
        $tgtParent = "$($DomainParents[$tgt.ToLower()])"
        # Missing mappings are unknown, not evidence of a second tree root.
        # Only successful Get-ADDomain reads populate DomainParents.
        $srcKnown = $DomainParents.ContainsKey($src.ToLower()) -or $src -eq $RootDomain
        $tgtKnown = $DomainParents.ContainsKey($tgt.ToLower()) -or $tgt -eq $RootDomain
        if (($srcParent -eq $tgt -or $tgtParent -eq $src)) { $kind = 'Parent-child' }
        elseif ((-not $srcKnown -and $src -match ('^[^.]+\.' + [regex]::Escape($tgt) + '$')) -or
                (-not $tgtKnown -and $tgt -match ('^[^.]+\.' + [regex]::Escape($src) + '$'))) { $kind = 'Parent-child' }
        elseif (($src -eq $RootDomain -and $tgtKnown -and $tgtParent -eq '') -or
                ($tgt -eq $RootDomain -and $srcKnown -and $srcParent -eq '')) { $kind = 'Tree-root' }
        elseif ($srcKnown -and $tgtKnown) { $kind = 'Shortcut' }
        else {
            $kind = 'Unverified intra-forest'
            Add-Warn "Trust kind unverified for $src -> $tgt - parent-domain mapping unavailable; DNS hierarchy does not establish a direct parent-child relationship."
            Register-Coverage 'Trusts' "$src -> $tgt (trust kind unverified)" $false
        }
    }
    elseif ($forestT) { $kind = 'Forest' }
    else { $kind = 'External' }

    if (($attr -band 0x1) -ne 0 -or [bool](Get-Prop $Trust 'DisallowTransivity')) { $transitive = 'No (non-transitive attribute set)' }
    elseif ($kind -eq 'External') { $transitive = 'No (external trusts are non-transitive)' }
    else { $transitive = 'Yes' }

    if ($intra) { $sidFiltering = 'Not applicable (intra-forest trust)' }
    elseif ($kind -eq 'Forest') { $sidFiltering = "SIDFilteringForestAware = $(Get-Prop $Trust 'SIDFilteringForestAware')" }
    else { $sidFiltering = "SIDFilteringQuarantined = $(Get-Prop $Trust 'SIDFilteringQuarantined')" }

    return [pscustomobject]@{
        Source = $src; Target = $tgt; Type = "$kind ($tt)"
        Direction = "$($Trust.Direction)"; Transitive = $transitive
        SelectiveAuth = if ($null -ne (Get-Prop $Trust 'SelectiveAuthentication')) { "$(Get-Prop $Trust 'SelectiveAuthentication')" } else { '' }
        SidFiltering = $sidFiltering
        Notes = ('Read from {0}; trust attributes 0x{1:X}' -f $ReadFrom, $attr)
        Key = ((@($src.ToLower(), $tgt.ToLower()) | Sort-Object) -join '|')
    }
}

function Merge-GpLinkMap($Map, $Objects) {
    # gPLink = '[LDAP://cn={GUID},cn=policies,cn=system,DC=x;0][...]'. Option bit 1 = link disabled, bit 2 = enforced.
    foreach ($o in @($Objects)) {
        $gpl = "$(Get-Prop $o 'gPLink')"
        foreach ($m in [regex]::Matches($gpl, '\[LDAP://([^;\]]+);(\d+)\]', 'IgnoreCase')) {
            $gpoDn = $m.Groups[1].Value.ToLower()
            $opt = [int]$m.Groups[2].Value
            $flags = @()
            if (($opt -band 1) -ne 0) { $flags += 'link disabled' }
            if (($opt -band 2) -ne 0) { $flags += 'enforced' }
            $text = "$($o.DistinguishedName)"
            if ($flags.Count -gt 0) { $text += " [$($flags -join ', ')]" }
            if (-not $Map.ContainsKey($gpoDn)) { $Map[$gpoDn] = New-Object System.Collections.ArrayList }
            [void]$Map[$gpoDn].Add($text)
        }
    }
}

function Get-RestrictedEmptyText([string]$Identity) {
    # No privilege inference from a username, local elevation, or an empty LDAP
    # result. We do not establish effective remote AD rights in this script.
    return "None visible to $Identity - reading these objects needs Domain Admins-equivalent rights; verify as an admin"
}

function Test-DnsNotServer($Record) {
    # Only positive evidence of a missing DNS role/service is informational.
    # RPC, firewall and access-denied errors still warn (not proof of no role).
    if ("$($Record.Exception.Message)" -match '(?i)not a DNS server|DNS (server )?(role|service) (is )?not installed|specified service does not exist') { return $true }
    return ("$(Get-Prop $Record.Exception 'NativeErrorCode')" -eq '1060')
}

# Collection outcomes describe query execution, not authoritative object absence.
# Privileged successful-empty reads retain the existing coverage-gap discipline.
function Register-CollectionResult([string]$Section, [string]$Scope, [bool]$Succeeded,
    $Count, [string]$Identity, [string]$ErrorText = '', [bool]$Restricted = $false) {
    $outcome = 'failed'
    $detail = $ErrorText
    if ($Succeeded) {
        if ([int]$Count -eq 0) {
            $outcome = 'successful-empty'
            $detail = "Successful query; no visible objects for identity $Identity (not authoritative absence)"
        } else {
            $outcome = 'successful-nonempty'
            $detail = "Successful query; $Count visible object(s)"
        }
    } else { $Count = $null }
    [void]$script:CollectionDiagnostics.Add([pscustomobject]@{
        Section = $Section; Scope = $Scope; Outcome = $outcome; Count = $Count
        Identity = $Identity; Detail = $detail; CollectedAt = $script:DataCollectedAt
    })
    $ok = $Succeeded -and (-not $Restricted -or [int]$Count -gt 0)
    $coverageScope = $Scope
    if (-not $ok -and $Succeeded) { $coverageScope = "$Scope - $detail" }
    Register-Coverage -Section $Section -Scope $coverageScope -Ok $ok
}

function Get-CollectionState($Data, [string[]]$Sections) {
    $state = Get-SectionState $Data $Sections
    $empty = @($Data['CollectionDiagnostics'] | Where-Object {
        $null -ne $_ -and $_.Section -in $Sections -and $_.Outcome -eq 'successful-empty'
    })
    if ($empty.Count -eq 0) { return $state }
    $text = (@($empty | ForEach-Object { "$($_.Section) [$($_.Scope)]: $($_.Detail)" }) -join '; ')
    if ($null -eq $state) { $state = [pscustomobject]@{ Status = 'ok'; Detail = '' } }
    # Failed-read details always take priority over successful-empty messages.
    if ($state.Status -in @('failed', 'partial')) {
        return [pscustomobject]@{ Status = $state.Status; Detail = "$($state.Detail); $text" }
    }
    return [pscustomobject]@{ Status = $state.Status; Detail = $text; EmptyText = $text }
}

# Replay recursively converts JSON objects to dictionaries; live DTOs are objects.
function Get-EvidenceValue($Object, [string]$Name) {
    if ($Object -is [System.Collections.IDictionary]) { return $Object[$Name] }
    return Get-Prop $Object $Name
}

function ConvertTo-PolicyBoolean($Value) {
    if ($Value -is [bool]) { return $Value }
    return $null
}

function ConvertTo-PolicyInterval($Value, [string]$Unit) {
    if ($null -eq $Value -or "$Value" -eq '') { return $null }
    $span = [TimeSpan]::Zero
    if ($Value -is [TimeSpan]) { $span = $Value }
    elseif (-not [TimeSpan]::TryParse("$Value", [Globalization.CultureInfo]::InvariantCulture, [ref]$span)) { return $null }
    if ($span.Ticks -lt 0) { return $null }
    if ($Unit -eq 'days') { return [double]$span.TotalDays }
    return [double]$span.TotalMinutes
}

function ConvertTo-PasswordSetting($Policy) {
    # Explicit evidence units: MinPasswordAge = days; lockout intervals = minutes.
    # Null is unknown, never coerced to false or zero. JSON stores booleans/numbers.
    return [pscustomobject]@{
        ComplexityEnabled = ConvertTo-PolicyBoolean (Get-Prop $Policy 'ComplexityEnabled')
        ReversibleEncryptionEnabled = ConvertTo-PolicyBoolean (Get-Prop $Policy 'ReversibleEncryptionEnabled')
        MinPasswordAge = ConvertTo-PolicyInterval (Get-Prop $Policy 'MinPasswordAge') 'days'
        LockoutObservationWindow = ConvertTo-PolicyInterval (Get-Prop $Policy 'LockoutObservationWindow') 'minutes'
        LockoutDuration = ConvertTo-PolicyInterval (Get-Prop $Policy 'LockoutDuration') 'minutes'
    }
}

function Format-PasswordSetting([string]$Name, $Value) {
    if ($null -eq $Value) { return 'unknown (not collected)' }
    if ($Name -in @('ComplexityEnabled', 'ReversibleEncryptionEnabled')) {
        if ($Value -isnot [bool]) { return 'unknown (invalid evidence type)' }
        if ($Value) { return 'Yes' }; return 'No'
    }
    if ($Value -isnot [ValueType] -or $Value -is [bool]) { return 'unknown (invalid evidence type)' }
    $number = [double]$Value
    if ([double]::IsNaN($number) -or [double]::IsInfinity($number) -or $number -lt 0) { return 'unknown (invalid evidence value)' }
    if ($number -eq 0) {
        switch ($Name) {
            'MinPasswordAge' { return 'can change immediately (zero minimum age)' }
            'LockoutObservationWindow' { return 'zero reset interval (no waiting interval; not a claim that lockout is disabled)' }
            'LockoutDuration' { return 'until an administrator unlocks' }
        }
    }
    $unit = 'minutes'
    if ($Name -eq 'MinPasswordAge') { $unit = 'days' }
    return ($number.ToString('0.########', [Globalization.CultureInfo]::InvariantCulture) + ' ' + $unit)
}

function Get-FgppComparison($Policy, $Domain) {
    $default = Get-EvidenceValue $Domain 'PasswordSettings'
    $parts = New-Object System.Collections.ArrayList
    if ("$($Policy.Notes)" -ne '') { [void]$parts.Add("$($Policy.Notes)") }
    foreach ($name in @('ComplexityEnabled', 'ReversibleEncryptionEnabled', 'MinPasswordAge', 'LockoutObservationWindow', 'LockoutDuration')) {
        $value = Get-EvidenceValue $Policy $name
        $reference = Get-EvidenceValue $default $name
        $text = Format-PasswordSetting $name $value
        $refText = Format-PasswordSetting $name $reference
        if ($text -like 'unknown*' -or $refText -like 'unknown*') {
            [void]$parts.Add("${name}: $text (default: $refText; comparison unknown)")
        } elseif ($value -eq $reference) {
            [void]$parts.Add("${name}: $text (same as default)")
        } else { [void]$parts.Add("${name}: $text (default: $refText; differs)") }
    }
    return (@($parts) -join '; ')
}

function Write-OptionalFeature($Tables, $Ns, $Data) {
    $rows = @($Data['OptionalFeatures'] | Where-Object { $null -ne $_ } | Sort-Object { $_.Name } | ForEach-Object {
        $enabled = Get-EvidenceValue $_ 'Enabled'
        $status = 'Unknown (not collected)'
        if ($enabled -is [bool]) { if ($enabled) { $status = 'Enabled' } else { $status = 'Not enabled' } }
        $hasScopes = $null -ne $_.PSObject.Properties['EnabledScopes']
        if ($_ -is [System.Collections.IDictionary]) { $hasScopes = $_.Contains('EnabledScopes') }
        $scopeText = 'Unknown (not collected in evidence)'
        if ($hasScopes -and $null -ne $_.EnabledScopes) {
            $scopeText = Join-List @($_.EnabledScopes | Sort-Object)
            if ($scopeText -eq '') { $scopeText = 'No visible enabled scopes (successful feature read)' }
        }
        ,@($_.Name, $status, $scopeText, $script:KeepPlaceholder)
    })
    $state = Get-CollectionState $Data @('OptionalFeatures')
    $outcomes = @($Data['CollectionDiagnostics'] | Where-Object { $null -ne $_ -and $_.Section -eq 'OptionalFeatures' })
    if ($rows.Count -eq 0 -and $outcomes.Count -eq 0 -and ($null -eq $state -or $state.Status -eq 'ok')) {
        $state = [pscustomobject]@{ Status = 'partial'; Detail = 'Optional feature evidence has no query outcome; visibility unknown'; EmptyText = 'Optional features unknown (no query outcome in evidence)' }
    }
    # Generic table cloning copies the first data row. Never copy a human-entered
    # enablement date to a new feature when the register grows beyond the template.
    $table = Find-Table -Tables $Tables -Ns $Ns -FirstRowSignatures @('Feature', 'Status', 'Scope / notes')
    $existingCount = 0
    if ($null -ne $table) { $existingCount = (Get-TableRows $table $Ns).Count }
    Write-DataTable -Tables $Tables -Ns $Ns -Signatures @('Feature', 'Status', 'Scope / notes') -DataRows $rows -Label 'Optional features' -State $state
    if ($null -ne $table) {
        $writtenRows = Get-TableRows $table $Ns
        for ($i = $existingCount; $i -lt $writtenRows.Count; $i++) {
            $cells = Get-RowCells $writtenRows.Item($i) $Ns
            if ($cells.Count -eq 4) { Set-CellText -Cell $cells.Item(3) -Ns $Ns -Value 'Unknown (not collected)' }
        }
    }
}

function Get-ADForestData {
    Import-Module ActiveDirectory -ErrorAction Stop
    # Forest-level splat (sites, config and schema partition reads). Per-domain
    # calls use New-DomainParams instead - never both on one call.
    $adParams = @{}
    if ($Server)     { $adParams['Server'] = $Server }
    if ($Credential) { $adParams['Credential'] = $Credential }

    $hasGP = $false
    if (Get-Module -ListAvailable GroupPolicy) {
        try { Import-Module GroupPolicy -ErrorAction Stop; $hasGP = $true }
        catch { Add-Warn "GroupPolicy module present but not loaded: $($_.Exception.Message)" }
    }
    $hasDns = [bool](Get-Module -ListAvailable DnsServer)

    $currentUser = "$env:USERDOMAIN\$env:USERNAME"
    $adIdentity = $currentUser
    if ($Credential) { $adIdentity = $Credential.UserName }

    $data = [ordered]@{}
    $data['ScriptVersion'] = $script:ScriptVersion
    $data['CollectedAt']   = (Get-Date).ToString('yyyy-MM-dd HH:mm')
    $data['CollectedBy']   = $adIdentity
    if ($Credential) { $data['CollectedBy'] = "$adIdentity (ActiveDirectory); $currentUser (GroupPolicy, DnsServer)" }
    $data['CollectedFrom'] = $env:COMPUTERNAME
    $data['Identities']    = [pscustomobject]@{ ActiveDirectory = $adIdentity; GroupPolicy = $currentUser; DnsServer = $currentUser }
    if ($Credential) {
        Add-Note "-Credential was applied to ActiveDirectory cmdlets only. GroupPolicy (Get-GPO, Get-GPOReport) and DnsServer cmdlets do not accept it and ran as $currentUser."
    }
    $script:DataCollectedAt = $data['CollectedAt']

    # --- Forest (fail closed: without the forest object nothing is meaningful) -
    $forest  = Get-ADForest @adParams -ErrorAction Stop
    $rootDse = Get-ADRootDSE @adParams -ErrorAction Stop
    $configNC = $rootDse.configurationNamingContext
    $schemaNC = $rootDse.schemaNamingContext

    $schemaVersion = ''
    try { $schemaVersion = "$((Get-ADObject -Identity $schemaNC -Properties objectVersion @adParams -ErrorAction Stop).objectVersion)"; Register-Coverage 'Forest' 'schema version' $true }
    catch { Add-Warn "Schema version not read: $($_.Exception.Message)"; Register-Coverage 'Forest' 'schema version' $false }
    $dsService = $null
    try {
        $dsService = Get-ADObject -Identity "CN=Directory Service,CN=Windows NT,CN=Services,$configNC" `
                        -Properties tombstoneLifetime, 'msDS-DeletedObjectLifetime' @adParams -ErrorAction Stop
        Register-Coverage 'Forest' 'lifetimes' $true
    } catch { Add-Warn "Tombstone / deleted-object lifetime not read: $($_.Exception.Message)"; Register-Coverage 'Forest' 'lifetimes' $false }

    $recycleBin = ''
    $pamFeature = ''
    try {
        $features = @(Get-ADOptionalFeature -Filter * @adParams -ErrorAction Stop)
        foreach ($f in $features) {
            if ($null -eq $f.PSObject.Properties['EnabledScopes'] -or $null -eq $f.EnabledScopes) { continue }
            $enabled = @($f.EnabledScopes | Where-Object { $null -ne $_ -and "$_" -ne '' }).Count -gt 0
            if ($f.Name -like '*Recycle Bin*') {
                if ($enabled) { $recycleBin = 'Enabled' } else { $recycleBin = 'Not enabled' }
            }
            if ($f.Name -like '*Privileged Access Management*') {
                if ($enabled) { $pamFeature = 'Present - enabled' } else { $pamFeature = 'Present - not enabled' }
            }
        }
        $data['OptionalFeatures'] = @($features | ForEach-Object {
            $scopeProperty = $_.PSObject.Properties['EnabledScopes']
            $scopes = @($_.EnabledScopes | Where-Object { $null -ne $_ -and "$_" -ne '' } | ForEach-Object { "$_" })
            [pscustomobject]@{
                Name = $_.Name
                Enabled = if ($null -ne $scopeProperty -and $null -ne $scopeProperty.Value) { $scopes.Count -gt 0 } else { $null }
                EnabledScopes = if ($null -ne $scopeProperty -and $null -ne $scopeProperty.Value) { ,$scopes } else { $null }
            }
        })
        Register-CollectionResult -Section 'OptionalFeatures' -Scope 'forest' -Succeeded $true -Count $features.Count -Identity $adIdentity -ErrorText '' -Restricted $true
    } catch {
        Add-Warn "Optional features not read: $($_.Exception.Message)"
        $data['OptionalFeatures'] = @()
        $recycleBin = ''; $pamFeature = ''
        Register-CollectionResult -Section 'OptionalFeatures' -Scope 'forest' -Succeeded $false -Count $null -Identity $adIdentity -ErrorText $_.Exception.Message -Restricted $true
    }

    # --- KDS root keys: forest-level objects in the configuration partition --
    # (Get-KdsRootKey has no -Server/-Credential; read the objects directly.)
    $kds = ''
    try {
        $keys = @(Get-ADObject -SearchBase "CN=Master Root Keys,CN=Group Key Distribution Service,CN=Services,$configNC" `
                    -LDAPFilter '(objectClass=msKds-ProvRootKey)' -Properties 'msKds-UseStartTime', whenCreated @adParams -ErrorAction Stop)
        if ($keys.Count -gt 0) {
            $earliest = $keys | Sort-Object { [long](Get-Prop $_ 'msKds-UseStartTime') } | Select-Object -First 1
            $effective = [DateTime]::FromFileTimeUtc([long](Get-Prop $earliest 'msKds-UseStartTime')).ToString('yyyy-MM-dd')
            $kds = "Yes - $($keys.Count) key(s); earliest effective $effective (UTC)"
            Register-Coverage 'KdsRootKey' 'forest' $true
        } else {
            $kds = Get-RestrictedEmptyText $adIdentity
            Add-Note "KdsRootKey (forest): $kds"
            Register-Coverage 'KdsRootKey' "forest - $kds" $false
        }
    } catch {
        Add-Warn "KDS root keys not read (CN=Master Root Keys): $($_.Exception.Message)"
        Register-Coverage 'KdsRootKey' 'forest' $false
    }

    $data['Forest'] = [pscustomobject]@{
        RootDomain        = $forest.RootDomain
        RootNetBIOS       = ''
        ForestMode        = "$($forest.ForestMode)"
        SchemaMaster      = $forest.SchemaMaster
        DomainNamingMaster = $forest.DomainNamingMaster
        SchemaVersion     = $schemaVersion
        TombstoneLifetime = "$(Get-Prop $dsService 'tombstoneLifetime')"
        DeletedObjectLifetime = "$(Get-Prop $dsService 'msDS-DeletedObjectLifetime')"
        DeletedObjectLifetimeRead = ($null -ne $dsService)
        RecycleBin        = $recycleBin
        PamFeature        = $pamFeature
        KdsRootKey        = $kds
        Sites             = @($forest.Sites)
        Domains           = @($forest.Domains)
        GlobalCatalogs    = @($forest.GlobalCatalogs)
        UPNSuffixes       = @($forest.UPNSuffixes)
        SPNSuffixes       = @($forest.SPNSuffixes)
    }

    $boundDomain = ''
    if ($Server) {
        try { $boundDomain = (Get-ADDomain @adParams -ErrorAction Stop).DNSRoot }
        catch { Add-Warn "Domain of -Server $Server not read; every domain will be reached by DNS name: $($_.Exception.Message)" }
    }
    $forestDomains = @($forest.Domains)

    # --- Domain controllers: Get-ADDomainController is domain-scoped, so ask every domain
    $rawDCs = New-Object System.Collections.ArrayList
    $dcFailedDomains = @{}
    foreach ($domainDns in $forestDomains) {
        $dp = New-DomainParams $domainDns $boundDomain
        try {
            $found = @(Get-ADDomainController -Filter * @dp -ErrorAction Stop)
            if ($found.Count -eq 0) { throw 'no domain controllers returned' }
            foreach ($x in $found) { [void]$rawDCs.Add($x) }
            Register-Coverage 'DomainControllers' $domainDns $true
        } catch {
            $dcFailedDomains[$domainDns.ToLower()] = $true
            Add-Warn "Domain controllers not read for domain ${domainDns}: $($_.Exception.Message)"
            Register-Coverage 'DomainControllers' $domainDns $false
        }
    }
    $allDCs = @($rawDCs | Sort-Object -Property HostName -Unique)
    $data['DomainControllers'] = @($allDCs | ForEach-Object {
        $roles = @($_.OperationMasterRoles | ForEach-Object { "$_" })
        [pscustomobject]@{
            HostName   = $_.HostName
            Name       = $_.Name
            Domain     = $_.Domain
            Site       = $_.Site
            IPv4       = $_.IPv4Address
            IPv6       = $_.IPv6Address
            OS         = "$($_.OperatingSystem) $($_.OperatingSystemServicePack)".Trim()
            OSVersion  = "$($_.OperatingSystemVersion)"
            IsGC       = [bool]$_.IsGlobalCatalog
            IsRODC     = [bool]$_.IsReadOnly
            FSMORoles  = ($roles -join '; ')
            Enabled    = [bool]$_.Enabled
            LdapPort   = $_.LdapPort
            SslPort    = $_.SslPort
        }
    })
    $dcByHost = @{}
    foreach ($dc in $data['DomainControllers']) { $dcByHost[("$($dc.HostName)").ToLower()] = $dc }
    $siteOfDC = {
        param($fqdn, $domainDns)
        $d = $dcByHost[("$fqdn").ToLower()]
        if ($d) { return $d.Site }
        if ($dcFailedDomains[("$domainDns").ToLower()]) { return 'Unknown - DC list not collected' }
        return ''
    }

    # --- Domains --------------------------------------------------------------
    $domainRows = New-Object System.Collections.ArrayList
    $domainDetails = New-Object System.Collections.ArrayList
    foreach ($domainDns in $forestDomains) {
        $dp = New-DomainParams $domainDns $boundDomain
        $notCollected = New-Object System.Collections.ArrayList
        try {
            $dom = Get-ADDomain -Identity $domainDns @dp -ErrorAction Stop
            Register-Coverage 'Domains' $domainDns $true
        } catch {
            Add-Warn "Domain $domainDns not read (Get-ADDomain): $($_.Exception.Message) - its Section 4 block is marked NOT COLLECTED."
            Register-Coverage 'Domains' $domainDns $false
            [void]$domainRows.Add([pscustomobject]@{ FQDN = $domainDns; NetBIOS = ''; DomainMode = 'NOT COLLECTED - see warnings'; Parent = '' })
            [void]$domainDetails.Add([pscustomobject]@{
                FQDN = $domainDns; CollectionStatus = 'NotCollected'; NotCollected = @('Domain'); NetBIOS = ''; SID = ''; DomainDN = ''
                Parent = ''; DomainMode = ''; DCCounts = ''; Users = ''; Computers = ''; Groups = ''
                PDCEmulator = ''; RIDMaster = ''; InfrastructureMaster = ''; PDCEmulatorSite = ''; RIDMasterSite = ''; InfrastructureMasterSite = ''
                MinPasswordLength = ''; PasswordHistory = ''; MaxPasswordAge = ''; MinPasswordAge = ''; Complexity = ''
                LockoutThreshold = ''; LockoutDuration = ''; LockoutWindow = ''; KerbTicket = ''; KerbRenewal = ''; KerbSkew = ''
                PolicySourceGpo = ''; FGPP = @(); GMSA = @()
            })
            continue
        }
        if ($data['Forest'].RootNetBIOS -eq '' -and $domainDns -eq $forest.RootDomain) {
            $data['Forest'].RootNetBIOS = $dom.NetBIOSName
        }
        if ($dcFailedDomains[$domainDns.ToLower()]) {
            $dcCountText = 'NOT COLLECTED - DC list for this domain could not be read (see warnings)'
            [void]$notCollected.Add('DomainControllers')
        } else {
            $writable = @($allDCs | Where-Object { $_.Domain -eq $domainDns -and -not $_.IsReadOnly }).Count
            $rodc     = @($allDCs | Where-Object { $_.Domain -eq $domainDns -and $_.IsReadOnly }).Count
            $dcCountText = "Writable: $writable  RODC: $rodc  Total: $($writable + $rodc)"
        }

        [void]$domainRows.Add([pscustomobject]@{
            FQDN = $dom.DNSRoot; NetBIOS = $dom.NetBIOSName
            DomainMode = "$($dom.DomainMode)"
            Parent = if ($dom.ParentDomain) { $dom.ParentDomain } elseif ($dom.DNSRoot -eq $forest.RootDomain) { 'Forest root' } else { "Tree root (trust parent: $($forest.RootDomain))" }
        })

        # Object counts: minimal property set (Get-ADObject default = DN/Name/class/GUID),
        # streamed into Measure-Object, one try per object class.
        $counts = @{ Users = ''; Computers = ''; Groups = '' }
        if (-not $SkipObjectCounts) {
            foreach ($kind in @(
                    @{ Key = 'Users';     Filter = '(&(objectCategory=person)(objectClass=user))' },
                    @{ Key = 'Computers'; Filter = '(objectCategory=computer)' },
                    @{ Key = 'Groups';    Filter = '(objectCategory=group)' })) {
                try {
                    $n = (Get-ADObject -LDAPFilter $kind.Filter -ResultPageSize 1000 @dp -ErrorAction Stop | Measure-Object).Count
                    $counts[$kind.Key] = "$n (exact, counted $($data['CollectedAt']))"
                    Register-Coverage 'ObjectCounts' "$domainDns ($($kind.Key))" $true
                } catch {
                    Add-Warn "$($kind.Key) count failed for ${domainDns}: $($_.Exception.Message)"
                    Register-Coverage 'ObjectCounts' "$domainDns ($($kind.Key))" $false
                    [void]$notCollected.Add("ObjectCounts:$($kind.Key)")
                }
            }
        }

        $pwdPolicy = $null
        try {
            $pwdPolicy = Get-ADDefaultDomainPasswordPolicy -Identity $dom.DNSRoot @dp -ErrorAction Stop
            Register-Coverage 'PasswordPolicy' $domainDns $true
        } catch {
            Add-Warn "Default domain password policy not read for ${domainDns}: $($_.Exception.Message)"
            Register-Coverage 'PasswordPolicy' $domainDns $false
            [void]$notCollected.Add('PasswordPolicy')
        }

        $kerb = @{ MaxTicketAge = ''; MaxRenewalAge = ''; MaxClockSkew = ''; Found = 0 }
        if ($hasGP) {
            try {
                $kerb = Get-KerberosPolicy $dom.DNSRoot
                if ($kerb.Found -lt 3) {
                    Add-Warn "Kerberos policy for ${domainDns}: only $($kerb.Found) of 3 settings (MaxTicketAge, MaxRenewAge, MaxClockSkew) are defined in the Default Domain Policy report; the rest may be set by another domain-linked GPO."
                    Register-Coverage 'KerberosPolicy' $domainDns $false
                    [void]$notCollected.Add('KerberosPolicy')
                } else { Register-Coverage 'KerberosPolicy' $domainDns $true }
            } catch {
                Add-Warn "Kerberos policy not read for ${domainDns} (Default Domain Policy report): $($_.Exception.Message)"
                Register-Coverage 'KerberosPolicy' $domainDns $false
                [void]$notCollected.Add('KerberosPolicy')
            }
        } else {
            Register-Coverage 'KerberosPolicy' $domainDns $false
            [void]$notCollected.Add('KerberosPolicy')
        }

        $restrictedEmpty = @{}
        $fgpp = @()
        try {
            $fgpp = @(Get-ADFineGrainedPasswordPolicy -Filter * @dp -ErrorAction Stop | ForEach-Object {
                [pscustomobject]@{
                    ComplexityEnabled = ConvertTo-PolicyBoolean (Get-Prop $_ 'ComplexityEnabled')
                    ReversibleEncryptionEnabled = ConvertTo-PolicyBoolean (Get-Prop $_ 'ReversibleEncryptionEnabled')
                    MinPasswordAge = ConvertTo-PolicyInterval (Get-Prop $_ 'MinPasswordAge') 'days'
                    LockoutObservationWindow = ConvertTo-PolicyInterval (Get-Prop $_ 'LockoutObservationWindow') 'minutes'
                    LockoutDuration = ConvertTo-PolicyInterval (Get-Prop $_ 'LockoutDuration') 'minutes'
                    ObjectGUID = "$(Get-Prop $_ 'ObjectGUID')"
                    Name = $_.Name
                    AppliesTo = (Join-List @($_.AppliesTo | ForEach-Object { Get-DnName "$_" }))
                    Precedence = "$($_.Precedence)"
                    Notes = "Min length $($_.MinPasswordLength); history $($_.PasswordHistoryCount); max age $($_.MaxPasswordAge); lockout threshold $($_.LockoutThreshold)"
                }
            })
            if ($fgpp.Count -eq 0) {
                $restrictedEmpty['FGPP'] = Get-RestrictedEmptyText $adIdentity
                Add-Note "FGPP ($domainDns): $($restrictedEmpty['FGPP'])"
                Register-CollectionResult -Section 'FGPP' -Scope $domainDns -Succeeded $true -Count 0 -Identity $adIdentity -ErrorText '' -Restricted $true
                [void]$notCollected.Add('FGPP')
            } else { Register-CollectionResult -Section 'FGPP' -Scope $domainDns -Succeeded $true -Count $fgpp.Count -Identity $adIdentity -ErrorText '' -Restricted $true}
        } catch {
            Add-Warn "FGPP not read for ${domainDns}: $($_.Exception.Message)"
            Register-CollectionResult -Section 'FGPP' -Scope $domainDns -Succeeded $false -Count $null -Identity $adIdentity -ErrorText $_.Exception.Message -Restricted $true
            [void]$notCollected.Add('FGPP')
        }

        $gmsa = @()
        try {
            $gmsa = @(Get-ADServiceAccount -Filter * -Properties PrincipalsAllowedToRetrieveManagedPassword, DNSHostName @dp -ErrorAction Stop |
                Where-Object { $_.ObjectClass -eq 'msDS-GroupManagedServiceAccount' } | ForEach-Object {
                    [pscustomobject]@{
                        Name = $_.Name
                        UsedBy = (Join-List @($_.PrincipalsAllowedToRetrieveManagedPassword | ForEach-Object { Get-DnName "$_" }))
                        Owner = ''; Notes = "DNS host: $($_.DNSHostName)"
                    }
                })
            if ($gmsa.Count -eq 0) {
                $restrictedEmpty['gMSA'] = Get-RestrictedEmptyText $adIdentity
                Add-Note "gMSA ($domainDns): $($restrictedEmpty['gMSA'])"
                Register-Coverage 'gMSA' "$domainDns - $($restrictedEmpty['gMSA'])" $false
                [void]$notCollected.Add('gMSA')
            } else { Register-Coverage 'gMSA' $domainDns $true }
        } catch {
            Add-Warn "gMSA accounts not read for ${domainDns}: $($_.Exception.Message)"
            Register-Coverage 'gMSA' $domainDns $false
            [void]$notCollected.Add('gMSA')
        }

        [void]$domainDetails.Add([pscustomobject]@{
            FQDN = $dom.DNSRoot; CollectionStatus = if ($notCollected.Count -eq 0) { 'Complete' } else { 'Partial' }
            NotCollected = @($notCollected)
            NetBIOS = $dom.NetBIOSName; SID = "$($dom.DomainSID)"; DomainDN = "$($dom.DistinguishedName)"
            Parent = if ($dom.ParentDomain) { $dom.ParentDomain } elseif ($dom.DNSRoot -eq $forest.RootDomain) { 'Forest root' } else { "Tree root (trust parent: $($forest.RootDomain))" }
            DomainMode = "$($dom.DomainMode)"
            DCCounts = $dcCountText
            Users = $counts.Users; Computers = $counts.Computers; Groups = $counts.Groups
            PDCEmulator = $dom.PDCEmulator; RIDMaster = $dom.RIDMaster; InfrastructureMaster = $dom.InfrastructureMaster
            PDCEmulatorSite = (& $siteOfDC $dom.PDCEmulator $domainDns)
            RIDMasterSite = (& $siteOfDC $dom.RIDMaster $domainDns)
            InfrastructureMasterSite = (& $siteOfDC $dom.InfrastructureMaster $domainDns)
            MinPasswordLength = if ($pwdPolicy) { "$($pwdPolicy.MinPasswordLength)" } else { '' }
            PasswordHistory   = if ($pwdPolicy) { "$($pwdPolicy.PasswordHistoryCount)" } else { '' }
            MaxPasswordAge    = if ($pwdPolicy) { "$($pwdPolicy.MaxPasswordAge)" } else { '' }
            MinPasswordAge    = if ($pwdPolicy) { "$($pwdPolicy.MinPasswordAge)" } else { '' }
            Complexity        = if ($pwdPolicy) { if ($pwdPolicy.ComplexityEnabled) { 'Yes' } else { 'No' } } else { '' }
            LockoutThreshold  = if ($pwdPolicy) { "$($pwdPolicy.LockoutThreshold)" } else { '' }
            LockoutDuration   = if ($pwdPolicy) { "$($pwdPolicy.LockoutDuration)" } else { '' }
            LockoutWindow     = if ($pwdPolicy) { "$($pwdPolicy.LockoutObservationWindow)" } else { '' }
            KerbTicket        = $kerb.MaxTicketAge; KerbRenewal = $kerb.MaxRenewalAge; KerbSkew = $kerb.MaxClockSkew
            # Get-ADDefaultDomainPasswordPolicy reads the domain head object; the GPO that
            # set those values is not determined, so it is not named here.
            PolicySourceGpo   = if ($pwdPolicy) { 'Not verified - values read from the domain head object (Get-ADDefaultDomainPasswordPolicy); the GPO that sets them was not determined' } else { '' }
            PasswordSettings = ConvertTo-PasswordSetting $pwdPolicy
            FGPP = $fgpp; GMSA = $gmsa; RestrictedEmpty = $restrictedEmpty
        })
    }
    if (-not $hasGP) { Add-Warn 'GroupPolicy module not available - Kerberos policy and GPO register not read.' }
    $data['Domains'] = @($domainRows)
    $data['DomainDetails'] = @($domainDetails)
    $collectedDomains = @($domainDetails | Where-Object { $_.CollectionStatus -ne 'NotCollected' })
    $domainParents = @{}
    foreach ($d in $domainDetails) {
        if ($d.CollectionStatus -eq 'NotCollected' -or "$($d.Parent)" -eq '') { continue }
        $p = "$($d.Parent)"; if ($p -eq 'Forest root' -or $p -like 'Tree root (trust parent:*') { $p = '' }
        $domainParents[("$($d.FQDN)").ToLower()] = $p
    }

    # --- Sites and subnets (subnets queried once, grouped by site DN) ---------
    $siteRows = New-Object System.Collections.ArrayList
    $subnetRows = New-Object System.Collections.ArrayList
    $siteLinkRows = New-Object System.Collections.ArrayList
    $sites = @(); $allSubnets = @(); $sitesRead = $false
    try {
        $sites = @(Get-ADReplicationSite -Filter * -Properties InterSiteTopologyGenerator, Location @adParams -ErrorAction Stop | Sort-Object Name)
        $sitesRead = $true
        Register-CollectionResult -Section 'Sites' -Scope 'forest' -Succeeded $true -Count $sites.Count -Identity $adIdentity
    } catch {
        Add-Warn "Sites not read: $($_.Exception.Message)"
        Register-CollectionResult -Section 'Sites' -Scope 'forest' -Succeeded $false -Count $null -Identity $adIdentity -ErrorText $_.Exception.Message
    }
    try {
        $allSubnets = @(Get-ADReplicationSubnet -Filter * -Properties Site, Location @adParams -ErrorAction Stop | Sort-Object Name)
        Register-CollectionResult -Section 'Subnets' -Scope 'forest' -Succeeded $true -Count $allSubnets.Count -Identity $adIdentity
    } catch {
        Add-Warn "Subnets not read: $($_.Exception.Message)"
        Register-CollectionResult -Section 'Subnets' -Scope 'forest' -Succeeded $false -Count $null -Identity $adIdentity -ErrorText $_.Exception.Message
    }
    try {
        $subnetsBySite = @{}
        foreach ($sn in $allSubnets) {
            $key = ("$($sn.Site)").ToLower()
            if (-not $subnetsBySite.ContainsKey($key)) { $subnetsBySite[$key] = New-Object System.Collections.ArrayList }
            [void]$subnetsBySite[$key].Add($sn)
        }
        $siteDns = @{}
        foreach ($s in $sites) {
            $siteDns[("$($s.DistinguishedName)").ToLower()] = $true
            $siteSubnets = @($subnetsBySite[("$($s.DistinguishedName)").ToLower()] | Where-Object { $null -ne $_ })
            foreach ($sn in $siteSubnets) {
                [void]$subnetRows.Add([pscustomobject]@{
                    Subnet = $sn.Name; Site = $s.Name
                    Location = if ($sn.Location) { $sn.Location } else { "$($s.Location)" }
                })
            }
            $domainsInSite = @($allDCs | Where-Object { $_.Site -eq $s.Name } | Select-Object -ExpandProperty Domain -Unique)
            [void]$siteRows.Add([pscustomobject]@{
                Name = $s.Name
                Location = "$($s.Location)"
                Subnets = (Join-List @($siteSubnets | ForEach-Object { $_.Name }))
                ISTG = (Get-NtdsServerName "$($s.InterSiteTopologyGenerator)")
                Bridgeheads = ''
                Domains = (Join-List $domainsInSite)
                DCCount = @($allDCs | Where-Object { $_.Site -eq $s.Name }).Count
                Notes = ''
            })
        }
        $unassigned = @($allSubnets | Where-Object { -not $siteDns.ContainsKey(("$($_.Site)").ToLower()) })
        foreach ($sn in $unassigned) {
            $siteLabel = '(not assigned to any site)'
            if ((-not $sitesRead -or $sites.Count -eq 0) -and "$($sn.Site)" -ne '') {
                $siteLabel = "$(Get-DnName "$($sn.Site)") (site inventory unavailable or empty; reference from subnet)"
            }
            [void]$subnetRows.Add([pscustomobject]@{ Subnet = $sn.Name; Site = $siteLabel; Location = "$($sn.Location)" })
        }
        if ($unassigned.Count -gt 0 -and $sitesRead -and $sites.Count -gt 0) {
            Add-Note "$($unassigned.Count) subnet(s) are not assigned to any site (listed in the subnet table): $(Join-List @($unassigned | ForEach-Object { $_.Name }) ', ')"
        }
    } catch {
        Add-Warn "Sites / subnets not read: $($_.Exception.Message)"
        Register-Coverage 'Sites' 'forest' $false
        Register-Coverage 'Subnets' 'forest' $false
    }
    try {
        $links = @(Get-ADReplicationSiteLink -Filter * -Properties Cost, ReplicationFrequencyInMinutes, SitesIncluded, Options, ReplicationSchedule @adParams -ErrorAction Stop)
        foreach ($l in $links) {
            $notify = ''
            if ($null -ne $l.Options) { if (($l.Options -band 1) -eq 1) { $notify = 'Yes' } else { $notify = 'No' } }
            $transport = 'Unknown'
            if ("$($l.DistinguishedName)" -match '(?i),CN=(IP|SMTP),CN=Inter-Site Transports,') { $transport = $Matches[1].ToUpper() }
            [void]$siteLinkRows.Add([pscustomobject]@{
                Name = $l.Name
                MemberSites = (Join-List @($l.SitesIncluded | ForEach-Object { Get-DnName "$_" }))
                Cost = "$($l.Cost)"
                Interval = "$($l.ReplicationFrequencyInMinutes)"
                Schedule = (Get-ScheduleText (Get-Prop $l 'ReplicationSchedule'))
                Transport = $transport
                ChangeNotification = $notify
            })
        }
        Register-CollectionResult -Section 'SiteLinks' -Scope 'forest' -Succeeded $true -Count $links.Count -Identity $adIdentity
    } catch {
        Add-Warn "Site links not read: $($_.Exception.Message)"
        Register-CollectionResult -Section 'SiteLinks' -Scope 'forest' -Succeeded $false -Count $null -Identity $adIdentity -ErrorText $_.Exception.Message
    }
    $data['Sites'] = @($siteRows)
    $data['Subnets'] = @($subnetRows)
    $data['SiteLinks'] = @($siteLinkRows)

    # --- Trusts: Get-ADTrust is domain-scoped too - read every domain, dedupe -
    $trustRows = New-Object System.Collections.ArrayList
    $trustByKey = @{}
    foreach ($domainDns in $forestDomains) {
        $dp = New-DomainParams $domainDns $boundDomain
        try {
            $domainTrusts = @(Get-ADTrust -Filter * @dp -ErrorAction Stop)
            foreach ($t in $domainTrusts) {
                $row = Get-TrustRow $t $domainDns $domainParents $forest.RootDomain
                if ($trustByKey.ContainsKey($row.Key)) {
                    $existing = $trustByKey[$row.Key]
                    $existing.Notes = "$($existing.Notes); also seen from $domainDns (direction there: $($row.Direction))"
                    continue
                }
                $trustByKey[$row.Key] = $row
                [void]$trustRows.Add($row)
            }
            Register-CollectionResult -Section 'Trusts' -Scope $domainDns -Succeeded $true -Count $domainTrusts.Count -Identity $adIdentity
        } catch {
            Add-Warn "Trusts not read for domain ${domainDns}: $($_.Exception.Message)"
            Register-CollectionResult -Section 'Trusts' -Scope $domainDns -Succeeded $false -Count $null -Identity $adIdentity -ErrorText $_.Exception.Message
        }
    }
    $data['Trusts'] = @($trustRows | Select-Object Source, Target, Type, Direction, Transitive, SelectiveAuth, SidFiltering, Notes)

    # --- Top-level OUs: one-level search under the domain head ---------------
    $ouRows = New-Object System.Collections.ArrayList
    foreach ($dom in $collectedDomains) {
        $dp = New-DomainParams $dom.FQDN $boundDomain
        try {
            $domainOUs = @(Get-ADOrganizationalUnit -Filter * -SearchBase $dom.DomainDN -SearchScope OneLevel @dp -ErrorAction Stop)
            foreach ($ou in $domainOUs) {
                [void]$ouRows.Add([pscustomobject]@{
                    OU = $ou.Name; Domain = $dom.FQDN
                    DelegatedGroup = ''; Permissions = ''; Owner = ''
                })
            }
            Register-CollectionResult -Section 'TopLevelOUs' -Scope $dom.FQDN -Succeeded $true -Count $domainOUs.Count -Identity $adIdentity
        } catch {
            Add-Warn "Top-level OUs not read for $($dom.FQDN): $($_.Exception.Message)"
            Register-CollectionResult -Section 'TopLevelOUs' -Scope $dom.FQDN -Succeeded $false -Count $null -Identity $adIdentity -ErrorText $_.Exception.Message
        }
    }
    $data['TopLevelOUs'] = @($ouRows | Sort-Object Domain, OU)

    # --- GPO register: per domain; links from gPLink (domain head, OUs, sites)
    $gpoRows = New-Object System.Collections.ArrayList
    if ($hasGP) {
        $linkMap = @{}
        $linkFailedDomains = @{}
        if (-not $SkipGpoLinks) {
            foreach ($dom in $collectedDomains) {
                $dp = New-DomainParams $dom.FQDN $boundDomain
                try {
                    Merge-GpLinkMap $linkMap @(Get-ADObject -LDAPFilter '(gPLink=*)' -Properties gPLink -ResultPageSize 1000 @dp -ErrorAction Stop)
                    Register-Coverage 'GpoLinks' $dom.FQDN $true
                } catch {
                    $linkFailedDomains[$dom.FQDN.ToLower()] = $true
                    Add-Warn "GPO links (gPLink) not read for $($dom.FQDN): $($_.Exception.Message)"
                    Register-Coverage 'GpoLinks' $dom.FQDN $false
                }
            }
            try {
                Merge-GpLinkMap $linkMap @(Get-ADObject -SearchBase "CN=Sites,$configNC" -LDAPFilter '(gPLink=*)' -Properties gPLink @adParams -ErrorAction Stop)
                Register-Coverage 'GpoLinks' 'sites' $true
            } catch {
                Add-Warn "Site-linked GPOs (gPLink on site objects) not read: $($_.Exception.Message)"
                Register-Coverage 'GpoLinks' 'sites' $false
            }
        } else { Set-SectionStatus 'GpoLinks' 'skipped' '-SkipGpoLinks' }
        foreach ($dom in $collectedDomains) {
            try { $gpos = @(Get-GPO -All -Domain $dom.FQDN -ErrorAction Stop); Register-Coverage 'GPOs' $dom.FQDN $true }
            catch {
                Add-Warn "GPO register not read for $($dom.FQDN): $($_.Exception.Message)"
                Register-Coverage 'GPOs' $dom.FQDN $false
                continue
            }
            foreach ($gpo in $gpos) {
                if ($SkipGpoLinks) { $linkText = 'Not resolved (-SkipGpoLinks)' }
                elseif ($linkFailedDomains[$dom.FQDN.ToLower()]) { $linkText = 'NOT READ - gPLink query failed for this domain (see warnings)' }
                else {
                    $key = ("cn={$($gpo.Id)},cn=policies,cn=system,$($dom.DomainDN)").ToLower()
                    if ($linkMap.ContainsKey($key)) { $linkText = Join-List @($linkMap[$key]) } else { $linkText = 'Not linked' }
                }
                [void]$gpoRows.Add([pscustomobject]@{
                    Name = $gpo.DisplayName; Domain = $dom.FQDN
                    LinkedTo = $linkText
                    Purpose = "$($gpo.Description)"
                    Owner = "$($gpo.Owner)"
                })
            }
        }
    } else {
        Set-SectionStatus 'GPOs' 'failed' 'GroupPolicy module not available'
    }
    $data['GPOs'] = @($gpoRows | Sort-Object Domain, Name)

    # --- DNS: zones from the first writable forest-root DC that answers; forwarders per DC
    $zoneRows = New-Object System.Collections.ArrayList
    $fwdRows = New-Object System.Collections.ArrayList
    $condRows = New-Object System.Collections.ArrayList
    $dnsLoaded = $false
    if ($hasDns) {
        try { Import-Module DnsServer -ErrorAction Stop; $dnsLoaded = $true }
        catch { Add-Warn "DnsServer module not loaded: $($_.Exception.Message)" }
    } else {
        Add-Warn 'DnsServer module not available - DNS zones and forwarders skipped.'
    }
    if ($dnsLoaded) {
        $candidates = @($data['DomainControllers'] | Where-Object { $_.Domain -eq $forest.RootDomain -and -not $_.IsRODC })
        $dnsServer = $null; $tried = New-Object System.Collections.ArrayList
        foreach ($c in $candidates) {
            try { $zones = @(Get-DnsServerZone -ComputerName $c.HostName -ErrorAction Stop); $dnsServer = $c.HostName; break }
            catch { [void]$tried.Add("$($c.HostName) ($($_.Exception.Message))") }
        }
        if ($dnsServer) {
            foreach ($z in $zones) {
                if ("$($z.ZoneType)" -eq 'Forwarder') {
                    [void]$condRows.Add([pscustomobject]@{
                        Zone = $z.ZoneName; Forwarders = (Join-List @($z.MasterServers | ForEach-Object { "$($_.IPAddressToString)" }))
                        Storage = "$($z.ReplicationScope)"; Purpose = ''; Server = $dnsServer
                    })
                } else {
                    [void]$zoneRows.Add([pscustomobject]@{
                        Zone = $z.ZoneName; Type = "$($z.ZoneType)"
                        ReplicationScope = "$($z.ReplicationScope)"
                        DynamicUpdate = "$($z.DynamicUpdate)"; Server = $dnsServer
                    })
                }
            }
            Add-Note "DNS zones and conditional forwarders are as seen on $dnsServer (file-backed zones and forwarders can differ per server)."
            Register-Coverage 'DnsZones' $dnsServer $true
        } else {
            Add-Warn "DNS zones not read: no writable forest-root DC answered Get-DnsServerZone. Tried: $(Join-List @($tried) ' | ')"
            Register-Coverage 'DnsZones' $forest.RootDomain $false
        }
        if ($SkipDnsForwarders) {
            Set-SectionStatus 'DnsForwarders' 'skipped' '-SkipDnsForwarders'
            Add-Note 'DNS forwarder sweep skipped (-SkipDnsForwarders); DNS zones were still attempted.'
        } else {
        foreach ($c in @($data['DomainControllers'])) {
            try {
                $fwd = Get-DnsServerForwarder -ComputerName $c.HostName -ErrorAction Stop
                [void]$fwdRows.Add([pscustomobject]@{
                    Server = $c.HostName
                    Forwarders = (Join-List @($fwd.IPAddress | ForEach-Object { "$($_.IPAddressToString)" }))
                    Notes = "Use root hints if no forwarder answers: $($fwd.UseRootHint)"
                })
                Register-Coverage 'DnsForwarders' $c.HostName $true
            } catch {
                if (Test-DnsNotServer $_) {
                    Add-Note "DNS forwarders not applicable on $($c.HostName) - not a DNS server: $($_.Exception.Message)"
                    Register-Coverage 'DnsForwarders' "$($c.HostName) (not applicable - not a DNS server)" $true
                } else {
                    Add-Warn "DNS forwarders not read from $($c.HostName) (unreachable, no rights, or DNS role unknown): $($_.Exception.Message)"
                    Register-Coverage 'DnsForwarders' $c.HostName $false
                }
            }
        }
        }
    } else {
        Set-SectionStatus 'DnsZones' 'failed' 'DnsServer module not available'
        if ($SkipDnsForwarders) { Set-SectionStatus 'DnsForwarders' 'skipped' '-SkipDnsForwarders' }
        else { Set-SectionStatus 'DnsForwarders' 'failed' 'DnsServer module not available' }
    }
    $data['DnsZones'] = @($zoneRows)
    $data['DnsForwarders'] = @($fwdRows)
    $data['DnsConditionalForwarders'] = @($condRows)

    # --- Protected groups: resolved by well-known SID/RID (language-neutral) --
    # Direct count = values of 'member' (includes foreign security principals);
    # transitive count = LDAP_MATCHING_RULE_IN_CHAIN within the group's domain.
    $protRows = New-Object System.Collections.ArrayList
    $rootDetail = $collectedDomains | Where-Object { $_.FQDN -eq $forest.RootDomain } | Select-Object -First 1
    foreach ($dom in $collectedDomains) {
        $dp = New-DomainParams $dom.FQDN $boundDomain
        $sids = @("$($dom.SID)-512", 'S-1-5-32-544', 'S-1-5-32-548', 'S-1-5-32-551', 'S-1-5-32-549', 'S-1-5-32-550')
        if ($rootDetail -and $dom.FQDN -eq $rootDetail.FQDN) { $sids += @("$($rootDetail.SID)-519", "$($rootDetail.SID)-518") }
        foreach ($sid in $sids) {
            try {
                $g = Get-ADGroup -Identity $sid -Properties member @dp -ErrorAction Stop
                $direct = @($g.member).Count
                $inChain = "(memberOf:1.2.840.113556.1.4.1941:=$(ConvertTo-LdapFilterValue $g.DistinguishedName))"
                $nested = (Get-ADObject -LDAPFilter $inChain -ResultPageSize 1000 @dp -ErrorAction Stop | Measure-Object).Count
                [void]$protRows.Add([pscustomobject]@{
                    Group = "$($g.Name) ($($dom.FQDN))"
                    MemberCount = "$direct direct; $nested transitive member objects incl. nested groups (in $($dom.FQDN) only)"
                    LastReviewed = ''; Owner = ''
                })
                Register-Coverage 'ProtectedGroups' "$sid@$($dom.FQDN)" $true
            } catch {
                Add-Warn "Protected group $sid not read in $($dom.FQDN): $($_.Exception.Message)"
                Register-Coverage 'ProtectedGroups' "$sid@$($dom.FQDN)" $false
            }
        }
    }
    $data['ProtectedGroups'] = @($protRows)

    # --- Schema objects (evidence export only - customs are a human call) ----
    try {
        $schemaObjs = @(Get-ADObject -SearchBase $schemaNC -LDAPFilter '(|(objectClass=attributeSchema)(objectClass=classSchema))' `
                            -Properties whenCreated -ResultPageSize 1000 @adParams -ErrorAction Stop)
        $data['SchemaObjectCount'] = $schemaObjs.Count
        $data['SchemaObjectsByYear'] = @($schemaObjs | Group-Object { $_.whenCreated.Year } |
            ForEach-Object { [pscustomobject]@{ Year = $_.Name; Count = $_.Count } })
        Register-Coverage 'SchemaObjects' 'forest' $true
    } catch {
        Add-Warn "Schema objects not read: $($_.Exception.Message)"
        $data['SchemaObjectCount'] = ''
        $data['SchemaObjectsByYear'] = @()
        Register-Coverage 'SchemaObjects' 'forest' $false
    }

    if ($SkipObjectCounts) { Set-SectionStatus 'ObjectCounts' 'skipped' '-SkipObjectCounts' }
    Complete-Coverage
    $data['SectionStatus'] = $script:SectionStatus
    $data['CollectionDiagnostics'] = @($script:CollectionDiagnostics)
    return $data
}

# ---------------------------------------------------------------------------
# EXPORT
# ---------------------------------------------------------------------------

function Export-ADData($Data, [string]$Folder) {
    if (-not (Test-Path -LiteralPath $Folder)) { New-Item -ItemType Directory -Path $Folder -Force -ErrorAction Stop | Out-Null }
    $tables = [ordered]@{
        'Domains.csv'              = $Data['Domains']
        'DomainControllers.csv'    = $Data['DomainControllers']
        'Sites.csv'                = $Data['Sites']
        'CollectionDiagnostics.csv' = $Data['CollectionDiagnostics']
        'OptionalFeatures.csv' = @($Data['OptionalFeatures'] | ForEach-Object { [pscustomobject]@{ Name = $_.Name; Enabled = $_.Enabled; EnabledScopes = Join-List $_.EnabledScopes } })
        'Subnets.csv'              = $Data['Subnets']
        'SiteLinks.csv'            = $Data['SiteLinks']
        'Trusts.csv'               = $Data['Trusts']
        'TopLevelOUs.csv'          = $Data['TopLevelOUs']
        'GPOs.csv'                 = $Data['GPOs']
        'DnsZones.csv'             = $Data['DnsZones']
        'DnsForwarders.csv'        = $Data['DnsForwarders']
        'DnsConditionalForwarders.csv' = $Data['DnsConditionalForwarders']
        'ProtectedGroups.csv'      = $Data['ProtectedGroups']
        'Warnings.csv'             = @($Data['Warnings'] | ForEach-Object { [pscustomobject]@{ Warning = $_ } })
        'SectionStatus.csv'        = @($Data['SectionStatus'].Keys | ForEach-Object { [pscustomobject]@{ Section = $_; Status = $Data['SectionStatus'][$_].Status; Detail = $Data['SectionStatus'][$_].Detail } })
    }
    if ($Overwrite) {
        # Remove this script's own files from a previous run so no stale CSV survives.
        $own = @('AD-Forest-Data.json') + @($tables.Keys)
        foreach ($f in $own) { $p = Join-Path $Folder $f; if (Test-Path -LiteralPath $p) { Remove-Item -LiteralPath $p -Force -ErrorAction Stop } }
        Get-ChildItem -LiteralPath $Folder -File | Where-Object { $_.Name -like 'FGPP-*.csv' -or $_.Name -like 'gMSA-*.csv' } | Remove-Item -Force -ErrorAction Stop
    }
    $Data | ConvertTo-Json -Depth 8 | Set-Content -Path (Join-Path $Folder 'AD-Forest-Data.json') -Encoding UTF8 -ErrorAction Stop
    foreach ($name in $tables.Keys) {
        $rows = @($tables[$name] | Where-Object { $null -ne $_ })
        $path = Join-Path $Folder $name
        # Written even when empty so a reader can tell "none" from "missing".
        if ($rows.Count -gt 0) { $rows | Export-Csv -Path $path -NoTypeInformation -Encoding UTF8 -ErrorAction Stop }
        else { Set-Content -Path $path -Value '' -Encoding UTF8 -ErrorAction Stop }
    }
    foreach ($dom in @($Data['DomainDetails'])) {
        $safe = $dom.FQDN -replace '[^a-zA-Z0-9.-]', '_'
        if (@($dom.FGPP).Count -gt 0) { @($dom.FGPP) | Export-Csv -Path (Join-Path $Folder "FGPP-$safe.csv") -NoTypeInformation -Encoding UTF8 -ErrorAction Stop }
        if (@($dom.GMSA).Count -gt 0) { @($dom.GMSA) | Export-Csv -Path (Join-Path $Folder "gMSA-$safe.csv") -NoTypeInformation -Encoding UTF8 -ErrorAction Stop }
    }
    Write-Host "Data exported to: $Folder"
}

# ---------------------------------------------------------------------------
# DOCX POPULATION  (edits word/document.xml inside the .docx - no Word needed)
# Tables are located by the text of their first row; key/value tables by the
# label in their first column. This matches the template exactly as built.
# ---------------------------------------------------------------------------

$script:W   = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
$script:W14 = 'http://schemas.microsoft.com/office/word/2010/wordml'

function New-NsManager($XmlDoc) {
    $ns = New-Object System.Xml.XmlNamespaceManager($XmlDoc.NameTable)
    $ns.AddNamespace('w', $script:W)
    # XmlNamespaceManager is IEnumerable (of prefixes) - the comma stops
    # PowerShell unrolling it into its prefix strings on return.
    return ,$ns
}

function Get-CellText($Cell, $Ns) {
    $texts = $Cell.SelectNodes('.//w:t', $Ns)
    return (($texts | ForEach-Object { $_.InnerText }) -join '')
}

function Get-SafeXmlText([string]$Value) {
    # XML 1.0 forbids most C0 control characters (e.g. vertical tab in GPO descriptions).
    return ($Value -replace '[\x00-\x08\x0B\x0C\x0E-\x1F]', '')
}

function Get-CellTextNodes($Cell, $Ns) {
    # Every w:t in the cell - including runs inside content controls (w:sdt),
    # hyperlinks and tracked insertions (w:ins) - but not inside a nested table.
    $list = New-Object System.Collections.ArrayList
    foreach ($t in $Cell.SelectNodes('.//w:t', $Ns)) {
        $p = $t.ParentNode; $nested = $false
        while ($null -ne $p -and -not [object]::ReferenceEquals($p, $Cell)) {
            if ($p.LocalName -eq 'tbl') { $nested = $true; break }
            $p = $p.ParentNode
        }
        if (-not $nested) { [void]$list.Add($t) }
    }
    return ,$list
}

function Clear-PlaceholderFormatting($TextNode, $Cell, $Ns) {
    # A filled value must not keep the placeholder look (grey / italic /
    # PlaceholderText style), and a content control must stop showing as a placeholder.
    $node = $TextNode.ParentNode
    while ($null -ne $node -and -not [object]::ReferenceEquals($node, $Cell)) {
        if ($node.LocalName -eq 'r') {
            $rPr = $node.SelectSingleNode('./w:rPr', $Ns)
            if ($rPr) {
                foreach ($name in @('i', 'iCs', 'color')) {
                    foreach ($n in @($rPr.SelectNodes("./w:$name", $Ns))) { [void]$rPr.RemoveChild($n) }
                }
                foreach ($n in @($rPr.SelectNodes('./w:rStyle', $Ns))) {
                    if ($n.GetAttribute('val', $script:W) -eq 'PlaceholderText') { [void]$rPr.RemoveChild($n) }
                }
            }
        }
        if ($node.LocalName -eq 'sdt') {
            foreach ($n in @($node.SelectNodes('./w:sdtPr/w:showingPlcHdr', $Ns))) { [void]$n.ParentNode.RemoveChild($n) }
        }
        $node = $node.ParentNode
    }
}

function Set-CellText($Cell, $Ns, [string]$Value) {
    $Value = Get-SafeXmlText $Value
    $tNodes = Get-CellTextNodes $Cell $Ns
    $original = (@($tNodes | ForEach-Object { $_.InnerText }) -join '')
    if ($tNodes.Count -eq 0) {
        $para = $Cell.SelectSingleNode('.//w:p', $Ns)
        if ($null -eq $para) {
            $para = $Cell.OwnerDocument.CreateElement('w', 'p', $script:W)
            [void]$Cell.AppendChild($para)
        }
        $run = $Cell.OwnerDocument.CreateElement('w', 'r', $script:W)
        [void]$para.AppendChild($run)
        $t = $Cell.OwnerDocument.CreateElement('w', 't', $script:W)
        [void]$run.AppendChild($t)
        $tNodes = @($t)
    }
    $first = $tNodes[0]
    $first.InnerText = $Value
    for ($i = 1; $i -lt $tNodes.Count; $i++) { $tNodes[$i].InnerText = '' }
    if ($Value.StartsWith(' ') -or $Value.EndsWith(' ')) {
        $space = $Cell.OwnerDocument.CreateAttribute('xml', 'space', 'http://www.w3.org/XML/1998/namespace')
        $space.Value = 'preserve'
        [void]$first.Attributes.Append($space)
    }
    if ($original -match '^\s*\[.*\]\s*$') { Clear-PlaceholderFormatting $first $Cell $Ns }
    # Remove a later paragraph only if it carried nothing but the text just
    # cleared (no drawing, field, object, content control or bookmark).
    $paras = @($Cell.SelectNodes('./w:p', $Ns))
    for ($i = $paras.Count - 1; $i -ge 1; $i--) {
        $p = $paras[$i]
        if ((Get-CellText $p $Ns) -ne '') { continue }
        if ($p.SelectSingleNode('.//w:drawing|.//w:pict|.//w:object|.//w:fldChar|.//w:fldSimple|.//w:instrText|.//w:sdt|.//w:bookmarkStart', $Ns)) { continue }
        if ($p.SelectSingleNode('.//w:t', $Ns)) { [void]$Cell.RemoveChild($p) }
    }
}

function Get-TableRows($Table, $Ns) {
    # Comma return: XmlNodeList is IEnumerable and would otherwise be
    # unrolled into a plain array, losing its .Item() method for callers.
    $rows = $Table.SelectNodes('./w:tr', $Ns)
    return ,$rows
}

function Get-RowCells($Row, $Ns) {
    $cells = $Row.SelectNodes('./w:tc', $Ns)
    return ,$cells
}

function Find-Table($Tables, $Ns, [string[]]$FirstRowSignatures) {
    foreach ($tbl in $Tables) {
        $rows = Get-TableRows $tbl $Ns
        if ($rows.Count -eq 0) { continue }
        $cells = Get-RowCells $rows.Item(0) $Ns
        if ($cells.Count -lt $FirstRowSignatures.Count) { continue }
        $match = $true
        for ($i = 0; $i -lt $FirstRowSignatures.Count; $i++) {
            if (-not (Get-CellText $cells.Item($i) $Ns).StartsWith($FirstRowSignatures[$i])) { $match = $false; break }
        }
        if ($match) { return $tbl }
    }
    return $null
}

function Get-SectionState($Data, [string[]]$Sections) {
    # Worst status across the named sections; $null when the data carries no
    # status record (pre-v1.1 data file).
    $ss = $Data['SectionStatus']
    if ($null -eq $ss) { return $null }
    $rank = @{ ok = 0; skipped = 1; partial = 2; failed = 3 }
    $worst = $null
    $details = New-Object System.Collections.ArrayList
    foreach ($s in $Sections) {
        $st = $ss[$s]
        if ($null -eq $st) { continue }
        $status = "$($st.Status)"
        if ($status -ne 'ok' -and "$($st.Detail)" -ne '') { [void]$details.Add("$s $($st.Detail)") }
        if ($null -eq $worst -or $rank[$status] -gt $rank[$worst]) { $worst = $status }
    }
    if ($null -eq $worst) { return $null }
    return [pscustomobject]@{ Status = $worst; Detail = (@($details) -join '; ') }
}

function New-MessageRow([string]$Text, [int]$CellCount) {
    $r = @($Text)
    for ($c = 1; $c -lt $CellCount; $c++) { $r += '' }
    return ,$r
}

function Write-DataTable($Tables, $Ns, [string[]]$Signatures, $DataRows, [string]$Label, $State = $null) {
    # $DataRows: a list of row arrays, each built with the unary comma
    # (ForEach-Object { ,@(...) }) and holding exactly one value per cell.
    # No re-chunking: a flat list or a count mismatch fails the table loudly.
    # A value equal to $script:KeepPlaceholder leaves that cell's template text.
    $dataList = @($DataRows | Where-Object { $null -ne $_ })
    $tbl = Find-Table $Tables $Ns $Signatures
    if ($null -eq $tbl -or (Get-TableRows $tbl $Ns).Count -lt 2) {
        if ($dataList.Count -gt 0) { Add-FillFailure "$Label - table not found in template or has no fillable data row; $($dataList.Count) collected rows not written" }
        else { Add-Skipped "$Label (table missing or unfillable; no collected rows)" }
        return
    }
    $rows = Get-TableRows $tbl $Ns
    $cellCount = (Get-RowCells $rows.Item(1) $Ns).Count

    for ($i = 0; $i -lt $dataList.Count; $i++) {
        $r = $dataList[$i]
        if ($r -isnot [System.Collections.IList]) {
            Add-FillFailure "$Label - row $($i + 1) is a single value, not a row array (refusing to re-chunk); table left unfilled"
            return
        }
        if ($r.Count -ne $cellCount) {
            Add-FillFailure "$Label - row $($i + 1) has $($r.Count) values but the template row has $cellCount cells; table left unfilled"
            return
        }
    }

    $final = New-Object System.Collections.ArrayList
    foreach ($r in $dataList) { [void]$final.Add($r) }
    $isPartial = ($null -ne $State) -and ($State.Status -eq 'partial' -or $State.Status -eq 'failed')
    if ($dataList.Count -eq 0) {
        if ($null -eq $State) { Add-Skipped "$Label (no data collected)"; return }
        if ($State.Status -eq 'skipped') { Add-Skipped "$Label (collection skipped: $($State.Detail))"; return }
        if ("$($State.EmptyText)" -ne '') {
            [void]$final.Add((New-MessageRow "$($State.EmptyText)" $cellCount))
        } elseif ($isPartial) {
            [void]$final.Add((New-MessageRow "NOT COLLECTED: $($State.Detail) - see run warnings" $cellCount))
        } else {
            [void]$final.Add((New-MessageRow "None found (collected $($script:DataCollectedAt))" $cellCount))
        }
    } elseif ($isPartial) {
        [void]$final.Add((New-MessageRow "PARTIAL COVERAGE: $($State.Detail) - rows above are incomplete; see run warnings" $cellCount))
    }

    $templateRow = $rows.Item(1).CloneNode($true)
    for ($i = 0; $i -lt $final.Count; $i++) {
        $rowIndex = $i + 1
        if ($rowIndex -lt $rows.Count) {
            $row = $rows.Item($rowIndex)
        } else {
            $row = $templateRow.CloneNode($true)
            if ($script:IdState) { Initialize-ClonedBlock @($row) $Ns $script:IdState }
            [void]$tbl.AppendChild($row)
            $rows = Get-TableRows $tbl $Ns
        }
        $cells = Get-RowCells $row $Ns
        if ($cells.Count -ne $cellCount) {
            Add-FillFailure "$Label - template row $rowIndex has $($cells.Count) cells, expected $cellCount; table partially written"
            return
        }
        for ($j = 0; $j -lt $cells.Count; $j++) {
            $v = $final[$i][$j]
            if (Test-Keep $v) { continue }
            $value = ''
            if ($null -ne $v) { $value = "$v" }
            Set-CellText $cells.Item($j) $Ns $value
        }
    }
    # Clear leftover template rows so no bracketed placeholders survive.
    $allRows = Get-TableRows $tbl $Ns
    for ($i = $final.Count + 1; $i -lt $allRows.Count; $i++) {
        $cells = Get-RowCells $allRows.Item($i) $Ns
        for ($j = 0; $j -lt $cells.Count; $j++) { Set-CellText $cells.Item($j) $Ns '' }
    }
    if ($dataList.Count -eq 0 -and $isPartial) { Add-PartialFill "$Label (NOT COLLECTED: $($State.Detail))" }
    elseif ($dataList.Count -eq 0) { Add-Filled "$Label (0 rows - none found)" }
    elseif ($isPartial) { Add-PartialFill "$Label ($($dataList.Count) rows, PARTIAL: $($State.Detail))" }
    else { Add-Filled "$Label ($($dataList.Count) rows)" }
}

function Set-KvTableValues($Table, $Ns, $Map, [string]$Label, $State = $null) {
    $failuresBefore = $script:FillFailures.Count
    # Plan before writing. Exact matches suppress prefix candidates so existing
    # exact labels retain their target. Otherwise select the longest prefix,
    # but disclose ALL overlaps; a deterministic choice is not a clean fill.
    $rows = Get-TableRows $Table $Ns
    $plan = New-Object System.Collections.ArrayList
    $keyRows = @{}
    for ($i = 0; $i -lt $rows.Count; $i++) {
        $cells = Get-RowCells $rows.Item($i) $Ns
        if ($cells.Count -lt 2) { continue }
        $text = (Get-CellText $cells.Item(0) $Ns).Trim()
        $keys = @($Map.Keys | Where-Object { $text -eq "$_" })
        if ($keys.Count -eq 0) {
            $keys = @($Map.Keys | Where-Object { $text.StartsWith("$_", [StringComparison]::OrdinalIgnoreCase) } |
                Sort-Object -Property @{ Expression = { "$($_)".Length }; Descending = $true }, @{ Expression = { "$_" }; Descending = $false })
        }
        if ($keys.Count -eq 0) { continue }
        if ($keys.Count -gt 1) { Add-FillFailure "$Label - ambiguous label '$text' in row $($i + 1) matches keys: $($keys -join ', '); longest prefix selected" }
        foreach ($key in $keys) {
            if (-not $keyRows.ContainsKey("$key")) { $keyRows["$key"] = New-Object System.Collections.ArrayList }
            [void]$keyRows["$key"].Add($i + 1)
        }
        [void]$plan.Add([pscustomobject]@{ Cell = $cells.Item(1); Key = $keys[0] })
    }
    foreach ($key in $keyRows.Keys) {
        if ($keyRows[$key].Count -gt 1) { Add-FillFailure "$Label - key '$key' matches more than one row: $($keyRows[$key] -join ', ')" }
    }
    $setCount = 0
    foreach ($entry in $plan) {
        if ("$($Map[$entry.Key])" -ne '') { Set-CellText $entry.Cell $Ns "$($Map[$entry.Key])"; $setCount++ }
    }
    if ($setCount -gt 0) {
        if ($script:FillFailures.Count -gt $failuresBefore) { Add-PartialFill "$Label ($setCount fields; ambiguous labels - see fill failures)" }
        elseif ($State -and $State.Status -ne 'ok') { Add-PartialFill "$Label ($setCount fields; $($State.Status): $($State.Detail))" }
        else { Add-Filled "$Label ($setCount fields)" }
    } else { Add-Skipped "$Label (no matching fields had data)" }
}

function Set-KvValues($Tables, $Ns, [string[]]$Signatures, $Map, [string]$Label, $State = $null) {
    $tbl = Find-Table $Tables $Ns $Signatures
    if ($null -eq $tbl) {
        if (@($Map.Keys | Where-Object { "$($Map[$_])" -ne '' }).Count -gt 0) { Add-FillFailure "$Label - table not found in template; collected fields not written" }
        else { Add-Skipped "$Label (table not found in template; no collected fields)" }
        return
    }
    Set-KvTableValues $tbl $Ns $Map $Label $State
}

function Edit-ParagraphText($ScopeNodes, $Ns, [string]$Search, [string]$Replace) {
    # Replaces $Search in the concatenated text of each paragraph in scope.
    # (Handles placeholders split across runs.)
    foreach ($node in $ScopeNodes) {
        $paras = @()
        if ($node.LocalName -eq 'p') { $paras = @($node) }
        else { $paras = @($node.SelectNodes('.//w:p', $Ns)) }
        foreach ($p in $paras) {
            $tNodes = $p.SelectNodes('.//w:t', $Ns)
            if ($tNodes.Count -eq 0) { continue }
            $full = ($tNodes | ForEach-Object { $_.InnerText }) -join ''
            if ($full.Contains($Search)) {
                $tNodes.Item(0).InnerText = (Get-SafeXmlText $full.Replace($Search, $Replace))
                for ($i = 1; $i -lt $tNodes.Count; $i++) { $tNodes.Item($i).InnerText = '' }
            }
        }
    }
}

function Get-HeadingText($Para, $Ns) {
    $texts = $Para.SelectNodes('.//w:t', $Ns)
    return (($texts | ForEach-Object { $_.InnerText }) -join '')
}

function Set-ParagraphText($Para, $Ns, [string]$Value) {
    $tNodes = $Para.SelectNodes('.//w:t', $Ns)
    if ($tNodes.Count -eq 0) { return }
    $tNodes.Item(0).InnerText = (Get-SafeXmlText $Value)
    for ($i = 1; $i -lt $tNodes.Count; $i++) { $tNodes.Item($i).InnerText = '' }
}

function Set-TableRowByContains($Tables, $Ns, [string[]]$Signatures, [string]$Contains, [string]$Value) {
    if ($Value -eq '') { return }
    $tbl = Find-Table $Tables $Ns $Signatures
    if ($null -eq $tbl) { return }
    $rows = Get-TableRows $tbl $Ns
    for ($i = 0; $i -lt $rows.Count; $i++) {
        $cells = Get-RowCells $rows.Item($i) $Ns
        if ($cells.Count -ge 2 -and (Get-CellText $cells.Item(0) $Ns) -like "*$Contains*") {
            Set-CellText $cells.Item(1) $Ns $Value
            return
        }
    }
}

function Resolve-AutomaticField($Tables, $Ns, [string]$Label, [string]$Name) {
    # Exact first-cell labels transcribed from the staged real template.
    # Search all tables so duplicate tables/rows cannot silently choose a winner.
    $matchingRows = New-Object System.Collections.ArrayList
    foreach ($table in $Tables) {
        foreach ($row in (Get-TableRows $table $Ns)) {
            $cells = Get-RowCells $row $Ns
            if ($cells.Count -ge 1 -and (Get-CellText $cells.Item(0) $Ns).Trim() -eq $Label) {
                [void]$matchingRows.Add($row)
            }
        }
    }
    if ($matchingRows.Count -ne 1) {
        Add-FillFailure "$Name - automatic field '$Label' requires exactly one row; found $($matchingRows.Count)"
        return $null
    }
    $cells = Get-RowCells $matchingRows[0] $Ns
    if ($cells.Count -ne 2) {
        Add-FillFailure "$Name - automatic field '$Label' requires two cells; found $($cells.Count)"
        return $null
    }
    return ,$cells.Item(1)
}

function Get-TablesInScope($ScopeNodes, $Ns) {
    $list = New-Object System.Collections.ArrayList
    foreach ($node in $ScopeNodes) {
        if ($node.LocalName -eq 'tbl') { [void]$list.Add($node) }
        foreach ($t in $node.SelectNodes('.//w:tbl', $Ns)) { [void]$list.Add($t) }
    }
    return $list
}

function Get-DcSite($Data, [string]$Fqdn) {
    $dc = $Data['DomainControllers'] | Where-Object { $_.HostName -eq $Fqdn } | Select-Object -First 1
    if ($dc) { return $dc.Site }
    $short = ($Fqdn -split '\.')[0]
    $dc = $Data['DomainControllers'] | Where-Object { $_.Name -eq $short } | Select-Object -First 1
    if ($dc) { return $dc.Site }
    return ''
}

function Get-CountTotal($Data, [string]$Field) {
    $total = 0; $found = $false
    $missing = New-Object System.Collections.ArrayList
    foreach ($dom in @($Data['DomainDetails'])) {
        $text = "$($dom.$Field)"
        if ($text -match '^\s*(\d+)') { $total += [int]$Matches[1]; $found = $true }
        else { [void]$missing.Add("$($dom.FQDN)") }
    }
    if (-not $found) { return '' }
    if ($missing.Count -gt 0) { return "$total (PARTIAL - excludes $(@($missing) -join ', '); exact counts summed per domain, $($Data['CollectedAt']))" }
    return "$total (exact, summed per domain, $($Data['CollectedAt']))"
}

function Get-DomainState($Dom, [string]$Section) {
    # Per-domain coverage from DomainDetails.NotCollected (v1.1 data); $null for older data.
    if ($Dom.RestrictedEmpty -and "$($Dom.RestrictedEmpty[$Section])" -ne '') {
        return [pscustomobject]@{ Status = 'partial'; Detail = "$($Dom.FQDN): $($Dom.RestrictedEmpty[$Section])"; EmptyText = "$($Dom.RestrictedEmpty[$Section])" }
    }
    $nc = $Dom.NotCollected
    if ($null -eq $nc -and $null -eq $Dom.CollectionStatus) { return $null }
    if (@($nc) -contains $Section) { return [pscustomobject]@{ Status = 'failed'; Detail = "for $($Dom.FQDN)" } }
    return [pscustomobject]@{ Status = 'ok'; Detail = '' }
}

function Initialize-ClonedBlock($Nodes, $Ns, $IdState) {
    # Cloned Section 4 nodes must not repeat bookmark names/ids, w14 paragraph
    # ids, drawing (wp:docPr) ids or content-control ids - duplicates trigger
    # Word's repair prompt. Bookmarks are dropped from clones (cross-references
    # keep pointing at the original block); the other ids are renumbered/removed.
    foreach ($node in $Nodes) {
        $all = New-Object System.Collections.ArrayList
        [void]$all.Add($node)
        foreach ($d in @($node.SelectNodes('.//*'))) { [void]$all.Add($d) }
        foreach ($el in $all) {
            if ($el.NodeType -ne [System.Xml.XmlNodeType]::Element) { continue }
            if ($el.LocalName -eq 'bookmarkStart' -or $el.LocalName -eq 'bookmarkEnd') {
                if ($null -ne $el.ParentNode -and -not [object]::ReferenceEquals($el, $node)) { [void]$el.ParentNode.RemoveChild($el) }
                continue
            }
            [void]$el.RemoveAttribute('paraId', $script:W14)
            [void]$el.RemoveAttribute('textId', $script:W14)
            if ($el.LocalName -eq 'docPr' -and $el.HasAttribute('id')) {
                $IdState.DocPr = $IdState.DocPr + 1; $el.SetAttribute('id', "$($IdState.DocPr)")
            }
            if ($el.LocalName -eq 'id' -and $el.NamespaceURI -eq $script:W -and $null -ne $el.ParentNode -and $el.ParentNode.LocalName -eq 'sdtPr') {
                $IdState.Sdt = $IdState.Sdt + 1; [void]$el.SetAttribute('val', $script:W, "$($IdState.Sdt)")
            }
        }
    }
}

function Write-DomainBlock($ScopeNodes, $Ns, $Dom, [int]$Index) {
    $heading = $ScopeNodes[0]
    $K = $script:KeepPlaceholder
    # The real template has unnumbered Heading 3 text. Number by position,
    # including the original block, rather than depending on typed prefixes.
    $subheading = 0
    foreach ($node in $ScopeNodes) {
        $paras = @($node.SelectNodes('.//w:p', $Ns))
        if ($node.LocalName -eq 'p') { $paras = @($node) }
        foreach ($para in $paras) {
            $style = $para.SelectSingleNode('./w:pPr/w:pStyle', $Ns)
            if ($null -eq $style -or $style.GetAttribute('val', $script:W) -ne 'Heading3') { continue }
            $subheading++
            $title = (Get-HeadingText $para $Ns) -replace '^\s*4\.\d+\.\d+\s*', ''
            Set-ParagraphText $para $Ns "4.$Index.$subheading  $title"
            # Suppress any direct or inherited automatic numbering: the text
            # above is the sole numbering source, not an extra list prefix.
            $pPr = $para.SelectSingleNode('./w:pPr', $Ns)
            $numPr = $pPr.SelectSingleNode('./w:numPr', $Ns)
            if ($null -eq $numPr) {
                $numPr = $para.OwnerDocument.CreateElement('w', 'numPr', $script:W)
                $afterNum = $pPr.SelectSingleNode('./w:suppressLineNumbers|./w:pBdr|./w:shd|./w:tabs|./w:suppressAutoHyphens|./w:kinsoku|./w:wordWrap|./w:overflowPunct|./w:topLinePunct|./w:autoSpaceDE|./w:autoSpaceDN|./w:bidi|./w:adjustRightInd|./w:snapToGrid|./w:spacing|./w:ind|./w:contextualSpacing|./w:mirrorIndents|./w:suppressOverlap|./w:jc|./w:textDirection|./w:textAlignment|./w:textboxTightWrap|./w:outlineLvl|./w:divId|./w:cnfStyle|./w:rPr|./w:sectPr|./w:pPrChange', $Ns)
                if ($afterNum) { [void]$pPr.InsertBefore($numPr, $afterNum) } else { [void]$pPr.AppendChild($numPr) }
            }
            $numPr.RemoveAll()
            $numId = $para.OwnerDocument.CreateElement('w', 'numId', $script:W)
            [void]$numId.SetAttribute('val', $script:W, '0')
            [void]$numPr.AppendChild($numId)
        }
    }
    if ("$($Dom.CollectionStatus)" -eq 'NotCollected') {
        Set-ParagraphText $heading $Ns "4.$Index  Domain: $($Dom.FQDN) - NOT COLLECTED (see run warnings)"
        $tables = Get-TablesInScope $ScopeNodes $Ns
        Set-KvValues $tables $Ns @('Domain FQDN', '[Enter FQDN]') ([ordered]@{ 'Domain FQDN' = $Dom.FQDN }) "Domain overview - $($Dom.FQDN) (heading only)"
        Add-PartialFill "Section 4.$Index $($Dom.FQDN) (NOT COLLECTED - Get-ADDomain failed)"
        return
    }
    Set-ParagraphText $heading $Ns "4.$Index  Domain: $($Dom.FQDN)"
    $tables = Get-TablesInScope $ScopeNodes $Ns

    $kv = [ordered]@{
        'Domain FQDN'               = $Dom.FQDN
        'NetBIOS name'              = $Dom.NetBIOS
        'Domain SID'                = $Dom.SID
        'Parent domain / tree'      = $Dom.Parent
        'Domain functional level'   = $Dom.DomainMode
        'Domain controllers (count)' = $Dom.DCCounts
        'Users'                     = $Dom.Users
        'Computers'                 = $Dom.Computers
        'Groups'                    = $Dom.Groups
    }
    Set-KvValues $tables $Ns @('Domain FQDN', '[Enter FQDN]') $kv "Domain overview - $($Dom.FQDN)"

    $fsmoRows = @(
        @('PDC Emulator', $Dom.PDCEmulator, $Dom.PDCEmulatorSite),
        @('RID Master', $Dom.RIDMaster, $Dom.RIDMasterSite),
        @('Infrastructure Master', $Dom.InfrastructureMaster, $Dom.InfrastructureMasterSite)
    )
    Write-DataTable $tables $Ns @('Role (PDC Emulator') $fsmoRows "Domain FSMO - $($Dom.FQDN)"

    $pwdKv = [ordered]@{
        'Minimum password length'    = $Dom.MinPasswordLength
        'Password history'           = $Dom.PasswordHistory
        'Maximum password age'       = $Dom.MaxPasswordAge
        'Minimum password age'       = $Dom.MinPasswordAge
        'Complexity enabled'         = $Dom.Complexity
        'Account lockout threshold'  = $Dom.LockoutThreshold
        'Lockout duration'           = $Dom.LockoutDuration
        'Lockout observation window' = $Dom.LockoutWindow
        'Policy source GPO'          = $Dom.PolicySourceGpo
    }
    Set-KvValues $tables $Ns @('Minimum password length') $pwdKv "Password policy - $($Dom.FQDN)"
    Set-TableRowByContains $tables $Ns @('Minimum password length') 'ticket lifetime' $Dom.KerbTicket
    Set-TableRowByContains $tables $Ns @('Minimum password length') 'renewal lifetime' $Dom.KerbRenewal
    Set-TableRowByContains $tables $Ns @('Minimum password length') 'Clock skew' $Dom.KerbSkew
    if ("$($Dom.KerbTicket)$($Dom.KerbRenewal)$($Dom.KerbSkew)" -eq '') { Add-Skipped "Kerberos policy - $($Dom.FQDN) (not read; template placeholder kept)" }

    $fgppRows = @($Dom.FGPP | Where-Object { $null -ne $_ } | Sort-Object @{ Expression = { [int]$_.Precedence } }, @{ Expression = { $_.Name } }, @{ Expression = { $_.ObjectGUID } } | ForEach-Object { ,@($_.Name, $_.AppliesTo, $_.Precedence, (Get-FgppComparison $_ $Dom)) })
    Write-DataTable $tables $Ns @('PSO name') $fgppRows "FGPP - $($Dom.FQDN)" (Get-DomainState $Dom 'FGPP')
    $gmsaRows = @($Dom.GMSA | Where-Object { $null -ne $_ } | ForEach-Object { ,@($_.Name, $_.UsedBy, $K, $_.Notes) })
    Write-DataTable $tables $Ns @('gMSA name') $gmsaRows "gMSA - $($Dom.FQDN)" (Get-DomainState $Dom 'gMSA')
}

function ConvertTo-DataHashtable($Object) {
    if ($null -eq $Object) { return $null }
    if ($Object -is [System.Management.Automation.PSCustomObject]) {
        $hash = [ordered]@{}
        foreach ($prop in $Object.PSObject.Properties) { $hash[$prop.Name] = ConvertTo-DataHashtable $prop.Value }
        return $hash
    }
    if ($Object -is [System.Collections.IEnumerable] -and $Object -isnot [string]) {
        $list = New-Object System.Collections.ArrayList
        foreach ($item in $Object) { [void]$list.Add((ConvertTo-DataHashtable $item)) }
        # Comma return: keeps empty and one-element arrays as arrays.
        return ,$list.ToArray()
    }
    return $Object
}

function Get-VerificationText($Data, [string]$DataFileName) {
    # What goes under "could not verify". 'None' only when collection ran in
    # this process and produced no warning, no partial section and no fill failure.
    $items = New-Object System.Collections.ArrayList
    if ($script:LiveCollection) {
        foreach ($w in $script:Warnings) { [void]$items.Add("$w") }
    } else {
        if (-not $Data.Contains('Warnings')) {
            return "UNKNOWN - the data file ($DataFileName) predates v1.1 and carries no collection-warning record; verify every section manually against AD"
        }
        foreach ($w in @($Data['Warnings'] | Where-Object { $null -ne $_ })) { [void]$items.Add("$w") }
        foreach ($w in $script:Warnings) { [void]$items.Add("(populate run) $w") }
    }
    foreach ($f in $script:FillFailures) { [void]$items.Add("Table fill failed: $f") }
    $nonOk = @()
    if ($Data['SectionStatus']) {
        $nonOk = @($Data['SectionStatus'].Keys | Where-Object { "$($Data['SectionStatus'][$_].Status)" -in @('partial', 'failed', 'skipped') })
    }
    if ($items.Count -eq 0 -and $nonOk.Count -eq 0) {
        if ($script:LiveCollection) { return 'None' }
        return "None recorded at collection ($($Data['CollectedAt']), data file $DataFileName); not re-verified in this -DataFile run"
    }
    $shown = @($items | Select-Object -First 15)
    $text = "$($items.Count) issue(s)"
    if ($items.Count -eq 0 -and $nonOk.Count -gt 0) { $text = "$($nonOk.Count) unverified section(s)" }
    if (-not $script:LiveCollection) { $text += " recorded at collection ($($Data['CollectedAt']), data file $DataFileName)" }
    if ($nonOk.Count -gt 0) { $text += "; partial/failed/skipped sections: $($nonOk -join ', ')" }
    if ($shown.Count -gt 0) { $text += ': ' + ($shown -join ' | ') }
    if ($items.Count -gt $shown.Count) { $text += " | ... $($items.Count - $shown.Count) more in AD-Forest-Data.json / Warnings.csv" }
    return $text
}

# ---------------------------------------------------------------------------
# DOCUMENT FILL
# ---------------------------------------------------------------------------

function Repair-DuplicateCellShading($Doc, $Ns) {
    # DEF-05: valid property containers are a strict no-op. For duplicate
    # shading only, last wins; then restore the complete ECMA CT_TcPr order.
    # cellIns/cellDel/cellMerge share a choice position. Stable ordering also
    # preserves the relative position of unrecognized extension elements.
    $order = @('cnfStyle', 'tcW', 'gridSpan', 'hMerge', 'vMerge', 'tcBorders',
        'shd', 'noWrap', 'tcMar', 'textDirection', 'tcFitText', 'vAlign',
        'hideMark', 'headers', 'cellIns', 'cellDel', 'cellMerge', 'tcPrChange')
    $rank = @{}
    for ($i = 0; $i -lt $order.Count; $i++) { $rank[$order[$i]] = $i }
    $rank['cellDel'] = $rank['cellIns']; $rank['cellMerge'] = $rank['cellIns']
    $count = 0
    foreach ($tcPr in @($Doc.SelectNodes('//w:tcPr', $Ns))) {
        $shading = @($tcPr.SelectNodes('w:shd', $Ns))
        if ($shading.Count -le 1) { continue }
        for ($i = 0; $i -lt $shading.Count - 1; $i++) {
            [void]$tcPr.RemoveChild($shading[$i])
        }
        $position = 0
        $children = @(foreach ($child in @($tcPr.ChildNodes)) {
            if ($child.NodeType -eq [System.Xml.XmlNodeType]::Element) {
                $key = $order.Count
                if ($child.NamespaceURI -eq $script:W -and $rank.ContainsKey($child.LocalName)) {
                    $key = $rank[$child.LocalName]
                }
                [pscustomobject]@{ Node = $child; Rank = $key; Position = $position }
            }
            $position++
        })
        foreach ($item in @($children | Sort-Object Rank, Position)) {
            [void]$tcPr.AppendChild($item.Node)
        }
        $count++
    }
    return $count
}

function Write-ForestDocument($Data, [string]$Template, [string]$Output, [string]$DataFileName) {
    # Paths arrive fully resolved. The template is only ever read (Copy-Item
    # source); all editing happens on a temp copy beside the output, which is
    # moved into place only after a successful save.
    $ErrorActionPreference = 'Stop'
    $templateHash = $script:TemplateHashAtStart
    if ((Get-FileHash -LiteralPath $Template -Algorithm SHA256 -ErrorAction Stop).Hash -ne $templateHash) { throw 'Template changed since start of run; output not published.' }
    $outDir = Split-Path -Parent $Output
    $temp = Join-Path $outDir ('~' + [IO.Path]::GetFileNameWithoutExtension($Output) + '.' + [guid]::NewGuid().ToString('N') + '.tmp.docx')
    try {
        Copy-Item -LiteralPath $Template -Destination $temp -ErrorAction Stop
        Add-Type -AssemblyName System.IO.Compression
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $zip = [System.IO.Compression.ZipFile]::Open($temp, [System.IO.Compression.ZipArchiveMode]::Update)
        try {
            Write-DocumentXml $zip $Data $DataFileName $Output
        } finally {
            $zip.Dispose()
        }
        if ((Get-FileHash -LiteralPath $Template -Algorithm SHA256).Hash -ne $templateHash) {
            throw "The template file changed during the run ($Template) - output not published."
        }
        if (Test-Path -LiteralPath $Output) {
            if (-not $Overwrite) { throw "Output appeared during the run and -Overwrite was not given: $Output" }
            # Content guard follows aliases through the filesystem provider.
            # Fail closed on unreadable targets; identical independent copies
            # are conservatively refused too. No path spelling can bypass it.
            if ((Get-FileHash -LiteralPath $Output -Algorithm SHA256 -ErrorAction Stop).Hash -eq $templateHash) {
                throw "Output content equals the start-of-run template hash; possible template alias. Refusing overwrite: $Output"
            }
            Remove-Item -LiteralPath $Output -Force -ErrorAction Stop
        }
        Move-Item -LiteralPath $temp -Destination $Output -ErrorAction Stop
        $script:PublishedDocumentPath = $Output
    } catch {
        if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue }
        throw
    }
    Write-Host "Populated document written to: $Output"
}

# Diagram helpers for Populate-ADForestOverview 1.5.2. Pure managed EMF writer.
# Integrate by inserting these functions before Write-DocumentXml; see DIAGRAM-INTEGRATION.md.
function Get-DiagramValue($Object, [string]$Name) {
    if ($null -eq $Object) { return $null }
    if ($Object -is [System.Collections.IDictionary]) { return ,$Object[$Name] }
    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property) { return $null }
    return ,$property.Value
}

function Get-DiagramSorted($Items, [string]$Property) {
    # Ordinal ordering, independent of current culture and input enumeration order.
    $map = New-Object 'System.Collections.Generic.SortedDictionary[string,object]' ([StringComparer]::Ordinal)
    foreach ($item in @($Items)) {
        $key = [string](Get-DiagramValue $item $Property)
        if ([string]::IsNullOrWhiteSpace($key)) { throw "Missing diagram identifier: $Property" }
        if ($map.ContainsKey($key)) { throw "Duplicate diagram identifier: $key" }
        $map.Add($key, $item)
    }
    return @($map.Values)
}

function Assert-DiagramSource($Data, [string[]]$Names) {
    foreach ($name in $Names) {
        if ($null -eq (Get-DiagramValue $Data $name)) { throw "source $name missing" }
        $state = Get-DiagramValue (Get-DiagramValue $Data 'SectionStatus') $name
        if ($null -eq $state -or [string](Get-DiagramValue $state 'Status') -ne 'ok') {
            throw "source $name collection not verified complete"
        }
    }
}

function New-DiagramNode {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory DTO constructor; no external state is changed and no confirmation is appropriate.')]
    param([string]$Id, [string]$Label, [string]$Group = '')
    return [pscustomobject]@{ Id = $Id; Label = $Label; Group = $Group }
}

function Get-ForestDiagramModel($Data) {
    # All source rows are the exported DTOs used by the tables. No new AD reads.
    $models = New-Object System.Collections.ArrayList
    foreach ($number in @('5-1','6-1','6-2','8-1')) {
        $model = [pscustomobject]@{ Number = $number; Title = ''; Nodes = @(); Edges = @(); Groups = @(); Design = ''; Domains = @(); Reason = ''; Date = ''; Forest = '' }
        try {
            $dateValue = Get-DiagramValue $Data 'CollectedAt'
            $stamp = [string]$dateValue
            # Newer ConvertFrom-Json runtimes can materialize ISO dates as DateTime;
            # Windows PowerShell 5.1 retains the string. Accept both DTO shapes.
            if ($dateValue -is [DateTime] -or $dateValue -is [DateTimeOffset]) {
                $stamp = $dateValue.ToString('yyyy-MM-dd', [Globalization.CultureInfo]::InvariantCulture)
            }
            if ($stamp -notmatch '^\d{4}-\d{2}-\d{2}') { throw 'collection date missing or malformed' }
            $model.Date = $stamp.Substring(0,10)
            $nodes = New-Object System.Collections.ArrayList
            $edges = New-Object System.Collections.ArrayList
            $groups = New-Object System.Collections.ArrayList
            switch ($number) {
                '5-1' {
                    Assert-DiagramSource $Data @('Forest','Domains','Trusts')
                    $model.Title = 'Logical topology - forest boundary and trees'
                    $forest = Get-DiagramValue $Data 'Forest'
                    $model.Forest = [string](Get-DiagramValue $forest 'RootDomain')
                    if (-not $model.Forest) { throw 'forest root missing' }
                    $domains = @(Get-DiagramSorted (Get-DiagramValue $Data 'DomainDetails') 'FQDN')
                    $lookup = @{}
                    foreach ($dom in $domains) {
                        $fqdn = [string](Get-DiagramValue $dom 'FQDN')
                        if ($lookup.ContainsKey($fqdn)) { throw "Duplicate domain $fqdn" }
                        $lookup[$fqdn] = $dom
                    }
                    $expected = @((Get-DiagramValue $forest 'Domains'))
                    if ($expected.Count -ne $domains.Count -or $domains.Count -eq 0) { throw 'domain inventory incomplete' }
                    foreach ($fqdn in $expected) { if (-not $lookup.ContainsKey([string]$fqdn)) { throw "domain $fqdn missing" } }
                    foreach ($dom in $domains) {
                        $fqdn = [string](Get-DiagramValue $dom 'FQDN')
                        $nb = [string](Get-DiagramValue $dom 'NetBIOS')
                        if (-not $nb -or [string](Get-DiagramValue $dom 'CollectionStatus') -eq 'NotCollected') { throw "domain $fqdn not collected" }
                        $tree = $fqdn; $seen = @{}
                        while ($true) {
                            if ($seen.ContainsKey($tree)) { throw 'cyclic domain parent map' }
                            $seen[$tree] = $true
                            $parent = [string](Get-DiagramValue $lookup[$tree] 'Parent')
                            if ($parent -eq 'Forest root' -or $parent -like 'Tree root (trust parent:*') { break }
                            if (-not $parent -or -not $lookup.ContainsKey($parent)) { throw "domain parent unverified for $tree" }
                            $tree = $parent
                        }
                        [void]$nodes.Add((New-DiagramNode -Id $fqdn -Label "$fqdn | NetBIOS: $nb" -Group $tree))
                    }
                    $treeKeys = @{}; foreach ($node in $nodes) { $treeKeys[$node.Group] = $true }
                    foreach ($key in @($treeKeys.Keys)) { [void]$groups.Add((New-DiagramNode $key "Tree: $key")) }
                    $trusts = New-Object System.Collections.ArrayList
                    foreach ($row in @((Get-DiagramValue $Data 'Trusts'))) {
                        $src = [string](Get-DiagramValue $row 'Source'); $dst = [string](Get-DiagramValue $row 'Target')
                        $type = [string](Get-DiagramValue $row 'Type'); $dir = [string](Get-DiagramValue $row 'Direction')
                        if (-not $src -or -not $dst -or -not $type -or $dir -notin @('Inbound','Outbound','Bidirectional')) { throw 'trust endpoint, type or direction missing/unrecognized' }
                        if (-not $lookup.ContainsKey($src)) { throw "trust source $src outside collected forest" }
                        # Type is copied verbatim from Get-TrustRow; never reclassified here.
                        [void]$trusts.Add([pscustomobject]@{ Id = "$src|$dst|$type|$dir"; Source = $src; Target = $dst; Label = "$type | $dir"; Direction = $dir; Members = @() })
                    }
                    $edges = @(Get-DiagramSorted $trusts 'Id')
                    foreach ($edge in $edges) {
                        if (-not $lookup.ContainsKey($edge.Target)) { $lookup[$edge.Target] = $true; [void]$nodes.Add((New-DiagramNode -Id $edge.Target -Label "$($edge.Target) | external endpoint" -Group 'External endpoints')) }
                    }
                }
                { $_ -in @('6-1','6-2') } {
                    Assert-DiagramSource $Data @('Sites','DomainControllers')
                    $model.Title = 'SCHEMATIC site map - positions are layout, not geography'
                    $sites = @(Get-DiagramSorted (Get-DiagramValue $Data 'Sites') 'Name')
                    if ($sites.Count -eq 0) { throw 'no sites collected' }
                    $siteMap = @{}
                    foreach ($site in $sites) {
                        $name = [string](Get-DiagramValue $site 'Name')
                        if ($siteMap.ContainsKey($name)) { throw "Duplicate site $name" }
                        $siteMap[$name] = $site
                        $count = @((Get-DiagramValue $Data 'DomainControllers') | Where-Object { [string](Get-DiagramValue $_ 'Site') -eq $name }).Count
                        $reported = Get-DiagramValue $site 'DCCount'
                        if ($null -eq $reported -or [string]$reported -ne [string]$count) { throw "DC count inconsistent for $name" }
                        $label = "$name | DCs: $count"
                        $location = [string](Get-DiagramValue $site 'Location')
                        if ($location) { $label += " | Location: $location" }
                        if ($count -eq 0) { $label += ' | NO DCs' }
                        $bridgeheads = [string](Get-DiagramValue $site 'Bridgeheads')
                        if ($number -eq '6-2' -and $bridgeheads) { $label += " | Bridgeheads: $bridgeheads" }
                        [void]$nodes.Add((New-DiagramNode $name $label))
                    }
                    foreach ($dc in @((Get-DiagramValue $Data 'DomainControllers'))) {
                        if (-not $siteMap.ContainsKey([string](Get-DiagramValue $dc 'Site'))) { throw 'DC references unknown site' }
                    }
                    if ($number -eq '6-2') {
                        Assert-DiagramSource $Data @('SiteLinks')
                        $model.Title = 'Replication topology - site-link membership (not connection objects)'
                        $links = @(Get-DiagramSorted (Get-DiagramValue $Data 'SiteLinks') 'Name')
                        $pairSet = @{}; $degree = @{}; foreach ($site in $sites) { $degree[[string](Get-DiagramValue $site 'Name')] = 0 }
                        $simple = $true
                        foreach ($link in $links) {
                            $name = [string](Get-DiagramValue $link 'Name')
                            # DTO uses Join-List's exact '; ' delimiter; reject ambiguous names.
                            $members = @(([string](Get-DiagramValue $link 'MemberSites') -split '; ') | Where-Object { $_ -ne '' })
                            $memberSet = @{}
                            foreach ($member in $members) {
                                if (-not $siteMap.ContainsKey($member) -or $memberSet.ContainsKey($member)) { throw "site-link $name has unknown/ambiguous member $member" }
                                $memberSet[$member] = $true
                            }
                            $members = [string[]]@($memberSet.Keys); [Array]::Sort($members, [StringComparer]::Ordinal)
                            $cost = [string](Get-DiagramValue $link 'Cost'); $interval = [string](Get-DiagramValue $link 'Interval')
                            if ($members.Count -lt 1 -or $cost -notmatch '^\d+$' -or $interval -notmatch '^\d+$') { throw "site-link $name membership/cost/interval unverified" }
                            $label = "$name | Cost: $cost | Interval: $interval minutes"
                            $notify = [string](Get-DiagramValue $link 'ChangeNotification')
                            if ($notify -eq 'Yes') { $label += ' | Change Notification: Yes' }
                            [void]$edges.Add([pscustomobject]@{ Id = $name; Source = ''; Target = ''; Label = $label; Direction = 'None'; Members = $members })
                            if ($members.Count -ne 2) { $simple = $false } else {
                                $pair = $members -join '|'
                                if ($pairSet.ContainsKey($pair)) { $simple = $false }
                                $pairSet[$pair] = $true
                                $degree[$members[0]]++; $degree[$members[1]]++
                            }
                        }
                        # Conservative design rule: only a simple complete graph or exact star,
                        # >=3 sites, every link binary, no parallel links. Otherwise stay human.
                        if ($simple -and $sites.Count -ge 3) {
                            $n = $sites.Count
                            if ($links.Count -eq (($n * ($n - 1)) / 2)) { $model.Design = 'Mesh' }
                            elseif ($links.Count -eq ($n - 1)) {
                                $hubs = @($degree.Keys | Where-Object { $degree[$_] -eq ($n - 1) })
                                $spokes = @($degree.Keys | Where-Object { $degree[$_] -eq 1 })
                                if ($hubs.Count -eq 1 -and $spokes.Count -eq ($n - 1)) {
                                    $model.Design = 'Hub-and-spoke'
                                    foreach ($node in $nodes) {
                                        if ($node.Id -eq $hubs[0]) { $node.Label += ' | Hub (site-link graph)' } else { $node.Label += ' | Spoke (site-link graph)' }
                                    }
                                }
                            }
                        }
                    }
                }
                '8-1' {
                    Assert-DiagramSource $Data @('Domains','TopLevelOUs')
                    $model.Title = 'OU structure - top level only; one model per collected domain'
                    $domains = @(Get-DiagramSorted (Get-DiagramValue $Data 'DomainDetails') 'FQDN')
                    if ($domains.Count -eq 0) { throw 'domain inventory missing' }
                    $forest = Get-DiagramValue $Data 'Forest'
                    $expected = @((Get-DiagramValue $forest 'Domains'))
                    if ($expected.Count -ne $domains.Count) { throw 'domain inventory incomplete' }
                    $known = @{}
                    foreach ($dom in $domains) {
                        $name = [string](Get-DiagramValue $dom 'FQDN')
                        if ([string](Get-DiagramValue $dom 'CollectionStatus') -eq 'NotCollected') { throw "domain $name not collected" }
                        $known[$name] = $true
                        [void]$groups.Add((New-DiagramNode $name "Domain root: $name"))
                        [void]$nodes.Add((New-DiagramNode -Id $name -Label "Domain root: $name" -Group $name))
                    }
                    foreach ($name in $expected) { if (-not $known.ContainsKey([string]$name)) { throw 'forest/domain inventory inconsistent' } }
                    $ouRows = New-Object System.Collections.ArrayList
                    foreach ($ou in @((Get-DiagramValue $Data 'TopLevelOUs'))) {
                        $domain = [string](Get-DiagramValue $ou 'Domain'); $name = [string](Get-DiagramValue $ou 'OU')
                        if (-not $known.ContainsKey($domain) -or -not $name) { throw 'OU owner domain or name unverified' }
                        [void]$ouRows.Add([pscustomobject]@{ Id = "$domain|$name"; Domain = $domain; Name = $name })
                    }
                    foreach ($ou in @(Get-DiagramSorted $ouRows 'Id')) {
                        [void]$nodes.Add((New-DiagramNode -Id $ou.Id -Label "OU: $($ou.Name)" -Group $ou.Domain))
                        [void]$edges.Add([pscustomobject]@{ Id = $ou.Id; Source = $ou.Domain; Target = $ou.Id; Label = 'Top-level OU'; Direction = 'None'; Members = @() })
                    }
                    $model.Domains = @($domains | ForEach-Object { [string](Get-DiagramValue $_ 'FQDN') })
                }
            }
            $model.Nodes = @(Get-DiagramSorted $nodes 'Id')
            $model.Edges = @(Get-DiagramSorted $edges 'Id')
            $model.Groups = @(Get-DiagramSorted $groups 'Id')
        } catch { $model.Reason = $_.Exception.Message }
        [void]$models.Add($model)
    }
    return @($models)
}

function Add-DiagramOp($Page, [string]$Kind, [int]$X, [int]$Y, [int]$X2, [int]$Y2, [string]$Text = '') {
    [void]$Page.Ops.Add([pscustomobject]@{ Kind=$Kind; X=$X; Y=$Y; X2=$X2; Y2=$Y2; Text=$Text })
}

function Get-DiagramLine([string]$Text, [int]$Limit = 70) {
    # Bound every text line without dropping any character; UTF-16 output is supported.
    $lines = New-Object System.Collections.ArrayList
    foreach ($paragraph in ($Text -split '\r?\n')) {
        $remaining = $paragraph
        while ($remaining.Length -gt $Limit) {
            $cut = $remaining.LastIndexOf(' ', $Limit)
            if ($cut -lt [int]($Limit / 2)) { $cut = $Limit }
            [void]$lines.Add($remaining.Substring(0,$cut))
            $remaining = $remaining.Substring($cut)
            if ($remaining.StartsWith(' ')) { $remaining = $remaining.Substring(1) }
        }
        [void]$lines.Add($remaining)
    }
    return @($lines)
}

function New-DiagramPage {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory layout DTO constructor; no external state is changed and no confirmation is appropriate.')]
    param([string]$Title)
    $p = [pscustomobject]@{ Ops=(New-Object System.Collections.ArrayList); Y=12; Height=0; NodeIds=(New-Object System.Collections.ArrayList); EdgeIds=(New-Object System.Collections.ArrayList) }
    foreach ($line in @(Get-DiagramLine $Title)) { Add-DiagramOp $p 'text' 18 $p.Y 0 0 $line; $p.Y += 27 }
    $p.Y += 24
    return $p
}

function Add-DiagramBox($Page, [string]$Label, [int]$X, [int]$Y, [int]$Width, [int]$Limit = 70) {
    $lines = @(Get-DiagramLine $Label $Limit)
    $height = 18 + 27 * $lines.Count
    Add-DiagramOp $Page 'rect' $X $Y ($X+$Width) ($Y+$height)
    $yText = $Y+7
    foreach ($line in $lines) { Add-DiagramOp $Page 'text' ($X+10) $yText 0 0 $line; $yText += 27 }
    return $height
}

function Get-DiagramPage($Model) {
    if ($Model.Reason) { throw $Model.Reason }
    if ($Model.Nodes.Count + $Model.Edges.Count -gt 2000) { throw 'diagram inventory exceeds safe rendering limit (2000)' }
    $pages = New-Object System.Collections.ArrayList
    $page = New-DiagramPage "Figure $($Model.Number) - $($Model.Title)"
    # Keep each card small and paginate at 1080 units; never shrink to illegibility.
    # Main node roster is a real bounded forest/tree or domain/OU grouping.
    $groupNames = @('')
    if ($Model.Groups.Count -gt 0) { $groupNames = @($Model.Groups | ForEach-Object { $_.Id }); if (@($Model.Nodes | Where-Object { $_.Group -eq 'External endpoints' }).Count -gt 0) { $groupNames += 'External endpoints' } }
    foreach ($group in $groupNames) {
        $groupNodes = @($Model.Nodes | Where-Object { $_.Group -eq $group })
        $groupTitle = $group
        if ($Model.Number -eq '5-1' -and $group -ne 'External endpoints') { $groupTitle = "Forest boundary: $($Model.Forest)`nTree: $group" }
        if ($Model.Number -eq '8-1') { $groupTitle = "Domain root: $group" }
        $groupStart=-1
        $groupLines = @(); if ($groupTitle) { $groupLines = @(Get-DiagramLine $groupTitle) }
        $bounded=($Model.Number -eq '5-1' -and $group -ne 'External endpoints')
        foreach ($node in $groupNodes) {
            $height = 18 + 27 * @(Get-DiagramLine $node.Label).Count
            if ($height -gt 750) { throw "node label too long: $($node.Id)" }
            $headingHeight=0; if ($groupStart -lt 0) { $headingHeight=27*$groupLines.Count }
            if ($page.Y + $height + $headingHeight + 24 -gt 1080) {
                if ($bounded -and $groupStart -ge 0) { Add-DiagramOp $page 'rect' 12 ($groupStart-5) 948 ($page.Y-10) }
                $page.Height=$page.Y+20; [void]$pages.Add($page); $page=New-DiagramPage "Figure $($Model.Number) - continued"; $groupStart=-1
            }
            if ($groupStart -lt 0) {
                $groupStart=$page.Y
                foreach ($line in $groupLines) { Add-DiagramOp $page 'text' 30 $page.Y 0 0 $line; $page.Y += 27 }
            }
            [void](Add-DiagramBox -Page $page -Label $node.Label -X 40 -Y $page.Y -Width 880)
            [void]$page.NodeIds.Add($node.Id)
            $page.Y += $height+24
        }
        if ($bounded -and $groupStart -ge 0) { Add-DiagramOp $page 'rect' 12 ($groupStart-5) 948 ($page.Y-10) }
    }
    # Edge panels are repeated-node views: each actual edge has visible endpoints
    # and a drawn connector. Hyperedges use one central link node and member spokes,
    # avoiding a fabricated pairwise mesh for 3+ member AD site links.
    $lookup = @{}; foreach ($node in $Model.Nodes) { $lookup[$node.Id] = $node.Label }
    foreach ($edge in $Model.Edges) {
        if ($edge.Members.Count -gt 0) {
            $rows = @($edge.Members)
            $header = $edge.Label
        } else { $rows = @($edge.Target); $header = $edge.Label }
        foreach ($target in $rows) {
            $left = $edge.Source; if ($edge.Members.Count -gt 0) { $left = $edge.Label }
            elseif ($lookup.ContainsKey($left)) { $left = $lookup[$left] }
            $right = $lookup[$target]
            if (-not $right) { throw "edge endpoint $target missing" }
            $lh = 18+27*@(Get-DiagramLine $left 27).Count; $rh=18+27*@(Get-DiagramLine $right 27).Count
            $height = [Math]::Max($lh,$rh)
            $headLines = @(Get-DiagramLine $header)
            $needed = $height + 27*$headLines.Count + 30
            if ($needed -gt 900) { throw "edge label too long: $($edge.Id)" }
            if ($page.Y + $needed -gt 1080) { $page.Height=$page.Y+20; [void]$pages.Add($page); $page=New-DiagramPage "Figure $($Model.Number) - relationships continued" }
            foreach ($line in $headLines) { Add-DiagramOp $page 'text' 30 $page.Y 0 0 $line; $page.Y+=27 }
            $leftY=$page.Y+[int](($height-$lh)/2)
            $rightY=$page.Y+[int](($height-$rh)/2)
            [void](Add-DiagramBox -Page $page -Label $left -X 30 -Y $leftY -Width 360 -Limit 27)
            [void](Add-DiagramBox -Page $page -Label $right -X 570 -Y $rightY -Width 360 -Limit 27)
            $mid=$page.Y+[int]($height/2)
            Add-DiagramOp $page 'line' 390 $mid 570 $mid
            # Arrow follows Source-relative AD trust direction, NOT inferred auth flow.
            if ($edge.Direction -in @('Outbound','Bidirectional')) { Add-DiagramOp $page 'line' 570 $mid 556 ($mid-8); Add-DiagramOp $page 'line' 570 $mid 556 ($mid+8) }
            if ($edge.Direction -in @('Inbound','Bidirectional')) { Add-DiagramOp $page 'line' 390 $mid 404 ($mid-8); Add-DiagramOp $page 'line' 390 $mid 404 ($mid+8) }
            $page.Y += $height+22
        }
        [void]$page.EdgeIds.Add($edge.Id)
    }
    if ($Model.Edges.Count -eq 0 -and $Model.Number -ne '6-1') {
        Add-DiagramOp $page 'text' 30 $page.Y 0 0 'No relationships returned by the successful source query.'; $page.Y+=30
    }
    $page.Height=$page.Y+20; [void]$pages.Add($page)
    # Fail closed: actual rendered node/edge occurrences must exactly cover model.
    $nodeSeen=@{}; $edgeSeen=@{}
    foreach ($p in $pages) {
        foreach ($id in $p.NodeIds) { if ($nodeSeen.ContainsKey($id)) { throw 'duplicate rendered node' }; $nodeSeen[$id]=$true }
        foreach ($id in $p.EdgeIds) { if ($edgeSeen.ContainsKey($id)) { throw 'duplicate rendered edge' }; $edgeSeen[$id]=$true }
    }
    if ($nodeSeen.Count -ne $Model.Nodes.Count -or $edgeSeen.Count -ne $Model.Edges.Count) { throw 'rendered inventory mismatch' }
    foreach ($node in $Model.Nodes) { if (-not $nodeSeen.ContainsKey($node.Id)) { throw 'rendered node missing' } }
    foreach ($edge in $Model.Edges) { if (-not $edgeSeen.ContainsKey($edge.Id)) { throw 'rendered edge missing' } }
    return @($pages)
}

function New-DiagramEmf {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory byte-array constructor using MemoryStream; no file or external state is changed.')]
    param($Page)
    # MS-EMF records only: HEADER, MAPMODE, BKMODE, SELECTOBJECT,
    # EXTCREATEFONTINDIRECTW, RECTANGLE, MOVETOEX, LINETO, EXTTEXTOUTW, EOF.
    # 960 logical units across a 6.3-inch frame; 23-unit font = approx 10.9pt.
    $stream = New-Object IO.MemoryStream
    $w = New-Object IO.BinaryWriter($stream)
    $records=1
    try {
        $w.Write([uint32]1); $w.Write([uint32]108)
        foreach ($v in @(0,0,960,$Page.Height,0,0,16002,[int]($Page.Height*16002/960))) { $w.Write([int32]$v) }
        $w.Write([uint32]1179469088); $w.Write([uint32]65536)
        $w.Write([uint32]0); $w.Write([uint32]0); $w.Write([uint16]2); $w.Write([uint16]0)
        foreach ($v in @(0,0,0,960,$Page.Height,160,[int]($Page.Height*160/960),0,0,0,160020,[int]($Page.Height*160020/960))) { $w.Write([int32]$v) }
        # MM_TEXT; transparent background; stock NULL_BRUSH.
        foreach ($pair in @(@(17,1),@(18,1),@(37,2147483653))) { $w.Write([uint32]$pair[0]); $w.Write([uint32]12); $w.Write([uint32]$pair[1]); $records++ }
        $w.Write([uint32]82); $w.Write([uint32]332); $w.Write([uint32]1)
        $font = New-Object byte[] 320
        [BitConverter]::GetBytes([int32]-23).CopyTo($font,0)
        [BitConverter]::GetBytes([int32]12).CopyTo($font,4)
        [BitConverter]::GetBytes([int32]400).CopyTo($font,16)
        $font[23]=1
        [Text.Encoding]::Unicode.GetBytes('Courier New').CopyTo($font,28)
        $w.Write($font); $records++
        $w.Write([uint32]37); $w.Write([uint32]12); $w.Write([uint32]1); $records++
        foreach ($op in $Page.Ops) {
            switch ($op.Kind) {
                'rect' { $w.Write([uint32]43); $w.Write([uint32]24); foreach ($v in @($op.X,$op.Y,$op.X2,$op.Y2)) { $w.Write([int32]$v) }; $records++ }
                'line' {
                    $w.Write([uint32]27); $w.Write([uint32]16); $w.Write([int32]$op.X); $w.Write([int32]$op.Y)
                    $w.Write([uint32]54); $w.Write([uint32]16); $w.Write([int32]$op.X2); $w.Write([int32]$op.Y2); $records+=2
                }
                'text' {
                    $textBytes=[Text.Encoding]::Unicode.GetBytes($op.Text)
                    $padding=(4-($textBytes.Length%4))%4
                    $w.Write([uint32]84); $w.Write([uint32](76+$textBytes.Length+$padding))
                    foreach ($v in @(0,0,960,$Page.Height)) { $w.Write([int32]$v) }
                    $w.Write([uint32]1); $w.Write([single]1); $w.Write([single]1)
                    $w.Write([int32]$op.X); $w.Write([int32]$op.Y); $w.Write([uint32]$op.Text.Length); $w.Write([uint32]76); $w.Write([uint32]0)
                    foreach ($v in @(0,0,960,$Page.Height,0)) { $w.Write([int32]$v) }
                    $w.Write($textBytes); if ($padding) { $w.Write((New-Object byte[] $padding)) }; $records++
                }
                default { throw "unknown diagram primitive $($op.Kind)" }
            }
        }
        $w.Write([uint32]14); $w.Write([uint32]20); $w.Write([uint32]0); $w.Write([uint32]0); $w.Write([uint32]20); $records++
        $length=$stream.Length; $stream.Position=48; $w.Write([uint32]$length); $w.Write([uint32]$records)
        return ,$stream.ToArray()
    } finally { $w.Dispose(); $stream.Dispose() }
}

function Read-DiagramZipXml($Zip, [string]$Name) {
    $entry=$Zip.GetEntry($Name)
    if ($null -eq $entry) { throw "Package part missing: $Name" }
    $r=New-Object IO.StreamReader($entry.Open())
    try { $x=New-Object Xml.XmlDocument; $x.PreserveWhitespace=$true; $x.LoadXml($r.ReadToEnd()); return ,$x } finally { $r.Dispose() }
}

function Write-DiagramZipPart($Zip, [string]$Name, [byte[]]$Bytes) {
    $entry=$Zip.GetEntry($Name); if ($null -eq $entry) { $entry=$Zip.CreateEntry($Name) }
    $s=$entry.Open(); try { $s.SetLength(0); $s.Write($Bytes,0,$Bytes.Length) } finally { $s.Dispose() }
}

function New-DiagramParagraph {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Constructs a detached XML paragraph in memory; no document publication or external state change occurs.')]
    param($Doc, [string]$Text)
    $w='http://schemas.openxmlformats.org/wordprocessingml/2006/main'
    $p=$Doc.CreateElement('w','p',$w); $r=$Doc.CreateElement('w','r',$w); $t=$Doc.CreateElement('w','t',$w)
    $t.InnerText=$Text; [void]$r.AppendChild($t); [void]$p.AppendChild($r); return ,$p
}

function New-DiagramDrawing {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Constructs a detached XML drawing in memory; no package write or external state change occurs.')]
    param($Doc, [string]$RelId, [int]$Id, [string]$Description, [int]$Height)
    $escape=[Security.SecurityElement]::Escape($Description)
    $h=[long]($Height*6000000/960)
    $xml='<w:p xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:r><w:drawing><wp:inline xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" distT="0" distB="0" distL="0" distR="0"><wp:extent cx="6000000" cy="'+$h+'"/><wp:docPr id="'+$Id+'" name="AD Figure '+$Id+'" descr="'+$escape+'"/><wp:cNvGraphicFramePr/><a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture"><pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"><pic:nvPicPr><pic:cNvPr id="'+$Id+'" name="AD Figure '+$Id+'"/><pic:cNvPicPr/></pic:nvPicPr><pic:blipFill><a:blip xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" r:embed="'+$RelId+'"/><a:stretch><a:fillRect/></a:stretch></pic:blipFill><pic:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="6000000" cy="'+$h+'"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr></pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing></w:r></w:p>'
    $fragment=New-Object Xml.XmlDocument; $fragment.LoadXml($xml)
    return ,$Doc.ImportNode($fragment.DocumentElement,$true)
}

function Write-ForestDiagram($Zip, $Doc, $Ns, $Data, [string]$Version) {
    $ErrorActionPreference='Stop'
    $script:DiagramStatus = [ordered]@{}
    $body=$Doc.SelectSingleNode('//w:body',$Ns)
    $models=@(Get-ForestDiagramModel $Data)
    $results=New-Object System.Collections.ArrayList
    $rels=Read-DiagramZipXml $Zip 'word/_rels/document.xml.rels'
    $types=Read-DiagramZipXml $Zip '[Content_Types].xml'
    $rn='http://schemas.openxmlformats.org/package/2006/relationships'; $ct='http://schemas.openxmlformats.org/package/2006/content-types'
    $id=0
    foreach ($node in @($Doc.SelectNodes("//*[local-name()='docPr']"))) { $v=0; if ([int]::TryParse($node.GetAttribute('id'),[ref]$v) -and $v -gt $id) { $id=$v } }
    foreach ($model in $models) {
        $number=$model.Number
        $blocks=@($body.SelectNodes('w:tbl',$Ns) | Where-Object { ([string]::Join('',@($_.SelectNodes('.//w:t',$Ns) | ForEach-Object { $_.InnerText }))) -match ('^FIGURE '+[regex]::Escape($number)+'\s') })
        $captions=@($body.SelectNodes('w:p',$Ns) | Where-Object { ([string]::Join('',@($_.SelectNodes('.//w:t',$Ns) | ForEach-Object { $_.InnerText }))) -match ('^Figure '+[regex]::Escape($number)+'\s') })
        if ($blocks.Count -ne 1 -or $captions.Count -ne 1) {
            $reason="template figure block/caption not uniquely found (blocks=$($blocks.Count), captions=$($captions.Count))"
            Add-FillFailure "Figure $number - $reason"
            Add-Warn "Figure $number not generated - $reason"
            $message=New-DiagramParagraph $Doc "Figure $number not generated - $reason"
            if ($captions.Count -eq 1) { [void]$body.ReplaceChild($message,$captions[0]) }
            elseif ($blocks.Count -eq 1) { [void]$body.ReplaceChild($message,$blocks[0]) }
            else { $section=$body.SelectSingleNode('w:sectPr',$Ns); if ($section) { [void]$body.InsertBefore($message,$section) } else { [void]$body.AppendChild($message) } }
            $script:DiagramStatus["Figure $number"]=[pscustomobject]@{Status='partial';Detail=$reason}
            [void]$results.Add([pscustomobject]@{Number=$number; Generated=$false; Reason=$reason; Pages=0})
            continue
        }
        $block=$blocks[0]; $caption=$captions[0]
        $reason=$model.Reason; $pages=@(); $parts=New-Object System.Collections.ArrayList
        try {
            if ($reason) { throw $reason }
            $pages=@(Get-DiagramPage $model)
            $pageNumber=0
            foreach ($page in $pages) {
                $pageNumber++; $id++
                $relId="rIdADFigure$id"
                while (@($rels.DocumentElement.ChildNodes | Where-Object { $_.GetAttribute('Id') -eq $relId }).Count -gt 0) { $id++; $relId="rIdADFigure$id" }
                $name="ad-figure-$number-$id.emf"; $part="word/media/$name"
                if ($Zip.GetEntry($part)) { throw "Diagram image part collision: $part" }
                $bytes=New-DiagramEmf $page
                # Inventory is attached to the drawing, tied to page ids and text primitives.
                $description=[ordered]@{ Figure=$number; Page=$pageNumber; NodeIds=@($page.NodeIds); EdgeIds=@($page.EdgeIds); Nodes=@($model.Nodes | Where-Object { $page.NodeIds -contains $_.Id }); Edges=@($model.Edges | Where-Object { $page.EdgeIds -contains $_.Id }); Text=@($page.Ops | Where-Object { $_.Kind -eq 'text' } | ForEach-Object { $_.Text }) } | ConvertTo-Json -Depth 12 -Compress
                $drawing=New-DiagramDrawing -Doc $Doc -RelId $relId -Id $id -Description $description -Height $page.Height
                [void]$parts.Add([pscustomobject]@{Part=$part; Bytes=$bytes; Rel=$relId; Target="media/$name"; Drawing=$drawing})
            }
        } catch { $reason=$_.Exception.Message }
        # Renderer exceptions remain local gaps. Package commit exceptions propagate
        # to the existing publication guard; a partially committed ZIP is never published.
        if (-not $reason) {
            foreach ($part in $parts) {
                Write-DiagramZipPart $Zip $part.Part $part.Bytes
                $rel=$rels.CreateElement('Relationship',$rn); $rel.SetAttribute('Id',$part.Rel); $rel.SetAttribute('Type','http://schemas.openxmlformats.org/officeDocument/2006/relationships/image'); $rel.SetAttribute('Target',$part.Target); [void]$rels.DocumentElement.AppendChild($rel)
                $override=$types.CreateElement('Override',$ct); $override.SetAttribute('PartName','/'+$part.Part); $override.SetAttribute('ContentType','image/x-emf'); [void]$types.DocumentElement.AppendChild($override)
            }
            # Persist relationships/types before exposing any drawing in document.xml.
            $utf8=New-Object Text.UTF8Encoding($false)
            Write-DiagramZipPart $Zip 'word/_rels/document.xml.rels' ($utf8.GetBytes($rels.OuterXml))
            Write-DiagramZipPart $Zip '[Content_Types].xml' ($utf8.GetBytes($types.OuterXml))
        }
        if ($reason) {
            [void]$body.InsertBefore((New-DiagramParagraph $Doc "Figure $number not generated - $reason"),$block)
            Add-PartialFill "Figure $number not generated - $reason"
            Add-Warn "Figure $number not generated - $reason"
        } else {
            foreach ($part in $parts) { [void]$body.InsertBefore($part.Drawing,$block) }
            Add-Filled "Figure $number ($($pages.Count) vector panel(s))"
        }
        [void]$body.RemoveChild($block)
        $date=$model.Date; if (-not $date) { $date='[YYYY-MM-DD]' }
        $text="Figure $number  $($model.Title) - Diagram version: $Version - Date: $date"
        if ($number -eq '5-1') { $text="Figure $number  Logical topology - $($model.Forest) - Diagram version: $Version - Date: $date - Author: [Name]" }
        if ($number -eq '6-2') { $design=$model.Design; if (-not $design) { $design='[Hub-and-spoke / Mesh / Hybrid]' }; $text+=" - Design: $design" }
        if ($number -eq '8-1') { $text+=" - Model applies to: $($model.Domains -join '; ')" }
        if ($reason) { $text+=" - not generated - $reason" }
        [void]$caption.ParentNode.ReplaceChild((New-DiagramParagraph $Doc $text),$caption)
        $script:DiagramStatus["Figure $number"]=[pscustomobject]@{Status=if ($reason) {'partial'} else {'ok'};Detail=$reason}
        [void]$results.Add([pscustomobject]@{Number=$number; Generated=(-not [bool]$reason); Reason=$reason; Pages=if ($reason) {0} else {$pages.Count}})
    }
    return @($results)
}


function Write-DocumentXml($Zip, $Data, [string]$DataFileName, [string]$OutputDocumentPath) {
    $ErrorActionPreference = 'Stop'
    $entry = $Zip.GetEntry('word/document.xml')
    if ($null -eq $entry) { throw 'Template is not a Word document: word/document.xml not found.' }
    $reader = New-Object System.IO.StreamReader($entry.Open())
    $xmlText = $reader.ReadToEnd()
    $reader.Close()

    $doc = New-Object System.Xml.XmlDocument
    $doc.PreserveWhitespace = $true
    $doc.LoadXml($xmlText)
    $ns = New-NsManager $doc
    $script:NormalizedShadingCells = Repair-DuplicateCellShading $doc $ns
    $body = $doc.SelectSingleNode('//w:body', $ns)
    $children = @($body.ChildNodes)
    $getTables = { @($doc.SelectNodes('//w:tbl', $ns)) }
    $K = $script:KeepPlaceholder

    $forest = $Data['Forest']
    $today = (Get-Date).ToString('yyyy-MM-dd')

    # Highest drawing / content-control ids in the template; clones (Section 4
    # blocks and appended table rows) are numbered above them.
    $script:IdState = [pscustomobject]@{ DocPr = 0L; Sdt = 0L }
    foreach ($n in @($doc.SelectNodes("//*[local-name()='docPr']"))) { $v = 0L; if ([long]::TryParse($n.GetAttribute('id'), [ref]$v) -and $v -gt $script:IdState.DocPr) { $script:IdState.DocPr = $v } }
    foreach ($n in @($doc.SelectNodes('//w:sdtPr/w:id', $ns))) { $v = 0L; if ([long]::TryParse($n.GetAttribute('val', $script:W), [ref]$v) -and $v -gt $script:IdState.Sdt) { $script:IdState.Sdt = $v } }

    # --- Section 4: clone the domain block once per extra domain -------------
    $startIdx = -1; $endIdx = -1
    for ($i = 0; $i -lt $children.Count; $i++) {
        if ($children[$i].LocalName -ne 'p') { continue }
        $text = Get-HeadingText $children[$i] $ns
        if ($startIdx -lt 0 -and $text -like '*Domain:*Enter domain FQDN*') { $startIdx = $i }
        elseif ($startIdx -ge 0 -and $text -like '5*Logical Topology*') { $endIdx = $i; break }
    }
    $domains = @($Data['DomainDetails'] | Where-Object { $null -ne $_ })
    if ($domains.Count -eq 0) {
        Add-Skipped 'Section 4 domain block (no domain details in the data - block left as template)'
    } elseif ($startIdx -ge 0 -and $endIdx -gt $startIdx) {
        $domainBlocks = New-Object System.Collections.ArrayList
        $blockNodes = @($children[$startIdx..($endIdx - 1)])
        [void]$domainBlocks.Add($blockNodes)
        $anchor = $children[$endIdx]
        for ($d = 1; $d -lt $domains.Count; $d++) {
            $clones = New-Object System.Collections.ArrayList
            foreach ($node in $blockNodes) {
                $clone = $node.CloneNode($true)
                [void]$body.InsertBefore($clone, $anchor)
                [void]$clones.Add($clone)
            }
            $cloneNodes = @($clones | Where-Object { $_.LocalName -ne 'bookmarkStart' -and $_.LocalName -ne 'bookmarkEnd' })
            foreach ($c in @($clones | Where-Object { $_.LocalName -eq 'bookmarkStart' -or $_.LocalName -eq 'bookmarkEnd' })) { [void]$body.RemoveChild($c) }
            Initialize-ClonedBlock $cloneNodes $ns $script:IdState
            [void]$domainBlocks.Add($cloneNodes)
        }
        for ($d = 0; $d -lt $domains.Count; $d++) {
            Write-DomainBlock $domainBlocks[$d] $ns $domains[$d] ($d + 1)
        }
    } else {
        Add-Skipped 'Section 4 domain block (heading pattern not found - per-domain fill skipped)'
    }

    $dcState = Get-SectionState $Data @('DomainControllers')
    $dcPartialNote = ''
    if ($dcState -and $dcState.Status -ne 'ok') { $dcPartialNote = " (PARTIAL - $($dcState.Detail))" }

    # --- Cover, scope, executive summary, forest overview ---------------------
    Set-KvValues (& $getTables) $ns @('Forest root domain', '[Enter forest root domain FQDN]') ([ordered]@{
        'Forest root domain' = $forest.RootDomain
        'Date of this version' = $today
    }) 'Cover table'
    Set-KvValues (& $getTables) $ns @('In-scope forest') ([ordered]@{
        'In-scope forest' = $forest.RootDomain
        'In-scope domains' = (Join-List @($Data['Domains'] | ForEach-Object { $_.FQDN }))
        'In-scope sites / regions' = (Join-List @($Data['Sites'] | ForEach-Object { $_.Name }))
    }) 'Scope table'

    $writableTotal = @($Data['DomainControllers'] | Where-Object { $null -ne $_ -and -not $_.IsRODC }).Count
    $rodcTotal = @($Data['DomainControllers'] | Where-Object { $null -ne $_ -and $_.IsRODC }).Count
    $dcTotal = @($Data['DomainControllers'] | Where-Object { $null -ne $_ }).Count
    Set-KvValues (& $getTables) $ns @('Forest root domain', '[Enter FQDN]') ([ordered]@{
        'Forest root domain' = $forest.RootDomain
        'Number of domains' = "$(@($Data['Domains'] | Where-Object { $null -ne $_ }).Count)"
        'Number of domain controllers' = "$dcTotal - writable: $writableTotal  RODC: $rodcTotal$dcPartialNote"
        'Number of AD sites' = "$(@($Data['Sites'] | Where-Object { $null -ne $_ }).Count)"
        'Users (approx. / exact, state which)' = (Get-CountTotal $Data 'Users')
        'Computers' = (Get-CountTotal $Data 'Computers')
        'Groups' = (Get-CountTotal $Data 'Groups')
        'Forest functional level' = $forest.ForestMode
    }) 'Executive summary - forest at a glance'

    $deletedLifetime = $forest.DeletedObjectLifetime
    if ($deletedLifetime -eq '' -and $forest.DeletedObjectLifetimeRead -ne $false) { $deletedLifetime = 'Not set - tombstone lifetime applies' }
    # The forest overview KV table shares its first-row text with the
    # executive summary table, so fill it by its distinctive row labels.
    foreach ($tbl in (& $getTables)) {
        $rows = Get-TableRows $tbl $ns
        $hasSchemaRow = $false
        for ($i = 0; $i -lt $rows.Count; $i++) {
            $cells = Get-RowCells $rows.Item($i) $ns
            if ($cells.Count -ge 1 -and (Get-CellText $cells.Item(0) $ns) -like 'Schema version*') { $hasSchemaRow = $true }
        }
        if ($hasSchemaRow) {
            $map = [ordered]@{
                'Forest functional level' = $forest.ForestMode
                'Schema version (objectVersion)' = $forest.SchemaVersion
                'Tombstone lifetime (days)' = $forest.TombstoneLifetime
                'Deleted-object lifetime (days)' = $deletedLifetime
                'AD Recycle Bin' = $forest.RecycleBin
            }
            $map['Forest root domain'] = $forest.RootDomain
            for ($i = 0; $i -lt $rows.Count; $i++) {
                $cells = Get-RowCells $rows.Item($i) $ns
                if ($cells.Count -lt 2) { continue }
                $labelText = (Get-CellText $cells.Item(0) $ns).Trim()
                if ($labelText -like 'Forest root domain*NetBIOS*') { $map[$labelText] = $forest.RootNetBIOS }
            }
            $fState = Get-SectionState $Data @('Forest', 'OptionalFeatures')
            Set-KvTableValues $tbl $ns $map 'Forest overview' $fState
        }
    }

    # KDS root key sits in the forest-level table in Section 3.4 of the
    # template (not in the per-domain block) - fill it once.
    $kdsValue = "$($forest.KdsRootKey)"
    if ($kdsValue -ne '') {
        Set-KvValues (& $getTables) $ns @('KDS root key created') ([ordered]@{
            'KDS root key created' = $kdsValue
        }) 'KDS root key (forest level)' (Get-SectionState $Data @('KdsRootKey'))
    } else { Add-Skipped 'KDS root key (forest level) (not read; template placeholder kept)' }

    # --- Section 3 tables -----------------------------------------------------
    $domainTableRows = @($Data['Domains'] | Where-Object { $null -ne $_ } | ForEach-Object { ,@($_.FQDN, $_.NetBIOS, $_.DomainMode, $_.Parent) })
    Write-DataTable (& $getTables) $ns @('Domain FQDN', 'NetBIOS name', 'Domain functional level') $domainTableRows 'Domains in this forest' (Get-SectionState $Data @('Domains'))

    $fsmoForestRows = @(
        @('Schema Master', $forest.SchemaMaster, (Get-DcSite $Data $forest.SchemaMaster)),
        @('Domain Naming Master', $forest.DomainNamingMaster, (Get-DcSite $Data $forest.DomainNamingMaster))
    )
    # Forest FSMO table rows are pre-labelled; fill holder/site by label. The
    # fourth (verified/checked) column is a human field and keeps its placeholder.
    $fsmoTbl = Find-Table (& $getTables) $ns @('Role', 'Holder (DC FQDN)')
    if ($fsmoTbl) {
        $rows = Get-TableRows $fsmoTbl $ns
        for ($i = 1; $i -lt $rows.Count; $i++) {
            $cells = Get-RowCells $rows.Item($i) $ns
            if ($cells.Count -lt 1) { continue }
            $labelText = (Get-CellText $cells.Item(0) $ns)
            foreach ($fr in $fsmoForestRows) {
                if ($labelText -like "*$($fr[0])*") {
                    if ($cells.Count -ge 2) { Set-CellText $cells.Item(1) $ns $fr[1] }
                    if ($cells.Count -ge 3 -and "$($fr[2])" -ne '') { Set-CellText $cells.Item(2) $ns $fr[2] }
                }
            }
        }
        Add-Filled 'Forest-wide FSMO roles (holder, site)'
    }

    # All optional features, retaining scope evidence and human dates.
    Write-OptionalFeature -Tables (& $getTables) -Ns $ns -Data $Data

    # --- Section 5: trusts ------------------------------------------------------
    $trustState = Get-CollectionState $Data @('Trusts')
    $trustRowsA = @($Data['Trusts'] | Where-Object { $null -ne $_ } | ForEach-Object { ,@($_.Source, $_.Target, $_.Type, $_.Direction) })
    Write-DataTable (& $getTables) $ns @('Source domain', 'Target domain / forest') $trustRowsA 'Trusts (source/target/type/direction)' $trustState
    $trustRowsB = @($Data['Trusts'] | Where-Object { $null -ne $_ } | ForEach-Object { ,@($_.Transitive, $_.SelectiveAuth, $_.SidFiltering, $_.Notes) })
    Write-DataTable (& $getTables) $ns @('Transitivity', 'Selective Authentication?') $trustRowsB 'Trusts (transitivity/selective auth/SID filtering)' $trustState

    # --- Section 6: sites, subnets, site links -----------------------------------
    $siteState = Get-CollectionState $Data @('Sites')
    $siteRowsA = @($Data['Sites'] | Where-Object { $null -ne $_ } | ForEach-Object { ,@($_.Name, $_.Location, $_.Subnets, $_.ISTG) })
    Write-DataTable (& $getTables) $ns @('Site name', 'Location / country') $siteRowsA 'Sites' $siteState
    $siteRowsB = @($Data['Sites'] | Where-Object { $null -ne $_ } | ForEach-Object { ,@($_.Name, $K, $_.Domains, $K) })
    Write-DataTable (& $getTables) $ns @('Site name', 'Preferred bridgehead') $siteRowsB 'Sites (bridgeheads/domains)' (Get-CollectionState $Data @('Sites', 'DomainControllers'))
    $subnetDataRows = @($Data['Subnets'] | Where-Object { $null -ne $_ } | ForEach-Object { ,@($_.Subnet, $_.Site, $_.Location) })
    Write-DataTable (& $getTables) $ns @('Subnet (CIDR)', 'Site') $subnetDataRows 'Subnets' (Get-CollectionState $Data @('Subnets'))
    $linkState = Get-CollectionState $Data @('SiteLinks')
    $linkRowsA = @($Data['SiteLinks'] | Where-Object { $null -ne $_ } | ForEach-Object { ,@($_.Name, $_.MemberSites, $_.Cost, $_.Interval) })
    Write-DataTable (& $getTables) $ns @('Site link name', 'Member sites') $linkRowsA 'Site links' $linkState
    $linkRowsB = @($Data['SiteLinks'] | Where-Object { $null -ne $_ } | ForEach-Object { ,@($_.Name, $_.Schedule, $_.Transport, $_.ChangeNotification) })
    Write-DataTable (& $getTables) $ns @('Site link name', 'Schedule') $linkRowsB 'Site links (schedule/transport/notification)' $linkState

    # --- Section 7: DC inventory (five matched tables) and services matrix -----
    # Service states (AD DS running, KDC, checked-on date) are NOT collected by
    # this script and are left as template placeholders for a human check.
    $dcs = @($Data['DomainControllers'] | Where-Object { $null -ne $_ })
    Write-DataTable (& $getTables) $ns @('Hostname', 'FQDN', 'Domain', 'Site') `
        @($dcs | ForEach-Object { ,@($_.Name, $_.HostName, $_.Domain, $_.Site) }) 'DC inventory 1/5 (identity/site)' $dcState
    Write-DataTable (& $getTables) $ns @('Hostname', 'Location / data centre') `
        @($dcs | ForEach-Object { ,@($_.Name, $K, (Join-List @($_.IPv4, $_.IPv6) ' / '), ((("$($_.OS) $($_.OSVersion)")).Trim())) }) 'DC inventory 2/5 (location/IP/OS)' $dcState
    Write-DataTable (& $getTables) $ns @('Hostname', 'Physical / Virtual / Azure') `
        @($dcs | ForEach-Object { ,@($_.Name, $K, $(if ($_.IsGC) { 'Yes' } else { 'No' }), $(if ($_.IsRODC) { 'Yes' } else { 'No' })) }) 'DC inventory 3/5 (GC/RODC)' $dcState
    Write-DataTable (& $getTables) $ns @('Hostname', 'FSMO roles held') `
        @($dcs | ForEach-Object { ,@($_.Name, $_.FSMORoles, $K, $K) }) 'DC inventory 4/5 (FSMO)' $dcState
    Write-DataTable (& $getTables) $ns @('Hostname', 'Backup agent / method') `
        @($dcs | ForEach-Object { ,@($_.Name, $K, $K, $(if (-not $_.Enabled) { 'DC object disabled in AD' } else { $K })) }) 'DC inventory 5/5 (backup/monitoring)' $dcState
    Write-DataTable (& $getTables) $ns @('DC FQDN', 'AD DS') `
        @($dcs | ForEach-Object { ,@($_.HostName, $K, $K, "Configured ports (from AD, not probed): LDAP $($_.LdapPort) / LDAPS $($_.SslPort)") }) 'Services matrix 1/3 (FQDN, ports from AD; service states left for a human)' $dcState
    Write-DataTable (& $getTables) $ns @('DC FQDN', 'Kerberos KDC') `
        @($dcs | ForEach-Object { ,@($_.HostName, $K, $K, $(if ($_.IsGC) { 'Yes' } else { 'No' })) }) 'Services matrix 2/3 (FQDN, GC flag from AD; KDC state left for a human)' $dcState
    Write-DataTable (& $getTables) $ns @('DC FQDN', 'W32Time role') `
        @($dcs | ForEach-Object { ,@($_.HostName, $(if ($_.FSMORoles -like '*PDCEmulator*') { 'PDC emulator (from FSMO data; W32Time config not checked)' } else { 'Non-PDC DC (from FSMO data; W32Time config not checked)' }), $K, $K) }) 'Services matrix 3/3 (FQDN, role from FSMO data; checked-on date left for a human)' $dcState

    # Per-DC detail table: forest root PDC Emulator - only collected AD facts.
    $rootDom = $Data['DomainDetails'] | Where-Object { $null -ne $_ -and $_.FQDN -eq $forest.RootDomain } | Select-Object -First 1
    if ($rootDom) {
        $pdc = $dcs | Where-Object { $_.HostName -eq $rootDom.PDCEmulator } | Select-Object -First 1
        if ($pdc) {
            Set-KvValues (& $getTables) $ns @('Domain controller (FQDN)') ([ordered]@{
                'Domain controller (FQDN)' = $pdc.HostName
                'Global Catalog' = $(if ($pdc.IsGC) { 'Yes (from AD)' } else { 'No (from AD)' })
                'W32Time' = 'PDC emulator (from FSMO data; W32Time config not checked)'
            }) 'Per-DC services detail (forest root PDC Emulator; service states left for a human)'
        }
    }

    # --- Sections 8, 9, 10, 11 -------------------------------------------------
    $ouDataRows = @($Data['TopLevelOUs'] | Where-Object { $null -ne $_ } | ForEach-Object { ,@("$($_.OU) [$($_.Domain)]", $K, $K, $K) })
    Write-DataTable (& $getTables) $ns @('Top-level OU', 'Delegated group / role') $ouDataRows 'Top-level OUs' (Get-CollectionState $Data @('TopLevelOUs', 'Domains'))
    $gpoDataRows = @($Data['GPOs'] | Where-Object { $null -ne $_ } | ForEach-Object { ,@($_.Name, $_.LinkedTo, $(if ("$($_.Purpose)" -ne '') { $_.Purpose } else { $K }), $_.Owner) })
    Write-DataTable (& $getTables) $ns @('GPO name', 'Linked OU / site / domain') $gpoDataRows 'GPO register' (Get-SectionState $Data @('GPOs', 'GpoLinks', 'Domains'))
    $zoneDataRows = @($Data['DnsZones'] | Where-Object { $null -ne $_ } | ForEach-Object { ,@($_.Zone, $_.Type, $_.ReplicationScope, $_.DynamicUpdate) })
    Write-DataTable (& $getTables) $ns @('Zone name', 'Zone type') $zoneDataRows 'DNS zones' (Get-SectionState $Data @('DnsZones'))
    $fwdDataRows = @($Data['DnsForwarders'] | Where-Object { $null -ne $_ } | ForEach-Object { ,@($_.Server, $_.Forwarders, $_.Notes) })
    Write-DataTable (& $getTables) $ns @('DNS server / scope', 'Forwarder IP(s)') $fwdDataRows 'DNS forwarders' (Get-SectionState $Data @('DnsForwarders'))
    $condDataRows = @($Data['DnsConditionalForwarders'] | Where-Object { $null -ne $_ } | ForEach-Object { ,@($_.Zone, $_.Forwarders, $_.Storage, $K) })
    Write-DataTable (& $getTables) $ns @('Domain / zone', 'Forwarder IP(s)') $condDataRows 'DNS conditional forwarders' (Get-SectionState $Data @('DnsZones'))
    $protDataRows = @($Data['ProtectedGroups'] | Where-Object { $null -ne $_ } | ForEach-Object { ,@($_.Group, $_.MemberCount, $K, $K) })
    Write-DataTable (& $getTables) $ns @('Protected group', 'Member count') $protDataRows 'Protected groups' (Get-SectionState $Data @('ProtectedGroups', 'Domains'))

    $script:DiagramResults = @(Write-ForestDiagram -Zip $Zip -Doc $doc -Ns $ns -Data $Data -Version $script:ScriptVersion)

    # Global placeholder sweep for the forest root FQDN tokens.
    Edit-ParagraphText @($body.ChildNodes) $ns '[Enter forest root domain FQDN]' $forest.RootDomain

    # Automatic-field labels come from the REAL template, not placeholder text.
    # Validated by remains a human name/role sign-off, as in earlier versions.
    $source = 'live collection in this run'
    if (-not $script:LiveCollection) { $source = "data file $DataFileName (collected $($Data['CollectedAt']))" }
    $tools = "PowerShell - Populate-ADForestOverview.ps1 v$($script:ScriptVersion) (ActiveDirectory module; GroupPolicy / DnsServer where available); source: $source"
    $ids = $Data['Identities']
    if ($ids -and "$($ids.ActiveDirectory)" -ne "$($ids.GroupPolicy)") { $tools += "; AD read as $($ids.ActiveDirectory), GroupPolicy/DNS read as $($ids.GroupPolicy)" }
    $automatic = [ordered]@{
        'Validation date' = $today
        'Validation method' = $tools
        'Validation run date/time' = "$($Data['CollectedAt'])"
        'Run by' = "$($Data['CollectedBy'])"
        'Run from' = "$($Data['CollectedFrom'])"
        'Output location' = $OutputDocumentPath
    }
    foreach ($label in $automatic.Keys) {
        $name = 'Validation summary'
        if ($label -in @('Validation run date/time', 'Run by', 'Run from', 'Output location')) { $name = 'Appendix C' }
        $cell = Resolve-AutomaticField (& $getTables) $ns $label $name
        if ("$($automatic[$label])" -eq '') { Add-FillFailure "$name - automatic field '$label' has no source value" }
        elseif ($null -ne $cell) { Set-CellText $cell $ns "$($automatic[$label])" }
    }
    # Resolve before computing the text, so all automatic-field failures appear
    # in known gaps when that cell is available. Wording branches are unchanged.
    $gapsCell = Resolve-AutomaticField (& $getTables) $ns 'Known gaps at validation' 'Known gaps at validation'
    $verification = Get-VerificationText $Data $DataFileName
    if ($null -ne $gapsCell) { Set-CellText $gapsCell $ns $verification }

    # --- Save -----------------------------------------------------------------
    $newXml = $doc.OuterXml
    $stream = $entry.Open()
    try {
        $stream.SetLength(0)
        $bytes = (New-Object System.Text.UTF8Encoding($false)).GetBytes($newXml)
        $stream.Write($bytes, 0, $bytes.Length)
    } finally { $stream.Close() }
}

# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------

function Test-SamePath([string]$A, [string]$B) {
    $onWindows = ($PSVersionTable.PSEdition -eq 'Desktop') -or $IsWindows
    $cmp = [System.StringComparison]::Ordinal
    if ($onWindows) { $cmp = [System.StringComparison]::OrdinalIgnoreCase }
    return [string]::Equals([IO.Path]::GetFullPath($A).TrimEnd('\', '/'), [IO.Path]::GetFullPath($B).TrimEnd('\', '/'), $cmp)
}

try {
    # Resolve every path against the PowerShell location up front. .NET APIs
    # (ZipFile) resolve relative paths against the process directory instead.
    if ($TemplatePath) { $TemplatePath = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($TemplatePath) }
    if ($OutputPath)   { $OutputPath   = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($OutputPath) }
    if ($OutputFolder) { $OutputFolder = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($OutputFolder) }
    if ($DataFile)     { $DataFile     = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($DataFile) }

    if ($ExportOnly -and $DataFile) { throw '-ExportOnly and -DataFile cannot be combined (nothing to collect or populate).' }
    if (-not $ExportOnly) {
        if (-not $TemplatePath) { throw 'TemplatePath is required unless -ExportOnly is used.' }
        if (-not $OutputPath)   { throw 'OutputPath is required unless -ExportOnly is used.' }
        if (-not (Test-Path -LiteralPath $TemplatePath -PathType Leaf)) { throw "Template not found: $TemplatePath" }
        if (Test-SamePath $TemplatePath $OutputPath) { throw "OutputPath resolves to the template itself ($OutputPath). Refusing: the template must never be modified." }
        if ((Test-Path -LiteralPath $OutputPath) -and -not $Overwrite) { throw "Output already exists: $OutputPath. Use -Overwrite to replace it, or choose another -OutputPath." }
        $script:TemplateHashAtStart = (Get-FileHash -LiteralPath $TemplatePath -Algorithm SHA256 -ErrorAction Stop).Hash
        if ((Test-Path -LiteralPath $OutputPath) -and
            (Get-FileHash -LiteralPath $OutputPath -Algorithm SHA256 -ErrorAction Stop).Hash -eq $script:TemplateHashAtStart) {
            throw "Output content equals the template hash; possible template alias. Refusing overwrite: $OutputPath"
        }
        $outParent = Split-Path -Parent $OutputPath
        if (-not (Test-Path -LiteralPath $outParent -PathType Container)) { throw "Output folder does not exist: $outParent" }
    }
    # Evidence-folder safety is mode-independent, including -DataFile replay.
    if ((Test-Path -LiteralPath $OutputFolder) -and @(Get-ChildItem -LiteralPath $OutputFolder -Force).Count -gt 0 -and -not $Overwrite) {
        throw "Evidence folder is not empty: $OutputFolder. Use a new folder (the default is timestamped) or -Overwrite."
    }
    if ($DataFile) {
        if (-not (Test-Path -LiteralPath $DataFile -PathType Leaf)) { throw "Data file not found: $DataFile" }
    }
} catch {
    Write-Host "REFUSED: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$dataFileName = ''
$script:PublishedDocumentPath = ''
$failureStep = 'data loading, collection or export'
try {
    if ($DataFile) {
        $Data = ConvertTo-DataHashtable (Get-Content -LiteralPath $DataFile -Raw | ConvertFrom-Json)
        $dataFileName = Split-Path -Leaf $DataFile
        $script:DataCollectedAt = "$($Data['CollectedAt'])"
        Write-Host "Loaded data from: $DataFile"
        if (-not $Data.Contains('ScriptVersion')) {
            Add-Note 'The data file predates v1.1: it has no warning record and no section status, and its "Policy source GPO" values were never verified.'
            foreach ($dom in @($Data['DomainDetails'] | Where-Object { $null -ne $_ })) {
                if ("$($dom['PolicySourceGpo'])" -ne '') { $dom['PolicySourceGpo'] = 'Not verified (data file predates v1.1)' }
            }
        }
    } else {
        try {
            $script:LiveCollection = $true
            $Data = Get-ADForestData
        } catch {
            throw "AD collection failed: $($_.Exception.Message). Is the RSAT ActiveDirectory module installed and are you connected to the forest?"
        }
        $Data['Warnings'] = @($script:Warnings)
        $Data['Notes'] = @($script:Notes)
        Export-ADData $Data $OutputFolder
    }

    if (-not $ExportOnly) {
        $failureStep = 'document population/publication'
        try {
            Write-ForestDocument $Data $TemplatePath $OutputPath $dataFileName
        } finally {
            Write-Host "Normalized duplicate-shading cells: $script:NormalizedShadingCells"
        }
        $failureStep = "normalization-evidence write: $(Join-Path $OutputFolder 'DOCX-Normalization.json')"
        # Run-local evidence, separate from immutable collection-origin data.
        if (-not (Test-Path -LiteralPath $OutputFolder -PathType Container)) {
            [void](New-Item -ItemType Directory -Path $OutputFolder -Force -ErrorAction Stop)
        }
        [ordered]@{
            ScriptVersion = $script:ScriptVersion
            TemplatePath = $TemplatePath
            OutputPath = $OutputPath
            NormalizedShadingCells = $script:NormalizedShadingCells
        } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $OutputFolder 'DOCX-Normalization.json') -Encoding UTF8 -ErrorAction Stop
        $failureStep = "diagram-evidence write: $(Join-Path $OutputFolder 'DOCX-Diagrams.json')"
        [ordered]@{
            ScriptVersion = $script:ScriptVersion
            Figures = @($script:DiagramResults)
            SectionStatus = $script:DiagramStatus
        } | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath (Join-Path $OutputFolder 'DOCX-Diagrams.json') -Encoding UTF8 -ErrorAction Stop
    }
} catch {
    Write-Host ''
    Write-Host "FAILED: $($_.Exception.Message)" -ForegroundColor Red
    if ($script:PublishedDocumentPath) {
        Write-Host "Document WAS written to: $script:PublishedDocumentPath" -ForegroundColor Yellow
        Write-Host "Failed step: $failureStep" -ForegroundColor Red
    } elseif (-not $ExportOnly -and $OutputPath) {
        Write-Host "No document was published by this run to $OutputPath; any pre-existing output may remain." -ForegroundColor Red
    }
    exit 1
}

# --- Report -------------------------------------------------------------------
$collectionWarnings = @()
$hasRecord = $true
if ($script:LiveCollection) { $collectionWarnings = @($script:Warnings) }
else {
    $hasRecord = $Data.Contains('Warnings')
    $collectionWarnings = @($Data['Warnings'] | Where-Object { $null -ne $_ })
    foreach ($n in @($Data['Notes'] | Where-Object { $null -ne $_ })) { [void]$script:Notes.Add("(collection) $n") }
}
$nonOkSections = @()
if ($Data['SectionStatus']) {
    $nonOkSections = @($Data['SectionStatus'].Keys | Where-Object { "$($Data['SectionStatus'][$_].Status)" -in @('partial', 'failed', 'skipped') } |
        ForEach-Object { "$_ = $($Data['SectionStatus'][$_].Status): $($Data['SectionStatus'][$_].Detail)" })
}

Write-Host ''
if ($ExportOnly) {
    Write-Host 'ExportOnly specified - no document was populated.'
} else {
    Write-Host '=== Population report ==='
    Write-Host "Filled sections (complete): $($script:Filled.Count)"
    $script:Filled | ForEach-Object { Write-Host "  [filled]  $_" }
    if ($script:PartialFills.Count -gt 0) {
        Write-Host "Partially filled (coverage gaps are marked in the document): $($script:PartialFills.Count)"
        $script:PartialFills | ForEach-Object { Write-Host "  [partial] $_" }
    }
    if ($script:FillFailures.Count -gt 0) {
        Write-Host "Table fills FAILED (left unfilled): $($script:FillFailures.Count)"
        $script:FillFailures | ForEach-Object { Write-Host "  [FAILED]  $_" }
    }
    if ($script:Skipped.Count -gt 0) {
        Write-Host "Skipped / needs a human: $($script:Skipped.Count)"
        $script:Skipped | ForEach-Object { Write-Host "  [skip]    $_" }
    }
}
if (-not $hasRecord) {
    Write-Host 'Collection warnings: UNKNOWN (data file predates v1.1 - no warning record).'
} elseif ($collectionWarnings.Count -gt 0) {
    Write-Host "Collection warnings: $($collectionWarnings.Count)"
    $collectionWarnings | ForEach-Object { Write-Host "  [warn]    $_" }
} else {
    Write-Host 'Collection warnings: 0'
}
if (-not $script:LiveCollection -and $script:Warnings.Count -gt 0) {
    Write-Host "Populate-run warnings: $($script:Warnings.Count)"
    $script:Warnings | ForEach-Object { Write-Host "  [warn]    $_" }
}
if ($nonOkSections.Count -gt 0) {
    Write-Host "Sections with partial / failed / skipped collection: $($nonOkSections.Count)"
    $nonOkSections | ForEach-Object { Write-Host "  [cover]   $_" }
}
if ($script:Notes.Count -gt 0) {
    Write-Host 'Notes:'
    $script:Notes | ForEach-Object { Write-Host "  [note]    $_" }
}
Write-Host ''
Write-Host 'Reminder: business purpose, risks, OU delegation, tiering,'
Write-Host 'backup tooling, Entra ID tenant fields and DC service states are human'
Write-Host 'fields by design. Check the document against the CSV/JSON evidence pack.'
foreach ($figure in @($script:DiagramResults | Where-Object { -not $_.Generated })) {
    Write-Information -MessageData "Figure $($figure.Number) not generated - $($figure.Reason)" -InformationAction Continue
}

$issues = $script:Warnings.Count + $collectionWarnings.Count + $script:FillFailures.Count + $script:PartialFills.Count + $nonOkSections.Count
if (-not $hasRecord) { $issues++ }
if ($issues -gt 0) {
    Write-Host "RESULT: COMPLETED WITH WARNINGS - exit code 2." -ForegroundColor Yellow
    exit 2
}
Write-Host 'RESULT: COMPLETE - exit code 0.'
exit 0
