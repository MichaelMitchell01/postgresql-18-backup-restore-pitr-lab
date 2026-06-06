INSERT INTO clinical.departments (department_name, cost_center)
VALUES
('Radiology', 'RAD-100'),
('Cardiology', 'CARD-200');

INSERT INTO clinical.imaging_devices (asset_tag, device_name, modality, department_id)
VALUES
('RAD-CT-001', 'CT Scanner 1', 'Radiology', 1),
('RAD-MRI-001', 'MRI Scanner 1', 'Radiology', 1),
('CARD-EKG-001', 'EKG Cart 1', 'Cardiology', 2),
('CARD-ECHO-001', 'Echo Workstation 1', 'Cardiology', 2);

INSERT INTO clinical.orders (patient_mrn, order_type, order_status, device_id)
VALUES
('MRN10001', 'CT', 'Scheduled', 1),
('MRN10002', 'MRI', 'Completed', 2),
('MRN10003', 'EKG', 'Scheduled', 3),
('MRN10004', 'Echo', 'Completed', 4);

INSERT INTO admin.recovery_events (event_name, event_note)
VALUES
('INITIAL_LOAD', 'Initial clinical imaging and cardiology order data loaded.');

INSERT INTO admin.restore_baseline (baseline_name, expected_order_count)
SELECT 'INITIAL_BASELINE_BEFORE_LOGICAL_BACKUP', COUNT(*)
FROM clinical.orders;