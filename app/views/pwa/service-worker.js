// FestNoz Service Worker
// Caching strategy: network-first for API/navigation, cache-first for static assets

const CACHE_VERSION = "v1";
const STATIC_CACHE  = `festnoz-static-${CACHE_VERSION}`;
const API_CACHE     = `festnoz-api-${CACHE_VERSION}`;
const IMAGE_CACHE   = `festnoz-images-${CACHE_VERSION}`;

const PRECACHE_URLS = ["/", "/offline.html"];

// ── Install ──────────────────────────────────────────────────────────────────
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(STATIC_CACHE).then((cache) => cache.addAll(PRECACHE_URLS))
  );
  self.skipWaiting();
});

// ── Activate (clean up old caches) ───────────────────────────────────────────
self.addEventListener("activate", (event) => {
  const validCaches = [STATIC_CACHE, API_CACHE, IMAGE_CACHE];
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys
          .filter((key) => !validCaches.includes(key))
          .map((key) => caches.delete(key))
      )
    )
  );
  self.clients.claim();
});

// ── Fetch ─────────────────────────────────────────────────────────────────────
self.addEventListener("fetch", (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // Only handle same-origin requests
  if (url.origin !== location.origin) return;

  // API routes → network-first (fresh data preferred)
  if (url.pathname.startsWith("/api/")) {
    event.respondWith(networkFirst(request, API_CACHE, 5000));
    return;
  }

  // Vite static assets (hashed filenames — effectively immutable) → cache-first
  if (url.pathname.startsWith("/vite/") || url.pathname.startsWith("/vite-dev/")) {
    event.respondWith(cacheFirst(request, STATIC_CACHE));
    return;
  }

  // Images → cache-first with network fallback (long-lived)
  if (request.destination === "image") {
    event.respondWith(cacheFirst(request, IMAGE_CACHE));
    return;
  }

  // Navigation (HTML page) → network-first, offline fallback
  if (request.mode === "navigate") {
    event.respondWith(navigationHandler(request));
    return;
  }

  // Everything else → network-first
  event.respondWith(networkFirst(request, STATIC_CACHE));
});

// ── Strategies ───────────────────────────────────────────────────────────────

// Network-first: try network, fall back to cache; optionally with a timeout
async function networkFirst(request, cacheName, timeoutMs) {
  const cache = await caches.open(cacheName);
  try {
    const networkPromise = fetch(request);
    const response = timeoutMs
      ? await Promise.race([networkPromise, timeout(timeoutMs)])
      : await networkPromise;
    if (response && response.status === 200) {
      cache.put(request, response.clone());
    }
    return response;
  } catch {
    const cached = await cache.match(request);
    return cached || Response.error();
  }
}

// Cache-first: serve from cache, update cache in background if outdated
async function cacheFirst(request, cacheName) {
  const cache = await caches.open(cacheName);
  const cached = await cache.match(request);
  if (cached) return cached;
  try {
    const response = await fetch(request);
    if (response.status === 200) cache.put(request, response.clone());
    return response;
  } catch {
    return Response.error();
  }
}

// Navigation handler: network-first, fall back to cached "/" then /offline.html
async function navigationHandler(request) {
  const cache = await caches.open(STATIC_CACHE);
  try {
    const response = await fetch(request);
    if (response.status === 200) cache.put(request, response.clone());
    return response;
  } catch {
    const cached =
      (await cache.match(request)) ||
      (await cache.match("/")) ||
      (await cache.match("/offline.html"));
    return cached || Response.error();
  }
}

// Timeout utility
function timeout(ms) {
  return new Promise((_, reject) =>
    setTimeout(() => reject(new Error("Network timeout")), ms)
  );
}

// ── Push Notifications ────────────────────────────────────────────────────────
self.addEventListener("push", async (event) => {
  if (!event.data) return;
  const { title, options } = await event.data.json();
  event.waitUntil(
    self.registration.showNotification(title, {
      icon: "/icon.png",
      badge: "/icon.png",
      ...options,
    })
  );
});

self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  const path = event.notification.data?.path || "/";
  event.waitUntil(
    clients.matchAll({ type: "window" }).then((clientList) => {
      const existing = clientList.find(
        (c) => new URL(c.url).pathname === path && "focus" in c
      );
      if (existing) return existing.focus();
      if (clients.openWindow) return clients.openWindow(path);
    })
  );
});

