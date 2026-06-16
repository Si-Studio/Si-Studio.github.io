/**
 * Scroll Animations — Intersection Observer reveals
 * Observes all [data-animate] elements and adds .is-visible when they
 * enter at least 15% of the viewport. One-time trigger (unobserves after).
 *
 * Animation classes (CSS-driven): fade-up, fade-in, scale-in
 * Uses only transform + opacity (GPU-composited).
 * Duration range enforced in SCSS: 150ms–1000ms.
 *
 * Deferred: waits for DOMContentLoaded + si:page-ready custom event.
 * prefers-reduced-motion: elements start in final state; observer never created.
 */
(function () {
  'use strict';

  var THRESHOLD = 0.15;

  /**
   * Initialise the scroll-animation observer.
   * Called only after both DOMContentLoaded and si:page-ready have fired.
   */
  function init() {
    // If reduced motion is preferred, ensure all animated elements are
    // visible immediately and skip observer creation entirely.
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
      var elements = document.querySelectorAll('[data-animate]');
      for (var i = 0; i < elements.length; i++) {
        elements[i].classList.add('is-visible');
      }
      return;
    }

    var observer = new IntersectionObserver(function (entries) {
      // Collect newly-intersecting entries and stagger their reveal
      var revealed = [];
      for (var i = 0; i < entries.length; i++) {
        if (entries[i].isIntersecting) {
          revealed.push(entries[i].target);
          observer.unobserve(entries[i].target);
        }
      }

      // Stagger: 80ms between each element in the same batch
      for (var k = 0; k < revealed.length; k++) {
        (function (el, delay) {
          if (delay === 0) {
            el.classList.add('is-visible');
          } else {
            setTimeout(function () {
              el.classList.add('is-visible');
            }, delay);
          }
        })(revealed[k], k * 80);
      }
    }, { threshold: THRESHOLD });

    var targets = document.querySelectorAll('[data-animate]');
    for (var j = 0; j < targets.length; j++) {
      observer.observe(targets[j]);
    }
  }

  // --- Deferred startup logic ---
  // Both conditions must be met before init() runs:
  //   1. DOMContentLoaded has fired
  //   2. si:page-ready custom event has fired (loader finished)

  var domReady = false;
  var pageReady = false;

  function tryInit() {
    if (domReady && pageReady) {
      init();
    }
  }

  // DOMContentLoaded may have already fired if this script loads late.
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function () {
      domReady = true;
      tryInit();
    });
  } else {
    domReady = true;
  }

  document.addEventListener('si:page-ready', function () {
    pageReady = true;
    tryInit();
  });
})();
