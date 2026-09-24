# Markhor Farms - Quick Start Guide

Get your farmOS v4 system running in minutes.

## Prerequisites

- Docker & Docker Compose installed
- 4GB+ available RAM
- 20GB+ disk space

## 5-Minute Setup

### 1. Initial Configuration

```bash
# Navigate to project
cd /Users/ammadminhas/Projects/markhor-farms

# Copy environment template
make setup

# Edit environment (change defaults)
nano .env

# Key variables to update:
# - DB_PASSWORD (change from "changeme")
# - FARMOS_ADMIN_PASSWORD (change from "changeme")
# - HASH_SALT (run: openssl rand -base64 32)
```

### 2. Start Development

```bash
# Build and start services
make dev-up

# Wait for database to be ready (~30 seconds)
sleep 30

# Install Drupal
make dev-install

# Access application
open http://127.0.0.1:8080
```

## Login Credentials

- **Username**: admin
- **Password**: (from your `.env` FARMOS_ADMIN_PASSWORD)

## Development Tools Access

| Service | URL | Purpose |
|---------|-----|---------|
| farmOS | http://127.0.0.1:8080 | Main application |
| Adminer | http://127.0.0.1:8081 | Database browser |
| MailHog | http://127.0.0.1:8025 | Email testing |

## Common First Tasks

### Create Content

```bash
# Access PHP container
docker-compose exec php bash

# Create a farm record
drush entity:create farm --type=equipment --label="Tractor A"

# Clear cache
drush cache:rebuild
```

### Enable Modules

```bash
# List available modules
docker-compose exec php drush pm:list --type=module

# Enable a module
docker-compose exec php drush pm:enable farm_livestock
```

### View Database

1. Open http://127.0.0.1:8081
2. Server: postgres
3. Username: farmos
4. Password: (from `.env` DB_PASSWORD)

### Send Test Email

1. Make a change that triggers email
2. Check MailHog: http://127.0.0.1:8025
3. View captured emails in UI

## Check System Status

```bash
# View all services
make ps

# Check health
make health-check

# View logs
make logs SERVICE=php
```

## Stop Services

```bash
# Stop (data preserved)
make dev-down

# Stop and delete everything
make clean
```

## Production Setup

For production deployment:

```bash
# Update .env with production values
nano .env

# Set environment
APP_ENV=production

# Start production
make prod-up

# Access via
open https://markhorconsultants.com
```

## Backup & Restore

```bash
# Manual backup
make backup

# List backups
ls -la backups/

# Restore
make restore FILE=backups/db_backup_*.sql
```

## Next Steps

1. Read [DOCKER_SETUP.md](./DOCKER_SETUP.md) for detailed information
2. Customize profiles, themes, modules
3. Configure email, backup locations, SSL
4. Set up monitoring and alerts

## Troubleshooting

### "Connection refused"
- Wait 30 seconds after `make dev-up` for database to start
- Check: `make health-check`

### "Docker daemon not running"
- Start Docker Desktop (Mac/Windows) or Docker service (Linux)

### Port 8080 already in use
- Change `NGINX_PORT` in `.env`
- Or stop other services using port 8080

### Memory errors
- Increase Docker's memory allocation in Docker Desktop settings
- Or increase PHP memory in `docker/php/php-dev.ini`

### Database won't connect
- Verify credentials in `.env`
- Check: `docker-compose logs postgres`

## Get Help

```bash
# View all available commands
make help

# View service logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f php
docker-compose logs -f postgres
```

## Quick Reference

```bash
# Execute Drush commands
make drush CMD="cache:rebuild"

# Execute Composer commands
make composer CMD="require drupal/module_name"

# Run any command in PHP container
make exec CMD="php -v"

# Database shell
make db-shell

# PHP shell
make php-shell
```

## File Structure

Key locations:
- **Drupal root**: `./web/` (created after first run)
- **Custom modules**: `./modules/custom/`
- **Custom themes**: `./themes/`
- **Custom profiles**: `./profiles/`
- **Backups**: `./backups/` (production only)
- **Configuration**: `.env` file

## Performance Tips

- Use `make` commands for consistency
- Run `docker-compose pull` weekly for updates
- Monitor with `docker system df`
- Clean old images: `docker image prune`

## Security Tips

1. Change all default passwords in `.env`
2. Generate random `HASH_SALT`: `openssl rand -base64 32`
3. Never commit `.env` to version control
4. Use strong database credentials
5. Enable HTTPS in production (automatic with Caddy)
6. Regularly backup with `make backup`

---

**Ready to go?** Run `make setup` then `make dev-up` and open http://127.0.0.1:8080

For detailed documentation, see [DOCKER_SETUP.md](./DOCKER_SETUP.md)
