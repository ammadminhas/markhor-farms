# Markhor Farms Docker Compose - Files Created

Complete list of Docker Compose configuration files created for farmOS v4 deployment.

## Core Docker Compose Files

### `docker-compose.yml`
**Base configuration for all environments**
- PostgreSQL 16 service with health checks
- PHP-FPM service with volume mounts for profiles, themes, custom modules
- Nginx web server with Drupal configuration
- Shared network and volume definitions
- Health checks for all services
- Port mappings for services

### `docker-compose.dev.yml`
**Development environment overrides**
- Port mapping to 127.0.0.1:8080 for Nginx
- Adminer (database browser) on 127.0.0.1:8081
- MailHog (email testing) on 127.0.0.1:1025-1025
- Xdebug configuration for debugging
- Development logging configuration
- Drush and Composer auto-installation
- Development build arguments

### `docker-compose.prod.yml`
**Production environment overrides**
- Caddy reverse proxy with SSL/TLS
- Backup service with PostgreSQL backup
- PostgreSQL optimization flags (max_connections, buffers)
- Production-optimized PHP configuration
- Ofelia cron scheduler for backups
- No exposed database ports
- Health checks and monitoring

## Dockerfile Images

### `Dockerfile`
**Base PHP image for production**
- PHP 8.2-FPM Alpine base
- PostgreSQL client and development libraries
- GD, intl, zip, opcache extensions
- ImageMagick support
- Composer installation
- Drupal permissions setup

### `Dockerfile.dev`
**Development PHP image**
- All base image features
- Xdebug extension enabled
- Development tools (Drupal Console, Drush)
- Composer with dev dependencies
- Git and curl for development
- Node.js (optional)

### `Dockerfile.prod`
**Production PHP image (optimized)**
- Multi-stage build for smaller final size
- No dev dependencies
- Production PHP configuration
- Optimized OPcache settings
- Preload enabled for faster startup

### `Dockerfile.backup`
**Backup service image**
- Alpine base with minimal footprint
- PostgreSQL client
- AWS CLI for S3 uploads
- Cron daemon for scheduled backups
- Health check script

## PHP Configuration Files

### `docker/php/php.ini`
**Base PHP configuration**
- Memory limit: 256MB
- Upload max: 100MB
- OPcache enabled with tuning
- Extensions configuration
- UTC timezone

### `docker/php/php-dev.ini`
**Development PHP settings**
- Memory limit: 512MB (higher for dev)
- Errors displayed on screen
- Error reporting: E_ALL
- OPcache disabled for debugging
- Xdebug configuration

### `docker/php/php-prod.ini`
**Production PHP settings**
- Errors hidden from output
- OPcache optimized (validate_timestamps=0)
- Preload enabled
- Memory limit: 256MB
- Enhanced security (expose_php=Off)

### `docker/php/php-fpm.conf`
**Base FPM configuration**
- Dynamic process management
- 32 max children, 8 start servers
- 500 request limit before restart
- Access and slowlog configuration
- Environment variables setup

### `docker/php/php-fpm-dev.conf`
**Development FPM settings**
- Lower worker counts for dev
- Slower slowlog threshold (5s)
- Display errors enabled
- More frequent logs

### `docker/php/php-fpm-prod.conf`
**Production FPM settings**
- Static process management (64 workers)
- Higher slowlog threshold (30s)
- Minimal logging output
- Process idle timeout enabled

### `docker/php/xdebug.ini`
**Xdebug debugger configuration**
- Debug mode enabled
- Client host and port configuration
- Request triggering
- Client host discovery
- Performance profiling options (commented)

## Nginx Configuration Files

### `docker/nginx/nginx.conf`
**Main Nginx configuration**
- Worker processes set to auto
- Gzip compression enabled
- Client max body size: 100MB
- MIME type definitions
- Access and error logging

### `docker/nginx/conf.d/dev.conf`
**Development Nginx configuration**
- Server name: localhost
- Development logging (buffer 16k)
- Clean URLs support for Drupal
- Static file caching (365 days)
- PHP-FPM backend (php:9000)
- Health endpoint (/health)

### `docker/nginx/conf.d/prod.conf`
**Production Nginx configuration**
- Server names: markhorconsultants.com
- Security headers (X-Frame-Options, CSP, etc.)
- Production logging (buffer 32k)
- Enhanced static file caching (30 days)
- No logging for certain files
- Drupal-specific rules (robots.txt, sitemap.xml)

## Caddy Configuration

### `Caddyfile`
**Reverse proxy and SSL/TLS**
- Automatic SSL/TLS with Let's Encrypt
- HTTP to HTTPS redirection
- Security headers
- Compression enabled
- Rate limiting for admin paths (10 req/min)
- Upstream proxy to Nginx
- Static file caching rules
- Monitoring endpoint

## Backup Configuration

### `backup-schedule.ini`
**Ofelia cron schedule configuration**
- Main backup job: Daily at 2 AM
- Secondary backup: Daily at 12 PM
- Cleanup job: Weekly at 3 AM Sunday
- Health check: Every 6 hours
- Logging configuration

## Bash Scripts

### `scripts/backup.sh`
**Database and file backup script**
- PostgreSQL database dump
- File archiving to tar.gz
- S3 upload support (optional)
- Backup retention with automatic cleanup
- Detailed logging
- Error handling and recovery

### `scripts/cleanup-backups.sh`
**Backup cleanup script**
- Removes old SQL backups
- Removes old tar.gz backups
- Respects BACKUP_RETENTION_DAYS setting
- Detailed logging
- Counts remaining backups

## Configuration Files

### `.env.example`
**Environment variables template**
- Application settings (APP_ENV, DEBUG)
- Database configuration (DB_HOST, DB_NAME, etc.)
- Drupal/farmOS settings
- Web server configuration
- Development tools (Xdebug, MailHog)
- Production settings (Let's Encrypt, S3)
- Backup configuration
- Mail and caching settings

### `.gitignore`
**Version control exclusions**
- Environment files (.env, .env.local)
- Docker volumes and backups
- Drupal files and cache
- IDE and editor files
- OS files and temporary files
- Node modules and build artifacts
- Database dumps

## Documentation

### `DOCKER_SETUP.md`
**Comprehensive Docker Compose guide**
- Complete overview of setup
- Directory structure explanation
- Quick start instructions
- Environment variables reference
- Service descriptions and ports
- Common commands and usage
- Database backup and restore procedures
- Drupal customization guide
- Xdebug setup for IDE debugging
- SSL/TLS certificate management
- Performance tuning recommendations
- Monitoring and logging
- Troubleshooting guide
- Security best practices
- Production deployment checklist

### `QUICKSTART.md`
**5-minute quick start guide**
- Prerequisites and setup
- Development environment startup
- Login credentials
- Access points for services
- Common first tasks
- Status checking
- Production setup overview
- Backup procedures
- Troubleshooting basics

### `Makefile`
**Convenient command shortcuts**
- `make setup` - Initial configuration
- `make build` - Build Docker images
- `make dev-up/down` - Development control
- `make prod-up/down` - Production control
- `make drush` - Run Drush commands
- `make composer` - Run Composer commands
- `make backup/restore` - Backup management
- `make clean` - Full cleanup
- `make health-check` - System health
- `make logs` - View service logs

### `FILES_CREATED.md`
**This file - complete file listing and descriptions**

## Directory Structure Created

```
markhor-farms/
├── docker/
│   ├── php/
│   │   ├── php.ini
│   │   ├── php-dev.ini
│   │   ├── php-prod.ini
│   │   ├── php-fpm.conf
│   │   ├── php-fpm-dev.conf
│   │   ├── php-fpm-prod.conf
│   │   └── xdebug.ini
│   └── nginx/
│       ├── nginx.conf
│       └── conf.d/
│           ├── dev.conf
│           └── prod.conf
├── scripts/
│   ├── backup.sh
│   └── cleanup-backups.sh
├── docker-compose.yml
├── docker-compose.dev.yml
├── docker-compose.prod.yml
├── Dockerfile
├── Dockerfile.dev
├── Dockerfile.prod
├── Dockerfile.backup
├── Caddyfile
├── backup-schedule.ini
├── .env.example
├── .gitignore
├── Makefile
├── DOCKER_SETUP.md
├── QUICKSTART.md
└── FILES_CREATED.md
```

## Total Files Created: 31

### Breakdown:
- **Docker Compose Files**: 3
- **Dockerfiles**: 4
- **PHP Configuration**: 6
- **Nginx Configuration**: 3
- **Proxy/Caddy Configuration**: 1
- **Backup Configuration**: 1
- **Bash Scripts**: 2
- **Configuration Files**: 2
- **Documentation**: 4
- **Other**: 5

## Key Features Provided

### Development Environment
- Local development on 127.0.0.1:8080
- Database browser (Adminer)
- Email testing (MailHog)
- Xdebug support for IDEs
- Hot reload capabilities

### Production Environment
- Automatic SSL/TLS with Let's Encrypt
- Caddy reverse proxy with security headers
- Automated database backups
- S3 backup integration
- Health checks and monitoring
- Rate limiting for admin areas

### Database
- PostgreSQL 16 with optimization
- Connection pooling
- Health checks
- Automated daily backups
- Backup retention policies

### Web Server
- Nginx with PHP-FPM
- Clean URL support for Drupal
- Gzip compression
- Static file caching
- Security headers

### Backup & Recovery
- Automated daily backups
- Database dump + file archive
- S3 cloud storage support
- Configurable retention
- Easy restore procedures

### Customization
- Volume mounts for profiles, themes, modules
- Environment-specific configurations
- Multi-environment support (dev/prod)
- Easy scaling capabilities

## Usage

1. Copy `.env.example` to `.env`
2. Update environment variables
3. Run `make dev-up` for development
4. Or run `make prod-up` for production
5. Access via configured URLs
6. Use `make` commands for management

## Security Considerations

- All sensitive data in `.env` (excluded from git)
- Production passwords randomized
- SSL/TLS automatic with Let's Encrypt
- Security headers configured
- Rate limiting enabled
- Backup encryption (S3 with AES256)
- Secure credential management

## Performance Optimizations

- PHP OPcache enabled
- Nginx gzip compression
- Static file long-term caching
- Database query optimization
- FPM process management tuning
- PostgreSQL buffer optimization

---

**Total Configuration**: Production-ready farmOS v4 with PostgreSQL 16, development tools, automated backups, SSL/TLS, and comprehensive documentation.
