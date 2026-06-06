# PostgreSQL 18.4 Backup, Restore, and PITR Validation Report

## Environment

- OS: Windows 11
- PostgreSQL: 18.4
- pgAdmin: 4 v9.15
- Primary port: 5432
- PITR restore port: 5433

## Backup Types Tested

| Backup Type | Tool | Result |
|---|---|---|
| Logical custom backup | pgAdmin / pg_dump | Successful |
| Logical restore | pgAdmin / pg_restore | Successful |
| Physical base backup | pg_basebackup | Successful |
| Backup verification | pg_verifybackup | Successful |
| WAL archiving | archive_command | Successful |
| PITR restore | recovery.signal + restore_command | Successful |

## PITR Scenario

A destructive DELETE removed scheduled and completed imaging/cardiology orders.

Recovery target time:

`PASTE_TIMESTAMP_HERE`

## Validation Results

| Check | Expected | Actual | Status |
|---|---:|---:|---|
| Orders before damage | 6 | 6 | Pass |
| BAD_DELETE event after PITR | 0 | 0 | Pass |
| Restored cluster online | Yes | Yes | Pass |
| Restored cluster promoted | Yes | Yes | Pass |

## Evidence

Screenshots are stored in `/screenshots`.