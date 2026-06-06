-- PostgreSQL 18.4 Backup, Restore, and PITR Lab
-- Validation queries used before backup, after logical restore, after damage, and after PITR.

-- 1. Confirm current database
SELECT current_database() AS connected_database;

-- 2. Validate schemas exist
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name IN ('clinical', 'admin')
ORDER BY schema_name;

-- 3. Validate table row counts
SELECT 'clinical.departments' AS table_name, COUNT(*) AS row_count
FROM clinical.departments

UNION ALL

SELECT 'clinical.imaging_devices' AS table_name, COUNT(*) AS row_count
FROM clinical.imaging_devices

UNION ALL

SELECT 'clinical.orders' AS table_name, COUNT(*) AS row_count
FROM clinical.orders

UNION ALL

SELECT 'admin.recovery_events' AS table_name, COUNT(*) AS row_count
FROM admin.recovery_events

UNION ALL

SELECT 'admin.restore_baseline' AS table_name, COUNT(*) AS row_count
FROM admin.restore_baseline
ORDER BY table_name;

-- 4. Validate restore summary view
SELECT *
FROM admin.restore_validation;

-- 5. Validate imaging devices
SELECT 
    device_id,
    asset_tag,
    device_name,
    modality,
    department_id,
    is_active,
    created_at
FROM clinical.imaging_devices
ORDER BY device_id;

-- 6. Validate clinical orders
SELECT 
    order_id,
    patient_mrn,
    order_type,
    order_status,
    device_id,
    ordered_at
FROM clinical.orders
ORDER BY order_id;

-- 7. Validate recovery event timeline
SELECT 
    event_id,
    event_name,
    event_note,
    event_time
FROM admin.recovery_events
ORDER BY event_id;

-- 8. Validate baseline records
SELECT 
    baseline_id,
    baseline_name,
    expected_order_count,
    captured_at
FROM admin.restore_baseline
ORDER BY baseline_id;

-- 9. Check for orphaned orders
SELECT 
    o.order_id,
    o.patient_mrn,
    o.device_id
FROM clinical.orders o
LEFT JOIN clinical.imaging_devices d
    ON o.device_id = d.device_id
WHERE d.device_id IS NULL;

-- Expected result: zero rows.

-- 10. Validate WAL archiving status
SELECT 
    archived_count,
    last_archived_wal,
    last_archived_time,
    failed_count,
    last_failed_wal,
    last_failed_time
FROM pg_stat_archiver;