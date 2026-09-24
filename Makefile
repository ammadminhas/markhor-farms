.PHONY: help build up down logs shell clean dev prod install backup restore exec drush composer reset test deploy-lab

help:
	@echo "Markhor Farms - Docker Compose Commands"
	@echo ""
	@echo "Quick Start:"
	@echo "  make up                 - Start services (default: docker-compose.yml)"
	@echo "  make down               - Stop services"
	@echo "  make logs               - View service logs (follow mode)"
	@echo "  make shell              - Access container shell"
	@echo "  make reset              - Reset database and cache (dev only)"
	@echo ""
	@echo "Setup:"
	@echo "  make setup              - Copy .env.example to .env"
	@echo "  make build              - Build Docker images"
	@echo ""
	@echo "Development:"
	@echo "  make dev-up             - Start development environment"
	@echo "  make dev-down           - Stop development environment"
	@echo "  make dev-logs           - View development logs"
	@echo "  make dev-install        - Install Drupal in development"
	@echo ""
	@echo "Production:"
	@echo "  make prod-up            - Start production environment"
	@echo "  make prod-down          - Stop production environment"
	@echo "  make prod-logs          - View production logs"
	@echo ""
	@echo "Management:"
	@echo "  make drush CMD=<cmd>    - Run Drush command"
	@echo "  make composer CMD=<cmd> - Run Composer command"
	@echo "  make exec CMD=<cmd>     - Execute command in PHP container"
	@echo "  make backup             - Manual backup (production)"
	@echo "  make restore FILE=path  - Restore database from backup"
	@echo "  make test               - Run test suite"
	@echo "  make deploy-lab         - Deploy to lab environment"
	@echo "  make clean              - Remove all containers and volumes"
	@echo "  make ps                 - List running containers"
	@echo "  make status             - Show container status and health"
	@echo "  make health-check       - Run health checks"

setup:
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "✓ .env created from .env.example"; \
		echo "⚠ Update .env with your configuration"; \
	else \
		echo "✓ .env already exists"; \
	fi

build:
	docker-compose build

dev-up:
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
	@echo "✓ Development environment started"
	@echo "Application: http://127.0.0.1:8080"
	@echo "Adminer: http://127.0.0.1:8081"
	@echo "MailHog: http://127.0.0.1:8025"

dev-down:
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml down
	@echo "✓ Development environment stopped"

dev-logs:
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml logs -f

dev-install:
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml exec php \
		drush site:install farmos --db-url=pgsql://farmos:changeme@postgres:5432/farmos -y
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml exec php \
		drush user:create admin --mail=admin@markhorconsultants.com
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml exec php \
		drush user:password admin changeme
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml exec php \
		drush user-add-role administrator admin
	@echo "✓ Drupal installation completed"

prod-up:
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
	@echo "✓ Production environment started"
	@echo "Application: https://markhorconsultants.com"

prod-down:
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml down
	@echo "✓ Production environment stopped"

prod-logs:
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml logs -f

drush:
	docker-compose exec php drush $(CMD)

composer:
	docker-compose exec php composer $(CMD)

exec:
	docker-compose exec php sh -c '$(CMD)'

backup:
	docker-compose exec backup /usr/local/bin/backup.sh
	@echo "✓ Backup completed"

restore:
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make restore FILE=path/to/backup.sql"; \
		exit 1; \
	fi
	docker-compose exec postgres psql -U farmos farmos < $(FILE)
	@echo "✓ Database restored from $(FILE)"

clean:
	docker-compose down -v
	rm -rf backups/ postgres_data/ php_vendor/ php_cache/ caddy_data/ caddy_config/
	@echo "✓ All containers and volumes removed"

ps:
	docker-compose ps

logs:
	docker-compose logs -f $(SERVICE)

db-shell:
	docker-compose exec postgres psql -U farmos -d farmos

php-shell:
	docker-compose exec php sh

status:
	@echo "=== Container Status ==="
	docker-compose ps
	@echo ""
	@echo "=== Disk Usage ==="
	docker system df
	@echo ""
	@echo "=== Recent Logs (last 20 lines) ==="
	docker-compose logs --tail=20

update:
	docker-compose pull
	docker-compose build --no-cache
	docker-compose up -d
	@echo "✓ Containers updated"

health-check:
	@echo "Checking PostgreSQL..."
	docker-compose exec postgres pg_isready || echo "✗ PostgreSQL down"
	@echo "Checking PHP-FPM..."
	docker-compose exec php php -v || echo "✗ PHP-FPM down"
	@echo "Checking Nginx..."
	curl -s http://localhost/health || echo "✗ Nginx down"
	@echo "✓ Health check completed"

# Quick start targets (aliases for common operations)
up: dev-up
	@echo "✓ Services started"

down: dev-down
	@echo "✓ Services stopped"

shell: php-shell
	@echo "✓ Shell closed"

reset:
	@echo "WARNING: This will reset the database and cache."
	@echo "Press Ctrl+C to cancel, or wait 5 seconds to continue..."
	@sleep 5
	docker-compose down -v
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
	@echo "✓ Database and cache reset complete."

test:
	@echo "Running test suite..."
	docker-compose exec php ./vendor/bin/phpunit
	@echo "✓ Tests completed"

deploy-lab:
	@echo "Deploying to lab environment..."
	@echo "This target requires manual configuration for your lab setup."
	@echo "Implement deployment-specific logic here (docker push, kubectl, etc)."
	@echo "Update docker-compose.lab.yml as needed."
