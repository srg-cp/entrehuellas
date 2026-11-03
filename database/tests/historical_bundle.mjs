import {readFile} from 'node:fs/promises';
// Explicit pre-042 baseline for tests of the retired migrations, not current product behavior.
export async function historicalBundle(){const sql=await readFile(new URL('../run_all.sql',import.meta.url),'utf8');return sql.split('-- Source: database/functions/136_remove_private_sightings.sql')[0]+'\ncommit;\n';}
