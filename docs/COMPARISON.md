# Feature comparison — AD Forest Overview vs the ADDS Inventory reference script vs ADRecon

**Date:** 2026-10-29. **Method:** source-based comparison against the current repository
heads — the ADDS Inventory reference script (v2.26 lineage, source updated 2025-10) and
sense-of-security/ADRecon (v1.1) — and this repository's v1.4.1 script and template v1.1.1.
No tool was run against a live forest for this comparison; claims are from the code, help
text, and sample output in each repo.

## At a glance

| | **AD Forest Overview (this repo)** | **ADDS Inventory reference script** | **ADRecon** |
|---|---|---|---|
| Job | Fill a **controlled document template** with verified forest facts | Generate a complete **documentation document** of a forest | **Reconnaissance/assessment** data collection and report |
| Script size | ~2,200 lines | ~16,500 lines (+ signed copy) | ~12,100 lines |
| Output | One DOCX (your template) + evidence pack (JSON/CSV) | DOCX, PDF, HTML, or text | Excel workbook + CSV/XML/JSON/HTML per artefact |
| Office needed | **None** — edits DOCX XML directly | **Microsoft Word required** (COM automation) | Excel required for the flagship report (offline `-GenExcel` from CSVs exists) |
| Document model | **Your template**: your sections, branding, human-fillable areas | Fixed generated layout; cover-page company fields | Fixed workbook/report layout |
| Data replay | **First-class**: `-DataFile` regenerates the document from the exported JSON with identical gap reporting | None | Partial: Excel can be regenerated from a prior CSV folder |
| Gap honesty | Per-domain, per-section status; ACL-hidden objects are labelled "none visible to this identity", never "absent"; named fill failures | Errors surface in output, but no per-section status model | Collection is exhaustive; gaps are a log concern |
| Output validity | **Full OOXML XSD validation** of generated documents; template defects normalized with disclosed counts (DEF-05) | Word produces the file, so validity is Word's | N/A (workbook/data exports) |
| Safety guards | Refuses non-empty output folders and template-aliased output paths; read-only `Get-*` only (AST-verified each round) | Read-only documentation intent | Read-only collection; some modules need privileged accounts |

## Collection breadth

**The reference script is the deepest documenter.** Beyond the core forest/domain/site/trust/GPO/DNS
material, it records per-DC detail the others don't: DC event-log data, time-server
configuration, DC DNS/IP configuration, Certificate Authority information, DHCP, and
Exchange organization data, plus computer counts by OS. It has been refined in the field
since 2014.

**ADRecon is the broadest collector.** Its 24 modules add a security layer neither
documentation tool attempts: ACLs, LAPS, BitLocker recovery keys, user/computer SPNs,
password attributes, dormant accounts, full user/group/computer enumeration, printers, and
optional Kerberoast/service-account modules. It is engineered for scale (threading, LDAP
page size, ADWS-or-LDAP protocol choice).

**This tool is deliberately narrower.** It collects what the overview document needs —
forest and per-domain facts, DCs, trusts, sites/subnets/links, policies (incl. Kerberos
policy from the Default Domain Policy report), FGPP, gMSA, KDS keys, GPO register and
links, DNS zones/forwarders, protected-group counts, object counts — and stops there. It
does not enumerate users or export security artefacts.

## Where each wins

- **Reference script:** documentation depth and formats; a decade of edge cases already met.
- **ADRecon:** security-analysis breadth, scale engineering, output-format matrix.
- **This repo:** the controlled-document model (an organisation's own template, human
  sections left human), replayable evidence, refusal guards, per-section honesty, and
  schema-validated output — the properties that make the document usable as a *record*.

## Borrow list (candidates for the normal workshop route)

1. **From the reference — content depth for the DC section:** time-configuration and
   event-log summaries per DC, Certificate Authority information, computer counts by OS.
   These fit the existing template/collector shape.
2. **From ADRecon — an optional security annex:** LAPS presence, SPN inventory, and
   dormant-account counts as *optional* collection modules feeding annex tables, off by
   default, consistent with the evidence model. Also its scale options (page size) if
   large-forest runs need them.
3. **Not to borrow:** Word/Excel COM dependencies (this tool is Office-free by design);
   ADRecon's full object enumeration (a different product — recon, not a controlled
   overview); the reference's fixed layout (the template *is* the product here).

## Limits of this comparison

Source- and documentation-based only; performance, accuracy, and behaviour on a real
forest were not tested. ADRecon has active forks with newer code than the v1.1 line
examined here. The reference script's version (2.26, 2020) predates its repository's latest
packaging updates.
