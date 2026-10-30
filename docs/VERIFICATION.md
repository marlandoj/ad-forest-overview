# Populate-ADForestOverview v1.2 - LAB VERIFICATION RECORD

Every lab-gate criterion for the AD Forest Overview populate script, with its verification state in the
build/review environment. The criteria are the PowerShell Expert reviewer's 12-point lab checklist
(re-review t_8d171f1c), carried unchanged through the v1.2 approval (diff re-check t_83a14558,
VERDICT: APPROVE v1.2 for the lab gate, not for production). Run the items in order, keep the
transcript of every run, and fill in the results table at the end. Do not modify the script: if a
hash below does not match, stop - you do not have the approved build.

**Subject under test:**
- Script: `Populate-ADForestOverview-v1.2.ps1` - MD5 **2dae40f7a8ffdc0dcef6c99224740963**
  (112,093 bytes, 2,024 lines, UTF-8 with BOM). Verify with `Get-FileHash -Algorithm MD5` before item 1.
- Template: `ad-forest-overview-template.docx` - MD5 **0f05c69495ed4a646db5c27527c338ce**.
  Hash it before the first run and after the last; the script must never change it.

**Build/review environment:** Linux, PowerShell 7.4.6, PSScriptAnalyzer 1.25.0, mocked
ActiveDirectory / GroupPolicy / DnsServer cmdlets and synthetic templates. No Windows, no Windows
PowerShell 5.1, no real AD forest, no real template, no Word. Review chain: v1.0 review t_91200028
(REJECT) -> v1.1 build t_c1ed01ab -> re-review t_8d171f1c (APPROVE WITH RESIDUAL FIXES) -> v1.2 build
t_3937bc5a -> diff re-check t_83a14558 (APPROVE v1.2).

Legend:
- **CI-VERIFIED (pwsh 7.4.6 / Linux, mocked modules)** - proven in the workshop reviews by the named
  tests; evidence cited. Where the criterion also names PS 5.1, a real forest, the real template or
  Word, that half is still outstanding and listed.
- **LAB-ONLY / NOT VERIFIED IN THIS ENVIRONMENT** - nothing in the reviews claims it passed. The lab
  procedure says exactly what the lab run must do.

CI evidence base: re-review t_8d171f1c (own harness, 16 behavioural cases T1-T16 plus static scans);
v1.2 build t_3937bc5a self-tests (parser 0 errors; PSScriptAnalyzer Error 0, totals 0/55/130, 5.1
compatibility profile 0; DataFile suite 30/30; per-domain suite 11/11; targeted integration 20/20;
helper/publish 9/9); diff re-check t_83a14558 (own harness: integration 21/21, helpers 10/10, static
checks re-run; the builder's 30/30 and 11/11 suites were NOT rerun by the re-check and are not the
basis of its verdict).

**Exit-code contract (read before running anything):**
- **0** = complete, with no skipped data coverage.
- **2** = completed, but with warnings, partial collection, unverified sections, or intentional
  skips (`-SkipObjectCounts`, `-SkipDnsForwarders`). Exit 2 is **not** an execution failure - read
  the section statuses and the could-not-verify list in the output.
- **1** = failed or refused. On a refusal no document is written and a previous output is left intact.

Invoke every run as
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Populate-ADForestOverview-v1.2.ps1 ...`
unless an item says otherwise, start `Start-Transcript` first, and record `$LASTEXITCODE`
immediately after each run.

## Lab fixture - required for every LAB-ONLY item

Assemble or confirm in the lab forest (this is item 1, and the precondition for items 2-12):

- Forest root, a child domain, and a second tree; one external trust, one forest trust, one
  shortcut trust.
- At least one RODC, and at least one DC that is not a DNS server; one DC that can be made
  unreachable for item 11.
- A site link with a custom schedule (and an SMTP site link if available); an unassigned subnet.
- One PSO (fine-grained password policy), one gMSA, and a KDS root key.
- GPOs: one linked at a site, one linked at an OU with the link disabled, one linked at an OU with
  the link enforced, and one unlinked GPO; one domain where a GPO other than the Default Domain
  Policy wins for Kerberos policy.
- A protected group (e.g. Domain Admins) with a nested group and a foreign security principal as
  members.
- Accounts: a Domain/Enterprise Admin account; a non-admin read account (Domain Users is fine);
  optionally a dedicated `-Credential` account.
- Client: Windows with Windows PowerShell 5.1 (`powershell.exe`) AND pwsh 7 for item 5; RSAT AD,
  GPMC and DNS tools installed; Microsoft Word installed (item 7); local admin rights for item 8;
  control of a firewall rule (or the ADWS service) for item 6; Directory Service Changes auditing
  enabled on the DCs before item 2 (item 12).

## Criteria

### 1. Forest shape (fixture precondition)

State: **LAB-ONLY.** The reviews simulated comparable shapes against mocks (3-domain forest;
60-domain / 600-DC synthetic), never a real directory.

Lab procedure: assemble or confirm every element of the fixture above. Save the output of
`Get-ADForest`, `Get-ADDomain` per domain, `Get-ADTrust -Filter *` per domain, and
`Get-ADDomainController -Filter *` per domain as the ground-truth pack for items 3 and 9.

Pass condition: every element present. An element that cannot be built is recorded as NOT RUN with
the reason, and every dependent check below is NOT RUN too - never passed by default.

### 2. Default run on Windows PowerShell 5.1, `-Server` pinned to a non-PDC root DC

State: **LAB-ONLY** (statically supported: PSScriptAnalyzer 5.1 compatibility profile reports 0
findings on v1.2, and an AST scan finds 0 calls combining a splat with an explicit `-Server` -
the v1.0 defect that only failed on 5.1. The real 5.1 binder has never run this script).

Lab procedure:
1. From `powershell.exe`, hash the script and template (see Subject under test).
2. `Start-Transcript`; run the script with `-TemplatePath <real template>`,
   `-OutputPath <new path>`, `-Server <a non-PDC root DC>`.
3. Record `$LASTEXITCODE`; search the transcript for "specified more than once" and any
   parameter-binding error.
4. Confirm the output document and a timestamped evidence folder were created, and that no stray
   .zip or temp file appeared in the working directory or `C:\Windows\System32`.

Pass condition: the run completes with exit 0 or 2 (an exit 2 must be fully explained by warning /
skip lines in the transcript), zero binding errors, output + evidence present.

### 3. DC and trust ground truth

State: **CI-VERIFIED against domain-scoped mocks** (re-review T4/T5: 12 of 12 DCs across 3 domains;
trust views deduplicated incl. a shortcut trust visible only from a child domain; a failed domain
produces named warnings, PARTIAL rows and exit 2). **LAB-ONLY** for a real directory.

Lab procedure: using the item 1 ground-truth pack, compare per-domain DC counts and the document's
Section 7 rows; compare trust rows after deduplication (kinds, transitivity, SID-filtering labels);
check the second-tree domain is labelled "Tree root (trust parent: <forest root>)" and the root
domain "Forest root" (criterion R5).

Pass condition: exact agreement. Any discrepancy is a FAIL - record both values verbatim.

### 4. Privilege test - restricted objects must never be asserted absent **(reviewer-flagged: most important)**

State: **CI-VERIFIED against ACL-hiding mocks** (diff re-check, own run: with KDS/PSO/gMSA objects
hidden and no error raised, every affected cell reads exactly "None visible to CORP\auditor -
reading these objects needs Domain Admins-equivalent rights; verify as an admin", notes are
recorded, coverage is failed, exit 2; the v1.1 control build still produced "No" / "None found" /
exit 0, so the test discriminates). **LAB-ONLY** for real ACL behaviour.

Lab procedure:
1. Run the script as the Domain/Enterprise Admin account. Keep the output.
2. Run it as the non-admin read account, same template and parameters.
3. Compare the KDS root key section, the FGPP/PSO section and the gMSA section, the
   could-not-verify list, and the two exit codes.

Pass condition: the non-admin run never claims "No" or "None found" for those sections; it shows
the "None visible to <identity>" wording (or lists the sections as unverified in could-not-verify)
and exits 2. NOTE: the admin run may show the same wording and exit 2 for a section that is
genuinely empty - that conservative behaviour was reviewed and accepted (re-check Q2a). Record it
as observed; it is not by itself a FAIL.

### 5. Round trip: `-ExportOnly` then `-DataFile`, on 5.1 and on pwsh 7

State: **CI-VERIFIED on pwsh 7** (DataFile suites across the reviews: clean, warnings-present and
pre-v1.1 data files reproduce their recorded warnings, wording and exit codes). **LAB-ONLY** for
5.1 JSON serialisation.

Lab procedure:
1. `powershell.exe`: run with `-ExportOnly`. Keep `AD-Forest-Data.json` and the CSV pack.
2. `powershell.exe`: run with `-DataFile <that JSON>`; then `pwsh.exe`: same `-DataFile` run.
3. Inspect the raw JSON text: search for `{"value":` and `,"Count":` wrapper objects and for
   one-element collections written as scalars.
4. Compare the could-not-verify text in all three documents: a clean export reads "None recorded
   at collection ...; not re-verified in this -DataFile run", never a bare "None".

Pass condition: no wrappers, no scalar-collapsed arrays, wording and exit codes consistent across
hosts.

### 6. Fault injection: child domain unreachable

State: **CI-VERIFIED with mocks** (per-domain failures produce a warning naming the domain,
PARTIAL rows, a PARTIAL executive summary, exit 2, in live and `-DataFile` modes). **LAB-ONLY**
for real ADWS failure shapes.

Lab procedure:
1. Block ADWS (TCP 9389) to the child domain's DCs, or stop the ADWS service on them - record
   which method was used.
2. Run the script live; record exit code and the warning text.
3. Replay with `-DataFile` from that run's export.

Pass condition: the warning names the child domain; the document marks that domain's sections
PARTIAL (including the executive summary); exit 2 in both modes; the replay reads "N issue(s)
recorded at collection".

### 7. Real template and Word **(reviewer-flagged: most important)**

State: **LAB-ONLY / NOT VERIFIED IN THIS ENVIRONMENT.** No review ever saw the real template;
every fill test used synthetic templates. A renamed table header or an ambiguous label is exactly
what this item exists to catch (v1.2 turns both into named fill failures with exit 2).

Lab procedure:
1. Hash the template. Run the script against it for the full fixture forest (3+ domains).
2. Read the run's [skip] list: it must contain no data tables. Any data table listed, or a fill
   failure naming one, is a FAIL with the table name recorded.
3. Open the output in Word: there must be no repair prompt; domain sub-headings are renumbered
   (4.2.x, 4.3.x); content controls show values, not bracketed placeholders; update the TOC
   (right-click -> Update Field -> entire table) without error. Record the Word version.
4. Hash the template again - unchanged.

Pass condition: all of the above. A Word repair prompt is a FAIL on its own.

### 8. Refusals and path safety on Windows **(reviewer-flagged: most important)**

State: **CI-VERIFIED on Linux** (relative `-OutputPath`; template = output by literal path and by
`..` alias; existing output; non-zip template; and the v1.2 R4 content-hash publish guard against
equal-content copies, hardlinks, symlinks and a hardlink created during the fill). **LAB-ONLY**
for the Windows alias forms and the locked-file case.

Lab procedure (elevated `powershell.exe`, template hash taken first):
1. `cd` to a scratch directory; run with a relative `-OutputPath`: output lands in the scratch
   directory; check `C:\Windows\System32` for a stray zip/temp - expect none.
2. `-OutputPath` set to a case variant of the template path (`.\TEMPLATE.DOCX`): expect refusal,
   exit 1.
3. 8.3 short-name alias of the template (get it with `dir /x`), then a `\\localhost\C$\...` alias,
   then a `subst`-drive alias - each with `-Overwrite`: expect refusal each time, and the
   template intact (hash + opens in Word).
4. Existing output without `-Overwrite`: refusal. Non-empty `-OutputFolder` without
   `-Overwrite`: refusal.
5. Open the current output document in Word and leave it open; rerun with `-Overwrite`: expect
   FAILED, exit 1, and the open document unharmed.

Pass condition: every refusal is exit 1 with a clear message; the template hash at the end equals
the hash at the start.

### 9. Values against the authoritative tools

State: **CI-VERIFIED against documented shapes and mocks** (Kerberos policy read from the GPO
report's Account elements - re-review T4/T15 incl. a 2-of-3-settings partial case; site-link
schedule decoding; GPO links from gPLink with disabled/enforced flags). **LAB-ONLY** for real
GPO and schedule data.

Lab procedure:
1. `Get-GPOReport -Guid 31B2F340-016D-11D2-945F-00C04FB984F9 -ReportType Xml` and compare the
   Kerberos values (ticket lifetime, renewal, clock skew) with the document. Repeat in the domain
   where a different GPO wins for Kerberos, and record how the document's policy-source label
   reads there.
2. Site-link schedule and transport (IP/SMTP) against AD Sites and Services.
3. GPO link flags (enabled / enforced / disabled, "Not linked") against GPMC for the fixture's
   site, OU and domain links.

Pass condition: values match the authoritative tool. Any mismatch is a FAIL - record both values
verbatim.

### 10. Exit codes end-to-end, and the first fill

State: **CI-VERIFIED on pwsh 7** (exit 0 / 2 / 1 cases across all suites above). **LAB-ONLY** for
`powershell.exe -File` end-to-end and for the `System.IO.Compression` load order (v1.1 P1-16 was
verified statically only).

Lab procedure: collect the `$LASTEXITCODE` recorded in items 2, 4, 5, 6 and 8 into the results
table; confirm the first-ever fill in a fresh 5.1 session produced no compression / ZipArchiveMode
error.

Pass condition: every observed code matches the contract for its scenario.

### 11. Timing **(reviewer-flagged: most important)**

State: **NOT MEASURED on Windows.** (Linux reference only: the fill engine processed a synthetic
60-domain / 600-DC / 3,000-GPO data file in ~69 s; real runs are dominated by collection.)
**LAB-ONLY.**

Lab procedure:
1. Record total run time and per-phase times (transcript timestamps) for the item 2 run.
2. Make one DC unreachable (firewall DROP, not REJECT) and time the DNS forwarder sweep phase;
   record the DC count and the sweep duration.
3. Repeat with `-SkipDnsForwarders`: the sweep is skipped, the skip is disclosed in the output,
   and it contributes exit 2 - record all three facts.

Pass condition: times are recorded (this item sets the operational baseline; there is no fixed
threshold). Flag it as a finding if the sweep alone exceeds 30 minutes or dominates the total.

### 12. Read-only confirmation

State: **CI-VERIFIED by AST** (in every reviewed version the script's AD/GPO/DNS operations are
Get-* only - 27 collection calls in v1.2, all with `-ErrorAction Stop`; the only writes are the
output document and the evidence pack). **LAB-ONLY** for directory-side proof.

Lab procedure: with Directory Service Changes auditing enabled before item 2, after all runs query
the Security log on the DCs for events 5136 / 5137 / 5139 / 5141 by the run accounts within the
run window.

Pass condition: zero such events attributable to the run accounts. Any event is a FAIL - attach
the event XML.

## Overall verdict (the verifying agent completes exactly one)

- **PASS - cleared for production:** all 12 items PASS (item 1 elements present, or formally
  NOT RUN with their dependent checks also NOT RUN), and no FAIL anywhere.
- **PASS WITH FINDINGS:** no FAIL on items 2, 4, 6, 7, 8 or 12 (the safety/honesty core); findings
  on other items recorded verbatim with evidence.
- **FAIL:** any FAIL on a core item, a Word repair prompt (item 7), a changed template hash
  (items 7/8), a wrong DC or trust count (item 3), or a directory-modification event (item 12).

Return: this record with the results table filled, all transcripts, the populated documents, the
`AD-Forest-Data.json` exports, and the item 1 ground-truth pack.

## Results table (fill in during the lab run)

| Item | Host / account | Result | Exit code(s) | Evidence (transcript / file) | Date | By |
|---|---|---|---|---|---|---|
| Hash check (script + template) | | | - | | | |
| 1 | | | - | | | |
| 2 | | | | | | |
| 3 | | | - | | | |
| 4 | | | | | | |
| 5 | | | | | | |
| 6 | | | | | | |
| 7 | | | | | | |
| 8 | | | | | | |
| 9 | | | - | | | |
| 10 | | | | | | |
| 11 | | | - | | | |
| 12 | | | - | | | |

**Overall verdict:** ______________  **Date:** __________  **By:** ______________
