# Production Gate B — Fixture Assembly Plan

**Status:** PLAN ONLY — no lab changes authorized or performed by this document  
**Baseline:** [Gate B inventory verdict](verification.md) — INCOMPLETE  
**Coverage decision:** **Full coverage; no scope exclusions**  
**Execution rule:** Each wave requires explicit execution authorization, a verified rollback point, and evidence capture before the next wave begins.

## 1. Assumptions and settled scope decisions

1. The objective is to satisfy every open Gate B fixture requirement, not to obtain a reduced-scope or replay-only clearance.
2. No fixture is waived. Synthetic `-DataFile` fixtures may supplement testing but do not substitute for the required live topology.
3. All work remains in the isolated lab. No trust, DNS, network, or routing connection to production is permitted.
4. Existing domains `ad.example.com` and `child.ad.example.com`, their DCs, and their current Default Domain Policies are preserved.
5. Word will not be installed on a domain controller. A separate domain-joined, Word-equipped validation client will be used.
6. New fixture GPOs will be empty except for the dedicated Kerberos-winner GPO. The existing Default Domain Policy will not be edited.
7. Proposed IP addresses and names must pass preflight conflict checks before use. A conflict requires changing the plan record before execution, not improvising during promotion.
8. A restorable VM snapshot or equivalent lab rollback point is mandatory before each infrastructure wave. If none can be created, that wave stops.
9. Gate B becomes PASS only after a fresh inventory proves every fixture and the evidence package is accepted. Creating objects alone is insufficient.

## 2. Target fixture layout

### Proposed infrastructure identities

| Role | Host | Candidate IP | Domain/forest | Purpose |
|---|---|---|---|---|
| Non-DNS RODC | `LABRODC51` | `10.20.30.120` | `child.ad.example.com` | RODC and DC-without-DNS coverage |
| Second-tree DC | `LABTREE52` | `10.20.30.121` | `dftree.test` in the existing forest | Genuine second tree and automatic tree-root trust |
| Forest-trust DC | `LABFOREST53` | `10.20.30.122` | Root of separate forest `dfforest.test` | External-forest trust coverage |
| External-trust DC | `LABEXT54` | `10.20.30.123` | Root of separate forest `dfexternal.test` | External trust coverage, kept separate from the forest-trust fixture |

Use Windows Server versions compatible with the current forest/domain functional levels. Keep all four VMs on the isolated lab network with DNS client settings pointing only to the appropriate lab DNS servers.

### Proposed replication fixtures

| Object | Proposed configuration | Coverage |
|---|---|---|
| `LabVerify-Empty-Site` | New site with no DCs | Empty-site labeling and topology coverage |
| `LabVerify-IP-Link` | IP link joining `Default-First-Site-Name` and `LabVerify-Empty-Site`; cost `150`, interval `30`, custom schedule | Multi-site Figure 6-2 and custom IP schedule |
| `LabVerify-SMTP-Link` | SMTP link joining the same two sites; cost `160`, interval `60` | SMTP transport coverage |
| `10.254.253.0/24` | Subnet object with no Site assignment | Unassigned-subnet coverage |

The empty site must remain empty. Place the RODC in `Default-First-Site-Name`, not in `LabVerify-Empty-Site`.

### Proposed service-account fixtures

| Object | Proposed configuration | Coverage |
|---|---|---|
| KDS root key | One valid forest KDS root key created on a writable root-domain DC | KDS key collection |
| `LabVerify-gMSA` | Enabled gMSA in `ad.example.com`; DNS hostname `LabVerify-gMSA.ad.example.com`; password-retrieval principal limited to a dedicated lab group | gMSA collection |

**Rollback limitation:** a KDS root key is not an ordinary disposable test object. Do not promise deletion as cleanup. Retain it for subsequent tests or restore the lab snapshot if complete removal is required.

### Proposed GPO fixtures

| GPO/link | Proposed configuration | Coverage |
|---|---|---|
| `LabVerify-SiteLinked` | Empty GPO linked to `LabVerify-Empty-Site` | Site-linked GPO |
| `LabVerify-LinkDisabled` | Empty GPO linked to a dedicated test OU with link disabled | Disabled-link flag |
| `LabVerify-LinkEnforced` | Empty GPO linked to a different dedicated test OU with link enforced | Enforced-link flag |
| `LabVerify-Unlinked` | Empty GPO with no links | Unlinked GPO |
| `LabVerify-KerberosWinner` | Root-domain GPO with only a distinctive lab Kerberos value; linked at higher precedence than Default Domain Policy | Non-default winning Kerberos policy |

For `LabVerify-KerberosWinner`, retain the current values except set **MaxClockSkew = 6 minutes** so the winning source is distinguishable from the Default Domain Policy's 5 minutes. Export before/after GPO reports and effective domain policy. Apply this change only in the lab maintenance window and roll it back immediately after the authoritative-value test.

## 3. Execution waves

### Wave 0 — Authorization, baseline, and rollback

1. Record the approved full-scope decision and maintenance window.
2. Re-run the read-only Gate B inventory; confirm no new collection errors and no leftover `ADForestVerify*` tasks/rules.
3. Export current forest/domain/trust/site/subnet/GPO/KDS/gMSA state.
4. Back up current GPOs and export reports for both Default Domain Policies.
5. Verify restorable snapshots for every existing and new VM that the wave can affect.
6. Confirm candidate IPs, hostnames, DNS names, NetBIOS names, and OU names are unused.
7. Record build versions, administrators, and evidence paths.

**Exit criterion:** baseline and rollback evidence are complete. Otherwise stop.

### Wave 1 — Second tree and trust infrastructure

1. Promote `LABTREE52` as the first DC of new tree root `dftree.test` **in the existing `ad.example.com` forest**, with DNS installed as required for the new domain.
2. Verify the automatic tree-root trust and replication health.
3. Promote `LABFOREST53` as the first DC of separate forest `dfforest.test`.
4. Promote `LABEXT54` as the first DC of separate forest `dfexternal.test`.
5. Establish a two-way forest trust between `ad.example.com` and `dfforest.test`.
6. Establish a two-way external trust between `ad.example.com` and `dfexternal.test`.
7. Establish a shortcut trust between `child.ad.example.com` and `dftree.test`.
8. Validate trust type, direction, transitivity, SID filtering, and authentication paths from both sides.

**Exit criterion:** second tree, tree-root, forest, external, and shortcut trusts all appear correctly in live reads. No production DNS forwarders or conditional forwarders are introduced.

**Rollback order:** remove shortcut/external/forest trusts first; demote the fixture DCs; remove their DNS zones and domain metadata only through supported demotion/cleanup procedures; restore snapshots if demotion fails.

### Wave 2 — RODC without DNS

1. Pre-stage or promote `LABRODC51` as an RODC in `child.ad.example.com` using the existing lab administrative process.
2. Do not install the DNS Server role. Configure DNS clients to use existing lab DNS servers.
3. Place the RODC in `Default-First-Site-Name`.
4. Verify `IsReadOnly = true`, `DnsFeatureInstalled = false`, ADWS health, replication, and read-only behavior.
5. Confirm all three original DCs remain writable and healthy.

**Exit criterion:** live inventory reports one RODC and one DC without DNS, with no collection errors.

**Rollback:** demote the RODC and remove its computer/account metadata through supported AD procedures; restore the snapshot if required.

### Wave 3 — Sites, links, schedule, and subnet

1. Create `LabVerify-Empty-Site` with no DCs.
2. Create `LabVerify-IP-Link` with both sites, cost `150`, interval `30`, and a documented custom replication schedule.
3. Create `LabVerify-SMTP-Link` with both sites, cost `160`, and interval `60`.
4. Create subnet `10.254.253.0/24` without a Site assignment.
5. Export site-link schedules and verify that `DEFAULTIPSITELINK` remains cost `100`, interval `180`, with its original schedule.
6. Run Figure 6-2 live/replay verification and confirm no fabricated pairwise topology or design classification.

**Exit criterion:** custom IP schedule, SMTP link, multi-site topology, empty site, and unassigned subnet are all visible in evidence.

**Rollback:** delete the subnet, custom links, and empty site after dependent GPO links are removed; verify the original site/link state.

### Wave 4 — KDS and gMSA

1. Create the KDS root key on a writable root-domain DC using the lab-approved immediate-effect procedure.
2. Allow forest replication and verify the key is readable from every required collection context.
3. Create a dedicated lab group for password retrieval and then `LabVerify-gMSA` with that group as its only retrieval principal.
4. Verify `Get-KdsRootKey` and `Get-ADServiceAccount` return the fixtures without error.
5. Record the KDS key as intentionally persistent for subsequent testing unless a snapshot restore is planned.

**Exit criterion:** valid KDS root key and enabled gMSA are visible, with no fabricated DNS/service dependency.

**Rollback:** delete the gMSA and dedicated group if no longer needed. Do not delete or mutate the KDS key as routine cleanup; use the snapshot decision recorded in Wave 0.

### Wave 5 — GPO and winning Kerberos fixtures

1. Create the four empty fixture GPOs and dedicated test OUs.
2. Link `LabVerify-SiteLinked` to the empty site.
3. Configure one disabled and one enforced link on separate test OUs.
4. Leave `LabVerify-Unlinked` unlinked.
5. Export all `gPLink` values and verify flags `1` and `2` on the intended links only.
6. During the maintenance window, create/link `LabVerify-KerberosWinner` at higher precedence than Default Domain Policy.
7. Refresh policy on the required DCs and verify the effective root-domain MaxClockSkew is 6 minutes and the reported source is the non-default fixture GPO.
8. Confirm the child domain's Default Domain Policy remains unchanged.

**Exit criterion:** site-linked, disabled, enforced, unlinked, and non-default-winning-Kerberos cases are all authoritative in live evidence.

**Rollback:** unlink/delete `LabVerify-KerberosWinner` first and refresh policy; verify MaxClockSkew returns to 5 minutes. Then remove the empty fixture links, GPOs, and OUs. Restore from GPO backup if the observed state differs from the baseline.

### Wave 6 — Word and later-run prerequisites

1. Provide a separate domain-joined validation client with a licensed supported Microsoft Word installation.
2. Record Word version, client host, and OS.
3. Open the v1.5.2 live output and confirm no repair prompt.
4. Inspect all four figures at normal zoom; capture Figure 6-2 and any defect screenshots.
5. Immediately before Gate C/F live runs that require it, enable Directory Service Changes Success and Failure auditing on the required DCs and capture the prior setting.
6. After those runs, restore the original auditing state (`No Auditing` in the current baseline) and verify restoration.

**Exit criterion:** Word evidence is complete; auditing is enabled only for the designated runs and restored afterward.

## 4. Gate B re-verification and acceptance

Run the existing read-only fixture inventory and compare it with every requirement. The final Gate B record must prove:

- Genuine second tree plus tree-root, external, forest, and shortcut trusts.
- Three original writable GC DCs remain healthy; new RODC is read-only and has no DNS Server role.
- Custom IP schedule, SMTP link, and unassigned subnet exist.
- gMSA and valid KDS root key are readable.
- Site-linked, disabled, enforced, and unlinked GPO fixtures exist.
- The non-default Kerberos winner is authoritative in live collection.
- A Word-equipped validation client is available.
- No temporary tasks, verification firewall rules, orphaned fixture accounts, or unapproved DNS/network changes remain.
- Every collection has zero top-level and per-domain errors, or any error is explicitly blocking and corrected before PASS.

**Gate B PASS is prohibited if any item is missing and no formal scope exclusion has been approved.** This plan selects no exclusions.

## 5. Final cleanup decision

Retain the fixtures until Gates C–F and regression replays are complete. Then make one explicit recorded choice:

1. **Retain the assembled lab** for repeatable verification, including the KDS key and trust infrastructure; or
2. **Restore the Wave 0 lab baseline** using the documented rollback sequence and snapshots.

Do not partially remove trust, replication, or policy fixtures while later gates still depend on them. Every cleanup run must end with a fresh inventory, health check, and task/firewall cleanup confirmation.

## 6. Evidence index

Baseline references:

- [Gate B verdict](verification.md)
- [Live fixture inventory](evidence/fixture-inventory.json)
- [Endpoint roles and audit baseline](evidence/endpoint-roles-audit.json)
- [Requirement analysis](evidence/gate-b-analysis.json)
- [Word availability baseline](evidence/word-availability.json)
- [Gate A connectivity clearance](../gate-a/verification.md)
