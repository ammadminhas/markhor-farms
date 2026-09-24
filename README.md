# Markhor Farms - farmOS Management System

A comprehensive farm management and tracking system built on **farmOS** (Drupal-based) for livestock, crops, and agricultural operations management at Markhor Consultants.

**Location:** Punjab, Pakistan (31°24'22.5"N 74°08'07.7"E)  
**License:** [GPL-2.0+](./LEGAL.md) | [Attribution](./LEGAL.md)

---

## Project Description

Markhor Farms provides a unified platform for:

- **Livestock Management** - Track cattle breeds (Neeli Ravi, Sahiwal, Cholistani), calves, and mixed herd operations
- **Crop Management** - Document cultivation, harvesting, and seasonal crops (maize, etc.)
- **Land Operations** - Monitor rental properties, resource allocation, and equipment inventory
- **Farm Data** - Comprehensive farm records, audit trails, and operational insights

The system integrates **farmOS** (an open-source farm management platform built on Drupal) with custom modules for regional agricultural practices.

---

## Quick Start

### Prerequisites

- Docker & Docker Compose
- Git
- Make (optional, but recommended)
- 4GB+ RAM, 10GB+ disk space

### Setup (5 minutes)

```bash
# Clone and enter project
git clone https://github.com/markhorconsultants/markhor-farms.git
cd markhor-farms

# Copy environment file
make setup
# (or: cp .env.example .env)

# Start development environment
make dev-up

# Install Drupal & farmOS
make dev-install

# Access the application
# Application:  http://127.0.0.1:8080
# Admin login:  admin / changeme
```

### Common Commands

```bash
make up              # Start services
make down            # Stop services
make logs            # View logs (follow mode)
make shell           # Access PHP container shell
make reset           # Reset database (dev only)
make backup          # Create database backup
make test            # Run test suite
make help            # Show all available commands
```

---

## Project Phases

### Phase 1: Core Setup ✓
- [x] Docker infrastructure (Compose, multi-stage builds)
- [x] farmOS base installation (Drupal 10 + farmOS modules)
- [x] Database setup (PostgreSQL)
- [x] Web server configuration (Nginx, Caddy)
- [x] Development & Production environments
- [x] Backup & restore procedures

### Phase 2: Livestock Management
- [ ] Custom livestock module (breeds, genealogy, health records)
- [ ] Animal movement tracking
- [ ] Breeding records and timeline
- [ ] Health monitoring (vaccinations, treatments, feed)
- [ ] Economic metrics (weight, market value)

### Phase 3: Crop & Land Management
- [ ] Field mapping and crop rotation
- [ ] Planting, growing, harvesting workflows
- [ ] Equipment inventory & maintenance
- [ ] Input tracking (seeds, fertilizers, pesticides)
- [ ] Yield analytics

### Phase 4: Reports & Analytics
- [ ] Custom dashboards for livestock and crops
- [ ] Herd health and productivity reports
- [ ] Financial & cost analysis
- [ ] Seasonal trends and forecasting
- [ ] Export capabilities (PDF, Excel, CSV)

### Phase 5: Integration & Scaling
- [ ] Mobile app for field workers
- [ ] IoT sensor integration (optional)
- [ ] Multi-farm support
- [ ] User roles and access control
- [ ] API for third-party integrations

---

## Architecture

### Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **CMS/Framework** | Drupal 10 | Content management & extensibility |
| **Farm Module** | farmOS 2.x | Farm management core |
| **Database** | PostgreSQL 15+ | Reliable data persistence |
| **Web Server** | Nginx / Caddy | HTTP serving & reverse proxy |
| **Cache** | Redis (optional) | Performance optimization |
| **Containerization** | Docker Compose | Environment consistency |
| **Backup** | Custom scripts | Automated database/file backups |

### Directory Structure

```
markhor-farms/
├── web/                          # Drupal root (web-accessible)
│   ├── modules/custom/           # Custom farmOS modules
│   ├── themes/custom/            # Custom themes
│   └── sites/default/            # Drupal configuration
├── docker/                       # Docker build files
│   ├── Dockerfile*               # Container definitions
│   ├── php/                      # PHP configuration
│   └── nginx/                    # Nginx configuration
├── scripts/                      # Operational scripts
│   ├── backup.sh                 # Backup automation
│   └── restore.sh                # Restore automation
├── compose/                      # Docker Compose overlays
│   ├── dev.yml                   # Development services
│   └── prod.yml                  # Production services
├── docs/                         # Documentation
├── tests/                        # Test suites
├── docker-compose.yml            # Base composition
├── docker-compose.dev.yml        # Dev overrides
├── docker-compose.prod.yml       # Prod overrides
├── Dockerfile                    # Production image
├── Dockerfile.dev                # Development image
├── Makefile                      # Development commands
├── CLAUDE.md                     # Development guidelines
├── LEGAL.md                      # License & attribution
├── CHANGELOG.md                  # Version history
└── README.md                     # This file
```

---

## Development Workflow

### Development Environment

```bash
# Start with code hot-reload
make dev-up

# View logs
make dev-logs

# Run shell commands
make exec CMD="drush status"
make composer CMD="install"
make drush CMD="cache:rebuild"

# Database access
make db-shell
```

### Testing

```bash
# Run full test suite
make test

# Run specific tests
make exec CMD="./vendor/bin/phpunit tests/Modules/Livestock/"
```

### Database Management

```bash
# Create backup
make backup

# Restore from backup
make restore FILE=backups/farmos_db_20250925_120000.sql

# Manual database shell
make db-shell
```

### Production Deployment

```bash
# Start production environment
make prod-up

# Monitor logs
make prod-logs

# Perform health check
make health-check
```

---

## Configuration

### Environment Variables

Copy `.env.example` to `.env` and configure:

```env
# Database
POSTGRES_DB=farmos
POSTGRES_USER=farmos
POSTGRES_PASSWORD=<secure_password>

# Drupal
DRUPAL_ADMIN_EMAIL=admin@markhorconsultants.com
DRUPAL_ADMIN_PASSWORD=<secure_password>
DRUPAL_SITE_NAME=Markhor Farms
DRUPAL_BASE_URL=http://127.0.0.1:8080

# Web Server
CADDY_DOMAIN=markhorconsultants.com
CADDY_EMAIL=admin@markhorconsultants.com

# Backup
BACKUP_SCHEDULE=daily
BACKUP_RETENTION_DAYS=30
```

### Drupal Configuration

Key modules to enable:

- **farm_livestock** - Livestock management
- **farm_crop** - Crop management
- **farm_land** - Land & field management
- **farm_equipment** - Equipment tracking
- **farm_group** - Grouping and taxonomy
- **farm_log** - Activity logging
- **farm_map** - Geospatial features

---

## Support & Documentation

- [Docker Setup Guide](./DOCKER_SETUP.md)
- [Quick Start Guide](./QUICKSTART.md)
- [Deployment Checklist](./DEPLOYMENT_CHECKLIST.md)
- [Changelog](./CHANGELOG.md)
- [Contributing Guidelines](./CONTRIBUTING.md)
- [Official farmOS Documentation](https://farmos.org/)

---

## License

This project is licensed under **GPL-2.0 or later**. See [LEGAL.md](./LEGAL.md) for:
- Full GPL-2.0+ license text
- Attribution requirements for farmOS and Drupal
- Third-party component credits

---

## Contact & Support

- **Project Lead:** Ammad Admin-Hafiz  
- **Email:** admin@markhorconsultants.com  
- **Website:** markhorconsultants.com  
- **Location:** 31°24'22.5"N 74°08'07.7"E (Punjab, Pakistan)

---

**Last Updated:** September 25, 2026  
**Version:** 0.1.0 (Beta)
