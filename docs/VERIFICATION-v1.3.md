# Populate-ADForestOverview v1.3 - LAB VERIFICATION RECORD (ROUND 2)

Round 2 of the lab gate. Round 1 (v1.2, 2026-10-27) returned **FAIL** with four defects,
DEF-01 to DEF-04. v1.3 fixes those four defects and nothing else; the workshop re-check
(t_50e5700b) returned **APPROVE v1.3 for the lab re-gate**. This record scopes the re-run per the
round-1 defect handoff's regression gate: full re-run of items 2, 3, 5, 6, 7, 8 and 10;
items 4 and 11 as regression checks; items 1, 9 and 12 and the Word checks carried forward as
NOT RUN - completing them is required for production clearance. Run the items in order, keep
the transcript of every run, and fill in the results table at the end. Do not modify the script:
if a hash below does not match, stop - you do not have the approved build.

**Subject under test:**
- Script: `Populate-ADForestOverview-v1.3.ps1` - MD5 **00afd6ebcfbab71eddb62eedcaeed29b**
  (118,446 bytes, 2,095 lines, UTF-8 with BOM). Verify with `Get-FileHash -Algorithm MD5`
  before item 1. **v1.2 is superseded - do not run it.**
- Template: `ad-forest-overview-template.docx` - MD5 **0f05c69495ed4a646db5c27527c338ce**
  (unchanged from round 1). Hash it before the first run and after the last.

**Provenance:** built by factory card t_5ada63a5 (PowerShell Expert seat, GPT 6.1 Sol executing)
from the hash-verified v1.2 baseline; re-checked by card t_50e5700b, same seat and model, verdict
APPROVE for the lab re-gate on the reviewer's own fresh harness (per-defect: DEF-01 24/24,
DEF-02 18/18, DEF-03 15/15 + live 197/197, DEF-04 395/395 + supplemental 322/322; aggregate
1,031 assertion records, not unique scenarios). One provenance caveat from the re-check: the
builder's preserved records support its mid-run test-expectation correction as test-only, but do
not conclusively prove every historical builder result ran against the final script bytes. This
lab run executes the final bytes directly; its results are the operative evidence.

**Exit-code contract (unchanged):** 0 = complete with no skipped data coverage; 2 = completed
with warnings, partial collection, unverified sections or intentional skips (not an execution
failure - read the section statuses); 1 = failed or refused, no document written, previous
output intact. Invoke as `powershell.exe -NoProfile -ExecutionPolicy Bypass -File
.\Populate-ADForestOverview-v1.3.ps1 ...` unless an item says otherwise; `Start-Transcript`
first; record `$LASTEXITCODE` immediately after each run.

## What v1.3 changed (the behaviours this round must assert)

- **DEF-01:** the non-empty `-OutputFolder` refusal now applies in `-DataFile` mode exactly as
  in live mode (exit 1, no document). New explicit case in item 8.
- **DEF-02:** the verification text now lands in the template field labelled "Known gaps at
  validation": warning-bearing replays read "N issue(s) recorded at collection ...", clean
  replays read "None recorded at collection ...; not re-verified in this -DataFile run". A
  missing or duplicated known-gaps row is now a named fill failure (exit 2).
- **DEF-03:** an unknown parent domain no longer produces a "Tree-root" label. A direct child
  namespace is still classified parent-child via a DNS-hierarchy fallback; anything unresolved
  is labelled "Unverified intra-forest" (rendered with its direction suffix) with the Trusts
  section marked partial.
- **DEF-04:** Section 4 Heading 3 subheadings are numbered deterministically (4.1.x, 4.2.x,
  4.3.x) by the script in every domain block, and Appendix C is populated from the labels
  "Run by", "Run from" and "Output location" (collecting account, collecting host, resolved
  output document path). The "Validated by" name/role sign-off remains a human field by design -
  it is expected to stay a placeholder for a human to complete, and is not a failure.

## Round 1 results and round 2 disposition

| Item | Round 1 (v1.2) | Round 2 disposition |
|---|---|---|
| 1 - Forest shape | NOT RUN (two-domain lab only) | COMPLETE if the full fixture can be assembled; otherwise NOT RUN again with the gaps listed |
| 2 - Default 5.1 run | PASS | RE-RUN in full |
| 3 - DC and trust ground truth | FAIL (DEF-03) | RE-RUN, incl. the failed-child trust case |
| 4 - Privilege test | PASS | REGRESSION check (abbreviated procedure below) |
| 5 - Export / replay | FAIL (DEF-02) | RE-RUN |
| 6 - Child unreachable | FAIL (DEF-02 wording) | RE-RUN |
| 7 - Real template and Word | FAIL (DEF-04); Word NOT RUN | RE-RUN; Word checks still outstanding |
| 8 - Refusals and path safety | FAIL (DEF-01) | RE-RUN, incl. the new -DataFile folder case |
| 9 - Authoritative values | NOT RUN | COMPLETE if fixtures allow |
| 10 - Exit codes | FAIL (inherited DEF-01) | RE-RUN (collect from items 2, 4, 5, 6, 8) |
| 11 - Timing | PASS | REGRESSION check (abbreviated procedure below) |
| 12 - Read-only confirmation | NOT RUN (auditing off) | COMPLETE: enable auditing before item 2 |

## Lab fixture

Round 1 lab (sufficient for the defect re-tests): forest root + one child domain, three writable
DCs, PS 5.1 host, read-only network identity, firewall control. Still missing in round 1 and
required for items 1, 9 and 12 and full clearance: second tree; external, forest and shortcut
trusts; an RODC; a non-DNS DC; custom site-link schedule / SMTP link / unassigned subnet; gMSA
and KDS root key; the GPO-link fixture set (site link, disabled link, enforced link, unlinked
GPO) and a domain where a non-default GPO wins for Kerberos; Microsoft Word on the client;
Directory Service Changes auditing enabled on the DCs before the runs. If the forest still has
two domains, verify the 4.3.x numbering (item 7) by replaying a three-domain `-DataFile` export
through the real template and record that method in the results table.

## Criteria (round 2 procedures)

### 1. Forest shape - COMPLETE or NOT RUN

Assemble or confirm the full fixture above; save the ground-truth pack (`Get-ADForest`,
per-domain `Get-ADDomain`, `Get-ADTrust -Filter *`, `Get-ADDomainController -Filter *`).
Pass: every element present. Anything unbuildable is NOT RUN with the reason, and its dependent
checks are NOT RUN too.

### 2. Default run on PS 5.1, `-Server` pinned to a non-PDC root DC - RE-RUN

As round 1: hash check; transcript; `-Server <non-PDC root DC>`; record exit code; search the
transcript for "specified more than once" and binding errors; output + evidence folder created;
no stray .zip/temp in the working directory or `C:\Windows\System32`; template hash unchanged.
Pass: exit 0 or 2 (2 fully explained by warning/skip lines), zero binding errors.

### 3. DC and trust ground truth - RE-RUN

As round 1 (per-domain counts and Section 7 rows against ground truth; trusts deduplicated with
kind, transitivity and SID-filtering labels; tree-root labelling for a genuine second tree if
present), PLUS the DEF-03 scenario explicitly:
1. Make the child domain's ADWS unavailable to the collection host (as in item 6) and run live.
2. The root-to-child trust must read **Parent-child** (via the DNS-hierarchy fallback) - or, if
   the hierarchy cannot establish it, **Unverified intra-forest** with the Trusts section marked
   partial. It must NOT read "Tree-root".
3. Restore connectivity and re-run: the same trust reads Parent-child from the authoritative
   mapping, DC/trust counts unchanged from the failed-child run.
Pass: exact agreement with ground truth in the healthy run, and no Tree-root mislabel in the
failed-child run.

### 4. Privilege test - REGRESSION

Abbreviated: one admin run and one non-admin (`runas /netonly`) run. Compare the KDS, FGPP/PSO
and gMSA cells, the could-not-verify list and exit codes. Pass: the non-admin run keeps the
"None visible to <identity> - reading these objects needs Domain Admins-equivalent rights;
verify as an admin" wording (never "No" / "None found") and exits 2; the admin run's
conservative wording on a genuinely empty section remains accepted behaviour, recorded as
observed.

### 5. Round trip: `-ExportOnly` then `-DataFile`, on 5.1 and pwsh 7 - RE-RUN

As round 1, with the DEF-02 assertions now explicit:
1. `-ExportOnly` from a warning-bearing collection; replay on 5.1 and on pwsh 7.
2. In BOTH replay documents, the "Known gaps at validation" field contains "N issue(s) recorded
   at collection" with N matching the export's warning count - not the placeholder.
3. Repeat with a clean export: the field reads "None recorded at collection ...; not re-verified
   in this -DataFile run".
4. JSON inspection as round 1 (no `{"value":` / `,"Count":` wrappers, one-element collections
   stay arrays).
Pass: wording present and correct in the documents themselves on both hosts; exit codes
consistent.

### 6. Fault injection: child domain unreachable - RE-RUN

As round 1 (block TCP 9389 to the child DCs or stop ADWS there; record the method). Live run:
warning names the child domain, sections and executive summary PARTIAL, exit 2. Replay from
that export: the document's known-gaps field carries the recorded-issues wording (item 5
assertion), exit 2. (Round 1 note: the lab's child domain already had an ADWS failure before
injection; if that persists, record it - the assertions are the same.)

### 7. Real template and Word - RE-RUN + Word outstanding

1. Hash the template; run against it for the full available forest.
2. The [skip] list contains no data tables.
3. Every Section 4 Heading 3 carries its block number (4.1.x, 4.2.x - and 4.3.x via a third
   domain or the three-domain replay method in the fixture note), in order, with no doubled
   numbering.
4. Appendix C shows the collecting account, host and output path - no bracketed placeholders in
   "Run by", "Run from" or "Output location". ("Validated by" stays human; see What changed.)
5. The "Known gaps at validation" field is populated per items 5/6.
6. Word checks (NOT RUN in round 1): open the output in Word - no repair prompt; content
   controls show values; update the TOC (Update Field, entire table) without error. Record the
   Word version.
7. Template hash unchanged at the end.
Pass: all of the above. A Word repair prompt is a FAIL on its own.

### 8. Refusals and path safety - RE-RUN, incl. the DEF-01 case

Repeat all round 1 cases (relative output; case-variant, 8.3, `\\localhost\C$` and subst
template aliases with `-Overwrite`; existing output; non-empty folder live; locked output).
PLUS the round 1 failure, now as an explicit case:
- Non-empty `-OutputFolder` without `-Overwrite` in **`-DataFile` mode**: expect refusal,
  **exit 1**, no document created, folder contents untouched.
Pass: every refusal exit 1 with a clear message; template hash identical at the end.

### 9. Authoritative values - COMPLETE or NOT RUN

As round 1 (Kerberos vs `Get-GPOReport` incl. the alternate-winning-GPO domain; site-link
schedule/transport vs Sites and Services; GPO link flags vs GPMC). Round 1 ground truth is on
file (both domains: ticket lifetime 10h, renewal 7d, skew 5m) - the document must now populate
those values where collection succeeds. Pass: values match the authoritative tool; any mismatch
recorded verbatim is a FAIL.

### 10. Exit codes end-to-end - RE-RUN

Collect the `$LASTEXITCODE` values from items 2, 4, 5, 6 and 8 into the results table, including
the new item 8 -DataFile case (expect 1). Confirm the first fill in a fresh 5.1 session has no
compression / ZipArchiveMode error. Pass: every code matches the contract for its scenario.

### 11. Timing - REGRESSION

Record total and per-phase times for the item 2 run, and the DNS forwarder sweep time with one
DC unreachable (DROP rule). Pass: times recorded; flag a finding if the sweep alone exceeds 30
minutes or dominates the total. (Round 1 baseline: sweep 1.075s over 2 DCs; full run ~32s.)

### 12. Read-only confirmation - COMPLETE

Enable Directory Service Changes auditing on the DCs BEFORE item 2. After all runs, query the
Security logs for events 5136 / 5137 / 5139 / 5141 by the run accounts in the run window.
Pass: zero attributable events. Any event is a FAIL - attach the event XML. (Round 1's
zero-event result was inconclusive because auditing was off; it does not carry forward.)

## Overall verdict (the verifying agent completes exactly one)

- **PASS - cleared for production:** every item 1-12 PASS in this round (items 2, 4 and 11
  round-1 passes do not carry forward - their round-2 re-run / regression results are the ones
  that count), Word checks passed, item 12 passed with auditing enabled.
- **INCOMPLETE:** every executed item passes, but one or more of items 1, 9, 12 or the Word
  checks remain NOT RUN. Not cleared for production; the outstanding items are listed.
- **PASS WITH FINDINGS:** no FAIL on items 2, 4, 6, 7, 8 or 12; findings on other items
  recorded verbatim with evidence.
- **FAIL:** any FAIL on a core item, a Word repair prompt, a changed template hash, a wrong DC
  or trust count, a surviving automatic-field placeholder, or a directory-modification event.

Return: this record with the results table filled, all transcripts, the populated documents,
the `AD-Forest-Data.json` exports, and the ground-truth pack.

## Results table (round 2 - fill in during the lab run)

| Item | Host / account | Result | Exit code(s) | Evidence (transcript / file) | Date | By |
|---|---|---|---|---|---|---|
| Hash check (script + template) | | | - | | | |
| 1 | | | - | | | |
| 2 | | | | | | |
| 3 | | | | | | |
| 4 (regression) | | | | | | |
| 5 | | | | | | |
| 6 | | | | | | |
| 7 | | | | | | |
| 8 | | | | | | |
| 9 | | | - | | | |
| 10 | | | | | | |
| 11 (regression) | | | - | | | |
| 12 | | | - | | | |

**Overall verdict:** ______________  **Date:** __________  **By:** ______________
