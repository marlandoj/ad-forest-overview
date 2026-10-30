# Lab Confirmation — DEF-05 (OOXML duplicate shading) — v1.4.1 + template v1.1.1

**Purpose:** close DEF-05 in the lab. The workshop chain is complete: fix build t_08785a03,
zoom repair t_4dbe6885, re-check t_c7ad641b (APPROVE WITH RESIDUAL FIXES), residual fix
t_053c0c19, focused re-check t_9138a4ce — **APPROVE Populate-ADForestOverview v1.4.1 with
template v1.1.1 for the lab confirmation runs.** This record is the lab's confirmation leg;
it sits alongside the production-clearance runbook's Gates A–F, which are unchanged and
still required. Nothing in this record clears production on its own.

## Inputs (verify hashes before running; STOP and report on any mismatch)

| Artifact | MD5 |
|---|---|
| Populate-ADForestOverview-v1.4.1.ps1 | `cac3b3102e2f9289aa1add2ffac57683` |
| ad-forest-overview-template-v1.1.1.docx (supported template) | `a3e0fdb3fe23de25a701dcda265b0383` |
| ad-forest-overview-template.docx (ORIGINAL defective template, Run A only) | `0f05c69495ed4a646db5c27527c338ce` |

Environment: Windows PowerShell 5.1 on the pinned lab host, as in rounds 1–2. Run both runs
against the same replay data set used in round 2 (or a live collection, if the lab prefers —
the assertions below are about the document, not the data).

## Run A — regression against the defective input (original template)

Run v1.4.1 with the ORIGINAL template and produce a document. Expected:

1. The run completes and writes the document. The console summary line
   "Normalized duplicate-shading cells: **48**" is printed, and the run's
   `DOCX-Normalization.json` records NormalizedShadingCells = 48 with the original template
   as the resolved TemplatePath.
2. The generated document contains **zero** table cells with more than one `w:shd` element
   in `w:tcPr` (the lab's own counter from the round-2 addendum is the reference method).
3. Full OOXML XSD validation of the generated document: `word/document.xml` passes with zero
   errors. The package may retain exactly one further error — the `<w:zoom>` percent error in
   `word/settings.xml` — inherited from the superseded original template, which v1.4.1 does
   not modify. Any other error is a FAIL for this run.
4. The exit code follows the data set, as in round 2 (0 for a clean replay; 2 when the data
   set carries collection issues). Normalization itself does not change the exit code.

## Run B — the supported configuration (template v1.1.1)

Run v1.4.1 with template v1.1.1 and produce a document from the same data. Expected:

1. The console prints "Normalized duplicate-shading cells: **0**" and
   `DOCX-Normalization.json` records 0.
2. The generated document contains zero duplicate-shading cells.
3. Full OOXML XSD validation: **all parts pass, zero errors** (the lab's 15-part method, or
   the 18-part ECMA method used in the workshop — either is acceptable; name the method and
   validator in the results).
4. Document content matches Run A's document apart from template-driven differences (the
   services matrix renders white in both; text identical).

## Verdict

- **DEF-05 CLOSED (lab)** when every expectation in both runs is met. Record per-run: script
  and template hashes used, the console count line, the DOCX-Normalization.json content, the
  duplicate-cell count, the XSD result per part, and the exit code.
- **FAIL** if any expectation misses — return the run outputs and the generated documents as
  evidence; do not repair generated documents locally for this gate (the round-2 repaired
  copy was containment for that delivery only).
- After closure, production clearance still requires Gates A–F of the clearance runbook.
