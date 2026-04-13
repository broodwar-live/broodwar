// broodwar.live — minimal client-side JS
// No framework. Just fetch() and DOM.

// Service worker registration
if ("serviceWorker" in navigator) {
  navigator.serviceWorker.register("/sw.js")
}

// Theme toggle (exposed globally for onclick handlers in base.html)
window.setTheme = function(theme) {
  if (theme === "system") {
    localStorage.removeItem("bwl:theme")
    document.documentElement.removeAttribute("data-theme")
  } else {
    localStorage.setItem("bwl:theme", theme)
    document.documentElement.setAttribute("data-theme", theme)
  }
}
