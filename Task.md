# Cogent Agent Engineer Take‑Home
We are a very practical team at Cogent and this extends to the way that we work with you to find out if this team is a great fit for you. We want you to come away with a great understanding of the work that we actually do day to day and what it is like to work with us.

So instead of coding at a whiteboard with someone watching over your shoulder under high pressure, we instead discuss code that you have written previously when we meet.

## Guidelines
* This is meant to be an assignment that you spend approximately ~6 hours of dedicated, focused work. Do not feel like you need to overengineer the solution with dozens of hours to impress us. Be biased toward quality over quantity.

* Think of this like an open source project. Create a repo on Github, use git for source control, and use README.md to document what you built for the newcomer to your project.

* Our team builds, alongside our customers and partners, systems engineered to run in production. Given this, please organize, design, test, deploy, and document your solution as if you were going to put into production. We completely understand this might mean you can't do as much in the time budget. Be biased for production-readiness over features.

* Think out loud in your submission's documentation. Document tradeoffs, the rationale behind your technical choices, or things you would do or do differently if you were able to spend more time on the project or do it again.

* Our team meets our customers where they are in terms of software engineering platforms, frameworks, tools, and languages. This means you have wide latitude to make choices that express the best solution to the problem given your knowledge and favorite tools. Make sure to document how to get started with your solution in terms of setup.

* Use of generative AI-based tools (Code assistants, copilots, LLMs) to move fast in creating your solution is allowed and encouraged.


---
## The Problem 
**Problem Definition (Enterprise Customer Requirements):**
A large enterprise security team is struggling with fragmented asset and vulnerability data across multiple systems. Executives need a **daily, trustworthy report** of the most critical unresolved vulnerabilities by business unit. Engineering teams need a **programmatic API** to power internal dashboards. Today’s sources are inconsistent and overlapping. The customer needs an **AI Agent** that can autonomously ingest messy feeds, learn or apply mappings, reconcile conflicts, and produce a reliable, consumable service.

Your task: **design and implement an AI Agent** that orchestrates the end‑to‑end workflow: normalize and unify asset & vulnerability data from multiple sources, derive useful fields, deduplicate across scanners, compute a daily summary, and expose results via an API.
**Implementation details are up to you** (language, frameworks, storage, orchestration). Choose technologies you’re most effective with and that you believe are pragmatic for the problem.

---

## Data Sources

You will receive three files/sources:

### A) Assets (two sources)

1. **Qualys CSV** — `assets_qualys.csv`

```
qid,hostname,ip,last_seen,os,owner
```

2. **Internal CMDB** — table `cmdb_assets`

```
asset_id UUID PRIMARY KEY,
fqdn TEXT,
business_unit TEXT,
owner_email TEXT,
created_at TIMESTAMP
```

### B) Vulnerabilities (two sources for the same entity)

1. **Qualys Vulnerabilities CSV** — `vulns_qualys.csv`

```
scanner_vuln_id,hostname,ip,cve,severity,detected_at,resolved_at
```

2. **Tenable Vulnerabilities CSV** — `vulns_tenable.csv`

```
plugin_id,asset_fqdn,asset_ip,cve,cvss,vpr,first_seen,last_seen,status
```

> Expect duplication/overlap across the two vuln sources for the **same (asset, CVE)**. Your Agent must consolidate these into **one normalized record** per (asset, CVE).

---

## What to Build: The AI Agent

Design an **autonomous Agent** that can plan, call tools, and explain its decisions. Keep it simple but real.

### Core Agent Capabilities

* **Tool Use & Orchestration:** The Agent should invoke tools you provide (e.g., FileReader, DB/Storage, SchemaMapper, Merger, Scorer, Summarizer, APIServer, Scheduler). The exact toolset is up to you; document each tool’s contract.
* **Normalization & Mapping:** Map source‑specific fields to a **normalized schema** for assets and vulnerabilities. The Agent should either (a) learn mappings from examples/prompts/config, or (b) apply deterministic rules — but structure it so the mapping can evolve.
* **Derivation:** Compute derived fields from the normalized schema (examples below).
* **Deduplication & Merge:** Merge vulnerability records across sources for the same (asset, CVE) using clear, deterministic logic with confidence scoring.
* **Summarization:** Produce a **Top 10 unresolved vulnerabilities per business unit**.
* **Serving:** Expose results via an HTTP API.
* **Autonomy & Recovery:** Be idempotent; safe to re‑run. Handle partial failures and produce useful logs/metrics.
* **Explainability:** Provide a machine‑readable trace for key decisions (e.g., why a field was chosen; confidence for merges).

### Suggested Agent Interfaces (non‑binding)

* **Agent Manifest (YAML/JSON):** declare tools, configs, and policies (rate limits, retries, timeouts).
* **Planning Loop:** lightweight loop that (1) reads inputs, (2) plans steps, (3) calls tools, (4) writes outputs, (5) emits a brief reasoning trace (no need for complex chain‑of‑thought; just decisions and assumptions).
* **Confidence & DQ:** publish confidence on merges and simple data‑quality metrics.

---

## Functional Requirements

### 1) Normalization & Derivation

* Define a normalized schema for **assets** and **vulnerabilities** that accommodates both sources.
* Map source fields to the schema, resolving conflicts with clear rules.
* Derive additional fields (examples; you may change or extend):

  * Asset: `is_active` (e.g., last\_seen within 30 days), `age_days` (now − created\_at), `criticality_score` (your documented formula).
  * Vulnerability: merged `severity` (unified 1–5 scale), `status` (open/resolved), `confidence` (0–1), `first_seen`, `last_seen`.
* Record data quality issues (e.g., missing owner, hostname mismatch) for later reporting.

### 2) Pipeline (Agent‑run)

* Ingest the two asset sources and two vulnerability sources.
* Normalize, deduplicate, and merge into your unified schema.
* Compute **Top 10 unresolved vulnerabilities per business unit**:

  * Filter for unresolved/open.
  * Sort by severity, then recency, then asset criticality.
* Produce a daily summary dataset/table.
* Emit DQ metrics (e.g., percent missing owners, hostname conflicts).

### 3) API

Expose a minimal HTTP API that allows:

* Fetching summary data per business unit and across all BUs.
* Fetching normalized asset details and its open vulnerabilities.
* Fetching alerts (e.g., any BU with >100 open critical vulns).

### 4) Packaging & Delivery

* Make the Agent easy to run end‑to‑end (containerized or otherwise).
* Provide clear setup instructions.
* Assume the customer’s engineers are moderately technical but expect simplicity.

---

## Stretch Goals (optional)

* **Learning Mappings:** Make the Agent **learn** normalization/derivation rules from examples and persist them (e.g., a simple mapping store or lightweight model) instead of hardcoding everything.
* **Active Feedback:** If merge confidence is low, have the Agent flag/ask for human input (e.g., write a review queue).
* **Streaming/Near‑Real‑Time:** Support incremental ingestion.
* **Caching:** Cache API responses.
* **Observability:** Minimal dashboard of summary and DQ metrics.
* **Tests:** Automated tests for normalization/merge logic.

---

## Seed Data (provided)

The exercise includes seed CSVs and SQL inserts for Qualys assets, CMDB assets, and vulnerabilities from both Qualys and Tenable. These contain overlapping, inconsistent records the Agent must normalize and deduplicate.

### Provided CSV files (place at project root)

**`assets_qualys.csv`**

```csv
qid,hostname,ip,last_seen,os,owner
Q-A-001,web-01.acme.local,10.0.1.10,2025-08-25T10:15:00Z,Ubuntu 22.04,alice@acme.com
Q-A-002,db-01.acme.local,10.0.1.20,2025-08-28T02:05:00Z,Ubuntu 20.04,bob@acme.com
Q-A-003,win-01.acme.local,10.0.2.10,2025-08-22T18:45:00Z,Windows Server 2019,carol@acme.com
Q-A-004,eng-ci-01.acme.local,10.0.3.50,2025-08-29T12:30:00Z,Ubuntu 22.04,devops@acme.com
Q-A-005,hr-app-01.acme.local,10.0.4.10,2025-08-18T09:00:00Z,Ubuntu 18.04,hr-owner@acme.com
Q-A-006,finance-core-01.acme.local,10.0.5.10,2025-08-29T21:10:00Z,Windows Server 2022,finops@acme.com
Q-A-007,sales-portal-01.acme.local,10.0.6.10,2025-08-27T07:25:00Z,Ubuntu 22.04,salesit@acme.com
Q-A-008,shared-cache-01.acme.local,10.0.7.10,2025-08-23T11:40:00Z,Ubuntu 22.04,platform@acme.com
```

**`vulns_qualys.csv`**

```csv
scanner_vuln_id,hostname,ip,cve,severity,detected_at,resolved_at
Q-V-1001,web-01.acme.local,10.0.1.10,CVE-2024-12345,4,2025-08-24T08:00:00Z,
Q-V-1002,db-01.acme.local,10.0.1.20,CVE-2023-99999,5,2025-08-27T10:00:00Z,
Q-V-1003,win-01.acme.local,10.0.2.10,CVE-2022-5678,3,2025-08-20T06:00:00Z,2025-08-28T13:00:00Z
Q-V-1004,eng-ci-01.acme.local,10.0.3.50,CVE-2025-11111,4,2025-08-29T10:30:00Z,
Q-V-1005,hr-app-01.acme.local,10.0.4.10,CVE-2020-1350,5,2025-08-10T12:00:00Z,
Q-V-1006,finance-core-01.acme.local,10.0.5.10,CVE-2025-22222,5,2025-08-29T20:50:00Z,
Q-V-1007,sales-portal-01.acme.local,10.0.6.10,CVE-2021-34527,4,2025-08-26T07:20:00Z,
Q-V-1008,shared-cache-01.acme.local,10.0.7.10,CVE-2024-88888,2,2025-08-22T09:45:00Z,
Q-V-1009,db-01.acme.local,10.0.1.20,CVE-2024-12345,4,2025-08-28T11:15:00Z,
Q-V-1010,finance-core-01.acme.local,10.0.5.10,CVE-2023-44444,3,2025-08-25T19:00:00Z,2025-08-29T04:00:00Z
```

**`vulns_tenable.csv`**

```csv
plugin_id,asset_fqdn,asset_ip,cve,cvss,vpr,first_seen,last_seen,status
19506,web-01.acme.local,10.0.1.10,CVE-2024-12345,8.7,6.2,2025-08-24T09:10:00Z,2025-08-29T09:30:00Z,open
21111,db-01.acme.local,10.0.1.20,CVE-2023-99999,9.8,7.9,2025-08-27T10:05:00Z,2025-08-29T03:15:00Z,open
30999,win-01.acme.local,10.0.2.10,CVE-2022-5678,6.5,5.0,2025-08-20T06:05:00Z,2025-08-28T12:30:00Z,closed
40001,eng-ci-01.acme.local,10.0.3.50,CVE-2025-11111,7.3,6.8,2025-08-29T10:35:00Z,2025-08-29T11:00:00Z,open
50002,hr-app-01.acme.local,10.0.4.10,CVE-2020-1350,10.0,8.5,2025-08-10T12:05:00Z,2025-08-25T08:00:00Z,open
60003,finance-core-01.acme.local,10.0.5.10,CVE-2025-22222,9.0,7.5,2025-08-29T20:55:00Z,2025-08-30T00:10:00Z,open
70004,sales-portal-01.acme.local,10.0.6.10,CVE-2021-34527,8.1,6.9,2025-08-26T07:25:00Z,2025-08-27T15:45:00Z,open
80005,shared-cache-01.acme.local,10.0.7.10,CVE-2024-88888,4.3,3.1,2025-08-22T09:50:00Z,2025-08-23T10:00:00Z,open
90006,db-01.acme.local,10.0.1.20,CVE-2024-12345,7.2,5.4,2025-08-28T11:20:00Z,2025-08-29T14:00:00Z,open
100007,finance-core-01.acme.local,10.0.5.10,CVE-2023-44444,6.8,4.9,2025-08-25T19:05:00Z,2025-08-29T05:00:00Z,closed
```

**CMDB seed (SQL)**

```sql
CREATE TABLE IF NOT EXISTS cmdb_assets(
  asset_id UUID PRIMARY KEY,
  fqdn TEXT,
  business_unit TEXT,
  owner_email TEXT,
  created_at TIMESTAMP
);

INSERT INTO cmdb_assets(asset_id,fqdn,business_unit,owner_email,created_at) VALUES
('11111111-1111-1111-1111-111111111111','web-01.acme.local','ENG','alice@acme.com','2024-11-05T09:00:00Z'),
('22222222-2222-2222-2222-222222222222','db-01.acme.local','ENG','bob@acme.com','2023-07-12T12:00:00Z'),
('33333333-3333-3333-3333-333333333333','win-01.acme.local','FIN','carol@acme.com','2025-01-20T08:30:00Z'),
('44444444-4444-4444-4444-444444444444','eng-ci-01.acme.local','ENG','devops@acme.com','2024-03-01T10:10:00Z'),
('55555555-5555-5555-5555-555555555555','hr-app-01.acme.local','HR','hr-sys@acme.com','2022-12-01T14:00:00Z'),
('66666666-6666-6666-6666-666666666666','finance-core-01.acme.local','FIN','finops@acme.com','2023-02-15T16:45:00Z'),
('77777777-7777-7777-7777-777777777777','sales-portal-01.acme.local','SALES','salesit@acme.com','2024-05-22T09:15:00Z'),
('88888888-8888-8888-8888-888888888888','shared-cache-01.acme.local','PLATFORM','platform@acme.com','2023-09-09T11:25:00Z');
```

---

## Deliverables

* Code and instructions to run the Agent end‑to‑end.
* **Agent Manifest** (YAML/JSON) describing tools, configs, and policies.
* Brief explanation of normalization/merge rules and confidence scoring.
* Example API responses.
* “What I’d do with another week.”

---

## Evaluation Criteria

* **Agentic Design:** sensible tools, planning loop, and autonomy boundaries.
* **Normalization & Merge:** correctness, determinism, clarity of rules or learned mappings.
* **Explainability & DQ:** decision trace and data‑quality metrics.
* **Reliability:** idempotent runs, error handling, observability.
* **API Quality:** useful shape, pagination/errors where appropriate.
* **Pragmatism & Velocity:** simple, effective solutions over heavy abstractions; clear trade‑offs.

---

## Submission
Share a link to your private github repo with your code hosted to `@snggeng` and `@thanosbaskous` at least 12 hours before your presentation. We will review it and come to the presentation with questions prepared.
