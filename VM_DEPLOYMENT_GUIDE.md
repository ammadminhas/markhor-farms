# Markhor Farms - Ubuntu VM Deployment Guide

## Overview
Deploy Markhor Farms (Drupal 10 + PostgreSQL) to Ubuntu VM at **10.27.27.105** using Docker Compose.

---

## Prerequisites

### 1. SSH Access
```bash
# From your Mac
ssh -i ~/.ssh/Markhor-S markhor@10.27.27.105
# or with password: C0ads47p...
```

### 2. Install Docker & Docker Compose
```bash
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker markhor

# Verify
docker --version
docker-compose --version
```

---

## Deployment Steps

### 1. Clone Repository
```bash
cd /opt
sudo git clone https://github.com/ammadminhas/markhor-farms.git
sudo chown -R markhor:markhor markhor-farms
cd markhor-farms
```

### 2. Configure Environment
```bash
# Copy example config
cp .env.example .env

# Edit for VM (optional)
# nano .env
# - Keep defaults or customize ports, database name, etc.
```

### 3. Start Containers
```bash
# Development setup (uses PostgreSQL, Nginx, PHP-FPM)
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# Verify all containers running
docker-compose -f docker-compose.yml -f docker-compose.dev.yml ps
```

### 4. Initial Setup (if database is empty)
```bash
# Wait 10 seconds for PostgreSQL to start
sleep 10

# Install Drupal with standard profile
docker-compose -f docker-compose.yml -f docker-compose.dev.yml exec php \
  ./vendor/bin/drush site:install standard \
  --db-url=pgsql://farmos:changeme@postgres:5432/farmos \
  --account-name=admin \
  --account-pass=changeme \
  -y
```

---

## Access Application

| Service | URL | Credentials |
|---------|-----|-------------|
| **Drupal** | http://10.27.27.105:8080 | admin / changeme |
| **Adminer** | http://10.27.27.105:8081 | pgsql / farmos / changeme |
| **MailHog** | http://10.27.27.105:8025 | (email testing) |

---

## Useful Commands

```bash
# View logs
docker-compose -f docker-compose.yml -f docker-compose.dev.yml logs php -f
docker-compose -f docker-compose.yml -f docker-compose.dev.yml logs nginx -f

# Shell access
docker-compose -f docker-compose.yml -f docker-compose.dev.yml exec php sh

# Run Drush commands
docker-compose -f docker-compose.yml -f docker-compose.dev.yml exec php \
  ./vendor/bin/drush status

# Backup database
docker-compose -f docker-compose.yml -f docker-compose.dev.yml exec postgres \
  pg_dump -U farmos farmos > backup_$(date +%Y%m%d_%H%M%S).sql

# Stop all containers
docker-compose -f docker-compose.yml -f docker-compose.dev.yml down

# Remove all (including volumes)
docker-compose -f docker-compose.yml -f docker-compose.dev.yml down -v
```

---

## Production Deployment

For production on Ubuntu, use:

```bash
# Production setup (with Caddy SSL, automatic backups)
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

See `docker-compose.prod.yml` for SSL/TLS, backup scheduling, and restart policies.

---

## Troubleshooting

### PHP-FPM connection rejected
```bash
# Check PHP-FPM config
docker-compose -f docker-compose.yml -f docker-compose.dev.yml exec php \
  grep "listen.allowed" /usr/local/etc/php-fpm.d/www.conf

# Should allow Docker network (172.17.0.0/16 or 172.18.0.0/16)
```

### Nginx 502 Bad Gateway
```bash
# Ensure PHP-FPM is healthy
docker-compose -f docker-compose.yml -f docker-compose.dev.yml ps

# Check PHP logs
docker-compose -f docker-compose.yml -f docker-compose.dev.yml logs php --tail 50
```

### Database connection failed
```bash
# Verify PostgreSQL is running
docker-compose -f docker-compose.yml -f docker-compose.dev.yml exec postgres \
  psql -U farmos -c "SELECT version();"
```

---

## Next Steps

1. **Test Drupal**: Access http://10.27.27.105:8080
2. **Add farmOS modules**: `composer require farmos/farm`
3. **Customize theme**: Edit `web/themes/markhor_theme/`
4. **Enable modules**: `drush en farm_*` for farm modules
5. **Set up backups**: Configure cron in `docker-compose.prod.yml`

---

## Support

- **Repository**: https://github.com/ammadminhas/markhor-farms
- **Documentation**: See README.md, CLAUDE.md
- **Issues**: GitHub issues

