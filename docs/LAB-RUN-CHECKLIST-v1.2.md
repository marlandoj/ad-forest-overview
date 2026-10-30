# AD Forest Overview — Populate v1.2 Lab Run Checklist

**Purpose:** v1.2 is APPROVED for the lab gate (PowerShell Expert diff-only re-check, 2026-10-27). Production use waits on this lab run only. Nothing in any review exercised Windows PowerShell 5.1, a real forest, the real template, or Word — this run is where those get proven.

**Script under test (verify before running):**
- `Populate-ADForestOverview-v1.2.ps1` — MD5 **2dae40f7a8ffdc0dcef6c99224740963** (2,024 lines, UTF-8 with BOM). If the hash differs, stop — you do not have the approved build.
- Template: the real `ad-forest-overview-template.docx` (never the synthetic review template).

**Environment:** Windows PowerShell 5.1 via `powershell.exe` (not pwsh 7, except item 5's second pass), RSAT AD + GPMC + DNS tools installed.

**Read the verdict line correctly before you start:**
- Exit **0** = run complete with no skipped data coverage.
- Exit **2** = run completed, but with warnings, partial collection, or skipped data coverage (e.g. a domain unreachable, a table missing). Exit 2 is **not** an execution failure — read the issue lines in the output and the transcript.
- Exit **1** = failed or refused (bad input, template problems, I/O failure). The previous output document is left intact on refusals.

**Reviewer-flagged as most important after v1.2: items 4, 7, 8 and 11.**

Record for each item: PASS / FAIL + the evidence noted. Keep the transcript of every run.

---

## 1. Forest shape (precondition — assemble or confirm in the lab forest)
- [ ] Forest root, a child domain, and a second tree
- [ ] One external trust, one forest trust, one shortcut trust
- [ ] At least one RODC, and one DC that is not a DNS server
- [ ] A site link with a custom schedule (and an SMTP link if available)
- [ ] An unassigned subnet
- [ ] One PSO, one gMSA, and a KDS root key
- [ ] GPOs linked at a site, at an OU with the link disabled, and at an OU with the link enforced, plus one unlinked GPO
- [ ] A protected group with a nested group and a foreign security principal

## 2. Default run
- [ ] Run with `-Server` pinned to a non-PDC root DC
- [ ] Search the transcript for "specified more than once" and any parameter-binding error — expect none
- [ ] Record `$LASTEXITCODE`

## 3. DC and trust ground truth
- [ ] Compare per-domain DC counts and Section 7 rows against `Get-ADDomainController -Filter * -Server <each domain>`
- [ ] Compare trust rows against `Get-ADTrust -Filter * -Server <each domain>`, deduplicated, including the shortcut trust

## 4. ★ Privilege test (residual R1)
- [ ] Run once as Domain/Enterprise Admin and once as a non-admin read account
- [ ] Compare KDS, FGPP and gMSA sections between the two outputs
- [ ] PASS condition: the non-admin run labels those sections "None visible to <identity> - reading these objects needs Domain Admins-equivalent rights; verify as an admin" (the verified v1.2 wording) — it must **not** claim "No" or "None found". Exit code will be 2 on the non-admin run; that is expected, not a failure. (An admin run may show the same wording + exit 2 for a genuinely empty section — accepted conservative behaviour, not a failure.)

## 5. Round trip
- [ ] `-ExportOnly` on PS 5.1, then `-DataFile` on 5.1, and again on pwsh 7
- [ ] Inspect `AD-Forest-Data.json` for `{"value":...,"Count":...}` wrappers and for one-element arrays — expect none
- [ ] Confirm "could not verify" reads "None recorded at collection … not re-verified", not "None"

## 6. Fault injection
- [ ] Block ADWS (TCP 9389) to the child domain's DCs
- [ ] Expect: a warning naming the domain, PARTIAL rows, executive summary marked PARTIAL, exit 2
- [ ] Repeat with `-DataFile` from that export: expect "N issue(s) recorded at collection" and exit 2

## 7. ★ Real template
- [ ] The `[skip]` list contains **no data tables** (residual R2 — a skipped data table now fails the fill with exit 2)
- [ ] Every KV label matches exactly one key (Q3)
- [ ] Open the output in Word: no repair prompt with 3 or more domain blocks; sub-headings renumbered; content controls show values, not placeholders; update the TOC

## 8. ★ Refusals on Windows (from an elevated shell)
- [ ] Relative `-OutputPath` after `cd`: check `C:\Windows\System32` for a stray zip or temp file — expect none
- [ ] Template equals output using a case variant (`.\TEMPLATE.DOCX`): expect refusal
- [ ] 8.3 short-name or `\\localhost\C$` alias with `-Overwrite` (R4): the template must survive
- [ ] An existing output, and a non-empty evidence folder: expect refusals
- [ ] Output open in Word (locked): expect FAILED, exit 1, and the old document intact

## 9. Values against tools
- [ ] Kerberos values against `Get-GPOReport -Guid 31B2F340-016D-11D2-945F-00C04FB984F9 -ReportType Xml`, including a domain where another GPO sets Kerberos
- [ ] Site-link schedule against Sites and Services
- [ ] GPO link flags against GPMC

## 10. Exit codes
- [ ] `powershell.exe -File` gives 0, 2 or 1 as documented above
- [ ] ZipArchiveMode loads on the first fill

## 11. ★ Timing
- [ ] Record total and per-phase times
- [ ] Especially: the DNS forwarder sweep with one unreachable DC (R3), and the fill time on 5.1

## 12. Read-only confirmation
- [ ] With auditing of Directory Service Changes on, expect **no** 5136/5137 events attributable to the run account

---

**After the run:** a clean pass on all 12 items clears v1.2 for production use against the real forest. Any FAIL: note the item number, the exact output/exit code, and keep the transcript — that is everything a fix round needs.

*Provenance: checklist items are the PowerShell Expert reviewer's lab checklist (t_8d171f1c), carried unchanged through the v1.2 approval (t_83a14558, 2026-10-27). Script MD5 verified against the delivered build on 2026-10-27.*
