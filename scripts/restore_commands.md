# Restore Commands Used

## Physical Base Backup

```powershell
$env:PGPASSWORD = "REDACTED"

& "C:\Program Files\PostgreSQL\18\bin\pg_basebackup.exe" `
  -h localhost `
  -p 5432 `
  -U postgres `
  -D "C:\pg_dba_lab\base_backups\base_001" `
  -Fp `
  -Xs `
  -P `
  -v

Remove-Item Env:\PGPASSWORD