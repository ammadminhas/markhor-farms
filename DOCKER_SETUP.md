# Markhor Farms - Docker Compose Setup

Complete Docker Compose configuration for farmOS v4 deployment with PostgreSQL 16, development and production environments.

## Overview

This Docker Compose setup provides:
- **farmOS v4** with Drupal 10
- **PostgreSQL 16** for database
- **Nginx** web server with PHP-FPM
- **Caddy** reverse proxy (production)
- **Automated backups** with S3 support
- **Development tools**: Xdebug, Adminer, MailHog
- **Health checks** and monitoring

## Directory Structure

```
markhor-farms/
├── docker-compose.yml           # Base configuration
├── docker-compose.dev.yml       # Development overrides
├── docker-compose.prod.yml      # Production overrides
├── .env.example                 # Environment template
├── Dockerfile                   # Base PHP image
├── Dockerfile.dev               # Development PHP image
├── Dockerfile.prod              # Production PHP image (optimized)
├── Dockerfile.backup            # Backup service image
├── Caddyfile                    # Caddy reverse proxy config
├── backup-schedule.ini          # Backup cron schedule
├── docker/
│   ├── php/
│   │   ├── php.ini              # Base PHP configuration
│   │   ├── php-dev.ini          # Development PHP settings
│   │   ├── php-prod.ini         # Production PHP settings
│   │   ├── php-fpm.conf         # Base FPM configuration
│   │   ├── php-fpm-dev.conf     # Development FPM settings
│   │   ├── php-fpm-prod.conf    # Production FPM settings
│   │   └── xdebug.ini           # Xdebug configuration
│   └── nginx/
│       ├── nginx.conf           # Nginx main config
│       └── conf.d/
│           ├── dev.conf         # Development server config
│           └── prod.conf        # Production server config
├── scripts/
│   ├── backup.sh                # Database & files backup script
│   └── cleanup-backups.sh       # Old backup cleanup
├── web/                         # Drupal web root (generated)
├── profiles/                    # Custom Drupal profiles
├── themes/                      # Custom Drupal themes
└── modules/
    └── custom/                  # Custom Drupal modules
```

## Quick Start

### 1. Clone and Setup

```bash
git clone <repository> markhor-farms
cd markhor-farms

# Copy environment file
cp .env.example .env

# Edit .env with your settings
nano .env
```

### 2. Development Environment

```bash
# Start services
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# Run Drupal installation
docker-compose exec php drush site:install farmos -y

# Access application
open http://127.0.0.1:8080

# Database admin (Adminer)
open http://127.0.0.1:8081

# Mail interface (MailHog)
open http://127.0.0.1:8025
```

### 3. Production Environment

```bash
# Start services
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Initial setup
docker-compose exec php drush site:install farmos -y

# Verify SSL certificate (Caddy)
docker-compose logs caddy | grep -i tls

# Access application
open https://markhorconsultants.com
```

## Environment Variables

See `.env.example` for all available options:

| Variable | Default | Description |
|----------|---------|-------------|
| `APP_ENV` | development | Application environment (development/production) |
| `DEBUG` | true | Enable debug mode |
| `DB_NAME` | farmos | PostgreSQL database name |
| `DB_USER` | farmos | PostgreSQL username |
| `DB_PASSWORD` | changeme | PostgreSQL password |
| `FARMOS_SITE_NAME` | Markhor Farms | Site display name |
| `FARMOS_ADMIN_USER` | admin | Admin username |
| `FARMOS_ADMIN_PASSWORD` | changeme | Admin password |
| `HASH_SALT` | random-hash | Drupal hash salt (set to random value) |
| `S3_BUCKET` | | AWS S3 bucket for backups |
| `S3_ACCESS_KEY` | | AWS access key |
| `S3_SECRET_KEY` | | AWS secret key |
| `BACKUP_RETENTION_DAYS` | 30 | Days to retain backups |

## Services

### PostgreSQL 16
- **Port**: 5432
- **Volume**: `postgres_data:/var/lib/postgresql/data`
- **Health Check**: Every 10s with 5s timeout

### PHP-FPM
- **Port**: 9000
- **Volumes**: Web root, profiles, themes, custom modules
- **Health Check**: PHP version check every 30s

### Nginx
- **Port**: 80 (dev: 127.0.0.1:8080, prod: via Caddy)
- **Config**: Drupal-optimized with clean URLs
- **Health Check**: HTTP GET to `/health` endpoint

### Caddy (Production Only)
- **Ports**: 80 (redirect), 443 (HTTPS)
- **Features**: 
  - Automatic SSL/TLS certificates
  - Security headers
  - Rate limiting for admin
  - Compression

### Backup Service (Production Only)
- **Schedule**: Daily at 2 AM + Noon
- **Backup Types**: Database (SQL) + Files
- **Retention**: Configurable (default 30 days)
- **S3 Upload**: Automatic if configured

### Adminer (Development Only)
- **Port**: 127.0.0.1:8081
- **Access**: Web-based database admin
- **Server**: postgres
- **Username**: From `DB_USER`

### MailHog (Development Only)
- **Port**: 127.0.0.1:8025 (web UI)
- **Port**: 127.0.0.1:1025 (SMTP)
- **Purpose**: Catch all outgoing emails in development

## Common Commands

### Development

```bash
# View logs
docker-compose logs -f php
docker-compose logs -f nginx
docker-compose logs -f postgres

# Run Drupal Console
docker-compose exec php drupal

# Run Drush
docker-compose exec php drush

# Access PHP container
docker-compose exec php sh

# Run Composer
docker-compose exec php composer install

# Clear cache
docker-compose exec php drush cache:rebuild

# Database shell
docker-compose exec postgres psql -U farmos -d farmos
```

### Production

```bash
# Start services
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Check backup status
docker-compose logs backup

# Manual backup
docker-compose exec backup /usr/local/bin/backup.sh

# Restore from backup
docker-compose exec postgres psql -U farmos -d farmos < /backups/db_backup_*.sql

# View Caddy logs
docker-compose logs caddy
```

## Database Backup & Restore

### Automatic Backup (Production)

Backups run automatically:
- **Database**: Daily at 2 AM and Noon
- **Files**: Included in tar.gz archive
- **Retention**: 30 days (configurable)
- **S3 Upload**: If `S3_*` environment variables set

### Manual Backup

```bash
# Database only
docker-compose exec postgres \
  pg_dump -U farmos farmos > backup_manual.sql

# With files
docker-compose exec backup /usr/local/bin/backup.sh
```

### Restore Database

```bash
# From backup file
docker-compose exec postgres \
  psql -U farmos farmos < backup_manual.sql

# From gzipped backup
docker-compose exec postgres \
  gunzip -c backup_manual.sql.gz | psql -U farmos farmos
```

## Drupal Customization

### Custom Profiles
Place custom profiles in `./profiles/`:
```
profiles/
└── custom_profile/
    ├── custom_profile.info.yml
    └── ...
```

### Custom Themes
Place custom themes in `./themes/`:
```
themes/
└── custom_theme/
    ├── custom_theme.info.yml
    ├── css/
    ├── js/
    └── templates/
```

### Custom Modules
Place custom modules in `./modules/custom/`:
```
modules/custom/
└── custom_module/
    ├── custom_module.info.yml
    ├── src/
    └── ...
```

## Xdebug Setup (Development)

### VS Code Configuration

Create `.vscode/launch.json`:
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Listen for Xdebug",
            "type": "php",
            "port": 9003,
            "pathMapping": {
                "/opt/drupal": "${workspaceFolder}"
            }
        }
    ]
}
```

### PhpStorm Configuration

1. Settings → PHP → Debug
2. Set Xdebug port to `9003`
3. Settings → PHP → Servers
4. Add server: `localhost` mapped to `/opt/drupal`

## SSL/TLS Certificates (Production)

Caddy automatically manages SSL certificates via Let's Encrypt:

```bash
# View certificate details
docker-compose exec caddy caddy list-certs

# Force certificate renewal
docker-compose exec caddy caddy reload --config /etc/caddy/Caddyfile
```

## Performance Tuning

### PHP-FPM Settings

Edit `docker/php/php-fpm-prod.conf`:
```ini
pm.max_children = 64          # Adjust based on available memory
pm.max_requests = 1000        # Restart workers after 1000 requests
```

### PostgreSQL Settings

Edit `docker-compose.prod.yml`:
```yaml
command:
  - "-c"
  - "shared_buffers=256MB"    # 25% of system RAM
  - "-c"
  - "effective_cache_size=1GB" # 50-75% of RAM
```

### Nginx Caching

Edit `docker/nginx/conf.d/prod.conf`:
```nginx
expires 30d;
add_header Cache-Control "public, immutable";
```

## Monitoring & Logging

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f php
docker-compose logs -f nginx
docker-compose logs -f postgres

# JSON format for log aggregation
docker-compose logs --no-color php > logs/php.log
```

### Health Checks

```bash
# Database health
docker-compose exec postgres pg_isready

# PHP health
docker-compose exec php php -v

# Nginx health
curl http://localhost/health

# All container health
docker-compose ps
```

## Troubleshooting

### Container won't start

```bash
# Check logs
docker-compose logs <service>

# Rebuild image
docker-compose build --no-cache <service>

# Remove old volumes and restart
docker-compose down -v
docker-compose up -d
```

### Database connection error

```bash
# Check PostgreSQL is running
docker-compose ps postgres

# Check credentials in .env
grep DB_ .env

# Test connection
docker-compose exec postgres \
  psql -U farmos -d farmos -c "SELECT 1"
```

### PHP memory limit exceeded

Edit `.env`:
```bash
# Increase memory limit (in php.ini)
docker/php/php.ini: memory_limit = 512M
```

Then rebuild:
```bash
docker-compose up -d --build
```

### Xdebug not working

```bash
# Check Xdebug installation
docker-compose exec php php -m | grep xdebug

# Check Xdebug logs
docker-compose exec php tail -f /var/log/xdebug.log

# Verify host access
docker-compose exec php ping host.docker.internal
```

## Security Best Practices

1. **Change default passwords** in `.env`
2. **Generate random `HASH_SALT`**:
   ```bash
   openssl rand -base64 32
   ```
3. **Use strong database credentials**
4. **Enable firewall** for production
5. **Restrict admin paths** (Caddy rate limiting)
6. **Enable HTTPS** (automatic with Caddy)
7. **Regular backups** to S3
8. **Keep containers updated**: `docker-compose pull`

## Production Deployment Checklist

- [ ] Update all `.env` variables
- [ ] Generate secure `HASH_SALT`
- [ ] Configure S3 for backups
- [ ] Set up SSL certificates
- [ ] Configure firewall rules
- [ ] Enable database backups
- [ ] Set up monitoring/alerting
- [ ] Configure log aggregation
- [ ] Test backup & restore procedures
- [ ] Document admin procedures

## Support & Documentation

- [farmOS Documentation](https://farmos.org/)
- [Drupal Documentation](https://www.drupal.org/docs)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Caddy Documentation](https://caddyserver.com/docs/)

## License

This Docker configuration is part of the Markhor Farms project.
