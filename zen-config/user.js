// Reduces disk I/O but may speed up revisits if you have enough RAM
user_pref("browser.cache.disk.enable", false);

// Decreases minimum interval between content reflows - improves perceived page loading speed
user_pref("content.notify.interval", 100000);

// Increases canvas cache size - improves performance for graphics-intensive pages
user_pref("gfx.canvas.accelerated.cache-size", 512);

// Increases maximum connections - improves loading speed for sites with many resources
user_pref("network.http.max-connections", 1800);

// Increases persistent connections per server - improves loading performance
user_pref("network.http.max-persistent-connections-per-server", 10);

// Disables HTTP request pacing - improves performance
user_pref("network.http.pacing.requests.enabled", false);

// Disables OCSP checking of certificate revocation - improves performance
user_pref("security.OCSP.enabled", 0);

// Enables CRLite in enforcing mode - improves performance of certificate checks
user_pref("security.pki.crlite_mode", 2);
