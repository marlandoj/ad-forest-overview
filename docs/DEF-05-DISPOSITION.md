# DEF-05 disposition — duplicate w:shd in generated DOCX (Alaric, 2026-10-28)

Source: lab AI-Engineer handoff dated 2026-10-28 (ai-engineer-handoff.md), evidence bundle
verification-evidence-v1.3-2.zip, SHA-256 1134821d6806555331b2cbfd9499f1a879d85514d29121e17f467c37f928461f
(verified locally before triage). All findings below were reproduced first-hand on the primary
artifacts, not taken from the handoff.

## Verdict on the finding: CONFIRMED, with a corrected origin

- The round-2 item 2 generated document contains exactly **48 table cells with two `w:shd`
  elements inside `w:tcPr`** — the handoff's count reproduces precisely (my own parse:
  1,760 cells, 48 duplicates, fills FFF8E1 + FFFFFF). The item 5 and item 7 outputs carry the
  same 48. The lab's repaired delivery copy contains 0.
- **The defect is in the TEMPLATE, not emitted by the script.** The supplied template
  (ad-forest-overview-template.docx, MD5 0f05c69495ed4a646db5c27527c338ce) already contains the
  same 48 duplicate cells in the identical property sequence
  `tcW, shd(FFF8E1), vAlign, shd(FFFFFF)`. The v1.3 script contains no code that writes `w:shd`
  into a cell property container (its only `shd` reference is a paragraph-property ordering
  XPath); it edits the template XML in place, so every output inherits the duplicates verbatim.
  The v1.2 round-1 output carries the same 48 — the defect predates v1.3 and has been present
  in every generated document since the template was built (chat-side template build,
  2026-10-26, where two shading passes overlapped on one table).
- All 48 cells sit in a single table: the **DC services / ports reference matrix** (Service |
  Port / protocol | Used by | Notes).

## Tracking

- **ID: DEF-05. Severity: P1 — deliverable integrity.** The generated package is OOXML
  schema-invalid (CT_TcPr permits one `w:shd`, in sequence). No data is lost and lenient
  readers open the files, but strict consumers can reject them, and this defect class is a
  plausible trigger for the Word repair prompt that item 7's still-outstanding Word check
  exists to catch. Not P0: no safety, honesty or data-correctness impact.
- The lab's local repair (keep the last `w:shd`, drop earlier duplicates, restore schema
  order; repaired copy passes 15-part XSD validation) is accepted as **one-off containment
  for that delivery copy only** — it is not a product fix and not evidence about newly
  generated output. Agreed with the handoff on this point.

## Intended shading ruling (handoff question 5)

The services matrix is pre-filled reference content, not a human-fillable area. In the
template's visual language FFF8E1 (pale yellow) marks cells a human must complete; these cells
are complete as shipped. **Intended value: FFFFFF (white)** — the value the lab's repair
retained. All other pale-yellow cells in the template carry a single `w:shd` and are valid;
they are untouched by this ruling.

## Required fix (for the fix build)

1. **Corrected template** (template v1.1): the services matrix body cells carry a single
   `w:shd` (FFFFFF) in schema order; no other content changes. New template MD5 to be recorded
   and hash-pinned for the lab. The corrected template must pass full OOXML XSD validation
   (all parts).
2. **Script hardening (v1.4):** when loading a template, normalize every `w:tcPr` — if more
   than one `w:shd` is present, keep the last and restore schema order — and disclose the
   number of normalized cells in the run output (never silent). Output produced from the OLD
   template must then also be schema-valid; output from the corrected template must show zero
   normalizations.
3. **Regression:** full OOXML XSD validation (the lab's 15-part method) added to the workshop
   test suites for the template and for generated outputs, including warning/highlight rows.
   ZIP integrity and XML well-formedness alone are no longer sufficient evidence for any
   future document claim.
4. **Lab confirmation (adds to Gates A–F):** regenerate with v1.4 from (a) the old template —
   expect XSD pass, 0 duplicate cells, normalization count disclosed as 48; (b) the corrected
   template — expect XSD pass and a zero normalization count.

## Clearance impact

Production clearance now requires DEF-05 closed (corrected template + v1.4 + re-validation)
in addition to the production-clearance runbook's Gates A–F, which are unchanged. The round-2
verdict otherwise stands: DEF-01 to DEF-04 closed; overall INCOMPLETE for lab-environment
reasons (fixture, cross-DC ADWS/GPO connectivity, Word).
