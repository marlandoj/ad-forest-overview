# Independent re-check — Populate-ADForestOverview v1.5

Task: t_b500b190. Candidate: MD5 9cceacd3ac65e0ddec43623492fcb70e; SHA256 45549eff7b8c72d0e836d6e98b12b873a7284bcb1d7289888f630e1ae51f83c3.

## Verdict: APPROVE WITH RESIDUAL FIXES

For progression to supervised lab confirmation with the unchanged v1.1.1 template, not production. The frozen candidate's diagram and eight-ADOPT behavior passed the independent cases below. An unconditional acceptance of every requested bar is NOT justified: default PSScriptAnalyzer findings increased, and the defective original cannot pass full XSD while its pre-existing zoom defect remains. The supported-template generated outputs do pass the explicitly qualified MC-aware schema gate.

Required residual R1 is the analyzer acceptance discrepancy. R2 is an independently reproduced, inherited malformed-replay robustness defect, not a new v1.5 regression. The package-write limitation R3 is a static risk, not a reproduced renderer failure. None is silently waived. No product or supplied-template file was modified by this review.

## Independence, freeze and evidence

Fresh reviewer-written AST/analyzer, mock collection, replay, binary decoder and XSD harnesses were executed. No builder test runner, fixture, validator implementation or saved assertion result was used as verification. Infrastructure reuse was limited to PowerShell 7.4.6 Core/Linux, PSScriptAnalyzer 1.25.0, an installed Python/lxml environment, and cached official schema source assets. The topology fixtures extend THIS review's fresh live-mock export, not a builder fixture. The build report was read as claims and sampled, not treated as evidence.

All nine MD5s matched initially and again at final aggregation:

| Input in /opt/zouroboros/review-inputs | Verified MD5 |
|---|---|
| Populate-ADForestOverview-v1.5.ps1 | 9cceacd3ac65e0ddec43623492fcb70e |
| Populate-ADForestOverview-v1.4.1.ps1 | cac3b3102e2f9289aa1add2ffac57683 |
| ad-forest-overview-template-v1.1.1.docx | a3e0fdb3fe23de25a701dcda265b0383 |
| ad-forest-overview-template.docx | 0f05c69495ed4a646db5c27527c338ce |
| v15-BUILD-REPORT.md | 68690473737b8e2db0d9892275b9e3eb |
| v15-adoption.diff | 0a413b46b82e882c2bb5c20b1f2f659e |
| v15-sample-all-figures.docx | 1cc781d8c2c517b6d9e79262386e2385 |
| v15-sample-live-clean.docx | 68ca8d52ee44783224c5d24e8ecbff30 |
| ADOPTION-SPEC.md | 1e10bf79565f5e24c6d990f51e73ddc3 |

The supported template remains v1.1.1, byte-unchanged. A human-date derivative exists only as an explicitly labelled test fixture; it is not a replacement supported template.

Final accepted runtime campaign: 26 frozen-candidate subprocesses, all publishing documents: 12 topology/failure replays plus 7 live-mock / 7 replay adoption runs. Exits: 6 zero, 20 two. Separate differential refusal probes exercised exit 1. Every final runtime invocation has start/end source hashes and command records. Exploratory runs are preserved but excluded from these final counts.

Evidence root is this workspace. FINAL-VERIFICATION.json is a parent-side programmatic read-back of assertion records, invocation freezes, all nine input hashes, schema populations and package inventories. Counts below are separate overlapping populations, not one inflated grand total.

## Standards axis: static bars and diff discipline

Fresh static ledger: 43 PASS, 1 FAIL. The sole acceptance failure is the default-analyzer increase.

- Full PowerShell parser: 0 errors in either version. Candidate: UTF-8 BOM, ASCII-only payload, 169927 bytes, 2848 CRLF lines, no bare LF.
- Explicit enabled PSUseCompatibleCommands, PSUseCompatibleSyntax and PSUseCompatibleTypes against Desktop 5.1: 0 findings in either version. Independent negative control triggers all three rules (3 diagnostics). This is static compatibility, not Windows execution.
- Default analyzer: baseline 0 Error / 58 Warning / 127 Information; candidate 0 / 68 / 139. Diagnostic multiset: 42 added, 20 removed; net +22. Thus 'no worse than baseline' FAILS if read literally. The build report did disclose these totals; its narrower zero-Error result is reproducible, but does not satisfy the broader requested bar.
- External AD/GP/DNS calls: 27 each, identical command extents, all Get-only, all ErrorAction Stop, no new query/module/permission scope or explicit binding beside splats. No empty catches.
- Four refusal cases against each version: 8/8 pass, exit 1 with sentinel files unchanged: same output/template path, identical content, existing output without overwrite, ExportOnly plus DataFile.
- Preflight region and final 0/2 decision region are byte-identical. Writer publication, late guard, cleanup, trust classifier and path helpers are byte-identical. Runtime clean/gap cases demonstrate the unchanged exit decision receiving new diagram gaps correctly.

Function accounting: 57 baseline -> 82 candidate; 52 byte-identical, 5 changed, 25 new, 0 removed. Original-byte AST slices, all 30 individual diffs and exhaustive outside-function diff are in static/. No Git repository was present; the fixed supplied baseline was compared directly.

Changed functions, fully accounted for:

1. Complete-Coverage — A3 outcome details.
2. Get-ADForestData — A1 scopes/nullable state, A2 five PSO/default values and stable GUID key, A3 diagnostics/independent site-subnet failure handling.
3. Export-ADData — diagnostics and optional-feature evidence files.
4. Write-DomainBlock — five PSO comparisons and deterministic ordering.
5. Write-DocumentXml — generic feature rows, touched diagnostic states and diagram integration.

New functions, fully accounted for:

- Adoption/diagnostics: Register-CollectionResult, Get-CollectionState, Get-EvidenceValue, ConvertTo-PolicyBoolean, ConvertTo-PolicyInterval, ConvertTo-PasswordSetting, Format-PasswordSetting, Get-FgppComparison, Write-OptionalFeature.
- Diagram model/layout: Get-DiagramValue, Get-DiagramSorted, Assert-DiagramSource, New-DiagramNode, Get-ForestDiagramModels, Add-DiagramOp, Get-DiagramLines, New-DiagramPage, Add-DiagramBox, Get-DiagramPages.
- Binary/package integration: New-DiagramEmf, Read-DiagramZipXml, Write-DiagramZipPart, New-DiagramParagraph, New-DiagramDrawing, Write-ForestDiagrams.

Outside-function changes are metadata/version/help, diagnostic/diagram initialization, diagram sidecar reporting and closing disclosure. Parameters are unchanged. Collection changes support A1/A2/A3 only; no ADOPT-OPTIONAL acquisition was added. PSO ObjectGUID is tie-break metadata, not a ninth adopted fact. A duplicated pure projection is a low-priority heuristic advisory only, not a hard standard violation.

DEF-05 freeze: Repair-DuplicateCellShading is byte-identical. Write-DocumentXml as a whole is NOT byte-identical, nor could it be while integrating the requested fills. Its normalization prologue, serialization tail and main normalization reporting region are byte-identical. Four fresh isolated baseline/candidate/template probes reproduce 48 then 0 for the defective original and 0 then 0 for v1.1.1, with matching normalized XML hashes. Full-script diagram runs independently reproduce normalized-cell counts 48 on original and 0 on supported, with zero duplicate-shading cells remaining. Behavioral normalization freeze passes.

Detailed standards evidence: static/static-review.md, summary.json, function-diff.json, analyzer-delta.json, compat-negative-control.json, freeze-proofs.json, normalization-*.json and guard-results.json.

## Spec axis: diagram correctness and failures

Binary/package/semantic ledger: 749 PASS, 0 FAIL, covering 28 final packages and 106 EMF parts. EMFs: 9 in the two builder samples, 61 in our 12 topology outputs, 36 in our 14 final adoption outputs. Every part is independently walked, not trusted through DrawingML alt-text. Inline decoder guards additionally enforce record framing and coordinate bounds; these are not separately inflated into the assertion total.

The main fixture has three domains across two trees, seven trust classifications, three sites including one without a DC, two binary site links and six top-level OUs. Its Figure 5-1 has two panels and Figure 8-1 two panels. Actual UTF-16 EMF labels, rectangle-contained node rosters, main connector segments and arrowheads are extracted and compared to source DTOs/table cells.

- D2 / Figure 5-1: exactly seven connectors, with Source, Target, classification and decoded arrow direction equal to the trust table and fixture. Types: Parent-child, Tree-root, Shortcut, Forest, External, Realm (MIT Kerberos) (MIT), Unverified intra-forest, preserving the baseline's full suffixes. No trust lost/duplicated across panels. Three internal and three external endpoint roster nodes are retained. This tests rendered DTO fidelity; baseline classifier identity is separately proven, not reclassified by the diagram harness.
- Single-domain fixture: one domain, no trusts; no trust connectors, explicit successful-query/no-relationships text, all four figures generated, exit 0.
- D3 / Figure 6-1: SCHEMATIC appears in actual vector text AND caption. Exact site-label assertions require name/DC count, Location only when present, and NO DCs when count is zero. Blank and Dormant have empty Location and receive no invented country/role label.
- Figure 6-2: main fixture link inventory is exactly Blue (cost 71, interval 23) and Green (92, 37), with four link-to-member connectors. No-DC marker survives. Separate three-member Hyper fixture has exactly its three membership spokes, not a fabricated pairwise mesh. Mesh/star/hyperedge/single-site Design caption branches were executed.
- D9 / Figure 8-1: exactly three domain roots and six OU nodes/root-to-OU connectors; domain-qualified section-8 table rows equal the decoded inventory. Covered-domain caption retains the collected domains. The single-domain case also matches its section-8 data.
- D1 replay: two fills with identical fixture JSON yield identical complete decoded inventories AND identical bytes/hashes of every EMF part. DOCX ZIP-byte identity is not claimed.
- D6: generated drawings replace the four template instruction boxes; figure numbers, collection dates and version captions remain associated with their locations. The source also leaves author as human input, not a collected identity claim.
- D7/D8: missing Trusts -> 5-1 gap; missing Sites -> 6-1 and 6-2 gaps; missing SiteLinks -> 6-2 gap; missing TopLevelOUs -> 8-1 gap. Every run writes the document and exits 2. Exact-location not-generated paragraphs, named reasons/warnings and DOCX-Diagrams.json per-figure partial status are checked; surviving figures remain generated.
- Malformed link membership suppresses only 6-2. An additional oversized OU label reaches Get-DiagramPages' rendering limit and throws 'node label too long'; the unchanged candidate writes the document with only 8-1 suppressed and exit 2. No test-only product variant was needed.
- The closing reminder no longer calls diagrams manual work and names ungenerated figures. Figure status is fill-local evidence, rather than invented collection-origin evidence.

Reproduction: diagrams/run.py; diagrams/run-renderer-fault.py; diagrams/audit.py. Exact commands, fixture hashes, logs, outputs and sidecars are in diagrams/<case>/. inventory.json contains actual decoded primitives/panels; assertions.json contains the enumerated comparisons.

## EMF, relationships, content types and schema

All 106 final EMFs pass header type/signature/length checks, sane positive bounds, aligned size-bounded record walks with matching header record count, bounded text/rectangle/line coordinates and final EMR_EOF. Actual UTF-16 text and connector geometry drive the inventory checks. DrawingML embed IDs resolve through document relationships to existing parts with declared content types; drawing IDs are unique.

The fresh independent XSD validator checks every XML/relationship part against cached authoritative ECMA Transitional/OPC and real Dublin Core/W3C schemas. It independently verifies 34 schema files, including 30 byte-identical nested ECMA archive members. Cached official-source provenance is explicitly trusted; no fresh publisher retrieval/signature verification is claimed. Minimal and full-package duplicate-free wrong-order controls fail as expected; six MC-isolation controls pass.

Final generated packages: 26 x 18 = 468 parts validated.

- 25 supported-template/labelled human-date-derivative packages: 450/450 parts pass, zero projected/fatal errors.
- One defective-original-derived output with all diagrams: 17/18 parts pass; one unchanged settings.xml zoom/@w:percent error. Its settings.xml is byte-identical to the original. Forty-eight shading errors are removed; normalization evidence reports 48. This is an unconditional full-schema FAIL, not a waived pass.
- Both builder samples separately pass 18/18 parts each, zero projected errors.

MC qualification: raw diagnostics are preserved. Each final supported output has 10 raw diagnostics; the original-derived output has 11. Explicit scoped MC projection removes only unsupported ignorable material/directives; ordinary WML defects remain failures. No raw-XSD-zero claim is made. The original input itself has 49 projected errors: 48 shading plus one zoom error. The supported input passes. It would be false to report both templates' outputs as fully schema-clean.

Authoritative final evidence: schema/all-final-generated-results.json, schema/sample-results.json, schema/provenance.json, schema/projection-selftests.json. schema/schema-review.md is the schema workstream's earlier checkpoint; this memo and the final-generated report supersede its 'parent outputs pending' statement.

## A1/A2/A3: eight ADOPT items

Fresh collection/export/replay ledger: 583 PASS, 0 FAIL (404 main + 179 supplemental). Fourteen final actual invocations, two domains, seven live/replay pairs. These runs intentionally lack GP/DNS provider mocks, so all exit 2 with published documents; they are not falsely counted as clean-exit demonstrations. The topology campaign separately demonstrates exit 0.

A1 / OF01–OF03: eight generic optional features exceed the supported register's six slots. Names, nullable enabled states, single/multi/empty/null/missing EnabledScopes survive actual collection DTO -> JSON -> DataFile replay. Entire live/replay T16 rows are identical. Scope DNs remain lossless arrays in JSON and sorted document text. Successful-empty scopes remain [], not null. Missing evidence is unknown, not false. A human-date derivative has one existing date; it stays once, while both genuinely appended rows are Unknown (not collected), not copied dates. No enablement date is synthesized.

A2 / five fgpp.* settings: both domains' T21 comparisons render ComplexityEnabled, ReversibleEncryptionEnabled, MinPasswordAge, LockoutObservationWindow and LockoutDuration against retained defaults, preserving legacy Notes. Tested same/differs/unknown, malformed types, failed defaults and deterministic precedence/name ordering. Zero LockoutDuration explicitly means until an administrator unlocks, never '0 minutes'. Zero minimum age and zero observation window have separate honest explanations. Live/replay registers are identical.

A3 / ST04: all ten scoped diagnostic records per case have JSON/CSV parity. Successful-empty = outcome successful-empty/count 0 with visibility caveat; failed = outcome failed/count null with injected error/identity. Section status and document text distinguish empty execution from failure. Restricted optional-feature/FGPP emptiness still marks visibility uncertainty. Independent site/subnet sibling failures and mixed-domain partial results preserve surviving evidence. Replay performs no directory calls.

Evidence: adoption/adoption-review.md, verified-summary.json, assertions.json, supplemental-assertions.json, modules/ActiveDirectory/ActiveDirectory.psm1, runs/<case>/{live,replay}/.

## Judgement-call rulings

(a) Managed MS-EMF writer / D5 — ACCEPT as a bounded technology choice for desktop Word-targeted vector figures. It actually executes, is structurally valid in our decoder, packages through standard DrawingML/image relationships, and avoids Office/System.Drawing/native headless graphics dependencies. Schema validity is not proof Word draws its text/glyphs/pages correctly. Word-version support, font substitution, clipping and pagination remain lab-pending; do not advertise verified Word compatibility.

(b) Figure 8-1 coverage / D9 — ACCEPT. One numbered figure with separately grouped models for every collected domain includes the required connected-domain minimum and preserves the frozen template's single caption. Three roots/six OUs were actually reconciled. It is not a separately captioned figure clone per domain and not an all-depth OU inventory.

(c) Figure 6-2 Design / D4 — ACCEPT. Only simple >=3-site complete graphs or exact stars qualify; title and Hub/Spoke labels explicitly describe site-link graph semantics, not operational roles/connection objects. Hyperedges and small/unclassified graphs keep the human placeholder. Star, mesh and nonclassifying cases were executed.

(d) Further calls:

- ACCEPT source-relative AD trust arrows rather than inferred authentication flow; actual direction heads match every table row.
- ACCEPT multi-member links as link-to-member spokes, and fixed-font paginated edge panels rather than shrinking the entire inventory.
- ACCEPT GUID retention for deterministic FGPP sorting and separate site/subnet catches as supporting A2/A3 correctness, not optional-scope collection.
- FLAG the effective narrowing of 'analyzer no worse' to zero Error/compatibility findings: that is not the stated static bar (R1).
- FLAG nontransactional figure-part commit: building vectors first protects renderer exceptions, but media/relationships/types are then committed inside a local catch without rollback. Mid-write I/O failure could leave orphan/untyped parts. This is a source-proven limitation, not a failure reproduced in the accepted rendering cases (R3).

## Exact bounded residual dispositions

R1 — Required before claiming all static bars passed. Restrict remediation to newly introduced code: remove the net 12 extra positional-parameter findings through explicit argument names; remove the net four plural-noun findings in diagram helper names/calls; resolve the five pure-constructor ShouldProcess findings without introducing confirmation prompts into in-memory DTO/XML constructors; remove the net one extra Write-Host finding while preserving named-gap operator output. static/analyzer-delta.json identifies exact diagnostic extents. Local, justified constructor-only annotations or agreed policy exceptions must be explicit, never global rule disabling. Re-run the identical default baseline comparison, all three enabled compatibility rules and controls, and affected integration fixtures against a newly frozen hash. Current counts must not be described as 'no worse'. No such fix/waiver is applied here.

R2 — Inherited malformed-replay robustness, separate follow-up. Exploratory replay DTOs omitting DC LdapPort/SslPort produce a trailing-space service note. Both baseline and candidate exit 0 but serialize illegal xmlns:d8p1="http://www.w3.org/XML/1998/namespace" instead of reserved xml:space. Strict XML parsing fails in each version. Set-CellText is byte-identical; this is not a diagram regression. Bounded correction: construct the space attribute with explicit xml prefix (CreateAttribute('xml','space',XML namespace URI), set preserve, append it), without changing text/formatting or DEF-05 behavior; test leading/trailing-space values in original/new text nodes and repeat this exact baseline/candidate fixture. Evidence: diagrams/missing-port-probes/ and schema/missing-port-probe-rerun.json. Normal collector-shaped acceptance fixtures include actual port properties; the bad packages remain unmodified and are excluded from final pass populations, not repaired by the validator.

R3 — Package-commit hardening before expanding fault-tolerance claims. In Write-ForestDiagrams' 2362–2371 commit stage, either restore/remove newly added parts and relationship/type entries on commit failure, or distinguish package-commit failure from recoverable rendering failure and abort publication. Exercise a one-shot relationship/content-type write failure after media creation and validate the resulting publication/refusal behavior. No broad renderer redesign is requested. This is not needed to explain the tested malformed-data renderer survival, which passes.

No change to supported template v1.1.1, no normalization expansion to fix original zoom, no extra directory queries or ADOPT-OPTIONAL implementation is authorized by these findings. The original-template zoom failure is a retained fixture limitation, not permission to ship a new template.

## NOT VERIFIED / clearance boundary

- Actual Windows PowerShell 5.1 Desktop/.NET Framework execution and RSAT module behavior.
- A real forest, real ACL visibility, actual trust/site/DC/OU completeness, network errors or runtime load.
- Word opening without repair, EMF pixel/glyph/font rendering, normal-zoom readability, clipping, pagination, TOC refresh and printed output.
- Gates A–F, operational interpretation/sign-off, human author/approval, genuine feature enablement dates or undetermined design narratives.
- Arbitrary package I/O-fault recovery, every malformed replay shape, extreme-scale resource behavior, and all historical suites/campaigns. This review is a fresh focused re-check, not a rerun of the builder's claimed thousands of assertions.
- Raw/unprojected XSD-zero, proprietary extension-schema certification, or full XSD success for the defective original.
- Historical proof that the builder never changed an unstaged template; this review proves supplied input/template byte identity and the reviewed candidate's unchanged-template execution.
- Production clearance. This memo grants none.
