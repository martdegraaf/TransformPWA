/* Start the service worker and cache all of the app's content */
self.addEventListener('install', function(e) {
  e.waitUntil(
    caches.open(cacheName).then(function(cache) {
      return cache.addAll(filesToCache);
    })
  );
});

/* Serve cached content when offline */
self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request).then(response => {
      // Return the cached response if available
      if (response) {
        return response;
      }

      // Otherwise, fetch the request and cache it for future use
      return fetch(event.request).then(response => {
        // Clone the response as it can only be consumed once
        const clonedResponse = response.clone();

        caches.open('my-cache').then(cache => {
          cache.put(event.request, clonedResponse);
        });

        return response;
      });
    })
  );
});