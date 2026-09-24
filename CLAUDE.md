# CLAUDE.md - Markhor Farms Development Guide

This file provides context and guidelines for Claude Code and AI assistants working on Markhor Farms.

---

## Project Overview

**Project Name:** Markhor Farms  
**Owner:** Ammad Admin-Hafiz (admin@markhorconsultants.com)  
**Location:** 31°24'22.5"N 74°08'07.7"E (Punjab, Pakistan)  
**Business:** Agricultural consulting & farm management  
**Tech Stack:** farmOS (Drupal), Docker, PostgreSQL, Nginx/Caddy  

### Assets & Livestock

The farm manages:
- **Livestock:** Neeli Ravi cattle (2 adults, 2 calves female), Sahiwal-Cholistani mix (female adult + male calf), mixed cattle/calves
- **Crops:** Maize (makki) - recently harvested from 2 acres
- **Land:** 2 acres rental farmland + rental equipment (carts, lights, fans)
- **Infrastructure:** Goat herds, farm buildings, equipment inventory

---

## Codebase Structure

```
markhor-farms/
├── README.md                 # Quick start & project overview
├── LEGAL.md                  # GPL-2.0+ license & attribution
├── CLAUDE.md                 # This file
├── CHANGELOG.md              # Version history
├── Makefile                  # Development commands
├── docker-compose.yml        # Base Docker setup
├── docker-compose.dev.yml    # Development overrides
├── docker-compose.prod.yml   # Production overrides
├── Dockerfile*               # Container images
├── web/                      # Drupal/farmOS root
│   ├── modules/custom/       # Custom modules (livestock, crops, etc)
│   ├── themes/custom/        # Custom themes for regional UX
│   └── sites/default/        # Configuration
├── docker/                   # Docker build artifacts
├── scripts/                  # Operational scripts (backup, restore, etc)
├── tests/                    # PHPUnit & integration tests
└── docs/                     # Documentation
    ├── DOCKER_SETUP.md
    ├── QUICKSTART.md
    ├── DEPLOYMENT_CHECKLIST.md
    └── FILES_CREATED.md
```

---

## Development Workflow

### Environment Setup

```bash
# Initial setup
make setup               # Create .env from .env.example
make dev-up             # Start development environment
make dev-install        # Install Drupal & farmOS

# Daily development
make dev-logs           # Watch logs
make shell              # Access PHP shell
make drush CMD="..."    # Run Drush commands
make composer CMD="..." # Run Composer commands
```

### Key Technologies

| Component | Purpose | Command |
|-----------|---------|---------|
| **Drupal 10** | CMS & framework | `make drush CMD="..."` |
| **farmOS 2.x** | Farm management | farmOS modules in `web/modules/` |
| **PostgreSQL** | Database | `make db-shell` |
| **Docker** | Containers | `docker-compose ...` |
| **PHPUnit** | Testing | `make test` |

### Database Access

```bash
# PostgreSQL shell
make db-shell

# Run SQL queries
docker-compose exec postgres psql -U farmos -d farmos -c "SELECT * FROM node;"

# Backup
make backup

# Restore
make restore FILE=backups/farmos_db_YYYYMMDD_HHMMSS.sql
```

---

## Module Development

### Custom Modules

Custom modules for livestock and crop management should be placed in:

```
web/modules/custom/
├── farm_livestock_custom/    # Livestock tracking enhancements
├── farm_crop_custom/         # Crop management customizations
├── farm_land_custom/         # Land & field tracking
└── farm_integration/         # Regional integrations
```

### Module Template

```php
<?php
// web/modules/custom/my_module/my_module.module

/**
 * @file
 * Custom Markhor Farms module.
 */

/**
 * Implements hook_entity_form_alter().
 */
function my_module_entity_form_alter(&$form, &$form_state, $form_id) {
  // Add custom fields or logic for livestock/crops
}
```

### Testing Modules

```bash
# Test a specific module
make exec CMD="./vendor/bin/phpunit tests/Modules/MyModule/"

# Test all
make test
```

---

## Coding Standards

### PHP

- Follow [PSR-12](https://www.php-fig.org/psr/psr-12/) (Extended Coding Style)
- Use strict types: `declare(strict_types=1);`
- Document with PHPDoc comments
- Use Drupal code standards for hooks

```php
<?php
declare(strict_types=1);

namespace Drupal\my_module\Controller;

/**
 * Controller for livestock operations.
 */
class LivestockController {
  /**
   * Load livestock by ID.
   *
   * @param int $id
   *   The livestock ID.
   *
   * @return \Drupal\node\NodeInterface
   *   The livestock node.
   */
  public function load(int $id) {
    return \Drupal::entityTypeManager()
      ->getStorage('node')
      ->load($id);
  }
}
```

### YAML Configuration

- Use 2-space indentation
- Clear, descriptive keys
- Document with comments

```yaml
# web/modules/custom/farm_livestock_custom/farm_livestock_custom.info.yml
name: Livestock Custom
description: Custom livestock tracking for Markhor Farms
type: module
core_version_requirement: ^10.0
dependencies:
  - farm:farm_livestock
  - drupal:node
```

### Database Queries

- Use Drupal's entity query API (not raw SQL when possible)
- Use prepared statements for any SQL

```php
// Good
$query = \Drupal::entityQuery('node')
  ->condition('type', 'livestock_record')
  ->condition('status', 1);

// Bad - avoid direct SQL
// $result = db_query("SELECT * FROM node WHERE type = 'livestock'");
```

---

## Git Workflow

### Commit Messages

Follow conventional commits:

```
type(scope): description

body (optional)

footer (optional)
```

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Examples:**

```
feat(livestock): add genealogy tracking for cattle breeds

This adds parent-child relationship tracking for Neeli Ravi
and Sahiwal cattle lineage.

Closes #42
```

```
fix(crop): correct harvest date validation

Ensures maize crop harvests are recorded on valid dates.
```

### Branches

- `main` - Production releases (tagged)
- `develop` - Integration branch (always deployable)
- `feature/` - Feature branches (e.g., `feature/livestock-health`)
- `hotfix/` - Emergency fixes
- `docs/` - Documentation updates

### Pull Request Template

Use the standard GitHub PR template. Include:
- Description of changes
- Related issues (#42)
- Testing instructions
- Screenshots (if UI changes)

---

## Security Considerations

### Sensitive Data

**Never commit:**
- `.env` files (use `.env.example`)
- Database credentials
- API keys or tokens
- Private keys or certificates

**Use environment variables:**

```php
// Good
$db_password = $_ENV['POSTGRES_PASSWORD'];

// Bad - hardcoded
// $db_password = 'changeme';
```

### Access Control

Implement proper Drupal permissions for:
- Admin operations (create/edit livestock)
- Field worker operations (log activities)
- Viewer-only access (reports)

```php
function my_module_permission() {
  return [
    'administer livestock' => [
      'title' => t('Administer livestock'),
      'restrict access' => TRUE,
    ],
    'edit livestock records' => [
      'title' => t('Edit livestock records'),
    ],
  ];
}
```

### Backup & Recovery

- Backups run daily (see `scripts/backup.sh`)
- Restore procedure documented in `DOCKER_SETUP.md`
- Test restores monthly
- Keep backups in secure location (not in git)

---

## Deployment

### Local Development

```bash
make dev-up
make dev-install
# http://127.0.0.1:8080
```

### Staging/Lab

```bash
make deploy-lab
# Requires custom configuration
```

### Production

```bash
# Build production image
docker build -f Dockerfile -t markhorconsultants/farmos:latest .

# Deploy
make prod-up

# Verify
make health-check
```

### Health Checks

```bash
make health-check
# Checks: PostgreSQL, PHP-FPM, Nginx
```

---

## Documentation

### Required for New Features

1. **Code comments** - Explain non-obvious logic
2. **Commit messages** - Clear history
3. **PR description** - Why the change?
4. **CHANGELOG.md** - User-facing changes
5. **README.md** - Update if architectural changes

### Documentation Files

- `README.md` - Quick start, overview
- `DOCKER_SETUP.md` - Docker configuration details
- `QUICKSTART.md` - Getting started in 5 minutes
- `DEPLOYMENT_CHECKLIST.md` - Pre-deployment tasks
- `LEGAL.md` - License and attribution
- `CHANGELOG.md` - Version history

---

## Troubleshooting

### Container Issues

```bash
# View logs
make logs

# Rebuild containers
docker-compose build --no-cache

# Reset environment
make reset
```

### Database Connection

```bash
# Check PostgreSQL status
make exec CMD="pg_isready -h postgres -U farmos"

# Access database shell
make db-shell

# Check Drupal database connection
make drush CMD="status"
```

### PHP/Drupal Issues

```bash
# Clear caches
make drush CMD="cache:rebuild"

# Check installed modules
make drush CMD="pm:list --type=module --status=enabled"

# View recent errors
make drush CMD="watchdog:list"
```

---

## Performance Optimization

### Caching

Enable Redis for production (configured in `docker-compose.prod.yml`):

```php
// Enable in settings.php
$settings['redis.interface'] = 'PhpRedis';
$settings['cache.default'] = 'cache.backend.redis';
```

### Database

- Index frequently queried fields
- Archive old log entries
- Optimize PostgreSQL settings in `docker-compose.yml`

### Drupal

```bash
# Enable aggregation
make drush CMD="config:set system.performance css.preprocess 1"
make drush CMD="config:set system.performance js.preprocess 1"

# Use CDN for static assets (if available)
```

---

## Related Infrastructure

Markhor Farms is part of a larger infrastructure ecosystem:

- **Ammad Fort Homelab** - Local development & testing
- **CodeMarkhor Maryland Cluster** - Production infrastructure (Proxmox)
- **Lahore Network** - Pakistan site (UniFi, NetBird VPN)
- **Infrastructure Brain** - Central documentation (see memory)

For infrastructure changes or VPS access, reference:
- [Infrastructure Brain](../../../nimbus/INFRASTRUCTURE_BRAIN.md)
- [Claude Management Guide](../../../nimbus/CLAUDE_MANAGEMENT_GUIDE.md)
- [Digital Access Master](../../../nimbus/02-INFRASTRUCTURE/DIGITAL_ACCESS_MASTER.md)

---

## Quick Reference

```bash
# Most common commands
make help              # Show all commands
make setup             # Initial setup
make dev-up            # Start environment
make dev-logs          # Watch logs
make shell             # PHP shell
make test              # Run tests
make backup            # Create backup
make reset             # Reset (dev only)
make clean             # Remove containers
```

---

## Contact & Questions

- **Project Owner:** Ammad Admin-Hafiz
- **Email:** admin@markhorconsultants.com
- **Location:** markhor-farms repository
- **Infrastructure Docs:** See MEMORY.md for shared infrastructure guides

---

**Last Updated:** September 25, 2026  
**Version:** 1.0
