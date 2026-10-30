# Lab Confirmation Record — Populate-ADForestOverview v1.5.1 + Template v1.1.1

**Candidate under test**

- Script: `Populate-ADForestOverview-v1.5.1.ps1` — MD5 `af74c882be90cb53e071dabb45bc2026`,
  SHA-256 `51b322674fd79e0ab451bf6390b409dc6d5ff248067600060b8fb4ebafc10d97`
- Supported template: `ad-forest-overview-template-v1.1.1.docx` — MD5 `a3e0fdb3fe23de25a701dcda265b0383`
- Regression fixture (Part 1, Run A only): the original defective template — MD5 `0f05c69495ed4a646db5c27527c338ce`

**Workshop status going in:** v1.5 (diagrams + the 8 coverage-gap ADOPT completions) was
approved by independent re-check with residuals R1–R3; v1.5.1 closed all three and the
focused re-check returned **APPROVE** for supervised lab confirmation. This record is the
lab gate for v1.5.1. It supersedes `VERIFICATION-DEF05-CONFIRMATION.md` (which targeted
v1.4.1) for the current candidate — Part 1 repeats its two runs with the new script.
Production clearance still requires this record **plus** Gates A–F of
`PRODUCTION-CLEARANCE-RUNBOOK.md`.

Record for every run: script and template hashes before and after (both must be
unchanged), host, account, exit code, console summary, and the evidence folder path.

## Part 1 — DEF-05 regression (must still hold with diagrams present)

### Run A — defective-template regression

Run v1.5.1 against the ORIGINAL defective template (MD5 `0f05c694...`).

Expected:
- Console output and `DOCX-Normalization.json` disclose **48** normalized cells.
- The generated document contains **zero** duplicate-`w:shd` cells.
- `word/document.xml` passes XSD validation; the package may retain exactly the one
  inherited `<w:zoom>` settings error from the superseded original template — no other
  errors, and diagram parts must not add any.
- Exit code follows the data set (normalization does not change it).

### Run B — supported configuration

Run v1.5.1 with template v1.1.1.

Expected: **0** normalizations disclosed; zero duplicate-shading cells; full-package XSD
validation with **zero errors** (name the method/validator used); diagrams present per
Part 2.

## Part 2 — Diagram confirmation (first rendering on real Windows + Word)

Use the Run B output (live run against the lab forest), then a `-DataFile` replay of the
same export.

1. **Presence:** Figures **5-1, 6-1, 6-2 and 8-1** each contain a generated diagram at
   their template locations (embedded vector image parts), not the manual drawing
   instructions. `DOCX-Diagrams.json` is present in the evidence folder and reports each
   figure's status.
2. **Word rendering (the workshop could not test this):** open the document in Microsoft
   Word. No repair prompt; each diagram renders legibly at normal zoom — node labels,
   trust arrows and site-link labels readable, nothing clipped off-page. Record the Word
   version used. Any rendering defect is a FAIL for this part, reported with a screenshot.
3. **Figure 5-1 vs the data:** the domains shown equal the forest's domains (FQDN +
   NetBIOS); every trust in `Trusts.csv` appears exactly once with the same type and
   direction as the Section 5 trusts table — nothing extra, nothing missing.
4. **Figure 6-1:** the word **SCHEMATIC** appears in the figure/caption; each site shows
   its name and DC count matching the site tables; no country or role label appears for a
   site whose Location attribute is empty.
5. **Figure 6-2:** every site link appears with its **cost** and **interval** matching
   `SiteLinks.csv`; sites with no DCs are marked as such.
6. **Figure 8-1:** the top-level OUs shown equal the Section 8 top-level OU table for the
   covered domain(s) named in the caption.
7. **Captions:** Figure 5-1's caption carries the real forest FQDN, the run date, and
   diagram version 1.5.1; the other captions carry the run date. Author fields remain
   human (blank/placeholder is correct).
8. **Replay identity:** the `-DataFile` replay of the same export produces the same four
   figures with the same node/edge inventories as the live run.
9. **Closing reminder:** the console reminder no longer lists diagrams as manual work.

## Part 3 — Adopted-field confirmation

1. **Optional Features register (Section 3 features table):** one row per feature returned
   by `Get-ADOptionalFeature` in the lab forest — name, enabled status, and the
   enabled-scope DNs where scopes exist. Spot-check against the exported evidence
   (`AD-OptionalFeatures` data): no feature missing, no scope invented. The "Date enabled"
   column must NOT be populated by the script.
2. **Fine-grained password policies (Section 4 comparison table):** if the lab forest has
   any FGPP, its row(s) show complexity, reversible encryption, minimum password age,
   lockout observation window and lockout duration against the default policy. A lockout
   duration of zero must read as the administrator-unlock mode, never "0 minutes". If the
   lab forest has **no** FGPP, record that, and confirm the section status/evidence
   distinguishes the successful-empty result from a collection failure.
3. **Diagnostics:** the evidence distinguishes at least one successful-empty collection
   result from a failed one (outcomes are recorded per collection in the exported data /
   `SectionStatus.csv`).

## Reporting

Return: this record with each part marked PASS / FAIL / NOT RUN with evidence paths; the
Run A and Run B evidence folders (or their hashes and key files: generated DOCX,
`DOCX-Normalization.json`, `DOCX-Diagrams.json`, console logs, XSD results); the Word
version and rendering result for Part 2 item 2; and any defect found, stated against the
v1.5.1 hashes above. Local repair of generated documents is not acceptable evidence.
