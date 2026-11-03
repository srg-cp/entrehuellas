[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$databaseRoot = Split-Path -Parent $PSScriptRoot
$repositoryRoot = Split-Path -Parent $databaseRoot
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/042_remove_private_sightings.json'
$migrationPath = Join-Path $repositoryRoot 'supabase/migrations/20261029004200_remove_private_sightings.sql'
$patchPath = Join-Path $databaseRoot 'patchs/042_patch_remove_private_sightings.sql'
[IO.File]::WriteAllText($patchPath, [IO.File]::ReadAllText($migrationPath), [Text.UTF8Encoding]::new($false))
Write-Output 'Generado database/patchs/042_patch_remove_private_sightings.sql.'
