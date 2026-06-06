-- PostgreSQL 18.4 Backup, Restore, and PITR Lab
-- Seed data for departments, imaging devices, initial orders, and recovery baseline.

-- Validation note:
-- A foreign key insert initially failed because device reference data was missing
-- from the target database. Parent tables are reseeded first, and order inserts
-- use stable asset_tag lookups instead of hardcoded device_id values.

-- 1. Seed parent table: departments

INSERT INTO clinical.departments (department_name, cost_center)
VALUES
('Radiology', 'RAD-100'),
('Cardiology', 'CARD-200')
ON CONFLICT (department_name) DO UPDATE
SET cost_center = EXCLUDED.cost_center;

-- 2. Seed parent table: imaging devices

INSERT INTO clinical.imaging_devices (asset_tag, device_name, modality, department_id, is_active)
VALUES
(
    'RAD-CT-001',
    'CT Scanner 1',
    'Radiology',
    (SELECT department_id FROM clinical.departments WHERE department_name = 'Radiology'),
    true
),
(
    'RAD-MRI-001',
    'MRI Scanner 1',
    'Radiology',
    (SELECT department_id FROM clinical.departments WHERE department_name = 'Radiology'),
    true
),
(
    'CARD-EKG-001',
    'EKG Cart 1',
    'Cardiology',
    (SELECT department_id FROM clinical.departments WHERE department_name = 'Cardiology'),
    true
),
(
    'CARD-ECHO-001',
    'Echo Workstation 1',
    'Cardiology',
    (SELECT department_id FROM clinical.departments WHERE department_name = 'Cardiology'),
    true
)
ON CONFLICT (asset_tag) DO UPDATE
SET
    device_name = EXCLUDED.device_name,
    modality = EXCLUDED.modality,
    department_id = EXCLUDED.department_id,
    is_active = EXCLUDED.is_active;

-- 3. Seed child table: initial clinical orders
-- Device IDs are resolved by asset_tag to avoid fragile hardcoded surrogate keys.

INSERT INTO clinical.orders (patient_mrn, order_type, order_status, device_id)
SELECT
    v.patient_mrn,
    v.order_type,
    v.order_status,
    d.device_id
FROM (
    VALUES
        ('MRN10001', 'CT', 'Scheduled', 'RAD-CT-001'),
        ('MRN10002', 'MRI', 'Completed', 'RAD-MRI-001'),
        ('MRN10003', 'EKG', 'Scheduled', 'CARD-EKG-001'),
        ('MRN10004', 'Echo', 'Completed', 'CARD-ECHO-001')
) AS v(patient_mrn, order_type, order_status, asset_tag)
JOIN clinical.imaging_devices d
    ON d.asset_tag = v.asset_tag
WHERE NOT EXISTS (
    SELECT 1
    FROM clinical.orders o
    WHERE o.patient_mrn = v.patient_mrn
      AND o.order_type = v.order_type
);

-- 4. Seed recovery event

INSERT INTO admin.recovery_events (event_name, event_note)
SELECT
    'INITIAL_LOAD',
    'Initial clinical imaging and cardiology order data loaded.'
WHERE NOT EXISTS (
    SELECT 1
    FROM admin.recovery_events
    WHERE event_name = 'INITIAL_LOAD'
);

-- 5. Capture restore baseline

INSERT INTO admin.restore_baseline (baseline_name, expected_order_count)
SELECT
    'INITIAL_BASELINE_BEFORE_LOGICAL_BACKUP',
    COUNT(*)
FROM clinical.orders
WHERE NOT EXISTS (
    SELECT 1
    FROM admin.restore_baseline
    WHERE baseline_name = 'INITIAL_BASELINE_BEFORE_LOGICAL_BACKUP'
);

-- 6. Validation output

SELECT * FROM admin.restore_validation;

SELECT
    device_id,
    asset_tag,
    device_name,
    modality,
    department_id,
    is_active
FROM clinical.imaging_devices
ORDER BY device_id;

SELECT
    order_id,
    patient_mrn,
    order_type,
    order_status,
    device_id,
    ordered_at
FROM clinical.orders
ORDER BY order_id;
