# Changelog

All notable changes to Markhor Farms are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Planned
- Phase 2: Livestock Management module
- Phase 3: Crop & Land Management module
- Phase 4: Reports & Analytics dashboard
- Phase 5: Mobile app and integrations
- Redis caching for production
- Multi-farm support

---

## [0.1.0] - 2026-09-25

### Added

#### Infrastructure & Deployment
- Docker Compose setup with multi-environment support (dev, prod, lab)
- Development environment with Nginx, PHP-FPM, PostgreSQL
- Production environment with Caddy reverse proxy and SSL/TLS
- Docker multi-stage builds for optimized images
  - `Dockerfile` - Production image (minimal, 500MB)
  - `Dockerfile.dev` - Development image with debugging tools
  - `Dockerfile.prod` - Production-optimized image
  - `Dockerfile.backup` - Backup utility image
- Makefile with 20+ targets for common operations
  - Setup: `make setup`, `make build`
  - Development: `make dev-up`, `make dev-down`, `make dev-logs`, `make dev-install`
  - Production: `make prod-up`, `make prod-down`, `make prod-logs`
  - Management: `make backup`, `make restore`, `make clean`, `make health-check`
  - Quick start: `make up`, `make down`, `make logs`, `make shell`, `make reset`, `make test`, `make deploy-lab`
- Backup & restore automation
  - Automated daily backups with configurable retention
  - `scripts/backup.sh` - Database and file backup script
  - `scripts/restore.sh` - Restore from backup files
  - Scheduled backups via cron (see `backup-schedule.ini`)
- Database persistence with PostgreSQL 15
- Caddy web server with automatic SSL/TLS
- Health check endpoint and monitoring

#### Core Application
- farmOS 2.x base installation (Drupal 10)
- Base data model for agricultural operations
  - Node-based entity model (compatible with farmOS)
  - Taxonomy for livestock breeds, crop types, equipment categories
  - Log system for activity tracking
  - Geometry/GIS support for field mapping
- Database schema ready for livestock and crop data
- Multi-locale support (English, Urdu - ready for customization)

#### Configuration & Secrets Management
- `.env.example` template with all required variables
  - Database credentials
  - Drupal admin credentials
  - Web server configuration (domain, email for SSL)
  - Backup settings
- Environment-specific configurations
  - `docker-compose.yml` - Base services
  - `docker-compose.dev.yml` - Development overrides (Adminer, MailHog, port mappings)
  - `docker-compose.prod.yml` - Production settings (Caddy, optimizations)
- No secrets committed to repository

#### Documentation
- `README.md` - Project overview, quick start, phases, tech stack
- `CLAUDE.md` - Development guidelines for AI assistants and developers
- `LEGAL.md` - GPL-2.0+ license and attribution requirements
- `DOCKER_SETUP.md` - Detailed Docker configuration guide
- `QUICKSTART.md` - 5-minute getting started guide
- `DEPLOYMENT_CHECKLIST.md` - Pre-deployment verification steps
- `FILES_CREATED.md` - Complete file listing and descriptions

#### Security & Compliance
- Git secret detection via gitleaks
  - `gitleaks-config.toml` - Rules for detecting passwords, API keys, tokens
  - Runs pre-commit to prevent accidental secret commits
- `.gitignore` with comprehensive exclusions
  - Secrets (`.env`, credentials)
  - Build artifacts and caches
  - IDE and OS files
  - Docker volumes and backups
  - Generated files (vendor, node_modules)
- HTTPS/TLS ready (Caddy auto-provisioning)
- PostgreSQL running in container (not exposed to host by default)
- PHP running as non-root user
- Drupal security headers configured

#### Development Tools
- Drush CLI integration (`make drush CMD="..."`)
- Composer package manager integration (`make composer CMD="..."`)
- Direct container access (`make exec CMD="..."`)
- Database shell access (`make db-shell`)
- PHP shell access (`make php-shell`)
- Adminer database UI (dev environment)
- MailHog email testing (dev environment)

#### Testing Infrastructure
- PHPUnit test framework configured
- Test directory structure (`tests/`)
- `make test` target for running test suite
- Ready for unit, integration, and functional tests

#### Operational Scripts
- `scripts/backup.sh` - Database and file backup automation
- `scripts/restore.sh` - Database restore from backups
- Health check mechanisms
- Log rotation support

### Changed
- N/A (initial release)

### Deprecated
- N/A (initial release)

### Removed
- N/A (initial release)

### Fixed
- N/A (initial release)

### Security
- All secrets excluded from git via `.gitignore`
- Gitleaks configuration to detect accidental secret commits
- No hardcoded credentials in any files
- Environment-based configuration for all sensitive settings
- PostgreSQL requires authentication (not accessible from host)
- PHP-FPM runs as non-root user
- TLS/HTTPS ready for production

---

## Migration Notes

### From Previous Versions
- N/A (first release)

### Upgrade Instructions
- N/A (first release)

### Breaking Changes
- N/A (first release)

---

## Version 0.1.0 Status

**Release Date:** September 25, 2026  
**Status:** Beta / Pre-Release  
**Stability:** Development

### Known Issues
- Phase 2-5 features not yet implemented
- Custom livestock/crop modules to be developed
- Analytics and reporting dashboard pending
- Mobile application in planning phase
- Multi-farm support not yet implemented

### Next Steps
1. **Phase 2 Development** - Livestock tracking module
   - Cattle breed management (Neeli Ravi, Sahiwal, Cholistani)
   - Genealogy and lineage tracking
   - Health and vaccination records
   - Weight and growth tracking
   - Market value tracking

2. **Phase 3 Development** - Crop & Land management
   - Field mapping and crop rotation
   - Planting and harvest workflows
   - Equipment inventory
   - Input tracking

3. **Phase 4 Development** - Reporting & Analytics
   - Dashboards for livestock and crops
   - Financial analysis
   - Seasonal trends
   - Custom report builder

4. **Phase 5 Development** - Mobile & Integration
   - React Native or Flutter mobile app
   - IoT sensor integration
   - Third-party API integrations
   - Multi-farm management

---

## How to Report Issues

Found a bug or want to suggest a feature?

1. Check [existing issues](https://github.com/markhorconsultants/markhor-farms/issues)
2. Create a new issue with:
   - Clear description of the problem
   - Steps to reproduce (if applicable)
   - Expected vs. actual behavior
   - Environment details (OS, Docker version, etc.)
3. For security issues, email: admin@markhorconsultants.com

---

## Contributors

### Version 0.1.0
- **Author:** Ammad Admin-Hafiz
- **Role:** Project Lead & Developer
- **Contact:** admin@markhorconsultants.com

### Special Thanks
- **farmOS Community** - Open-source farm management platform
- **Drupal Community** - Powerful web framework
- **Docker Community** - Container orchestration

---

## Resources

- [Official farmOS Documentation](https://farmos.org/)
- [Drupal 10 Documentation](https://www.drupal.org/docs/drupal-10)
- [Keep a Changelog](https://keepachangelog.com/)
- [Semantic Versioning](https://semver.org/)
- [Markhor Farms GitHub](https://github.com/markhorconsultants/markhor-farms)

---

**Last Updated:** September 25, 2026  
**Changelog Format Version:** 1.0
