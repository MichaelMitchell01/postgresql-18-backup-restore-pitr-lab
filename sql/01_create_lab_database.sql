CREATE SCHEMA clinical;
CREATE SCHEMA admin;

CREATE TABLE clinical.departments (
    department_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_name varchar(100) NOT NULL UNIQUE,
    cost_center varchar(25) NOT NULL UNIQUE
);

CREATE TABLE clinical.imaging_devices (
    device_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    asset_tag varchar(50) NOT NULL UNIQUE,
    device_name varchar(150) NOT NULL,
    modality varchar(50) NOT NULL CHECK (modality IN ('Radiology', 'Cardiology')),
    department_id integer NOT NULL REFERENCES clinical.departments(department_id),
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);

CREATE TABLE clinical.orders (
    order_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_mrn varchar(25) NOT NULL,
    order_type varchar(50) NOT NULL CHECK (order_type IN ('X-Ray', 'MRI', 'CT', 'EKG', 'Echo')),
    order_status varchar(50) NOT NULL CHECK (order_status IN ('Scheduled', 'Completed', 'Cancelled')),
    device_id integer NOT NULL REFERENCES clinical.imaging_devices(device_id),
    ordered_at timestamptz NOT NULL DEFAULT clock_timestamp()
);

CREATE TABLE admin.recovery_events (
    event_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_name varchar(150) NOT NULL,
    event_note text NOT NULL,
    event_time timestamptz NOT NULL DEFAULT clock_timestamp()
);

CREATE TABLE admin.restore_baseline (
    baseline_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    baseline_name varchar(150) NOT NULL,
    expected_order_count integer NOT NULL,
    captured_at timestamptz NOT NULL DEFAULT clock_timestamp()
);

CREATE VIEW admin.restore_validation AS
SELECT
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (WHERE order_status = 'Scheduled') AS scheduled_orders,
    COUNT(*) FILTER (WHERE order_status = 'Completed') AS completed_orders,
    COUNT(*) FILTER (WHERE order_status = 'Cancelled') AS cancelled_orders,
    MIN(ordered_at) AS earliest_order,
    MAX(ordered_at) AS latest_order
FROM clinical.orders;