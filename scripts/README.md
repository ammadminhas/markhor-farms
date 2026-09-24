# Markhor Farms - Seed Data Scripts

Seed data scripts for populating farmOS with test data for development and testing.

## Contents

### `seed-fake-data.php`
**Drush-based seed script using farmOS APIs**

- Recommended method for seeding data
- Uses Drupal entity creation APIs
- Includes error handling and logging
- Supports both metric and local units (maund, kanal, marla)

**Usage:**
```bash
# Run via drush
drush scr scripts/seed-fake-data.php

# Or from project root
make seed
```

**Creates:**
- **Farm Location:** Lahore (31.406250°N, 74.135194°E) — 2 acre rental land
- **Cattle:** 3 breeds
  - Jersey-Ferson Mix: 2 adult females + 1 calf (dairy)
  - Neeli Ravi: 2 adults + 2 female calves (dairy)
  - Sahewal-Cholistani Mix: 1 adult female + 1 male calf (dual-purpose)
- **Goats:** 5 asset groups
- **Equipment:** 5 items (2 carts, 2 lights, 1 fan)
- **Vaccination Logs:** 5 activities (FMD, Brucellosis, Anthrax)
- **Weight Measurements:** 8 quantity records in maund

**Data Types:**
- Assets: land, animal, equipment
- Activities: vaccination, health checks
- Quantities: weight measurements

---

### `seed-fake-data.sql`
**Direct SQL seed script for PostgreSQL**

Alternative method for seeding the database directly. Useful for:
- Direct database population (offline setup)
- Integration with deployment pipelines
- Backup/restore scenarios

**Usage:**
```bash
# Via drush
drush sql:cli < scripts/seed-fake-data.sql

# Or direct psql
psql -U postgres -d farmos -f scripts/seed-fake-data.sql
```

**Schema Notes:**
- Table names assume farmOS v4 core schema
- Adjust table/field names if your Drupal customization differs
- Uses PostgreSQL-specific functions (gen_random_uuid, EXTRACT, INTERVAL)

**Key Assumptions:**
- `asset` table with: uuid, type, name, status, created, changed
- `activity` table for logs/vaccination records
- `quantity` table for measurements
- `unit` table with at least 'Maund' unit defined

---

## Unit System

### Local Units (Pakistan)
- **1 Acre** = 8 Kanal = 160 Marla
- **1 Maund** = 40 kg (weight measurement)
- **1 Kanal** = 4,000 sq meters (land area)
- **1 Marla** = 225 sq meters (land area)

The seed scripts use **maund** for cattle weight measurements.

### Cattle Weight References
- **Jersey Adult:** 400–500 kg = 10–12.5 maund
- **Jersey Calf:** 150–200 kg = 3.75–5 maund
- **Neeli Ravi Adult:** 450–550 kg = 11.25–13.75 maund
- **Neeli Ravi Calf:** 180–220 kg = 4.5–5.5 maund
- **Sahewal Adult:** 500–600 kg = 12.5–15 maund
- **Sahewal Calf:** 200–250 kg = 5–6.25 maund

---

## Farm Data Reference

### Location (Lahore)
- **Coordinates:** 31°24'22.5"N, 74°08'07.7"E (decimal: 31.406250°N, 74.135194°E)
- **Land:** 2 acres (rental)
- **Equipment:** Owned (carts, lights, fans)

### Cattle Details

#### Jersey-Ferson Mix (Jersey-Ferson 001)
- **Total:** 3 animals (2 adult females + 1 calf)
- **Purpose:** Dairy production
- **Vaccines:** FMD, Brucellosis screening

#### Neeli Ravi (Neeli Ravi 001)
- **Total:** 4 animals (2 adult females + 2 female calves)
- **Purpose:** Dairy production
- **Vaccines:** FMD, Anthrax

#### Sahewal-Cholistani Mix (Sahewal-Cholistani 001)
- **Total:** 2 animals (1 adult female + 1 male calf)
- **Purpose:** Dual-purpose (dairy + meat)
- **Vaccines:** FMD

### Goat Groups
- 5 asset groups (Groups 1–5)
- 2–8 animals per group (varies)
- Purpose: Dairy/meat production

### Equipment
- Cart 001: Wooden cart (hay & feed transport)
- Cart 002: Metal cart (crop transport)
- LED Light 001: Solar barn light
- LED Light 002: Solar storage light
- Fan 001: Ventilation fan (barn cooling)

---

## Development Workflow

### First-Time Setup
```bash
# Start containers
make up

# Wait for healthchecks (postgres + farmOS)
make logs

# Seed test data
make seed

# Verify in browser
open http://127.0.0.1:8080
```

### Resetting Test Data
```bash
# Careful: This wipes the database!
make reset

# Re-seed
make seed
```

### Database Access
```bash
# Drush shell access
make shell

# Direct SQL queries
drush sql:cli
```

---

## Troubleshooting

### PHP Script Issues
- **Error:** "Missing function" → Check if Drupal APIs are loaded
  - Solution: Run via `drush scr`, not directly

- **Error:** "Unknown unit 'Maund'" → Custom unit not yet created
  - Solution: Define in `mf_core` module hooks, then re-seed

### SQL Script Issues
- **Error:** "Unknown column 'aid'" → Table names differ from farmOS core
  - Solution: Inspect actual schema with `\dt` in psql, adjust script

- **Error:** "Foreign key violation" → Referenced asset doesn't exist
  - Solution: Ensure assets are created before activities/quantities

---

## Extending the Seed Data

### Adding More Cattle
Edit `seed-fake-data.php`, duplicate a `create_asset('...')` block:

```php
$cattle_new = create_asset(
  'My Breed 001',
  'animal',
  'Description here',
  'active'
);
if ($cattle_new->hasField('animal_breed')) {
  $cattle_new->set('animal_breed', 'My Breed');
}
if ($cattle_new->hasField('count')) {
  $cattle_new->set('count', 5);
}
$cattle_new->save();
```

### Adding Crop Data
For Phase 2 (crop tracking):
```php
$crop = create_asset('Wheat Field A', 'plant', 'Rabi 2025 wheat crop', 'active');
// Set crop-specific fields via mf_crops_pk module
```

### Adding More Logs
Create vaccination, weight, or movement logs:

```php
$log = create_log(
  'Custom Log Name',
  'activity',
  $asset_id,
  strtotime('-5 days'),
  'Notes here'
);
```

---

## License

Markhor Farms seed data is part of the Markhor Farms platform, powered by farmOS.
farmOS is GPL-2.0-or-later. See LEGAL.md in the project root.
