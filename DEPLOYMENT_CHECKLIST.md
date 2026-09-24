# Markhor Farms - Deployment Checklist

Complete checklist for deploying farmOS v4 with Docker Compose.

## Pre-Deployment

### System Requirements
- [ ] Docker installed (v20.10+)
- [ ] Docker Compose installed (v1.29+)
- [ ] 4GB+ RAM available
- [ ] 20GB+ free disk space
- [ ] Domain name (for production)

### Project Setup
- [ ] Repository cloned
- [ ] `.env` file created from `.env.example`
- [ ] All environment variables reviewed and updated
- [ ] HASH_SALT generated (openssl rand -base64 32)
- [ ] Strong database password set
- [ ] Strong admin password set

## Development Deployment

### Initial Setup
- [ ] Run `make setup` to create .env
- [ ] Review and update `.env` file
- [ ] Run `make build` to build Docker images

### Starting Services
- [ ] Run `make dev-up` to start containers
- [ ] Wait 30 seconds for PostgreSQL to be ready
- [ ] Verify all containers running: `make ps`

### Installation
- [ ] Run `make dev-install` to install Drupal
- [ ] Verify installation completed successfully
- [ ] Check for any error messages in logs

### Verification
- [ ] Access http://127.0.0.1:8080
- [ ] Login with admin credentials
- [ ] Verify database connection (Adminer: http://127.0.0.1:8081)
- [ ] Test email capture (MailHog: http://127.0.0.1:8025)
- [ ] Check PHP functionality
- [ ] Run health checks: `make health-check`

### First Tasks
- [ ] Create a farm record
- [ ] Create equipment/assets
- [ ] Create a user account
- [ ] Configure site settings
- [ ] Enable required modules

## Production Deployment

### Pre-Deployment
- [ ] Database password changed from default
- [ ] Admin password changed from default
- [ ] HASH_SALT set to cryptographically random value
- [ ] APP_ENV set to "production"
- [ ] DEBUG set to "false"
- [ ] Domain DNS configured

### SSL/TLS Setup
- [ ] Domain points to production server
- [ ] Port 80 accessible from internet (for Let's Encrypt verification)
- [ ] Port 443 accessible from internet
- [ ] Firewall rules configured
- [ ] Email configured for certificate notices

### Database Configuration
- [ ] PostgreSQL password set to strong value
- [ ] PostgreSQL user created
- [ ] Database backup location configured
- [ ] S3 credentials configured (if using cloud backup)
- [ ] Backup retention days configured

### Backup Setup
- [ ] S3 bucket created (if using cloud backup)
- [ ] IAM credentials for S3 created
- [ ] Backup directory permissions correct
- [ ] Initial backup created and verified
- [ ] Backup restore procedure documented

### Starting Production
- [ ] Run `make prod-up` to start containers
- [ ] Wait for Caddy to obtain SSL certificates
- [ ] Monitor Caddy logs: `docker-compose logs caddy`
- [ ] Verify all containers running: `make ps`
- [ ] Check Caddy certificate: `docker-compose exec caddy caddy list-certs`

### Verification
- [ ] HTTPS certificate valid: https://markhorconsultants.com
- [ ] HTTP redirects to HTTPS
- [ ] Login works
- [ ] Admin panel accessible
- [ ] Database connected
- [ ] Security headers present
- [ ] Site accessible from internet
- [ ] Email functional (if configured)

## Post-Deployment

### Monitoring
- [ ] Enable monitoring/alerting
- [ ] Set up log aggregation
- [ ] Configure backup notifications
- [ ] Set up health check alerts
- [ ] Document monitoring procedures

### Documentation
- [ ] Document admin credentials (securely stored)
- [ ] Document database credentials
- [ ] Document backup locations
- [ ] Document access procedures
- [ ] Create runbooks for common tasks
- [ ] Document emergency procedures

### Security
- [ ] Change all default passwords
- [ ] Verify firewall rules
- [ ] Enable automatic backups
- [ ] Test backup restoration
- [ ] Set up intrusion detection (optional)
- [ ] Configure log retention policies
- [ ] Review security headers
- [ ] Verify SSL/TLS configuration

### Performance
- [ ] Monitor system resource usage
- [ ] Check database query performance
- [ ] Monitor cache hit rates
- [ ] Review PHP-FPM metrics
- [ ] Optimize slow queries
- [ ] Configure caching headers

### Backup & Recovery Testing
- [ ] Test database backup
- [ ] Test backup restoration
- [ ] Verify S3 backups (if configured)
- [ ] Document recovery time
- [ ] Create disaster recovery plan
- [ ] Schedule regular backup tests

## Ongoing Maintenance

### Daily Tasks
- [ ] Monitor application logs
- [ ] Check disk usage
- [ ] Verify backup completion
- [ ] Monitor system resources

### Weekly Tasks
- [ ] Review security logs
- [ ] Check for updates
- [ ] Verify backup integrity
- [ ] Test a backup restoration
- [ ] Monitor performance metrics

### Monthly Tasks
- [ ] Update Docker images
- [ ] Review and rotate credentials
- [ ] Full security audit
- [ ] Capacity planning review
- [ ] Disaster recovery drill

### Quarterly Tasks
- [ ] Full system backup restore test
- [ ] Security vulnerability scanning
- [ ] Performance optimization review
- [ ] Infrastructure scaling assessment
- [ ] Documentation update

## Troubleshooting Procedures

### Container Won't Start
- [ ] Check logs: `docker-compose logs <service>`
- [ ] Verify Docker daemon running
- [ ] Check disk space: `docker system df`
- [ ] Rebuild image: `docker-compose build --no-cache`
- [ ] Check port conflicts: `lsof -i :<port>`

### Database Connection Error
- [ ] Verify database running: `make ps`
- [ ] Check credentials in .env
- [ ] Test connection: `make db-shell`
- [ ] Check database logs: `docker-compose logs postgres`
- [ ] Verify network connectivity

### PHP Errors
- [ ] Check PHP logs: `docker-compose logs php`
- [ ] Verify PHP-FPM running: `make health-check`
- [ ] Check PHP configuration: `docker-compose exec php php -i`
- [ ] Review error logs in /var/log/

### SSL/TLS Issues
- [ ] Check Caddy logs: `docker-compose logs caddy`
- [ ] Verify domain DNS: `nslookup <domain>`
- [ ] Check certificate: `docker-compose exec caddy caddy list-certs`
- [ ] Review Caddy configuration: `cat Caddyfile`
- [ ] Check port accessibility: `curl -v https://<domain>`

### Performance Issues
- [ ] Monitor resources: `docker system stats`
- [ ] Check disk usage: `df -h`
- [ ] Review logs for errors
- [ ] Check slow queries in PostgreSQL
- [ ] Optimize OPcache settings
- [ ] Consider adding more workers

## Rollback Procedures

### In Case of Issues
1. [ ] Stop production services: `make prod-down`
2. [ ] Switch to previous version (if applicable)
3. [ ] Restore database from backup: `make restore FILE=<backup>`
4. [ ] Verify restoration successful
5. [ ] Restart services: `make prod-up`
6. [ ] Run health checks
7. [ ] Monitor for issues

## Emergency Procedures

### Complete System Failure
1. [ ] Document error details
2. [ ] Stop services: `docker-compose down`
3. [ ] Check disk space and system resources
4. [ ] Review logs for root cause
5. [ ] Restore from backup if necessary
6. [ ] Rebuild containers if needed
7. [ ] Restart services
8. [ ] Verify functionality
9. [ ] Monitor closely

### Data Loss Recovery
1. [ ] Identify lost data scope
2. [ ] Check backup availability
3. [ ] Select most recent valid backup
4. [ ] Restore database from backup
5. [ ] Restore files from backup
6. [ ] Verify data integrity
7. [ ] Implement data loss prevention measures
8. [ ] Document incident

## Sign-Off

- [ ] Project Manager: _________________ Date: _______
- [ ] System Administrator: _________________ Date: _______
- [ ] Security Team: _________________ Date: _______

---

## Quick Reference Commands

```bash
# Setup
make setup                          # Initial setup
make build                          # Build images

# Development
make dev-up                         # Start dev
make dev-down                       # Stop dev
make dev-logs                       # View logs

# Production
make prod-up                        # Start prod
make prod-down                      # Stop prod

# Management
make ps                             # List containers
make health-check                   # Health check
make backup                         # Manual backup
make restore FILE=path              # Restore backup

# Cleanup
make clean                          # Remove everything
```

## Support Contacts

- **Documentation**: See DOCKER_SETUP.md and QUICKSTART.md
- **Drupal Support**: https://www.drupal.org/support
- **farmOS Support**: https://farmos.org/support/
- **Docker Support**: https://docs.docker.com/

---

Last Updated: 2024
Status: Ready for Deployment
