# Populate-ADForestOverview v1.3 — Production Clearance Runbook

**Purpose:** Close the remaining holds from the round-2 lab verdict without repeating the defect regressions that already passed.  
**Current status:** INCOMPLETE — not cleared for production.  
**Approved script MD5:** `00afd6ebcfbab71eddb62eedcaeed29b`  
**Approved template MD5:** `0f05c69495ed4a646db5c27527c338ce`

Do not modify the approved script or template. If either hash changes, stop and re-approve the build before testing.

## Remaining clearance gates

| Gate | Required outcome |
|---|---|
| A — Lab connectivity | Healthy cross-DC ADWS and GPO collection from the pinned collection host |
| B — Full fixture | All item 1 and item 9 fixture elements present, or explicit production acceptance of any scope exclusion |
| C — Healthy item 3 run | Exact three-DC/trust agreement using authoritative domain mappings |
| D — Item 9 values | Kerberos, site-link, transport, schedule, and GPO-link values agree with authoritative tools |
| E — Microsoft Word | No repair prompt; content controls render; entire TOC updates without error |
| F — Final audit/evidence | Zero attributable directory-change events and a complete evidence bundle |

## 1. Preserve the baseline and start a new evidence set

Use a new working directory, for example `C:\ADForestVerify13\production-gate`. Do not overwrite the round-2 evidence.

```powershell
New-Item -ItemType Directory -Path 'C:\ADForestVerify13\production-gate' -Force
Get-FileHash -Algorithm MD5 -LiteralPath 'C:\ADForestVerify13\inputs\Populate-ADForestOverview-v1.3.ps1'
Get-FileHash -Algorithm MD5 -LiteralPath 'C:\ADForestVerify13\inputs\ad-forest-overview-template.docx'
```

Record the collection host, PowerShell version, account, start time, and both hashes. Start a transcript before every run and record `$LASTEXITCODE` immediately afterward.

## 2. Gate A — Restore healthy collection before rerunning the script

The previous post-restore run still failed to collect `child.ad.example.com` through ADWS. A firewall removal alone is not evidence of healthy collection.

From `DC02`, test every DC and record the results:

```powershell
$targets = @(
    '10.20.30.110',
    '10.20.30.111',
    '10.20.30.112'
)
foreach ($target in $targets) {
    Test-NetConnection -ComputerName $target -Port 9389 -InformationLevel Detailed
}
```

Then validate the actual AD and GPO reads used by the script:

```powershell
Import-Module ActiveDirectory
Import-Module GroupPolicy

Get-ADDomain -Server '10.20.30.110'
Get-ADDomain -Server '10.20.30.112'
Get-ADDomainController -Filter * -Server '10.20.30.110'
Get-ADDomainController -Filter * -Server '10.20.30.112'
Get-ADTrust -Filter * -Server '10.20.30.110'
Get-ADTrust -Filter * -Server '10.20.30.112'

Get-GPOReport -Guid '31B2F340-016D-11D2-945F-00C04FB984F9' -Domain 'ad.example.com' -ReportType Xml
Get-GPOReport -Guid '31B2F340-016D-11D2-945F-00C04FB984F9' -Domain 'child.ad.example.com' -ReportType Xml
```

If a read fails, correct the lab connectivity or collection-host configuration—not the script. Record any service, firewall, DNS, or policy change made to restore the fixture. Do not proceed to the authoritative healthy-run comparison until these reads succeed from the pinned collection host.

**Gate A pass:** TCP 9389 and the AD/GPO reads succeed against both domains; three DC objects are visible; no stale verification firewall rules remain.

## 3. Gate B — Assemble and inventory the complete fixture

Confirm and document all required elements before the final run:

- Forest root, child domain, and a genuine second tree.
- Parent-child, tree-root, shortcut, external, and forest trusts as applicable.
- Three writable DCs plus an RODC and a DC without the DNS role.
- Custom IP site-link schedule, SMTP site link, and an unassigned subnet.
- gMSA and a valid KDS root key.
- GPO-link fixtures: site link, disabled link, enforced link, and unlinked GPO.
- A domain where a non-default GPO supplies the winning Kerberos policy.
- Microsoft Word on the validation client.
- Directory Service Changes auditing enabled before the new live runs.

Refresh the ground-truth pack after assembling the fixture. Include `Get-ADForest`, per-domain `Get-ADDomain`, `Get-ADDomainController -Filter *`, and `Get-ADTrust -Filter *`, plus the authoritative GPO and Sites and Services exports.

**Gate B pass:** every required fixture element is present and represented in the ground-truth pack. Otherwise, the final verdict remains INCOMPLETE.

## 4. Enable auditing for the new live-run window

On every DC, record the current setting and enable Directory Service Changes auditing before running the script:

```powershell
auditpol.exe /get /subcategory:'Directory Service Changes'
auditpol.exe /set /subcategory:'Directory Service Changes' /success:enable /failure:enable
auditpol.exe /get /subcategory:'Directory Service Changes'
```

Record the exact run-window start time. Restore the original audit settings only after the final Security-log query and evidence collection.

## 5. Gate C — Run the healthy item 3 comparison

Use a new output directory and the pinned non-PDC root DC:

```powershell
$work = 'C:\ADForestVerify13\production-gate\item3-healthy'
New-Item -ItemType Directory -Path $work -Force
Set-Location $work
Start-Transcript -Path (Join-Path $work 'transcript.txt') -Force

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File 'C:\ADForestVerify13\inputs\Populate-ADForestOverview-v1.3.ps1' `
  -TemplatePath 'C:\ADForestVerify13\inputs\ad-forest-overview-template.docx' `
  -OutputPath (Join-Path $work 'AD-Forest-Overview.docx') `
  -Server 'DC02.ad.example.com'

$code = $LASTEXITCODE
Write-Host "LASTEXITCODE=$code"
Stop-Transcript
```

Inspect `AD-Forest-Data.json`, `Trusts.csv`, the DC inventory tables, and the transcript.

**Gate C pass criteria:**

- Exit `0`, or exit `2` fully explained by intentional skips or unrelated disclosed coverage gaps.
- No child-domain `Get-ADDomain`, DC-collection, or trust-collection warning.
- `DomainDetails` for `child.ad.example.com` shows successful collection and authoritative parent `ad.example.com`.
- All three current DCs appear exactly once and agree with ground truth; include additional fixture DCs in the comparison when assembled.
- `ad.example.com` → `child.ad.example.com` is `Parent-child (Uplevel)` from the authoritative mapping, not merely the DNS fallback.
- Trusts are deduplicated with correct kind, direction, transitivity, selective-authentication, and SID-filtering labels.
- A genuine second-tree root, when present, is `Tree-root`; unresolved intra-forest relationships are never invented as tree-root trusts.
- No wrong DC/trust count and no `Tree-root` label on the parent-child trust.

Any wrong count or trust classification is a FAIL, not a finding.

## 6. Gate D — Compare item 9 authoritative values

### Kerberos policy

Export the winning GPO report for each domain and compare the populated document with the authoritative values. Include the domain where a non-default GPO wins.

Verify at minimum:

- Maximum user ticket lifetime.
- Maximum service ticket lifetime, if reported by the template.
- Maximum ticket renewal period.
- Maximum clock skew.
- The GPO identified as the policy source.

The previous lab baseline was ticket lifetime `10` hours, renewal `7` days, and skew `5` minutes. Reconfirm these values rather than assuming they are still current.

### Sites, services, and GPO links

Compare the document with Active Directory Sites and Services and GPMC for:

- Site-link name, member sites, cost, and replication interval.
- Custom schedule and change notification.
- IP versus SMTP transport.
- Subnet-to-site assignment and the unassigned-subnet fixture.
- Site-linked, disabled, enforced, and unlinked GPO cases.
- The winning GPO where multiple policies could apply.

**Gate D pass:** every populated value agrees exactly with the authoritative tool. Record any mismatch verbatim and mark item 9 FAIL. Missing fixtures leave the production gate INCOMPLETE.

## 7. Gate E — Validate the populated DOCX in Microsoft Word

Use the output from the healthy run and a Word-equipped client. Record the Word edition, version, build, and client hostname.

1. Confirm the output DOCX still has valid package structure before opening it.
2. Open the document in Word. Record any repair or recovery prompt.
3. Inspect content controls and the following values:
   - Forest and domain names.
   - Section 4 numbering, including `4.3.x` when three or more domains are present.
   - `Run by`, `Run from`, and `Output location` in Appendix C.
   - `Known gaps at validation`.
4. Confirm no bracketed placeholder remains in automatic fields. `Validated by` remains a human sign-off field.
5. Click in the TOC and choose **Update Field → Update entire table**.
6. Confirm the TOC updates without error and shows the numbered domain subheadings.
7. Save the updated copy, close Word, and reopen it to confirm no repair prompt appears.
8. Verify the approved template hash is still unchanged.

**Gate E pass:** no repair prompt on either open, content controls show values, and the entire TOC updates without error. Any repair prompt is an automatic FAIL.

## 8. Gate F — Complete the final audit and evidence review

After all live runs, query every DC for the run window:

```powershell
$start = [datetime]'REPLACE_WITH_RUN_WINDOW_START_UTC'
Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    Id = 5136,5137,5139,5141
    StartTime = $start
} -ErrorAction SilentlyContinue |
    ForEach-Object { $_.ToXml() }
```

Review all returned events and attach the XML for anything attributable to the test accounts or run window.

**Gate F pass:** zero attributable directory-modification events, auditing was enabled before the runs, all transcripts and outputs are present, and the template hash is unchanged.

Restore the original audit settings and remove any temporary verification firewall rules. Record the restoration.

## 9. Final evidence package

Include:

- Completed verification record with one overall verdict.
- Script/template hashes before and after testing.
- Healthy-run and ground-truth transcripts.
- Populated DOCX files, including the Word-validated copy.
- All `AD-Forest-Data.json` exports and CSV evidence folders.
- Forest/domain/DC/trust ground-truth pack.
- Authoritative GPO XML, Sites and Services, and GPMC comparisons.
- Word version and repair/content-control/TOC results.
- Audit-policy records, run-window timestamps, event queries, and any event XML.
- Record of lab changes and restoration.

## Final clearance rule

Return **PASS — cleared for production** only when every checklist item passes in the final gate, including the healthy authoritative comparison, item 9, Word validation, and audited read-only confirmation. Keep **INCOMPLETE** for missing fixtures or unexecuted checks; return **FAIL** for any wrong count/trust label, surviving automatic-field placeholder, Word repair prompt, changed template hash, or attributable directory-modification event.
