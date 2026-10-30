# Workshop Defect Report — V151-01

**Title:** Figure 6-2 rejects a valid single-site topology  
**Candidate:** `Populate-ADForestOverview-v1.5.1.ps1`  
**Script MD5:** `af74c882be90cb53e071dabb45bc2026`  
**Script SHA-256:** `51b322674fd79e0ab451bf6390b409dc6d5ff248067600060b8fb4ebafc10d97`  
**Template:** v1.1.1, MD5 `a3e0fdb3fe23de25a701dcda265b0383`  
**Confirmation impact:** Part 2 items 1 and 5 FAIL; candidate not cleared  
**Reproducibility:** Deterministic in live collection and same-export replay

## Summary

On the live two-domain, single-site lab forest, v1.5.1 does not generate Figure 6-2. The source query succeeds and exports the site name, one-member `DEFAULTIPSITELINK`, numeric cost `100`, and numeric interval `180`. Nevertheless, diagram generation throws `site-link DEFAULTIPSITELINK membership/cost/interval unverified` and publishes the document without the required replication figure.

This is not a missing-source-data or DOCX-validation failure. The rejection is caused by an explicit diagram-model rule requiring at least two member sites. A one-site forest is therefore unable to satisfy Figure 6-2 even when its exported data is complete and internally consistent.

## Expected behavior

Per `VERIFICATION-v1.5.1-LAB.md`, Part 2 items 1 and 5:

- Figure 6-2 contains a generated vector diagram at its template location.
- Every site link appears with cost and interval matching `SiteLinks.csv`.
- Sites without DCs are marked as such.
- Live and same-export replay produce identical figure inventories.

For a valid one-member link, the figure should disclose that topology directly rather than inventing a second site or pairwise connector.

## Actual behavior

`DOCX-Diagrams.json` reports:

```json
{
  "Number": "6-2",
  "Generated": false,
  "Reason": "site-link DEFAULTIPSITELINK membership/cost/interval unverified",
  "Pages": 0
}
```

The generated document contains no EMF panel for Figure 6-2. Its caption discloses `not generated`, the console emits the same warning, and the run exits 2. The replay produces the identical failure.

Figures 5-1, 6-1 and 8-1 generate successfully, and the supported-template documents pass the complete 15-part OOXML XSD plus semantic validation with zero errors.

## Lab evidence

| Fact | Observed value |
|---|---|
| Host / account | `DC02` / `EXAMPLE\Administrator` |
| Forest domains | `ad.example.com`, `child.ad.example.com` |
| Sites | One: `Default-First-Site-Name`, with three DCs |
| Site link | `DEFAULTIPSITELINK` |
| Member sites | `Default-First-Site-Name` |
| Cost / interval | `100` / `180` minutes |
| `SiteLinks` collection status | `ok` |
| Figure 6-2 live / replay | Not generated / not generated |
| Other generated figures | 5-1, 6-1, 8-1; live/replay inventories match |

Evidence: [SiteLinks.csv](evidence/run-b-supported-live/evidence/SiteLinks.csv), [SectionStatus.csv](evidence/run-b-supported-live/evidence/SectionStatus.csv), [live DOCX-Diagrams.json](evidence/run-b-supported-live/evidence/DOCX-Diagrams.json), [replay DOCX-Diagrams.json](evidence/run-b-supported-replay/evidence/DOCX-Diagrams.json), [analysis summary](evidence/analysis-summary.json).

## Code-level cause

In `Get-ForestDiagramModel`, Figure 6-2 processing reads and validates the member set, cost, and interval. Line 2053 then rejects every link with fewer than two members:

```powershell
$cost = [string](Get-DiagramValue $link 'Cost')
$interval = [string](Get-DiagramValue $link 'Interval')
if ($members.Count -lt 2 -or $cost -notmatch '^\d+$' -or $interval -notmatch '^\d+$') {
    throw "site-link $name membership/cost/interval unverified"
}
```

The subsequent layout code already treats non-binary links conservatively by setting `$simple = $false`; that design-classification safeguard does not require suppressing the entire figure. Source: [candidate script](input/Populate-ADForestOverview-v1.5.1.ps1), lines 2036–2058.

## Minimal reproduction

1. Use a forest with one AD site and a successfully readable `DEFAULTIPSITELINK` containing only that site, with numeric cost and interval.
2. Run v1.5.1 with supported template v1.1.1:

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass `
     -File .\Populate-ADForestOverview-v1.5.1.ps1 `
     -TemplatePath .\ad-forest-overview-template-v1.1.1.docx `
     -OutputPath .\AD-Forest-Overview.docx `
     -OutputFolder .\evidence
   ```

3. Observe exit 2 and the Figure 6-2 warning.
4. Inspect `evidence\DOCX-Diagrams.json`: Figure 6-2 has `Generated = false` and `Pages = 0`.
5. Replay the exported data:

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass `
     -File .\Populate-ADForestOverview-v1.5.1.ps1 `
     -TemplatePath .\ad-forest-overview-template-v1.1.1.docx `
     -OutputPath .\AD-Forest-Overview-replay.docx `
     -OutputFolder .\replay-evidence `
     -DataFile .\evidence\AD-Forest-Data.json
   ```

6. Confirm the same absent figure and reason. No AD modification is needed for the replay reproduction.

Run records: [live transcript](evidence/run-b-supported-live/transcript.txt), [replay transcript](evidence/run-b-supported-replay/transcript.txt), [live document](evidence/run-b-supported-live/AD-Forest-Overview.docx), [replay document](evidence/run-b-supported-replay/AD-Forest-Overview.docx).

## Recommended correction direction

- Treat a nonempty, fully resolved one-member site link as a valid degenerate topology, not as unverified data.
- Render the site/link card with its verified cost and interval without fabricating a second endpoint, pairwise mesh, or hub-and-spoke design.
- Preserve fail-closed behavior for zero members, unknown or duplicate members, missing/non-numeric cost, and missing/non-numeric interval.
- Keep design classification (`Mesh`, `Hub-and-spoke`, `Hybrid`) separate from the decision to generate the inventory figure.

## Focused retest checklist

1. **Single-site live case:** Figure 6-2 is generated as a valid EMF panel; site, link name, cost `100`, and interval `180` match the export.
2. **Single-site replay:** The same export produces identical node/edge/text inventories.
3. **No fabrication:** No second site, pairwise trust-like connector, mesh, or hub-and-spoke claim is introduced for the one-member link.
4. **Existing cases:** Two-site and multi-member-link figures retain their verified memberships, costs, intervals, and conservative design labels.
5. **Invalid inputs:** Empty membership, unknown/duplicate members, and invalid cost/interval still produce named failures without a fabricated diagram.
6. **Regression gate:** Supported-template output retains zero duplicate-shading cells and zero full-package XSD errors; Figures 5-1, 6-1 and 8-1 remain unchanged for the same export.
7. **Word check:** When Word is available, confirm no repair prompt and legible, unclipped rendering at normal zoom.

The current Word unavailability is a separate NOT RUN item and is not a cause of V151-01. Full context: [v1.5.1 lab confirmation record](verification.md).
