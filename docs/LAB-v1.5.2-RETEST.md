# Lab Retest Record — Populate-ADForestOverview v1.5.2

**Scope:** Part 2 items 1 and 5, Figure 6-2 replay identity, and associated retest expectations  
**Candidate MD5:** `63ceb38e49e4c900f8d8cb045f0af20b`  
**Candidate SHA-256:** `de56e327258e464cdf80390300e292c6030a46049f8f7309d359354994feda5b`  
**Template:** v1.1.1, MD5 `a3e0fdb3fe23de25a701dcda265b0383`  
**Lab host/account:** `DC02` / `EXAMPLE\Administrator`, Windows PowerShell 5.1  
**Retest verdict:** **PASS — V151-01 CLOSED**  
**Word rendering:** **NOT RUN** — Word remains unavailable on the validation client  
**Production clearance:** **INCOMPLETE** — Gates A–F and the Word item remain separate

All seven product expectations passed. Under the supplied procedure, this completes the v1.5.x lab confirmation: Part 1 (DEF-05) and Part 3 (adopted fields) remain PASS from v1.5.1 and were not reopened. No new defect was found against the v1.5.2 hashes.

## Inputs and runs

Local and remote input hashes matched the checklist, and the PowerShell parser returned zero errors. Script and template MD5/SHA-256 hashes remained unchanged before/after both runs. The replay used the exact export from the live run. Generated documents were copied back with matching SHA-256 hashes and validated without repair.

| Run | Exit | Seconds | Generated DOCX SHA-256 |
|---|---:|---:|---|
| Live collection | 2 | 20.432 | `873b19ec3b2b47d37dbe1a6f178029efeeff96e4beb35f72f20bd58a179cc19c` |
| Same-export replay | 2 | 8.722 | `056889dcc91d077ea12a0e4d2535bcd9b742032e8a5172d0742822afe8e5520d` |

Exit 2 remains attributable to the pre-existing FGPP/gMSA/KDS collection gaps. Neither console names Figure 6-2 as a warning, partial fill, or failure. Evidence: [input validation](evidence/local-input-validation.json), [remote deployment](evidence/remote-deployment.json), [run summary](evidence/run-summary.json), [live task lifecycle](evidence/live-task-lifecycle.json).

## Expectations

| # | Expectation | Result | Evidence/observation |
|---|---|---|---|
| 1 | Figure 6-2 generated in both runs | **PASS** | `DOCX-Diagrams.json` reports `Generated = true`, `Pages = 1` in live and replay. Each DOCX contains one valid EMF panel at `word/media/ad-figure-6-2-3.emf`. |
| 2 | Correct single-site content; no second site or pairwise connector | **PASS** | Exactly one node: `Default-First-Site-Name | DCs: 3`. Exactly one link inventory row: `DEFAULTIPSITELINK | Cost: 100 | Interval: 180 minutes`, with one member and empty pairwise Source/Target fields. No second site exists in the figure inventory. |
| 3 | Design honesty / RC-01 | **PASS** | Caption retains `Design: [Hub-and-spoke / Mesh / Hybrid]`; the script asserts no Mesh, Hub-and-spoke, or Hybrid classification. The placeholder is accepted under RC-01 and is not flagged as a defect. |
| 4 | Replay identity | **PASS** | Figure 6-2 node, edge, member, label, and text inventories are identical between live and replay. Both EMF parts have SHA-256 `94a1c19888251f584fbf56c520179c4920b288afdb442d76b4bd4ab8169b67f8`. |
| 5 | Frozen EMF hashes | **PASS** | Figure 5-1, 6-1, and both 8-1 EMF hashes exactly equal the v1.5.1 live-run values. |
| 6 | Package health | **PASS** | Both documents have zero duplicate-shading cells and zero full-package XSD errors. Validator: Kimi Word `verify.py --no-repair`, bundled 15-part OOXML XSD and semantic package checks. Each retains 30 non-blocking table-width warnings; no repair was applied. |
| 7 | Exit behavior | **PASS** | Both runs exit 2 solely with the disclosed pre-existing collection gaps; Figure 6-2 is not a stated reason. |
| 8 | Microsoft Word rendering | **NOT RUN** | Word is not installed or command-available on `validation-client`. No Word version, repair-prompt, normal-zoom legibility, clipping, or screenshot claim is made. This remains a lab-side open item, not a product defect. |

Evidence: [live diagram status](evidence/run-b-supported-live/evidence/DOCX-Diagrams.json), [replay diagram status](evidence/run-b-supported-replay/evidence/DOCX-Diagrams.json), [shared live SiteLinks.csv](evidence/run-b-supported-live/evidence/SiteLinks.csv), [automated retest analysis](evidence/retest-analysis.json), [Word availability](evidence/word-availability.json).

## Frozen EMF comparison

| Figure | v1.5.1 and v1.5.2 SHA-256 | Result |
|---|---|---|
| 5-1 | `70bb0b91c9e3dfdb571ca930f114ee5b024f4656b2f5682ea456dad4c81ed8e2` | MATCH |
| 6-1 | `2150100f35924873a666b66b0e31035ffa9a1b24a831044b7b2c390e0a156e648e5f` | MATCH |
| 8-1 panel 1 | `0325ed51c2db8e24c8deb17342c57790902172e372f3a74ad566d764fb269311` | MATCH |
| 8-1 panel 2 | `7f16c5ed92397753cb1031bafc54457b77be76b50aa52af6873da670b7c645cd` | MATCH |

## Run evidence

### Live

- [Generated document](evidence/run-b-supported-live/AD-Forest-Overview.docx)
- [Console transcript](evidence/run-b-supported-live/transcript.txt)
- [Normalization evidence](evidence/run-b-supported-live/evidence/DOCX-Normalization.json)
- [Diagram evidence](evidence/run-b-supported-live/evidence/DOCX-Diagrams.json)
- [OOXML validation](evidence/run-b-supported-live/ooxml-validation.txt)
- [Run result](evidence/run-b-supported-live/run-result.json)

### Replay

- [Generated document](evidence/run-b-supported-replay/AD-Forest-Overview.docx)
- [Console transcript](evidence/run-b-supported-replay/transcript.txt)
- [Normalization evidence](evidence/run-b-supported-replay/evidence/DOCX-Normalization.json)
- [Diagram evidence](evidence/run-b-supported-replay/evidence/DOCX-Diagrams.json)
- [OOXML validation](evidence/run-b-supported-replay/ooxml-validation.txt)
- [Run result](evidence/run-b-supported-replay/run-result.json)

## Cleanup and final disposition

No forest topology, trust, GPO, auditing, or other persistent AD changes were made. All three DCs report zero remaining `ADForestVerify152` tasks and zero verification firewall rules. Evidence: [lab cleanup](evidence/lab-cleanup.json).

**V151-01 is closed.** The v1.5.2 focused retest passes items 1–7, completing the v1.5.x lab confirmation under the supplied checklist. Production clearance remains incomplete pending the separate production Gates A–F and a Word-equipped rendering check.
