DELETE FROM clinical.orders
WHERE order_status IN ('Scheduled', 'Completed');

INSERT INTO admin.recovery_events (event_name, event_note)
VALUES
('BAD_DELETE', 'Simulated accidental delete removed active imaging and cardiology orders.');

SELECT * FROM admin.restore_validation;