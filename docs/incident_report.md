# Incident Report: PostgreSQL PITR Recovery Test

## Incident Summary

A simulated accidental DELETE removed active imaging and cardiology orders from the `clinical.orders` table.

## Impact

Scheduled and completed imaging/cardiology orders were removed from the production-style lab database.

## Detection

The issue was detected through validation queries against `admin.restore_validation`, which showed an unexpected drop in total order count.

## Recovery Method

Recovery was performed using:

- Physical base backup from `pg_basebackup`
- Archived WAL files
- `restore_command`
- `recovery.signal`
- `recovery_target_time`
- Restored PostgreSQL instance on port 5433

## Result

The restored database recovered to the selected timestamp before the destructive DELETE. Good data inserted after the base backup was preserved. The destructive DELETE was excluded.

## Lessons Learned

- Logical backups are useful for object-level restore but do not support PITR.
- PITR requires a valid base backup and an unbroken WAL archive chain.
- WAL archiving must be tested before relying on it.
- Recovery validation queries are mandatory.

- ## Validation Issue Encountered

During the post-base-backup insert step, PostgreSQL rejected new rows in `clinical.orders` because the referenced `device_id` values were not present in `clinical.imaging_devices`.

Error:

`ERROR: insert or update on table "orders" violates foreign key constraint "orders_device_id_fkey"`

Root cause:

Foreign key validation failed because device reference data was missing from the target database. Issue corrected by reseeding parent tables before inserting child order records.

Resolution:

The insert logic was updated to reference devices by stable business keys, such as `asset_tag`, instead of hardcoded surrogate key values like `device_id = 1`.
