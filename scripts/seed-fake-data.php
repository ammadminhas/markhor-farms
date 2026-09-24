<?php

/**
 * @file
 * Seed script for Markhor Farms test data.
 *
 * Creates realistic farm entities for development & testing:
 * - 1 farm location (Lahore)
 * - 3 cattle assets with specific breeds & counts
 * - 5 goat assets
 * - Equipment (carts, lights, fans)
 * - Vaccination logs & weight measurements
 *
 * Run via: drush scr scripts/seed-fake-data.php
 *
 * @usage
 *   drush scr scripts/seed-fake-data.php
 */

use Drupal\asset\Entity\Asset;
use Drupal\log\Entity\Log;
use Drupal\quantity\Entity\Quantity;
use Drupal\Core\Datetime\DrupalDateTime;

// Track created entities for output.
$created = [];

// ============================================================================
// Helper: Create asset with standard fields.
// ============================================================================
function create_asset($name, $type, $description = '', $status = 'active') {
  $asset = Asset::create([
    'name' => $name,
    'type' => $type,
    'status' => $status,
    'description' => $description,
  ]);
  $asset->save();
  return $asset;
}

// ============================================================================
// Helper: Create log entry (vaccination, weight measurement, etc).
// ============================================================================
function create_log($name, $type, $asset_id, $timestamp = NULL, $notes = '') {
  if (!$timestamp) {
    $timestamp = time();
  }

  $log = Log::create([
    'name' => $name,
    'type' => $type,
    'timestamp' => $timestamp,
    'status' => 'done',
    'asset' => $asset_id,
    'notes' => $notes,
  ]);
  $log->save();
  return $log;
}

// ============================================================================
// Helper: Create quantity (weight measurement).
// ============================================================================
function create_quantity($asset_id, $measure, $value, $unit_id, $notes = '') {
  $quantity = Quantity::create([
    'measure' => $measure,
    'value' => $value,
    'unit' => $unit_id,
    'asset' => $asset_id,
    'notes' => $notes,
  ]);
  $quantity->save();
  return $quantity;
}

// ============================================================================
// 1. FARM LOCATION
// ============================================================================
drush_print("\n=== Creating Farm Location ===");

$farm_location = create_asset(
  'Lahore Farm',
  'land',
  'Primary farm location in Lahore, Pakistan. 2 acres rental land + equipment storage.',
  'active'
);

// Set location geometry (GeoJSON point).
// Coordinates: 31°24'22.5"N 74°08'07.7"E → 31.406250°N 74.135194°E
if ($farm_location->hasField('geometry')) {
  $geom = [
    'type' => 'Point',
    'coordinates' => [74.135194, 31.406250], // [lon, lat]
  ];
  $farm_location->set('geometry', json_encode($geom));
  $farm_location->save();
}

$created['farm_location'] = $farm_location;
drush_print(dt("Created farm location: !name (ID: @id)", [
  '!name' => $farm_location->label(),
  '@id' => $farm_location->id(),
]));

// ============================================================================
// 2. CATTLE ASSETS
// ============================================================================
drush_print("\n=== Creating Cattle Assets ===");

// Cattle 1: Jersey-Ferson Mix
$cattle_1 = create_asset(
  'Jersey-Ferson 001',
  'animal',
  'Jersey-Ferson cross breed. 2 adult females + 1 calf. Dairy production.',
  'active'
);

// Add animal-specific fields if available.
if ($cattle_1->hasField('animal_type')) {
  $cattle_1->set('animal_type', 'cattle');
}
if ($cattle_1->hasField('animal_breed')) {
  $cattle_1->set('animal_breed', 'Jersey-Ferson Mix');
}
if ($cattle_1->hasField('count')) {
  $cattle_1->set('count', 3); // 2 females + 1 calf
}
$cattle_1->save();
$created['cattle_jersey'] = $cattle_1;

drush_print(dt("Created cattle: !name (ID: @id)", [
  '!name' => $cattle_1->label(),
  '@id' => $cattle_1->id(),
]));

// Cattle 2: Neeli Ravi
$cattle_2 = create_asset(
  'Neeli Ravi 001',
  'animal',
  'Neeli Ravi breed. 2 adult females + 2 female calves. Dairy production.',
  'active'
);

if ($cattle_2->hasField('animal_type')) {
  $cattle_2->set('animal_type', 'cattle');
}
if ($cattle_2->hasField('animal_breed')) {
  $cattle_2->set('animal_breed', 'Neeli Ravi');
}
if ($cattle_2->hasField('count')) {
  $cattle_2->set('count', 4); // 2 adults + 2 calves
}
$cattle_2->save();
$created['cattle_neeli'] = $cattle_2;

drush_print(dt("Created cattle: !name (ID: @id)", [
  '!name' => $cattle_2->label(),
  '@id' => $cattle_2->id(),
]));

// Cattle 3: Sahewal-Cholistani Mix
$cattle_3 = create_asset(
  'Sahewal-Cholistani 001',
  'animal',
  'Sahewal-Cholistani cross breed. 1 adult female + 1 male calf. Dual purpose.',
  'active'
);

if ($cattle_3->hasField('animal_type')) {
  $cattle_3->set('animal_type', 'cattle');
}
if ($cattle_3->hasField('animal_breed')) {
  $cattle_3->set('animal_breed', 'Sahewal-Cholistani Mix');
}
if ($cattle_3->hasField('count')) {
  $cattle_3->set('count', 2); // 1 adult + 1 calf
}
$cattle_3->save();
$created['cattle_sahewal'] = $cattle_3;

drush_print(dt("Created cattle: !name (ID: @id)", [
  '!name' => $cattle_3->label(),
  '@id' => $cattle_3->id(),
]));

// ============================================================================
// 3. GOAT ASSETS
// ============================================================================
drush_print("\n=== Creating Goat Assets ===");

for ($i = 1; $i <= 5; $i++) {
  $goat = create_asset(
    "Goat Group $i",
    'animal',
    "Goat group $i. Mixed animals for dairy/meat production.",
    'active'
  );

  if ($goat->hasField('animal_type')) {
    $goat->set('animal_type', 'goat');
  }
  if ($goat->hasField('count')) {
    $goat->set('count', rand(2, 8)); // 2-8 goats per group
  }
  $goat->save();

  $created["goat_$i"] = $goat;
  drush_print(dt("Created goats: !name (ID: @id)", [
    '!name' => $goat->label(),
    '@id' => $goat->id(),
  ]));
}

// ============================================================================
// 4. EQUIPMENT ASSETS
// ============================================================================
drush_print("\n=== Creating Equipment Assets ===");

$equipment_data = [
  'Cart 001' => 'Wooden cart for hay & feed transport',
  'Cart 002' => 'Metal cart for crop transport',
  'LED Light 001' => 'LED solar light for barn area',
  'LED Light 002' => 'LED solar light for storage area',
  'Fan 001' => 'Ventilation fan for barn cooling',
];

foreach ($equipment_data as $name => $desc) {
  $equipment = create_asset($name, 'equipment', $desc, 'active');
  $created["equipment_" . str_replace(' ', '_', $name)] = $equipment;
  drush_print(dt("Created equipment: !name (ID: @id)", [
    '!name' => $equipment->label(),
    '@id' => $equipment->id(),
  ]));
}

// ============================================================================
// 5. VACCINATION LOGS
// ============================================================================
drush_print("\n=== Creating Vaccination Logs ===");

$vaccination_data = [
  $cattle_1->id() => [
    ['Foot & Mouth Disease Vaccination', strtotime('-30 days'), 'FMD vaccine administered to Jersey-Ferson herd'],
    ['Brucellosis Screening', strtotime('-60 days'), 'Routine screening completed'],
  ],
  $cattle_2->id() => [
    ['Foot & Mouth Disease Vaccination', strtotime('-15 days'), 'FMD booster dose for Neeli Ravi herd'],
    ['Anthrax Vaccination', strtotime('-90 days'), 'Annual anthrax prevention'],
  ],
  $cattle_3->id() => [
    ['Foot & Mouth Disease Vaccination', strtotime('-20 days'), 'Initial FMD vaccination for Sahewal herd'],
  ],
];

foreach ($vaccination_data as $asset_id => $vaccinations) {
  foreach ($vaccinations as $vax) {
    $log = create_log(
      $vax[0],
      'activity',
      $asset_id,
      $vax[1],
      $vax[2]
    );

    if ($log->hasField('type')) {
      $log->set('type', 'vaccination');
    }
    $log->save();

    drush_print(dt("Created vaccination log: !name (ID: @id)", [
      '!name' => $log->label(),
      '@id' => $log->id(),
    ]));
  }
}

// ============================================================================
// 6. WEIGHT MEASUREMENTS (in maund)
// ============================================================================
drush_print("\n=== Creating Weight Measurements ===");

// Note: 1 maund = 40 kg. Typical cattle weights:
// - Jersey adult: 400-500 kg = 10-12.5 maund
// - Jersey calf: 150-200 kg = 3.75-5 maund
// - Neeli Ravi adult: 450-550 kg = 11.25-13.75 maund
// - Neeli Ravi calf: 180-220 kg = 4.5-5.5 maund
// - Sahewal adult: 500-600 kg = 12.5-15 maund
// - Sahewal calf: 200-250 kg = 5-6.25 maund

// Get or create 'maund' unit (if not exists, use 'kg' as fallback).
$unit_storage = \Drupal::entityTypeManager()->getStorage('unit');
$maund_units = $unit_storage->loadByProperties(['label' => 'Maund']);
$maund_unit = reset($maund_units) ?: NULL;

// If maund doesn't exist, try to find or fallback to kg
if (!$maund_unit) {
  $kg_units = $unit_storage->loadByProperties(['label' => 'Kilogram']);
  $maund_unit = reset($kg_units);
  drush_print("Note: Using Kilogram instead of Maund (custom unit not yet created)");
} else {
  drush_print("Using Maund unit for weight measurements");
}

if ($maund_unit) {
  $measurements = [
    $cattle_1->id() => [
      [11.5, strtotime('-7 days'), 'Jersey-Ferson adult female weight check'],
      [10.8, strtotime('-7 days'), 'Jersey-Ferson adult female weight check'],
      [4.2, strtotime('-7 days'), 'Jersey-Ferson calf weight'],
    ],
    $cattle_2->id() => [
      [12.5, strtotime('-5 days'), 'Neeli Ravi adult female weight'],
      [13.0, strtotime('-5 days'), 'Neeli Ravi adult female weight'],
      [5.0, strtotime('-5 days'), 'Neeli Ravi female calf weight'],
      [4.8, strtotime('-5 days'), 'Neeli Ravi female calf weight'],
    ],
    $cattle_3->id() => [
      [13.2, strtotime('-10 days'), 'Sahewal-Cholistani adult female weight'],
      [5.5, strtotime('-10 days'), 'Sahewal-Cholistani male calf weight'],
    ],
  ];

  foreach ($measurements as $asset_id => $weight_list) {
    foreach ($weight_list as $measurement) {
      $quantity = create_quantity(
        $asset_id,
        'weight',
        $measurement[0],
        $maund_unit->id(),
        $measurement[2]
      );

      // Set timestamp via log if quantity doesn't have timestamp.
      $asset = Asset::load($asset_id);
      drush_print(dt("Created weight measurement: !value maund for !asset", [
        '!value' => $measurement[0],
        '!asset' => $asset->label(),
      ]));
    }
  }
} else {
  drush_print("Warning: No unit found for weight measurements. Skipping weight data.");
}

// ============================================================================
// SUMMARY
// ============================================================================
drush_print("\n=== Seed Data Creation Complete ===");
drush_print(dt("Total assets created: @count", [
  '@count' => count($created),
]));
drush_print("\nCreated entities:");
foreach ($created as $key => $entity) {
  drush_print(dt("  - @key: @name (ID: @id)", [
    '@key' => $key,
    '@name' => $entity->label(),
    '@id' => $entity->id(),
  ]));
}

drush_print("\nSeed data ready for development & testing.\n");
