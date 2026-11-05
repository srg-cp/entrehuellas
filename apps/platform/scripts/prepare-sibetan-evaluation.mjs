// Offline evaluation only. Keep the licensed source images outside Git/Storage.
// Dataset/attribution: https://www.lirmm.fr/YT-BB-Dog_Sibetan/ (CC BY 4.0).
import { readFile, readdir, writeFile } from 'node:fs/promises';
import { resolve, join } from 'node:path';
import { createHash } from 'node:crypto';

if (!process.argv[2]) throw new Error('Provide the extracted Sibetan directory containing gt_sibetan.json');
const root = resolve(process.argv[2]);
const groundTruthBytes = await readFile(join(root, 'gt_sibetan.json'));
const groundTruth = JSON.parse(groundTruthBytes);
const individuals = [];
for (const [identity, clusters] of Object.entries(groundTruth).sort((a, b) => Number(a[0]) - Number(b[0]))) {
  if (!/^\d+$/.test(identity) || !Array.isArray(clusters) || !clusters.length || clusters.some(id => !Number.isInteger(id) || id < 0)) {
    throw new Error('Unexpected Sibetan ground-truth structure');
  }
  const images = [];
  for (const cluster of [...clusters].sort((a, b) => a - b)) {
    for (const file of (await readdir(join(root, String(cluster)))).sort()) {
      if (/\.jpg$/i.test(file)) images.push({ file: `${cluster}/${file}`, cluster, camera: file.match(/_C(\d+)/)?.[1] });
    }
  }
  if (images.length < 2) throw new Error('Each identity must have at least two source images');
  individuals.push({ identity, clusters, images });
}
if (individuals.length !== 59) throw new Error('Expected the documented 59 Sibetan identities');
// Reserve singleton tracklets for development and negatives, retaining all
// cross-tracklet individuals for test positives. No model results guide this split.
const singletonIds = individuals.filter(item => item.clusters.length === 1).map(item => item.identity);
if (singletonIds.length < 9) throw new Error('Expected enough singleton tracklets for the fixed split');
const development = new Set(singletonIds.slice(-5));
const negative = new Set(singletonIds.slice(-9, -5));
const entries = [], pairs = [], hashes = new Set();
async function add(individual, image, role, split) {
  const hash = createHash('sha256').update(await readFile(join(root, image.file))).digest('hex');
  if (hashes.has(hash)) throw new Error('Repeated image bytes in the selected evaluation');
  hashes.add(hash);
  entries.push({ authorized: true, identity: `sibetan-${individual.identity}`, role, split,
    species: 'dog', file: image.file, sha256: hash,
    // Controlled equal values neutralize geography/time, isolating visual ranking.
    // These are experiment constants, never inferred capture metadata.
    occurredAt: '2000-01-01T00:00:00Z', latitude: 0, longitude: 0,
  });
}
for (const individual of individuals) {
  const split = development.has(individual.identity) ? 'development' : 'test';
  const gallery = individual.images[0];
  const queries = individual.images.filter(image => image.file !== gallery.file).sort((a, b) =>
    Number(b.camera !== gallery.camera) - Number(a.camera !== gallery.camera) ||
    Number(b.cluster !== gallery.cluster) - Number(a.cluster !== gallery.cluster) || b.file.localeCompare(a.file));
  const query = queries[0];
  await add(individual, query, 'query', split);
  if (!negative.has(individual.identity)) {
    await add(individual, gallery, 'gallery', split);
    if (split === 'test') pairs.push({ identity: individual.identity,
      crossCamera: query.camera !== gallery.camera, crossTracklet: query.cluster !== gallery.cluster });
  }
}
const manifest = {
  provenance: 'Sibetan-v1 (27/10/2025), LIRMM/SEAdogSEA; published individual labels in gt_sibetan.json, not tracklet directory names. Eugênio Dias Ribeiro Neto et al., Background-invariant re-identification of dogs from camera-trap videos in non-controlled environments, Ecological Informatics (2025), DOI:10.1016/j.ecoinf.2025.103547.',
  license: 'CC BY 4.0 — https://creativecommons.org/licenses/by/4.0/',
  source: 'https://www.lirmm.fr/YT-BB-Dog_Sibetan/',
  archive: { url: 'https://www.lirmm.fr/YT-BB-Dog_Sibetan/files/Sibetan.zip',
    sha256: 'df974f837086ebfb25c439f8464c5102e3fb610f4e81b0f1a85a571852a7c2f9' },
  groundTruthSha256: createHash('sha256').update(groundTruthBytes).digest('hex'),
  protocol: 'Deterministic 5 development / 54 test identities: 50 positive queries, 50 gallery cases, 4 negative queries. One image per role/case. Equal experiment constants neutralize time/geography; these are not real event metadata. Cross-camera then cross-tracklet query selection, without viewing scores.',
  limitations: 'Dogs only, cropped camera-trap images from one location/week in 2019. Some pairs share a video/tracklet; repeated frames/background can inflate retrieval. No local Peruvian cases, cats, calibrated thresholds, deployment latency or identification probability is established.',
  testPairs: { positives: pairs.length, crossCamera: pairs.filter(pair => pair.crossCamera).length,
    crossTracklet: pairs.filter(pair => pair.crossTracklet).length },
  entries,
};
const output = join(root, 'evaluation-manifest.json');
await writeFile(output, JSON.stringify(manifest, null, 2) + '\n');
console.log(JSON.stringify({ manifest: output, entries: entries.length, testPairs: manifest.testPairs,
  manifestSha256: createHash('sha256').update(await readFile(output)).digest('hex') }, null, 2));
