# Disposition — V151-01: Figure 6-2 rejects a valid single-site topology

**Filed:** 2026-10-30, from the lab's v1.5.1 confirmation submission
(bundle SHA-256 `7d7e7f3481ec2e261ca7ed899c1fe5a7facfce306ec191e8d10e0840a19c8a36`).
**Candidate:** Populate-ADForestOverview v1.5.1 (MD5 `af74c882be90cb53e071dabb45bc2026`) + template v1.1.1.
**Severity:** P1 — a required figure cannot be generated for an entire common topology
class (the single-site forest, whose only site link is the one-member
DEFAULTIPSITELINK). The failure mode is honest — explicit not-generated state, caption
disclosure, console warning, exit 2 — so no generated document is ever wrong, only
incomplete. Not P0.

## Lab result around the defect

- Part 1 (DEF-05 regression): **PASS** on all three runs (original-template, supported
  live, supported replay).
- Part 2: items for Figures 5-1, 6-1, 8-1 **PASS** on real lab data (5-1 trust inventory
  equals the Section 5 table; 8-1 OU inventories equal; live/replay EMF hashes identical
  for the generated figures). Figure 6-2 items **FAIL** solely due to V151-01. Word
  rendering item **NOT RUN** (no Word on the validation client — a lab limitation, not
  a product finding).
- Part 3 (adopted fields): **PASS** — Optional Features register (2 features, scopes,
  date left human), FGPP rows (2; no zero-lockout case present in this forest),
  diagnostics distinguish successful-empty from failed sections.

## Verification of the claim (first-hand, Alaric, 2026-10-30)

1. The bundle's input script hashes to the candidate MD5; the evidence SiteLinks.csv
   shows DEFAULTIPSITELINK with the single member `Default-First-Site-Name`, cost 100,
   interval 180, collection status ok — the source data was complete and valid.
2. `DOCX-Diagrams.json` in both live and replay evidence records Figure 6-2
   `Generated: false`, reason `site-link DEFAULTIPSITELINK membership/cost/interval
   unverified`; the generated DOCXs contain no 6-2 EMF part, and identical EMF hashes
   for 5-1/6-1/8-1 across live and replay.
3. Source confirmation, v1.5.1 line 2053 in `Get-ForestDiagramModel` (6-2 branch):
   `if ($members.Count -lt 2 -or $cost -notmatch '^\d+$' -or $interval -notmatch '^\d+$')
   { throw "site-link $name membership/cost/interval unverified" }`.
   The member loop immediately above already throws for unknown or duplicate members,
   so any link reaching line 2053 with one member is fully resolved and unambiguous;
   only the count check rejects it. The design classifier below already treats
   non-binary links conservatively (`$simple = $false`), independent of generation.
   **The defect is confirmed as reported.**

## Why the workshop chain missed it

The v1.5 re-check fixtures covered multi-site topologies, a three-member hyper link,
missing SiteLinks entirely, and a single-domain forest — but every fixture's site link
had two or more members. The degenerate one-member link (the default state of every
small forest) was never a fixture. The gap is in the build brief's fixture list, which
named "sites with and without DCs; site links with cost/interval" without the
one-member case. Standing correction: diagram fixture matrices must always include the
degenerate minimum case for every collection type (one domain, one site, one member,
empty).

## Required fix shape (v1.5.2, bounded)

- A fully resolved **one-member** site link is a valid degenerate topology: Figure 6-2
  generates, rendering the link as a card/spoke to its single member site with the
  verified name, cost and interval label. No second endpoint, pairwise connector, or
  design classification may be fabricated.
- Fail-closed behaviour preserved: zero members, unknown members, duplicate members,
  and missing/non-numeric cost or interval still throw named failures per link.
- Design classification (`Mesh` / `Hub-and-spoke` / human) unchanged: a one-member link
  sets `$simple = $false` exactly as other non-binary links do.
- Everything else frozen: diff confined to the 6-2 model validation/rendering path plus
  version/help metadata; the R1–R3 closures and all other figures byte-identical in
  behaviour (EMF hashes on the existing fixtures must match v1.5.1).
- Retest matrix (workshop, own harness): the lab's 7-point checklist in the defect
  report — single-site live shape, replay identity, no fabrication, existing two-site /
  multi-member cases unchanged, invalid inputs still fail closed, DEF-05/XSD regression,
  plus the degenerate-minimum fixtures for the other figures re-run.
- Then a focused independent re-check of the fix, then lab retest of Part 2 only
  (Parts 1 and 3 stand as PASS and are not re-opened; the Word item remains NOT RUN
  until a Word-equipped client is available).

## Addendum — RC-01 waiver (2026-10-30)

The focused re-check of v1.5.2 (t_4b629685) returned APPROVE WITH RESIDUAL FIXES,
the sole residual being RC-01: the re-check brief's literal prohibition on
Mesh/Hub-and-spoke text in the Figure 6-2 caption is not satisfied because the
caption retains template v1.1.1's human Design placeholder
("Design: [Hub-and-spoke / Mesh / Hybrid]"). The reviewer confirmed this is not a
fabricated classification — the script declined to classify and left the human
placeholder — and that it agrees with this disposition. **Marlando waived RC-01 on
2026-10-30**: the placeholder is the template working as designed; no caption-wording
fix will be commissioned. With the waiver recorded, v1.5.2 stands approved for the
lab Part 2 retest.
