// Page Transition — fade-out on internal navigation, fade-in on load
// Requirement 16.5: page transition 300–800ms
(function () {
  'use strict';

  var TRANSITION_MS = 400;
  var reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  // Skip transitions entirely if reduced motion is preferred
  if (reducedMotion) return;

  var main = document.querySelector('main');
  if (!main) return;

  // On internal link click: fade out, then navigate
  document.addEventListener('click', function (e) {
    var link = e.target.closest('a[href]');
    if (!link) return;

    var href = link.getAttribute('href');

    // Skip external links, anchors, special protocols
    if (!href) return;
    if (href.startsWith('#')) return;
    if (href.startsWith('mailto:')) return;
    if (href.startsWith('tel:')) return;
    if (link.target === '_blank') return;
    if (link.hasAttribute('download')) return;

    // Skip if modifier key held (open in new tab)
    if (e.metaKey || e.ctrlKey || e.shiftKey) return;

    // Only handle same-origin links
    try {
      var url = new URL(href, window.location.origin);
      if (url.origin !== window.location.origin) return;
    } catch (err) {
      return;
    }

    e.preventDefault();
    main.classList.add('page-exit');

    setTimeout(function () {
      window.location.href = href;
    }, TRANSITION_MS);
  });
})();
