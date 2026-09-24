# Markhor Farms — Implementation Plan

**Status:** Awaiting approval | **Updated:** 2026-09-25

## Overview
Building **Markhor Farms** — a branded, self-hosted farm management platform powered by farmOS v4 (Drupal-based, GPL-2.0-or-later). 
- **Development:** Docker on Mac (`127.0.0.1:8080`), targeting arm64 (Apple Silicon)
- **Deploy target:** Proxmox lab VM `markhor-farms` (10.27.27.0/24 Lahore LAN)

---

## Phase 1: Base Platform (Laptop) — CURRENT

### Deliverables
1. **farmOS v4 running in Docker**
   - Pin exact image: `farmos/farmos:4.x.x` with arm64 support
   - Postgres 16 backend (local volume)
   - HTTP: `http://127.0.0.1:8080`

2. **Branding (`markhor_theme`)**
   - Logo placeholder (until you provide)
   - Earthy neutral palette (until you provide brand colors)
   - Custom login page with "Markhor Farms" branding
   - About page with legal attribution: *"Markhor Farms is powered by farmOS software. farmOS is a registered trademark of Michel Stenta."*

3. **Install Profile (`markhor_farms`)**
   - Timezone: `Asia/Karachi`
   - Currency: PKR (Pakistani Rupee)
   - Units: metric
   - **Local units added:** kanal, marla, maund (1 acre = 8 kanal, 1 kanal = 20 marla, 1 maund = 40 kg)
   - Enable farmOS modules: land, plant, animal, equipment, logs, quantities, inventory, map
   - **Languages:** Urdu (RTL) + English (default)

4. **Seed Data**
   - Realistic fake farm data: 1 location, 5 fields, test animals, crops
   - For testing workflows without disturbing real data

5. **Git & CI/CD**
   - Push to private repo: `markhor-farms` (GitHub)
   - `.env.example` only (secrets in `.env`, gitignored)
   - gitleaks pre-commit hook
   - Branch-based workflow; I merge PRs

### Timeline & Blockers
- **Blockers awaiting your input:**
  - Brand colors (hex) for `markhor_theme`
  - Farm logo (PNG/SVG)
  - Farm coordinates (lat/lon)
  - Animal types & quantities to seed
  - Crop types for Phase 2 planning

---

## Phase 2: Crops & Livestock (Laptop → Lab)

### Features
- **`mf_crops_pk`:** Rabi (Oct–Apr) / Kharif (Apr–Oct) season templates
  - Crops: wheat, rice, cotton, maize, sugarcane, fodder
  - Yield in maund/acre
- **`mf_livestock`:** Animals with breeding, vaccination, weight, milk yield
  - Types: goats, sheep, cattle, buffalo
  - Reminders: vaccination schedule
  - Sales/purchases tracking

### Timeline
- After Phase 1 approval & deploy to lab

---

## Phase 3: Operations & Labor

### Features
- **`mf_labor`:** Workers, attendance, wages (PKR), advances
- **`mf_water`:** Tubewell/canal turns, irrigation logs, diesel/electricity
- **Dashboard:** Today's tasks, upcoming vaccinations, low stock, month spend vs income

### Timeline
- After Phase 2 in production (lab)

---

## Phase 4: Integrations & Edge Box (Later)

### Features
- **`mf_finance_bridge`:** Export to FinFort (CSV until API exists)
- **Farm edge box:** Offline-first Raspberry Pi 5 / mini PC, backups to lab when online
  - Plan only; hardware TBD after Phase 1

---

## Deployment Strategy

### Laptop (Dev)
```
make up          # docker compose -f compose/docker-compose.yml -f compose/docker-compose.dev.yml up -d
make down        # Stop containers
make logs        # Tail logs
make shell       # Drush shell in web container
make reset       # Wipe local dev data (confirms first)
make backup      # Local backup
```

### Lab VM (`markhor-farms`)
- SSH key: `~/.ssh/ammad_mac`
- Host config: `~/.ssh/config` (Host markhor-farms entry exists)
- **Deploy method (TBD after Phase 1):**
  1. Docker context over SSH: `docker context create markhor-farms --docker "host=ssh://markhor-farms"`
  2. Or: VM pulls tagged release, runs compose locally
  3. Will pick one & document in `make deploy-lab` after testing Phase 1

- **Production settings:**
  - `.env.prod` (never committed)
  - Caddy with internal TLS
  - Nightly backups (restic → TrueNAS + offsite)
  - No internet-facing ports

---

## Repository Structure

```
markhor-farms/
  README.md  LEGAL.md  CLAUDE.md  CHANGELOG.md  Makefile
  compose/
    docker-compose.yml          # base: farmos, postgres 16
    docker-compose.dev.yml      # laptop: 127.0.0.1 ports
    docker-compose.prod.yml     # lab: caddy, backups, restart
    .env.example
  web/
    profiles/markhor_farms/     # install profile
    themes/markhor_theme/       # branding
    modules/
      mf_core/  mf_crops_pk/  mf_livestock/  mf_inputs/
      mf_labor/  mf_water/  mf_finance_bridge/
  image/edge/                   # farm edge box (Phase 4)
  image/proxmox/                # cloud-init (Phase 4)
  data/                         # local volumes (gitignored)
  docs/  plan.md  architecture.md  data-model.md  runbook.md
  tests/
  .gitignore  .env.example  gitleaks-config.toml
```

---

## Approval Checklist

- [ ] farmOS v4 tag & Drupal/PHP versions confirmed in `architecture.md`
- [ ] arm64 image availability confirmed
- [ ] Repo structure approved
- [ ] Phase 1 timeline acceptable
- [ ] Brand colors & logo ready (or approved placeholder approach)

**Next step:** Show `docs/architecture.md` → await approval → implement Phase 1.
