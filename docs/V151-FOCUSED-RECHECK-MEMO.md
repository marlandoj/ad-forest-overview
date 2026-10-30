# Focused independent re-check — Populate-ADForestOverview v1.5.1

Task: t_299dafc0. Persona: powershell-expert. Target: VPS.

## Verdict: APPROVE

APPROVE v1.5.1 with the supplied, unchanged template v1.1.1 for progression to supervised lab confirmation only. R1, R2 and R3 satisfy the bounded residual dispositions in t_b500b190. No unaccounted functional change was found. This does not reopen the approved v1.5 features, certify Word rendering, or grant production clearance.

Candidate MD5: af74c882be90cb53e071dabb45bc2026.
Candidate SHA256: 51b322674fd79e0ab451bf6390b409dc6d5ff248067600060b8fb4ebafc10d97.

## Input integrity and independence

All eight specified MD5s matched before testing and again during final aggregation. No staged script, template or memo was modified.

| Input under /opt/zouroboros/review-inputs | Verified MD5 |
|---|---|
| Populate-ADForestOverview-v1.5.1.ps1 | af74c882be90cb53e071dabb45bc2026 |
| Populate-ADForestOverview-v1.5.ps1 | 9cceacd3ac65e0ddec43623492fcb70e |
| Populate-ADForestOverview-v1.4.1.ps1 | cac3b3102e2f9289aa1add2ffac57683 |
| ad-forest-overview-template-v1.1.1.docx | a3e0fdb3fe23de25a701dcda265b0383 |
| ad-forest-overview-template.docx | 0f05c69495ed4a646db5c27527c338ce |
| v15-RECHECK-MEMO.md | 70c78b58c38de01d18e8b96201748e27 |
| v151-BUILD-REPORT.md | 7780f6d61ddd47f45bbddc6ef4f9d198 |
| v151.diff | 4693daaec5304194be290b54d440b2aa |

Fresh reviewer-authored harnesses were executed, not the builder's runners or saved assertions. Installed infrastructure reused: PowerShell 7.4.6 Core/Linux, PSScriptAnalyzer 1.25.0, and existing Python/lxml. R2 fixtures were newly hand-authored. R3 inspected a prior independent-review DTO only for shape, then constructed a distinct fixture. The parent freeze fixtures extend this review's fresh R2 DTO, not a builder fixture. Commands, source/fixture hashes and actual subprocess exits are retained.

Separate final ledgers, not additive independent populations:

| Workstream | Recorded checks passed | Failed |
|---|---:|---:|
| Static/analyzer/diff | 616 | 0 |
| R2 direct functions and replay | 171 | 0 |
| R3 fault and renderer matrix | 224 | 0 |
| Parent behavioral freeze | 122 | 0 |

The additional version-neutral literal-output control passed separately. Parent final_verify.py independently reread ledgers, all eight inputs, fault snapshots/actual targets, EMF payloads/decoded text, complete document text and the literal-control package. Its result is FINAL-VERIFICATION.json, status PASS. Builder counts are not evidence for this verdict.

## R1 — PASS: analyzer parity and exact remediation

Identical default invocation: Invoke-ScriptAnalyzer -Path <source>, PSScriptAnalyzer 1.25.0, without a custom ruleset.

| Version | Error | Warning | Information |
|---|---:|---:|---:|
| v1.4.1 | 0 | 58 | 127 |
| v1.5 | 0 | 68 | 139 |
| v1.5.1 | 0 | 58 | 127 |

No severity band increases versus the specified baseline. This is not zero-warning code and not diagnostic identity with v1.4.1.

Diagnostic multisets preserve rule, severity, exact extent text, normalized diagnostic message and multiplicity. Only versioned filenames inside diagnostics are normalized; source bytes are not. v1.4.1 -> v1.5 has 42 additions / 20 removals. v1.5 -> v1.5.1 has exactly 22 removals / zero additions. v1.4.1 -> v1.5.1 retains 20 additions / 20 removals. The retained 185 candidate diagnostic extents also map back to unchanged v1.5 content at their relocated source offsets.

Every removed instance is joined to its actual old diagnostic in static/22-removal-accounting.json:

- 12 positional Information findings: Register-CollectionResult's Register-Coverage; Write-OptionalFeature's Find-Table and Set-CellText; four three-argument New-DiagramNode sites; three Add-DiagramBox sites; New-DiagramDrawing integration; final Write-ForestDiagram integration. Argument expressions/order match the original bindings; named parameters match actual declarations.
- Four plural-noun Warnings: Get-ForestDiagramModels -> Get-ForestDiagramModel; Get-DiagramLines -> Get-DiagramLine; Get-DiagramPages -> Get-DiagramPage; Write-ForestDiagrams -> Write-ForestDiagram. Old names are absent everywhere in candidate source. Each new function is defined once, with respective consistent call counts 1, 7, 1, 1.
- Five ShouldProcess Warnings: New-DiagramNode, New-DiagramPage, New-DiagramEmf, New-DiagramParagraph and New-DiagramDrawing receive individual, justified function-local annotations for that rule only. Original parameters move unchanged into attributed param blocks. No global disabling, SupportsShouldProcess, ShouldProcess/ShouldContinue call, Confirm or WhatIf parameter is introduced. Constructors remain pure in-memory DTO/byte/XML construction; isolated baseline/candidate child processes produce identical outputs, including full EMF bytes. No confirmation prompt was introduced into a fill path.
- One Write-Host Warning: the named-gap final message becomes Write-Information with explicit -InformationAction Continue. Executing the actual candidate AST loop yields exactly the named figure/reason on information stream 6, and zero success-stream objects. Full gap runs also retain operator-visible reasons.

PSUseCompatibleCommands, PSUseCompatibleSyntax and PSUseCompatibleTypes were explicitly included AND enabled against Windows Desktop 5.1 and syntax 5.1. All three versions have zero findings. Independent negative control triggers exactly three findings, one for each rule, using Get-Error, ?? and SemanticVersion. This establishes active static checking, not Windows runtime execution.

Evidence: static/REPORT.md; default-*.json; analyzer-delta-*.json; retained-diagnostic-extent-mapping.json; positional-mappings.json; compatibility-settings.json; compat-negative.json; constructors-*.json; stream6.json.

## R2 — PASS: reserved xml:space and normalization freeze

The sole Set-CellText change is the prescribed explicit xml-prefix attribute construction, preserve value and append operation on the existing-text-node branch. The already-correct new-node branch is unchanged.

Direct function campaign: 16 cases per version, covering original multi-run/bold nodes, an existing reserved xml:space node, an empty paragraph and a fully empty cell. Leading, trailing, both-edge and plain values were exercised. Candidate: 16/16 strict parses, exact values retained, all 12 boundary-whitespace cases use reserved xml:space="preserve", formatting retained. Baseline reproduces nine strict failures; seven cases parse, including the already-reserved-attribute controls. No XML recovery or repair is used in acceptance checks.

Actual omitted-port replay: a fresh two-DC fixture omits both LdapPort and SslPort. Both versions publish and exit 0 on both supplied templates. Both baseline document.xml parts strictly fail namespace parsing. Both candidate outputs strictly parse, retain the actual trailing-space service text `Configured ports (from AD, not probed): LDAP  / LDAPS ` and carry reserved xml:space. Every XML/relationship part is strictly parsed, not only document.xml.

Normal-port controls: all four baseline/candidate/template outputs parse and exit 0. Each template's complete 2,000-node w:t inventory, including empties, is equal apart from five explicit version-bearing nodes; field instructions are identical. The only permitted substitutions are the exact tool-version prefix and `Diagram version: 1.5.1 -` caption prefix. No paths, timestamps, classifications or arbitrary text are masked.

To resolve the unavoidable version-bump distinction literally, an additional labelled TEST-ONLY candidate control changes only `$script:ScriptVersion = '1.5.1'` back to '1.5' (original spacing retained). Against the same rich well-formed fixture and logical output path, its entire document text and all 23 uncompressed package parts are byte-identical to the real v1.5 output. Candidate product bytes remain unchanged. Exact edit, variant digest and command: freeze/literal-control/result.json. This is a version-neutral output control, not the shipping artifact.

DEF-05: isolated actual-source helpers reproduce 48 -> 0 on the defective original and 0 -> 0 on supported v1.1.1 for both versions. Normalized bytes match baseline/candidate and are idempotent; supported normalization is a byte-level no-op. Every full R2 replay independently reports 48 original / 0 supported. The original template's zoom/schema limitation is not fixed, waived or promoted to supported status.

Evidence: r2/REPORT.md; assertions.json; invocations.json; probes/; runs/; final-readback.json; freeze/literal-control/.

## R3 — PASS: publication failure, not rollback

Source establishes the selected option: renderer/model/page/EMF/drawing construction remains locally caught, while the existing media/relationships/content-type commit now occurs outside that catch under `if (-not $reason)`. A package-write exception escapes to unchanged Write-ForestDocument temporary-copy cleanup and the main publication-failure catch. There is no rollback implementation.

Fresh fault variants replace ONLY the AST-selected Write-DiagramZipPart function; all bytes outside its extent are proven unchanged. A one-shot fault opens and truncates the selected relationship/content-type entry, captures live entries, then throws before replacement bytes are written. Each snapshot proves actual nonempty EMF media already exists and the selected XML part is zero bytes. These are reconstructed live-entry ZIP snapshots, not copies of the original raw open archive.

| Fault after media creation | Initial target | Candidate | v1.5 differential |
|---|---|---|---|
| document.xml.rels after truncate | absent | exit 1; no output published | exit 2; publishes |
| document.xml.rels after truncate | overwrite sentinel | exit 1; sentinel preserved | exit 2; replaces sentinel |
| [Content_Types].xml after truncate | absent | exit 1; no output published | exit 2; publishes |
| [Content_Types].xml after truncate | overwrite sentinel | exit 1; sentinel preserved | exit 2; replaces sentinel |

All four candidate cases: actual target readback confirms no new publication; temporary DOCX is removed; no success/publication claim appears; explicit `No document was published by this run` is present. Thus no new published document contains the partial media/type state. This is an honest exit-1 publication failure, not a rolled-back figure reported at exit 2.

Baseline later successful figures rewrite shared relationships/types. Its final published XML is well-formed but retains failed Figure 5-1 media unused by document drawings, plus an unused relationship. The precise demonstrated residue is drawing-unreferenced media, not a claim that its final package has zero-length XML, lacks a relationship, or remains untyped. Eight fault snapshots are retained and rehashed.

D7 survival: both unmodified scripts publish with exit 2 for an oversized OU label (only 8-1 suppressed), missing Trusts (5-1), missing Sites (6-1/6-2), missing SiteLinks (6-2), and missing TopLevelOUs (8-1). Exact sidecar/document/console gaps and surviving figure inventories pass. Two normal controls publish all figures at exit 0. Final R3 population: 20 subprocesses, 224 checks.

Evidence: r3/REPORT.md; final/ast-variant-proofs.json; final/runs/*/{invocation,result,fault-event,snapshot-inventory}.json; live-entry-snapshot.zip; stdout.txt; published-inventory.json; verification.json. Only r3/final/ is the accepted campaign.

## Exhaustive diff accounting — PASS

82 functions map bijectively after the four authorized renames: 68 byte-identical, 14 changed, no semantic additions/removals. Original-byte AST extents preserve BOM/CRLF. Ordered literal edit mappings reconstruct every candidate byte exactly; unaccounted.diff is empty. The allowlist is not merely inferred from function names.

Every changed function, with overlapping edits consolidated:

1. Register-CollectionResult: explicit Register-Coverage arguments only.
2. Write-OptionalFeature: explicit Find-Table and Set-CellText arguments only.
3. Set-CellText: bounded R2 attribute replacement only.
4. New-DiagramNode: local justified annotation and unchanged parameters moved into param block.
5. Get-ForestDiagramModels -> Get-ForestDiagramModel: rename and four explicit New-DiagramNode argument lists only.
6. Get-DiagramLines -> Get-DiagramLine: definition rename only.
7. New-DiagramPage: local annotation/param relocation and one renamed Get-DiagramLine call.
8. Add-DiagramBox: one renamed Get-DiagramLine call only.
9. Get-DiagramPages -> Get-DiagramPage: definition rename, five renamed line-helper calls and three named box-helper calls only.
10. New-DiagramEmf: local annotation/param relocation only; binary writer body unchanged.
11. New-DiagramParagraph: local annotation/param relocation only; XML body unchanged.
12. New-DiagramDrawing: local annotation/param relocation only; XML body unchanged.
13. Write-ForestDiagrams -> Write-ForestDiagram: definition/helper renames, named drawing arguments, and only the R3 catch/commit boundary/comment changes; original commit operations unchanged.
14. Write-DocumentXml: only named singular diagram integration call; normalization prologue and serialization tail unchanged.

Outside functions: version/help metadata, diagram-helper version comment, and the single R1 final named-gap information statement only. Top-level parameters, collector Get-ADForestData, export code, preflight/refusal guards, Write-ForestDocument publication/cleanup, final exit-decision region and Repair-DuplicateCellShading are byte-identical. No additional collection/module/permission scope exists: all 27 external AD/GPO/DNS command extents remain identical, Get-only, with ErrorAction Stop and unchanged splatted bindings. No empty catches.

Evidence: static/function-manifest.json; function-diffs/; authorized-literal-edits.json; full.diff; outside-functions.diff; unaccounted.diff; boundary-freezes.json; external-queries.json. static/REPORT.md gives the detailed edit-level account.

## Behavioral freeze and remaining static bars — PASS within stated boundary

Parent campaign: six paired actual-script cases, 12 subprocesses, 122 checks: rich two-domain topology, deterministic repeat, single domain, missing Trusts, missing Sites and renderer-long. The rich DTO contains eight optional features (exceeding register capacity) with true/false/null states and empty/multiple scopes, plus typed nonempty FGPP rows in both domains with same/different/unknown and zero-interval values. First-cell labels prove T16 and T21 are the actual registers, and nonempty feature/comparison contents are asserted to avoid vacuous equality.

All six pairs have identical complete EMF byte/hash inventories and actual decoded UTF-16 text/geometry/record inventories: 20 EMF parts per version. Decoding validates header/signature/length/counts, framed aligned records and EOF. Actual drawing embeds resolve to existing typed media without unused diagram media. Deterministic repeats match. T16/T21 rows are raw-exact per pair, as are all field instructions. Complete document text matches except the two exact version-prefix forms already disclosed; no fresh live timestamp normalization is used. The separate version-neutral control establishes literal complete-part identity on a well-formed rich fixture.

Exits match every paired case: six subprocesses exit 0 and six exit 2. R3's additional source-gap cases pass separately. This is a focused freeze spot-check, not a rerun or expansion of the approved v1.5 feature campaign.

Full parser: zero errors. Candidate: UTF-8 BOM efbbbf, ASCII-only payload, 171705 bytes, 2863 CRLFs, no bare LF; ScriptVersion exactly '1.5.1'. PS5.1 compatibility rules pass with active controls as above; Get-only collection is unchanged.

Evidence: freeze/check.py; summary.json; invocations.json; runs/*/{inventory.json,output.docx,console.log}; text-differences/; literal-control/; FINAL-VERIFICATION.json.

## New findings and harness qualifications

N1 — Informational metadata-only wording: candidate help line 99 says `scoped analyzer remediation only`, but the candidate also contains R2 XML-space and R3 publication-failure hardening. This understates release scope. It has no runtime effect and is not a blocking residual; update the change note when metadata is next edited. No new functional finding was demonstrated in this focused review.

Exploratory failures are not silently relabelled. r2/initial/ preserves incomplete-fixture/too-narrow-version-normalizer failures, then the entire corrected campaign was rerun. R3 top-level exploratory evidence preserves an empty-feature fixture warning and an incorrect relationship-orphan expectation; all 20 cases were freshly rerun under final/. Static exploratory reports preserve profile/BOM-offset/location-mapping harness corrections. freeze/initial/ preserves a parent decoder assertion that wrongly demanded a Default content type; final decoding correctly resolves the product's per-part Override entries, then all 12 cases were freshly rerun. Parent aggregation's initial assertion-key mismatch (pass versus pass_) was corrected; the final readback completed successfully. None required a product edit.

## NOT VERIFIED / clearance boundary

- Real Windows PowerShell 5.1 Desktop/.NET Framework execution, RSAT/provider behavior, Windows filesystem semantics or aliases.
- A real forest, real ACL visibility, trust/DC/site/OU completeness, operational load or network behavior.
- Word opening without repair; EMF pixels/glyphs/fonts, normal-zoom readability, clipping, pagination, TOC refresh, printing or human interpretation.
- Gates A-F, human author/approver sign-off, operational acceptance or production clearance.
- Arbitrary persistent I/O faults, every commit boundary, crash/power-loss atomicity or rollback. R3 covers the specified one-shot relationship/content-type failures only.
- Full OOXML XSD/MC-projection gate in this focused campaign. Strict XML/package integrity is verified, not full schema conformance. The defective original's known settings zoom limitation remains outside the authorized fix and is not waived.
- All historical suites, live-collection behavioral replay of every adopted fact, extreme scale, or every malformed/whitespace input class. Collection freeze is source-byte proof plus the specified focused runtime spot-checks.
- Literal raw whole-document text equality across the shipping version bump, or whole ZIP-byte identity. Exact version differences are disclosed; the labelled version-neutral control is not the shipping file.

No production clearance is granted.
