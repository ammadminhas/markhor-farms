# Markhor Farms — Technical Architecture

**Status:** Phase 1 Planning | **Updated:** 2026-09-25

---

## Stack Overview

| Layer | Component | Version | Notes |
|-------|-----------|---------|-------|
| **App** | farmOS | v4.x | Official upstream, GPL-2.0-or-later |
| **Framework** | Drupal | 10.x | Bundled with farmOS v4 |
| **Language** | PHP | 8.2+ | Bundled with farmOS image |
| **Database** | PostgreSQL | 16 | Alpine Linux container |
| **Web Server** | Apache 2.4 | Built into farmOS image | |
| **Runtime** | Docker (arm64) | 29.4.0 | Apple Silicon (M4 Max) native |

---

## farmOS v4 Image Strategy

### Official Image
- **Source:** `farmos/farmos` on Docker Hub
- **Tag:** `4.x.x` (exact tag TBD during Phase 1 implementation)
- **Architecture:** arm64 native (to be verified)
  - If no arm64 variant exists: fallback to build from `farmos/farmos` Dockerfile for arm64, or use `platform: linux/amd64` emulation (slower, documented)
- **Build:** Drupal 10 + farmOS 4 modules bundled
- **No hard fork:** We layer custom code as a distribution (theme, custom modules, install profile)

### Image Variants Considered
1. **Official `farmos/farmos:latest-v4`** (preferred)
2. **Build from source** if arm64 unavailable
3. **Emulation** (`linux/amd64`) only as fallback

---

## Custom Codebase

### Mount Strategy
```
Container: /opt/drupal/web/
├── profiles/
│   └── markhor_farms/        # Install profile (mounted from ./web/profiles/)
├── themes/
│   └── markhor_theme/        # Branding (mounted from ./web/themes/)
├── modules/custom/
│   ├── mf_core/              # Core utilities
│   ├── mf_crops_pk/          # Crops (Rabi/Kharif)
│   ├── mf_livestock/         # Animals (goats, sheep, cattle, buffalo)
│   ├── mf_inputs/            # Stock management
│   ├── mf_labor/             # Workers & wages
│   ├── mf_water/             # Irrigation & diesel/electricity
│   └── mf_finance_bridge/    # Export to FinFort
```

**In Docker Compose:**
```yaml
services:
  web:
    image: farmos/farmos:4.x.x  # pinned
    volumes:
      - ./web/profiles/markhor_farms:/opt/drupal/web/profiles/markhor_farms:ro
      - ./web/themes/markhor_theme:/opt/drupal/web/themes/markhor_theme:ro
      - ./web/modules:/opt/drupal/web/modules/custom:ro
      # Data volumes:
      - farmdata:/opt/drupal/sites/default/files
      - dbdata:/var/lib/postgresql/data
```

---

## Licensing & Attribution

### Compliance
- **Product:** Markhor Farms
- **Base:** farmOS (upstream `farmos/farmos` image, GPL-2.0-or-later)
- **Our code:** GPL-2.0-or-later (custom modules, theme, profile)
- **Distribution:** Private use only; if ever distributed, source must be available

### Legal Files
- `LEGAL.md` in root: *"Markhor Farms is powered by farmOS software. farmOS is a registered trademark of Michel Stenta."*
- About page in `markhor_theme`: Same wording
- `.gitignore`: Excludes `data/` volumes and `.env`

---

## Local Units System

### Extension Strategy
farmOS v4 uses Drupal's `quantity` and `unit` entities. We extend via:

1. **`mf_core` module:**
   - Custom unit definitions: kanal, marla, maund
   - Conversion helpers: 1 acre → 8 kanal → 160 marla
   - 1 maund = 40 kg

2. **Hook implementations:**
   - `hook_farm_quantities_units()` to register custom units
   - Seed script populates units during `drush site:install`

3. **Quantities module config:**
   - Metric system + local units
   - Default unit for each crop/animal type

---

## Internationalization (i18n)

### Languages
- **English** (default, LTR)
- **Urdu** (RTL, secondary language)

### Implementation
1. **`web/modules/mf_core/translations/`**
   - `.po` files for Urdu translations
   - Generated from English strings via `drush locale:update`

2. **Theme:**
   - `markhor_theme/templates/*.twig` with `t()` filters
   - RTL CSS via `@media (dir: rtl)`

3. **Install profile:**
   - Set default language to English
   - Enable Urdu as secondary language
   - Configure text direction in theme

---

## Container Design

### docker-compose.yml (Base)
```yaml
version: '3.8'
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: farmos
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - dbdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  web:
    image: farmos/farmos:4.x.x  # pinned
    depends_on:
      db:
        condition: service_healthy
    environment:
      POSTGRES_HOST: db
      POSTGRES_DB: farmos
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      # Codebase (read-only for now)
      - ./web/profiles/markhor_farms:/opt/drupal/web/profiles/markhor_farms:ro
      - ./web/themes/markhor_theme:/opt/drupal/web/themes/markhor_theme:ro
      - ./web/modules:/opt/drupal/web/modules/custom:ro
      # Data (read-write)
      - farmdata:/opt/drupal/sites/default/files
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/status"]
      interval: 10s
      timeout: 5s
      retries: 3

volumes:
  dbdata:
  farmdata:
```

### docker-compose.dev.yml (Laptop Only)
```yaml
services:
  web:
    ports:
      - "127.0.0.1:8080:80"  # localhost only
    environment:
      ENVIRONMENT: development
      # PHP memory limits for laptop
```

### docker-compose.prod.yml (Lab VM)
```yaml
services:
  caddy:
    image: caddy:2-alpine
    # Internal TLS, reverse proxy
    environment:
      ACME_AGREE: "true"

  web:
    restart: unless-stopped
    environment:
      ENVIRONMENT: production

  backup:
    image: restic/restic:latest
    # Nightly backups to TrueNAS + offsite
    cron: "0 2 * * *"  # 2 AM daily
```

---

## Deployment Flow

### Phase 1 (Laptop)
```
$ make up
  → docker compose -f compose/docker-compose.yml -f compose/docker-compose.dev.yml up -d
  → Runs Postgres + farmOS at 127.0.0.1:8080
  → Auto-installs via markhor_farms profile

$ make seed
  → drush sql:cli < seeds/fake-data.sql
  → Populates test farm data

$ make logs
$ make shell      # Drush shell access
$ make reset      # Wipe data (confirms first)
```

### Phase 1 Validation
- [ ] Markhor Farms branding visible (logo, colors, login page)
- [ ] Urdu language available in settings
- [ ] Kanal, marla, maund units created
- [ ] Test data populated
- [ ] All farmOS modules (land, plant, animal, logs, quantities) enabled

### Phase 2+ (Lab VM)
```
# Deploy method TBD (after Phase 1 test):
Option A: Docker context over SSH
  $ docker context create markhor-farms --docker "host=ssh://markhor-farms"
  $ docker --context markhor-farms compose -f compose/docker-compose.yml \
      -f compose/docker-compose.prod.yml up -d

Option B: VM git pull + compose
  $ ssh markhor-farms "cd /opt/markhor-farms && git pull origin main && make up-prod"
```

---

## Data Model Overview (Phase 2+)

### farmOS Core Entities (Upstream)
- **Assets:** Land, plants, animals, equipment
- **Logs:** Activities (movements, treatments, observations)
- **Quantities:** Measurements (weight, yield, count)
- **Inventory:** Stock management

### Custom Modules (Ours)
- `mf_crops_pk`: Rabi/Kharif templates, yield tracking
- `mf_livestock`: Breeding, vaccination, milk yield, sales
- `mf_inputs`: Seed, fertilizer, feed, pesticide stock
- `mf_labor`: Workers, attendance, wages
- `mf_water`: Tubewell/canal turns, irrigation logs
- `mf_finance_bridge`: Export to FinFort

---

## Security Baseline

### Laptop (Dev)
- No internet exposure (127.0.0.1 binding)
- `.env` gitignored, secrets not committed
- gitleaks pre-commit hook

### Lab VM (Prod)
- Internal TLS via Caddy (no self-signed warnings for internal access)
- No internet-facing ports
- Firewall: only SSH + internal Markhor-Farms access
- Nightly encrypted backups to TrueNAS
- Separate `.env.prod` (never committed)

---

## Known Unknowns (TBD During Phase 1)

- [ ] Exact farmOS v4 image tag (e.g., `farmos/farmos:4.3.0`)
- [ ] arm64 image availability (will test on pull)
- [ ] Drupal/PHP exact versions (will document after pull)
- [ ] Whether custom units hook exists or needs contrib module
- [ ] i18n support in farmOS v4 (may need contrib modules)
- [ ] Brand colors (hex) — approved placeholder for now
- [ ] Farm coordinates (lat/lon) for map center
- [ ] Animal types/quantities to seed
- [ ] Crop types for Phase 2 planning

---

## Files to Create (Phase 1)

```
compose/
  docker-compose.yml
  docker-compose.dev.yml
  docker-compose.prod.yml
  .env.example

web/
  profiles/markhor_farms/markhor_farms.profile  (install profile)
  themes/markhor_theme/markhor_theme.info.yml  (theme)
  themes/markhor_theme/templates/
    page--login.html.twig
    page--about.html.twig
    etc.
  modules/mf_core/
    mf_core.info.yml
    mf_core.module
    src/Hooks.php  (unit hooks, i18n)

docs/
  runbook.md  (operational guide)
  data-model.md  (detailed ER diagram, Phase 2+)

scripts/
  seed-fake-data.php  (test data)

Makefile
README.md
LEGAL.md
CLAUDE.md
CHANGELOG.md
.gitignore
gitleaks-config.toml
```

---

## Next Steps

1. **Confirm this architecture** — approve farmOS strategy, Docker compose structure, module layout
2. **Provide:** Brand colors (hex), logo (PNG/SVG), farm name, coordinates
3. **Phase 1 implementation:**
   - Finalize farmOS v4 image tag
   - Build docker-compose files
   - Create install profile & theme
   - Seed test data
   - Push to GitHub (private repo)
4. **Phase 1 validation** on laptop at `127.0.0.1:8080`
5. **Deploy to lab** VM after approval
