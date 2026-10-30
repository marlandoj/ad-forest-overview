# Example diagrams

The four figures the script generates at fill time, as EMF vector parts embedded in
the document package. These examples are **actual script output**: produced by
Populate-ADForestOverview **v1.5.2** in `-DataFile` replay mode from a synthetic
example dataset — a two-domain forest (`ad.example.com` + child
`child.ad.example.com`, one site, three DCs) modelled on the topology shape confirmed
in lab validation. The full lab verification records are maintained privately; the
verification history summary in the README describes them.

Figures 6-1 and 6-2 contain no domain names, so their EMFs are byte-identical to the
output the script produced on the real lab forest during confirmation — including the
single-site Figure 6-2 case fixed by v1.5.2 (defect V151-01).

The `.emf` files in `assets/diagrams/` are the artifacts of record. The `.png` files
are preview renders produced with LibreOffice's EMF renderer — they show content and
layout faithfully, but they are **not** a Microsoft Word rendering.

| Figure | Content | EMF SHA-256 |
|---|---|---|
| 5-1 — Logical topology | Forest boundary, trees and domains (FQDN + NetBIOS), trust connectors with direction and classified type | `dfef5b24b78d36c926b8a4571842ff70ed1df48723496248263315bf896734c7` |
| 6-1 — Geographic site map | Site inventory, labelled SCHEMATIC in the figure itself: AD holds no reliable geography, so positions are layout, not geography; site Location attributes only where present | `2150100f35924873a666b66b0e31035ffa9a1b24a831004e7782e280d31016d6` |
| 6-2 — Replication topology | Site roster with DC counts, and one card per site link showing membership, cost and interval. Site-link membership is drawn, not connection objects — pairwise topology and design classification are never inferred | `94a1c19888251f584fbf56c520179c4920b288afdb442d76b4bd4ab8169b67f8` |
| 8-1 — OU structure (2 panels) | Per domain: domain root plus top-level OUs, with root→OU connectors | panel 1 `a5f3a16944311decef7b463b3fe7dd5219ea49eaa4b510f359fb6db56e72b1a0`, panel 2 `f82de824d549a0dcbfef02bac5217df6ab7a283325ed4fd972d50b20951f44cc` |

Notes:

- Figure 6-2 in this example is the single-site case: the forest's only link,
  `DEFAULTIPSITELINK` (cost 100, interval 180), has one member site, and the figure
  renders the roster plus the link card with no invented second endpoint.
- The script marks only what the collected data proves. A figure whose inputs cannot
  be collected or verified is not drawn; the document states "not generated" with the
  reason and the run reports it (exit code 2 semantics).
