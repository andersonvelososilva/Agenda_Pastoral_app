const CACHE_NAME = "agenda-pastoral-cache-v1";
const ASSETS = [
  "/",
  "/churches",
  "/calendar",
  "/assets/css/app.css",
  "/assets/js/app.js",
  "/favicon.ico",
  "/manifest.json",
  "/images/logo.png",
  "/images/logo.svg"
];

// Install Event
self.addEventListener("install", event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => {
      console.log("Caching shell assets");
      return cache.addAll(ASSETS).catch(err => {
        console.warn("Failed to add some assets to cache:", err);
      });
    })
  );
  self.skipWaiting();
});

// Activate Event
self.addEventListener("activate", event => {
  event.waitUntil(
    caches.keys().then(keys => {
      return Promise.all(
        keys.filter(key => key !== CACHE_NAME).map(key => caches.delete(key))
      );
    })
  );
  self.clients.claim();
});

// Fetch Event
self.addEventListener("fetch", event => {
  // Only cache GET requests and ignore WebSocket/LiveView connections
  if (event.request.method !== "GET" || event.request.url.includes("/live")) {
    return;
  }

  event.respondWith(
    caches.match(event.request).then(cachedResponse => {
      // Fetch from network and update cache in background
      const fetchPromise = fetch(event.request).then(networkResponse => {
        if (networkResponse && networkResponse.status === 200) {
          const responseToCache = networkResponse.clone();
          caches.open(CACHE_NAME).then(cache => {
            cache.put(event.request, responseToCache);
          });
        }
        return networkResponse;
      }).catch(() => {
        // Fallback for offline page requests
        if (event.request.mode === "navigate") {
          return caches.match("/");
        }
      });

      return cachedResponse || fetchPromise;
    })
  );
});
