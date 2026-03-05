// FestNoz Service Worker
// Caching strategy: network-first for API/navigation, cache-first for static assets

const CACHE_VERSION = "v2";
const STATIC_CACHE  = `festnoz-static-${CACHE_VERSION}`;
const API_CACHE     = `festnoz-api-${CACHE_VERSION}`;
const IMAGE_CACHE   = `festnoz-images-${CACHE_VERSION}`;
const API_TIMEOUT_MS = 4000;
const OFFLINE_FALLBACK = "/offline.html";

const PRECACHE_URLS = ["/", OFFLINE_FALLBACK, "/manifest.json", "/icon.png"];

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

  // API routes
  if (url.pathname.startsWith("/api/")) {
    // Never cache auth/account endpoints
    if (
      url.pathname.startsWith("/api/v1/auth") ||
      url.pathname.startsWith("/api/v1/account")
    ) {
      event.respondWith(fetch(request));
      return;
    }

    // Non-GET requests bypass cache
    if (request.method !== "GET") {
      event.respondWith(fetch(request));
      return;
    }

    event.respondWith(networkFirst(request, API_CACHE, API_TIMEOUT_MS));
    return;
  }

  // Vite static assets + images → stale-while-revalidate
  if (url.pathname.startsWith("/vite/") || url.pathname.startsWith("/vite-dev/")) {
    event.respondWith(staleWhileRevalidate(request, STATIC_CACHE));
    return;
  }

  // Images
  if (request.destination === "image") {
    event.respondWith(staleWhileRevalidate(request, IMAGE_CACHE));
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
    if (response && response.ok) {
      cache.put(request, response.clone());
    }
    return response;
  } catch {
    const cached = await cache.match(request);
    return cached || Response.error();
  }
}

// Cache-first: serve from cache, update cache in background if outdated
async function staleWhileRevalidate(request, cacheName) {
  const cache = await caches.open(cacheName);
  const cached = await cache.match(request);

  const networkPromise = fetch(request)
    .then((response) => {
      if (response && response.ok) {
        cache.put(request, response.clone());
      }
      return response;
    })
    .catch(() => null);

  if (cached) {
    return cached;
  }

  const response = await networkPromise;
  return response || Response.error();
}

// Navigation handler: network-first, fall back to cached "/" then /offline.html
async function navigationHandler(request) {
  const cache = await caches.open(STATIC_CACHE);
  try {
    const response = await fetch(request);
    if (response.ok) cache.put(request, response.clone());
    return response;
  } catch {
    const cached =
      (await cache.match(request)) ||
      (await cache.match("/")) ||
      (await cache.match(OFFLINE_FALLBACK));
    return cached || Response.error();
  }
}

// ── Background Sync ─────────────────────────────────────────────────────────
self.addEventListener("sync", (event) => {
  if (event.tag === "festnoz-refresh") {
    event.waitUntil(refreshCachedData());
  }
});

async function refreshCachedData() {
  const cache = await caches.open(API_CACHE);
  const requests = await cache.keys();

  await Promise.all(
    requests.map(async (request) => {
      try {
        const response = await fetch(request);
        if (response && response.ok) {
          await cache.put(request, response.clone());
        }
      } catch {
        // Ignore background refresh failures
      }
    })
  );
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

