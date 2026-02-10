# Recent Work

Track recent changes, ongoing work, and current context here.

## Format
```
### YYYY-MM-DD - [Developer Name]
**What was done:**
- Brief description of changes

**Context/Notes:**
- Important details for next person picking up work
```

---

### 2026-02-08 - Initial Setup
**What was done:**
- Created CLAUDE.md with complete stack architecture documentation
- Set up .claude-memory/ structure for team collaboration
- Documented all stack modes (default, develop, vue, cache, auth, storage)

**Context/Notes:**
- CLAUDE.md now auto-loads context about modular docker-compose service files
- Team memory system established for cross-machine collaboration
- Repository uses feature/SHW_General branch, main branch is for PRs
- STANDARD_array has been customized for SHW deployment (Postgres with ports, Kafdrop, SVFE electronic invoicing)

---

### 2026-02-08 - Production Deployment Documentation
**What was done:**
- Documented actual production deployment configuration from remote server
- Captured docker-compose.yml and docker compose convert output from running deployment
- Identified discrepancy between git baseline and actual running configuration

**⚠️ CRITICAL - Git Baseline (commit c51d7c8):**
- **Branch**: `feature/SHW_General`
- **Commit**: `c51d7c8` (detached HEAD on remote)
- **Commit date**: 2026-02-03
- **Commit message**: "Update adempiere-shw to 3.9.4.001-1.1.46"
- **Author**: Mario Calderon
- **Deployment files**: `/home/westfalia/Westfalia-Projekte/COFIA/04-Implementierung/2026/20260208-Claude/`

**⚠️ CRITICAL - Actual Running Deployment:**
- **Based on commit**: c51d7c8
- **Local modifications**: `.env` and `env_template.env` manually modified on server
- **Status**: Running with uncommitted changes

**Production Server Details:**
- **Domain**: erp-adempiere.westfalia-it.com
- **SSL**: Let's Encrypt certificates
- **Remote repo path**: /home/westfalia/adempiere/01-Repository/adempiere-ui-gateway/
- **Network**: 192.168.100.0/24 (gateway: 192.168.100.1)
- **Timezone**: America/El_Salvador

**Image Versions Comparison:**

| Service | Git (c51d7c8) | Actually Running | Notes |
|---------|---------------|------------------|-------|
| adempiere-zk | `jetty-3.9.4.001-shw-1.1.39` | `jetty-3.9.4.001-shw-1.1.45` | ⚠️ Modified in .env |
| adempiere-grpc-server | `3.9.4.001-shw-1.0.29` | `3.9.4.001-shw-1.0.29` | Same |
| adempiere-grpc-proxy | `3.9.4.001-shw-1.0.29` | `3.9.4.001-shw-1.0.29` | Same |
| adempiere-report-engine | `alpine-1.3.7` | `alpine-1.3.7` | Same |
| adempiere-processors | `alpine-1.1.11` | `alpine-1.1.11` | Same |
| adempiere-vue | `0.0.5` | `0.0.5` | Same |
| PostgreSQL | `14.5` | `14.5` | Same |
| nginx | `1.27.0-alpine3.19` | `1.27.0-alpine3.19` | Same |
| Kafka | `7.6.1` | `7.6.1` | Same |
| OpenSearch | `2.15.0` | `2.15.0` | Same |
| MinIO | `RELEASE.2024-07-31T05-46-26Z` | `RELEASE.2024-07-31T05-46-26Z` | Same |

**Services Running (STANDARD stack + SHW custom):**
1. PostgreSQL (port 55432)
2. MinIO S3 Storage (ports 9000, 9090)
3. S3 Client, S3 Gateway RS
4. ADempiere Site, ZK UI, Processor
5. DKron Scheduler (ports 8899, 8946)
6. gRPC Server, Report Engine
7. Envoy gRPC Proxy (port 5555)
8. Vue UI
9. Zookeeper, Kafka (port 29092), Kafdrop (port 19000)
10. OpenSearch, OpenSearch Setup, OpenSearch Dashboards (port 5601)
11. Dictionary RS
12. nginx UI Gateway (ports 80, 443)
13. SVFE API Firmador - El Salvador e-invoicing (port 8113)

**Context/Notes:**
- ⚠️ Server has local modifications not in git: ZK image upgraded from 1.1.39 → 1.1.45
- Git commit c51d7c8 from 2026-02-03 is the baseline
- Actual deployment may differ from git due to manual .env changes
- Always verify actual running versions vs git when troubleshooting
- Configuration uses STANDARD stack with SHW customizations

---

### 2026-02-10 - Fixed Envoy Proxy Startup Failure
**What was done:**
- Diagnosed and fixed envoy proxy crash: "Could not find 'form.out_bound_order.OutBoundOrderService' in the proto descriptor"
- Updated docker-compose volume mounts to include new `.dsc` proto descriptor file
- Replaced old `.pb` file with new `.dsc` file containing updated service definitions

**Problem:**
- Commit c7beb9c (2026-02-02) added new gRPC services to envoy.yaml and created new `.dsc` descriptor file
- BUT forgot to update docker-compose to mount the new file
- Envoy crashed on startup because it couldn't find the new service definitions

**Solution Applied (commit c7103fa):**
- Changed volume mount in `10c-grpc_proxy_service_standard.yml`:
  - FROM: `./envoy/definitions/adempiere-grpc-server.pb:/data/adempiere-grpc-server.pb:ro`
  - TO: `./envoy/definitions/adempiere-grpc-server.dsc:/data/adempiere-grpc-server.dsc:ro`
- Updated same in `docker-compose-standard.yml` and `docker-compose-auth.yml`
- Updated envoy.yaml proto_descriptor path from `.pb` to `.dsc`
- Deleted old `.pb` file

**New Services Added:**
- `form.out_bound_order.OutBoundOrderService`
- `form.payment_allocation.PaymentAllocation` (moved from old location)
- `form.trial_balance_drillable.TrialBalanceDrillable` (moved from old location)

**Context/Notes:**
- This is a common pitfall: updating envoy.yaml but forgetting to update docker-compose volumes
- The three-step pattern documented in learned-patterns.md must be followed
- Always verify descriptor file is mounted after adding new gRPC services
- Issue occurred between commits c51d7c8 (working) and 20b3208 (failing)
- Error files archived in: `/home/westfalia/Westfalia-Projekte/Kaltmann/.../20260208-Error_envoy_proxy/English/`
