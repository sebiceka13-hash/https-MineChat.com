const VERSION = 'minechat-v1.0.45';
const APP_SHELL = [
  '/',
  '/index.html',
  '/manifest.webmanifest',
  '/icons/icon-192.png',
  '/icons/icon-512.png',
  '/logo-custom.png',
  '/favicon.svg',
  '/og-image.svg'
];

self.addEventListener('install', (event) => {
  event.waitUntil((async () => {
    const cache = await caches.open(VERSION);
    await Promise.all(APP_SHELL.map(async (url) => {
      try {
        const res = await fetch(url, { cache: 'reload' });
        if (res && res.ok) await cache.put(url, res.clone());
      } catch { /* skip a missing asset instead of failing the whole install */ }
    }));
    await self.skipWaiting();
  })());
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k !== VERSION).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

function offlinePage() {
  const html =
    '<!doctype html><meta charset="utf-8">' +
    '<meta name="viewport" content="width=device-width,initial-scale=1">' +
    '<title>Mine Chat</title>' +
    '<body style="margin:0;min-height:100vh;display:grid;place-items:center;background:#0a0e1a;color:#eaf0ff;font-family:system-ui,-apple-system,Segoe UI,sans-serif">' +
    '<div style="text-align:center;padding:24px">' +
    '<h1 style="font-size:20px;margin:0 0 8px">Mine Chat</h1>' +
    '<p style="color:#9aa6c0;margin:0 0 14px">Pa lidhje interneti. Provo p\u00ebrs\u00ebri.</p>' +
    '<button onclick="location.reload()" style="font:inherit;padding:10px 18px;border-radius:10px;border:0;background:#2f6fe4;color:#fff;cursor:pointer">Provo p\u00ebrs\u00ebri</button>' +
    '</div></body>';
  return new Response(html, { status: 200, headers: { 'Content-Type': 'text/html; charset=utf-8' } });
}

self.addEventListener('fetch', (event) => {
  const req = event.request;
  if (req.method !== 'GET') return;

  const url = new URL(req.url);

  // APIs are never cached: always live, so auth and chat data are never stale.
  if (url.pathname.startsWith('/api/')) return;

  if (req.mode === 'navigate') {
    event.respondWith((async () => {
      try {
        const res = await fetch(req);
        if (res && res.ok) {
          const cache = await caches.open(VERSION);
          cache.put('/index.html', res.clone()).catch(() => {});
        }
        return res;
      } catch {
        const cached = (await caches.match(req)) || (await caches.match('/index.html'));
        return cached || offlinePage();
      }
    })());
    return;
  }

  if (url.origin !== self.location.origin) return;

  event.respondWith((async () => {
    const cached = await caches.match(req);
    if (cached) return cached;
    try {
      const res = await fetch(req);
      if (res && res.ok) {
        const cache = await caches.open(VERSION);
        cache.put(req, res.clone()).catch(() => {});
      }
      return res;
    } catch {
      return new Response('', { status: 504, statusText: 'Offline' });
    }
  })());
});
