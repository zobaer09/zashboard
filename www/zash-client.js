// Minimal client loader stub
async function loadManifest(url = 'manifest.json') {
  try {
    const res = await fetch(url, { cache: 'no-cache' });
    if (!res.ok) throw new Error('Manifest fetch failed');
    const manifest = await res.json();
    console.log('Manifest', manifest);
  } catch (e) {
    console.error(e);
  }
}
loadManifest();
