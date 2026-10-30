# Lab Retest Record — Populate-ADForestOverview v1.5.2 (Part 2 retest only)

**Candidate under test**

- Script: `Populate-ADForestOverview-v1.5.2.ps1` — MD5 `63ceb38e49e4c900f8d8cb045f0af20b`,
  SHA-256 `de56e327258e464cdf80390300e292c6030a46049f8f7309d359354994feda5b`
- Template: `ad-forest-overview-template-v1.1.1.docx` — MD5 `a3e0fdb3fe23de25a701dcda265b0383` (unchanged)

**Scope.** This is a retest of **Part 2 items 1 and 5** of `VERIFICATION-v1.5.1-LAB.md`
(plus the item 8 replay identity for Figure 6-2), following the fix for defect V151-01.
Part 1 (DEF-05 regression) and Part 3 (adopted fields) returned **PASS** against v1.5.1
and are **not** re-opened — v1.5.2 changes exactly one functional line (the Figure 6-2
member-count validation) plus version/help metadata; the focused workshop re-check
verified the freeze against this lab's own exported data, including EMF-hash equality
for Figures 5-1, 6-1 and 8-1 with the values recorded in the v1.5.1 submission.

**Operator ruling to apply during the retest (RC-01, waived 2026-10-30):** Figure 6-2's
caption retains the template's human placeholder `Design: [Hub-and-spoke / Mesh /
Hybrid]` when the design is not classified. That placeholder is accepted as the
template working as designed. **Do not flag it as a fabricated classification or a
defect.** A defect exists only if the script *asserts* a design (fills the field) that
the topology does not justify.

## Procedure

1. Live run of v1.5.2 with template v1.1.1 against the lab forest (same host/account
   discipline as the v1.5.1 runs). Record hashes before/after (must be unchanged),
   exit code, and console summary.
2. A `-DataFile` replay of the export from step 1.

## Expectations

1. **Figure 6-2 is generated** in both runs: `DOCX-Diagrams.json` reports `6-2`
   `Generated: true` with at least one EMF panel at the Figure 6-2 location.
2. **Content:** the figure shows the single site node (`Default-First-Site-Name`) and
   the link label `DEFAULTIPSITELINK | Cost: 100 | Interval: 180 minutes`, matching
   `SiteLinks.csv`. There is **no** second site node and **no** pairwise connector.
3. **Design honesty:** the caption's Design field remains the human placeholder (see
   the RC-01 ruling above) — the script must not assert Mesh/Hub-and-spoke/Hybrid for
   this topology.
4. **Replay identity:** the replay's Figure 6-2 inventory (nodes, link label) is
   identical to the live run's.
5. **Freeze spot-check:** the EMF SHA-256 hashes for Figures 5-1, 6-1 and 8-1 equal
   the v1.5.1 lab run's recorded values (5-1 `70bb0b91…`, 6-1 `2150100f…`, 8-1
   `0325ed51…` and `7f16c5ed…`; full values in the v1.5.1 analysis summary).
6. **Package health:** the supported-template documents keep zero duplicate-shading
   cells and zero full-package XSD errors (name the method/validator).
7. **Exit code:** the run's exit follows its remaining collection gaps. Note that the
   lab environment's known failed sections (KdsRootKey, gMSA) keep a live run at
   exit 2 — that is the pre-existing lab state, not a retest failure. The retest fails
   on exit behaviour only if Figure 6-2 is the stated reason for a gap.
8. **Word item (still open from v1.5.1):** if a Word-equipped client is available this
   round, perform Part 2 item 2 of the v1.5.1 record for all four figures including
   the new 6-2 (no repair prompt; legible, unclipped at normal zoom; record the Word
   version and a screenshot of Figure 6-2). If Word is still unavailable, record
   NOT RUN again — it remains a lab-side open item, not a product defect.

## Reporting

Return: this record with each expectation marked PASS / FAIL / NOT RUN and evidence
paths; the live and replay evidence folders (generated DOCX, `DOCX-Diagrams.json`,
`SiteLinks.csv`, console transcripts, XSD results); and any defect found, stated
against the v1.5.2 hashes above. A full PASS on items 1–7 completes the v1.5.x lab
confirmation (Parts 1 + 3 PASS from v1.5.1 stand); production clearance still requires
Gates A–F of `PRODUCTION-CLEARANCE-RUNBOOK.md`, and the Word item if it remains
NOT RUN.
