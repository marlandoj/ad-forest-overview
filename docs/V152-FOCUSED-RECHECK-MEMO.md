# Focused independent re-check — Populate-ADForestOverview v1.5.2

Verdict: APPROVE WITH RESIDUAL FIXES
Scope: candidate v1.5.2 with supported template v1.1.1, for focused lab retest of Part 2. NOT production clearance.
Task: t_4b629685. Review date: 2026-10-30.

The V151-01 functional fix is confirmed against the untouched REAL lab export. The candidate generates Figure 6-2 correctly; v1.5.1 rejects the same export with the original reason. All four recorded surviving-figure hashes match exactly. Fail-closed cases, existing topology outputs, static gates and the supported-template MC-aware schema gate pass. No additional functional source change or new functional regression was found.

The qualified verdict is solely for RC-01 below: the literal instruction forbidding Mesh/Hub-and-spoke text in the caption is NOT satisfied, because the preserved human Design placeholder contains those option words. This is not fabricated classification and agrees with the bounded disposition. An explicit acceptance clarification/waiver, or a separately authorized bounded caption-wording fix and retest, remains necessary; I have not silently converted that literal failure into a pass.

## 1. Input integrity and independent evidence

All seven supplied MD5 values matched before execution and at final verification. Reference inputs were not changed. Candidate SHA-256:

de56e327258e464cdf80390300e292c6030a46049f8f7309d359354994feda5b

Fresh harnesses were written for this re-check. Builder assertion counts were not adopted. Historical fixture/schema assets were inspected and reused as inputs, not historical results. Runtime: Linux PowerShell 7.4.6 Core; PSScriptAnalyzer 1.25.0. Python 3.14.4/lxml 6.1.3 performed independent EMF decoding, package comparisons and XSD validation.

Final acceptance populations, which overlap and must not be added into one grand assertion total:

- Static: 195/195 assertions.
- Replay/topology/negative-control: 91/91 behavioral assertions, PLUS one separately retained literal-caption failure.
- Parent readback/integrity reconciliation: 39/39 assertions; it explicitly verifies that the caption failure remains recorded, not that the caption prohibition passes.
- Final replay matrix: 16 actual invocations and 16 generated packages; 86 EMF instances independently decoded and structurally walked. Three invocations are explicitly nonshipping version-neutral controls.
- Separate normalization runs: two actual candidate invocations, one per template.
- Schema replay discovery: 19 paths, but three are duplicate baseline archive copies: 16 unique execution outputs, each 18/18 MC-projected parts. Together with the separate supported-template run, 17 supported-template execution outputs pass. No duplicated path is counted as another product execution.

## 2. Real failing lab case, replayed

The final candidate and negative-control commands point -DataFile directly at /opt/zouroboros/review-inputs/lab-v151-export.json, not a reconstructed DTO. Exact command arrays, source/data hashes and stdout/stderr are in replay/ledger.json and the per-case invocation records.

Candidate: document published, exit 2. Figures 5-1, 6-1, 6-2 and 8-1 Generated=true; pages 1, 1, 1 and 2 respectively. The warning exit is attributable to the lab export's existing KdsRootKey/gMSA/FGPP visibility gaps, NOT a diagram failure; the console retains those precise reasons.

Figure 6-2 decoded actual EMF:

- Exactly one roster site, Default-First-Site-Name, DCs: 3.
- Exactly one link-to-member card connector, from label DEFAULTIPSITELINK | Cost: 100 | Interval: 180 minutes to that site.
- One line total; no arrowheads, second site node or site-to-site pairwise connector.
- No Mesh/Hub-and-spoke text in EMF text records and no inferred classification.
- DOCX-Diagrams.json: 6-2 Generated=true, Pages=1, Reason="", section status ok.
- EMF SHA-256: 94a1c19888251f584fbf56c520179c4920b288afdb442d76b4bd4ab8169b67f8.

Recorded live-run comparison — every hash matches, with NO date/metadata normalization:

    5-1   70bb0b91c9e3dfdb571ca930f114ee5b024f4656b2f5682ea456dad4c81ed8e2
    6-1   2150100f35924873a666b66b0e31035ffa9a1b24a831004e7782e280d31016d6
    8-1a  0325ed51c2db8e24c8deb17342c57790902172e372f3a74ad566d764fb269311
    8-1b  7f16c5ed92397753cb1031bafc54457b77be76b50aa52af6873da670b7c645cd

There is therefore no differing-hash cause to excuse. All four surviving EMFs also equal the freshly executed v1.5.1 control.

Negative control v1.5.1: published, exit 2; only 6-2 suppressed, Generated=false, Pages=0, exact original reason:

    site-link DEFAULTIPSITELINK membership/cost/interval unverified

## 3. Fail-closed matrix

Each case is a separate mutated copy of the real lab export. All five publish, exit 2, suppress ONLY Figure 6-2, report Pages=0/Generated=false/partial status with the exact named reason in evidence, document and console, and preserve byte-identical other-figure EMFs.

    Mutation           Exact Figure 6-2 reason
    zero members       site-link DEFAULTIPSITELINK membership/cost/interval unverified
    unknown member     site-link DEFAULTIPSITELINK has unknown/ambiguous member UnknownSite
    duplicate member   site-link DEFAULTIPSITELINK has unknown/ambiguous member Default-First-Site-Name
    nonnumeric cost    site-link DEFAULTIPSITELINK membership/cost/interval unverified
    missing interval   site-link DEFAULTIPSITELINK membership/cost/interval unverified

Existing lab collection gaps remain; “ONLY” means only that figure is additionally suppressed, not that pre-existing collection gaps disappear.

## 4. Existing topologies frozen

Final runs use the untouched t_b500b190/diagrams/{multi,hyper,mesh}/data.json files. Parent verification proves exact source fixture bytes. This samples multi-site binary links, multi-tree/trust relationships, a three-member hyper link and Mesh classification. Six shipping baseline/candidate invocations all publish with exit 0.

    Shape   EMFs/version   Design, unchanged                 Package parts/control
    multi   6              Hub-and-spoke                    25
    hyper   6              [Hub-and-spoke / Mesh / Hybrid]   25
    mesh    7              Mesh                             26

All 19 EMFs per shipping version match in bytes and figure assignment. All text differences are exhaustively retained: exactly five product-version text nodes plus one exact logical output-path node per fixture. No date, design, warning, field, ordering or diagram bytes are normalized. Shipping raw text is therefore NOT literally identical across a version bump and different output paths; these six precise differences per fixture are benign metadata, not hidden regressions.

Stronger control: three clearly labelled NONSHIPPING candidate derivatives replace ONLY the ScriptVersion assignment with 1.5.1, retaining the threshold fix. At the same baseline logical OutputPath and exact DataFile path, every uncompressed package part equals the shipping v1.5.1 output: 76/76 parts in aggregate. All 6,474 w:t/w:instrText nodes, including empty-node positions, match exactly. The control source hash/literal edit is retained; it is not the shipping artifact.

## 5. Exhaustive diff discipline and N1

82 functions in each version; 81 byte-identical, one changed, none added/removed. Byte offsets are mapped from real parser extents with BOM handling and extent-text equality checks. The only changed function is Get-ForestDiagramModel, at baseline line 2053 / candidate line 2058:

    $members.Count -lt 2  ->  $members.Count -lt 1

No renderer changes were necessary or made. Unknown/duplicate membership resolution, numeric checks, edge creation and conservative classification remain byte-frozen. In particular, nonbinary links still set simple=false; no design is inferred for the one-member case.

The complete candidate reconstructs byte-for-byte from baseline with that threshold edit and four metadata edits: help release version/date; help change-note block; runtime ScriptVersion; diagram-helper comment version. N1 is corrected: inherited v1.5.1 history now names analyzer remediation, reserved xml:space serialization and abort-on-diagram-package-commit failure, rather than incorrectly saying analyzer-only. The v1.5.2 note plainly describes resolved one-member acceptance and preserved validation/classification.

Parameters, collection functions, guards, exit regions, DEF-05 repair and publisher/XML writer behavior are unchanged except explicit version disclosure. R1-R3 were not reopened: analyzer evidence was freshly checked; R2/R3 code was byte-frozen and exercised on ordinary replay paths, not new fault-injection campaigns.

## 6. Static, normalization and schema bars

- Full parser: 0 candidate / 0 baseline errors.
- UTF-8 BOM; ASCII payload; candidate 172043 bytes, 2868 CRLFs, zero bare LF. Runtime version exactly 1.5.2.
- PSScriptAnalyzer Error/Warning/Information: 0/58/127 both; diagnostic multisets 185 each, zero additions/removals, not merely equal totals.
- Explicitly enabled Windows Desktop 5.1 command/type and syntax compatibility rules: zero findings. Independent command, syntax and type negative controls each trigger the intended rule once. This is static compatibility, not Windows runtime certification.
- Normalization: 48 original-template / 0 supported-template cells; both resulting documents have zero duplicate-shading cells.
- Every final supported-template execution output passes all 18 XML/relationship parts after explicit logged MC projection. Raw validation remains 9/18 per output; no unprojected all-part pass is claimed.
- Fresh full-package positive control passes; duplicate-free wrong-order cell-properties negative control fails document.xml as intended. Nine MC projection self-tests pass.
- Verified 40 cached schema-manifest records and 30 ECMA XSDs against exact nested archive members. This trusts cached official-source attribution; it is not fresh vendor authentication.
- Defective original-template output is NOT an XSD pass: 17/18 projected parts. Unchanged settings.xml has w:zoom without required w:percent. This inherited limitation is retained, not waived and not attributed to v1.5.2.

## 7. Finding RC-01 — literal caption prohibition conflicts with preserved human placeholder

Classification: acceptance-text residual; not a new inferred-design or functional regression.

Exact generated caption:

    Figure 6-2  Replication topology - site-link membership (not connection objects) - Diagram version: 1.5.2 - Date: 2026-10-29 - Design: [Hub-and-spoke / Mesh / Hybrid]

The human Design placeholder remains, as required by the bounded disposition and unchanged-classification requirement. It nevertheless contains the exact prohibited words, so the brief's literal “no Mesh/Hub-and-spoke text ... in ... caption” check FAILS. Builder claims about no inferred design are accurate; they do not satisfy that stronger literal statement. No product regression is alleged.

Residual closure: the acceptance owner must explicitly clarify/waive literal option-word exclusion while preserving human options, or authorize a separate conservative caption wording change such as a human-only unspecified Design field and retest it. This review neither changes the input nor grants that waiver. V151-01's one-member-generation defect itself is resolved; candidate is suitable for the focused Part 2 lab retest subject to this recorded residual.

## 8. NOT VERIFIED

- Real Windows PowerShell 5.1 Desktop/.NET Framework execution, RSAT/provider/alias/filesystem behavior.
- Live collection on a real forest: this re-check REPLAYS the lab's existing export; no live queries were performed.
- Word opening without repair; EMF visual rendering/fonts/clipping, pagination, TOC, printing or human readability.
- Gates A-F, operational sign-off, production safety/readiness or production clearance.
- Fresh R2/R3 boundary/fault-injection suites, persistent I/O/crash behavior, every v1.5.1 feature or historical fixture, scale/load.
- Unprojected all-part schema success, proprietary extension certification, full XSD success for the defective original, or fresh schema-source download/signature verification.

## Evidence and reproducibility

Primary: replay/{run.py,decode_recheck.py,ledger.json,summary.json,assertions.json,inventory.json,freeze.json,literal-caption-requirement.json}; static/STATIC-RECHECK.md and raw-audit.json; SCHEMA-RECHECK.md and schema/{recheck.py,own-results.json,replay-results.json,controls.json,projection-selftests.json,provenance-recheck.json}; fixture-provenance.json; FINAL-VERIFICATION.json. Output DOCXs and sidecars remain with each case.

An earlier exploratory replay corpus under replay-initial-controls/ used historical port-omission probes rather than the exact original fixtures. It is excluded from final acceptance counts. Final runs above were rerun using the exact originals. An initial Python driver basename inspect.py collided with stdlib imports; it was renamed decode_recheck.py and decoder/schema drivers reran successfully. An initial parent aggregator expected a different static-summary key; the reader was corrected and rerun. No product source was altered for these harness corrections and no failed literal-caption result was relabelled.

Runtime paths and exact product commands are recorded in invocation ledgers. Decoder/schema/aggregation reruns are read-only/idempotent; run.py creates fresh case directories and needs a fresh output root. Supported template and both shipping scripts remain unchanged.
