# farmOS Installation Guide - VM .49 Setup

## What is farmOS?

farmOS is an open-source farm management platform built on Drupal. It tracks livestock, crops, equipment, activities, and more for farms.

**What we're building**: Markhor Farms - a customized farmOS installation for a dairy farm in Lahore, Pakistan.

---

## Prerequisites

✅ Snapshot taken (good! you can rollback if needed)
- VM: 10.27.27.49
- OS: Ubuntu (likely)
- RAM: 4GB+ 
- Disk: 20GB+
- Docker & Docker Compose installed

---

## Installation Steps

### Step 1: SSH into VM

```bash
# SSH to .49 VM
ssh markhor@10.27.27.49
# or with password if SSH key not set up

# Check you're in the right place
whoami
hostname
```

### Step 2: Install Docker (if not already installed)

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group (avoid sudo for docker commands)
sudo usermod -aG docker markhor
newgrp docker

# Verify installation
docker --version
docker-compose --version
```

### Step 3: Clone Markhor Farms Repository

```bash
# Create apps directory
mkdir -p /opt
cd /opt

# Clone the repository
sudo git clone https://github.com/ammadminhas/markhor-farms.git markhor-farms
sudo chown -R markhor:markhor markhor-farms

cd markhor-farms

# Verify files exist
ls -la docker-compose.yml docker-compose.dev.yml Dockerfile.dev
```

### Step 4: Configure Environment

```bash
# Copy default configuration
cp .env.example .env

# Edit configuration (optional - defaults work fine for dev)
nano .env

# Key variables:
# - DB_PASSWORD=changeme (change for production)
# - DB_NAME=farmos
# - FARMOS_ADMIN_PASSWORD=changeme
```

### Step 5: Start All Services

```bash
# Start development environment (includes Drupal + PostgreSQL + Nginx)
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# Wait for PostgreSQL to be ready
sleep 15

# Verify all containers are running
docker-compose -f docker-compose.yml -f docker-compose.dev.yml ps

# Expected output:
# - markhor_postgres (healthy)
# - markhor_php (healthy or starting)
# - markhor_nginx (running)
# - markhor_adminer (running)
# - markhor_mailhog (running)
```

### Step 6: Install Drupal with farmOS Profile

```bash
# Install Drupal with standard profile (farmOS profile not available yet)
docker-compose -f docker-compose.yml -f docker-compose.dev.yml exec php \
  ./vendor/bin/drush site:install standard \
  --db-url=pgsql://farmos:changeme@postgres:5432/farmos \
  --account-name=admin \
  --account-pass=changeme \
  -y

# Wait for installation to complete (1-2 minutes)
# You should see: [success] Installation complete
```

### Step 7: Access farmOS

Open in browser:
- **farmOS**: http://10.27.27.49:8080
- **Login**: admin / changeme
- **Database UI**: http://10.27.27.49:8081
- **Email Test**: http://10.27.27.49:8025

---

## Post-Installation: Enable farmOS Modules

```bash
# SSH into PHP container
docker-compose -f docker-compose.yml -f docker-compose.dev.yml exec php bash

# Inside container:

# List available farmOS modules
drush pm:list --type=module | grep farm

# Enable core farmOS modules
drush en farm_livestock -y
drush en farm_crop -y
drush en farm_equipment -y
drush en farm_log -y

# Enable Markhor custom module (for local units)
drush en mf_core -y

# Rebuild cache
drush cache:rebuild

# Exit container
exit
```

---

## Verify farmOS Installation

### Via Browser

1. Go to http://10.27.27.49:8080
2. Click **"Manage"** → **"Extend"**
3. Verify farmOS modules are listed and enabled:
   - Farm: Livestock
   - Farm: Crop
   - Farm: Equipment
   - Farm: Log

### Via Command Line

```bash
docker-compose -f docker-compose.yml -f docker-compose.dev.yml exec php \
  drush pm:list --type=module --status=enabled | grep farm
```

---

## Markhor Farms Customizations

Once farmOS is running, customize:

### 1. Add Custom Theme (Branding)

```bash
# Colors already set in web/themes/markhor_theme/
# - Orange: #FF6B35
# - Navy: #1a2332  
# - Lime: #C7E81E

# Verify theme is enabled
docker-compose exec php drush theme:list
```

### 2. Add Local Units (Pakistan Agriculture)

Already configured in `web/modules/mf_core/`:
- **kanal** (1 acre = 8 kanal)
- **marla** (1 kanal = 20 marla)
- **maund** (1 maund = 40kg)

Verify:
```bash
docker-compose exec php drush php:eval \
  "echo drupal_get_path('module', 'mf_core');"
```

### 3. Seed Fake Data (Optional - for testing)

```bash
# Create sample livestock, crops, activities
docker-compose exec php \
  php web/sites/default/files/scripts/seed-fake-data.php
```

---

## Daily Operations

### Backup Database

```bash
# Create backup
docker-compose -f docker-compose.yml -f docker-compose.dev.yml exec postgres \
  pg_dump -U farmos farmos > backup_$(date +%Y%m%d_%H%M%S).sql

# List backups
ls -lh backup_*.sql
```

### View Logs

```bash
# PHP/Drupal logs
docker-compose logs -f php

# Nginx logs
docker-compose logs -f nginx

# Database logs
docker-compose logs -f postgres

# Exit logs (Ctrl+C)
```

### Drush Commands

```bash
# Status check
docker-compose exec php ./vendor/bin/drush status

# Clear cache
docker-compose exec php ./vendor/bin/drush cache:rebuild

# Watchdog (error logs)
docker-compose exec php ./vendor/bin/drush watchdog:list

# Update database
docker-compose exec php ./vendor/bin/drush updatedb
```

### Stop Services

```bash
# Stop (data preserved)
docker-compose -f docker-compose.yml -f docker-compose.dev.yml down

# Stop and remove volumes (clean slate)
docker-compose -f docker-compose.yml -f docker-compose.dev.yml down -v
```

---

## Troubleshooting

### Connection Refused (http://10.27.27.49:8080)

```bash
# Check if containers are running
docker-compose ps

# Wait 30 seconds for database to start
sleep 30

# Check PHP-FPM health
docker-compose logs php | tail -20

# Restart if needed
docker-compose restart php
```

### Database Won't Connect

```bash
# Check PostgreSQL logs
docker-compose logs postgres

# Test connection manually
docker-compose exec postgres \
  psql -U farmos -d farmos -c "SELECT version();"
```

### 502 Bad Gateway (Nginx)

```bash
# Check PHP-FPM config
docker-compose exec php grep "listen.allowed_clients" \
  /usr/local/etc/php-fpm.d/www.conf

# Should be: listen.allowed_clients = 127.0.0.1,172.18.0.6

# Restart PHP
docker-compose restart php
```

### Port Already in Use

```bash
# Change port in docker-compose.dev.yml
# Find: 127.0.0.1:8080:80
# Change to: 127.0.0.1:8088:80

docker-compose down
docker-compose up -d
# Access at http://10.27.27.49:8088
```

---

## Next Steps

1. ✅ Install farmOS (this guide)
2. **Add Livestock Records**: Create cattle types (Jersey-Ferson, Neeli Ravi, Sahewal)
3. **Add Crops**: Record maize harvests
4. **Configure Land**: Add 2-acre farm parcel
5. **Equipment Tracking**: Add carts, lights, fans
6. **Activity Logs**: Start logging daily activities
7. **Custom Reports**: Build dashboards
8. **User Management**: Add farm workers

---

## Quick Reference

| Command | Purpose |
|---------|---------|
| `docker-compose up -d` | Start all services |
| `docker-compose down` | Stop all services |
| `docker-compose logs -f` | View live logs |
| `docker-compose exec php bash` | Shell into PHP container |
| `docker-compose exec postgres psql -U farmos farmos` | Database shell |

---

## Support & Documentation

- **Repository**: https://github.com/ammadminhas/markhor-farms
- **farmOS Docs**: https://farmos.org
- **This Guide**: VM_DEPLOYMENT_GUIDE.md
- **Docker Setup**: DOCKER_SETUP.md

---

## Success Checklist ✅

After completing installation:

- [ ] Docker containers running (`docker-compose ps`)
- [ ] Drupal accessible (http://10.27.27.49:8080)
- [ ] Login works (admin / changeme)
- [ ] farmOS modules enabled (Livestock, Crop, Equipment, Log)
- [ ] Database accessible (http://10.27.27.49:8081)
- [ ] Email testing works (http://10.27.27.49:8025)
- [ ] Can create livestock records
- [ ] Can create crop records

---

**Ready to start? Run these commands in sequence:**

```bash
cd /opt/markhor-farms
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
sleep 15
docker-compose -f docker-compose.yml -f docker-compose.dev.yml exec php \
  ./vendor/bin/drush site:install standard \
  --db-url=pgsql://farmos:changeme@postgres:5432/farmos \
  --account-name=admin --account-pass=changeme -y
```

Then open http://10.27.27.49:8080 and log in! 🚜

