// broodwar.live service worker
// Strategy: network-first for pages (LiveView needs fresh content),
// cache-first for static assets, offline fallback for navigation.

const CACHE_NAME = "bwl-v1"

const PRECACHE_URLS = [
  "/",
  "/offline"
]

// Install: precache the app shell
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(PRECACHE_URLS))
  )
  self.skipWaiting()
})

// Activate: clean up old caches
self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k)))
    )
  )
  self.clients.claim()
})

// Fetch: route requests to the right strategy
self.addEventListener("fetch", (event) => {
  const {request} = event
  const url = new URL(request.url)

  // Skip non-GET and cross-origin requests
  if (request.method !== "GET" || url.origin !== self.location.origin) return

  // Skip LiveView websocket and long-poll connections
  if (url.pathname.startsWith("/live")) return

  // Skip Phoenix live reload in development
  if (url.pathname.startsWith("/phoenix")) return

  // Static assets: cache-first
  if (url.pathname.startsWith("/assets/") || url.pathname.startsWith("/images/") || url.pathname.startsWith("/fonts/")) {
    event.respondWith(cacheFirst(request))
    return
  }

  // HTML navigation: network-first with offline fallback
  if (request.headers.get("accept")?.includes("text/html")) {
    event.respondWith(networkFirst(request))
    return
  }

  // API and everything else: network-only (don't cache dynamic data)
})

async function cacheFirst(request) {
  const cached = await caches.match(request)
  if (cached) return cached

  try {
    const response = await fetch(request)
    if (response.ok) {
      const cache = await caches.open(CACHE_NAME)
      cache.put(request, response.clone())
    }
    return response
  } catch {
    return new Response("", {status: 408})
  }
}

async function networkFirst(request) {
  try {
    const response = await fetch(request)
    if (response.ok) {
      const cache = await caches.open(CACHE_NAME)
      cache.put(request, response.clone())
    }
    return response
  } catch {
    const cached = await caches.match(request)
    if (cached) return cached

    // Offline fallback for navigation requests
    const fallback = await caches.match("/offline")
    if (fallback) return fallback

    return new Response("Offline", {status: 503, headers: {"Content-Type": "text/plain"}})
  }
}
