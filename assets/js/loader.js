(function () {
  'use strict';

  var loader = document.getElementById('page-loader');
  if (!loader) return;

  var FADE_OUT_MS = 600;
  var FORCE_HIDE_MS = 3000;
  var reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var done = false;

  function dispatchReady() {
    if (done) return;
    done = true;
    document.dispatchEvent(new CustomEvent('si:page-ready'));
  }

  function hideLoader() {
    if (done) return;

    if (reducedMotion) {
      // No animation — hide instantly, then dispatch
      loader.classList.add('loader--instant');
      dispatchReady();
      return;
    }

    // Trigger CSS fade-out (600ms)
    loader.classList.add('loader--hidden');

    // Dispatch event after fade-out transition completes
    loader.addEventListener('transitionend', function onEnd(e) {
      if (e.propertyName === 'opacity') {
        loader.removeEventListener('transitionend', onEnd);
        dispatchReady();
      }
    });

    // Fallback if transitionend doesn't fire
    setTimeout(function () {
      dispatchReady();
    }, FADE_OUT_MS + 50);
  }

  // Safety net: force-hide at 3000ms no matter what
  var forceTimer = setTimeout(function () {
    if (!done) {
      loader.classList.add('loader--hidden');
      // For reduced motion, use instant hide
      if (reducedMotion) {
        loader.classList.add('loader--instant');
      }
      dispatchReady();
    }
  }, FORCE_HIDE_MS);

  // On DOMContentLoaded: begin hide sequence
  document.addEventListener('DOMContentLoaded', function () {
    clearTimeout(forceTimer);
    hideLoader();
  });
})();
