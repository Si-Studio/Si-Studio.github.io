// Cookie Consent Banner — GDPR-compliant analytics consent
// Shows a consent banner on first visit. Stores preference in localStorage.
// If accepted, loads Google Analytics (or other tracking) script.
(function () {
  'use strict';

  var CONSENT_KEY = 'si_cookie_consent';
  var banner = null;

  // Check if consent was already given
  var consent = localStorage.getItem(CONSENT_KEY);
  if (consent === 'accepted') {
    loadAnalytics();
    return;
  }
  if (consent === 'rejected') {
    return; // User already said no
  }

  // Show consent banner after page is ready
  document.addEventListener('si:page-ready', showBanner);

  function showBanner() {
    banner = document.createElement('div');
    banner.className = 'consent-banner';
    banner.setAttribute('role', 'dialog');
    banner.setAttribute('aria-label', 'Zgoda na pliki cookies');
    banner.innerHTML =
      '<div class="consent-banner__inner">' +
        '<p class="consent-banner__text">Ta strona używa plików cookies w celu analizy ruchu. ' +
        '<a href="/privacy/" class="consent-banner__link">Polityka prywatności</a></p>' +
        '<div class="consent-banner__actions">' +
          '<button class="consent-banner__btn consent-banner__btn--accept" type="button">Akceptuję</button>' +
          '<button class="consent-banner__btn consent-banner__btn--reject" type="button">Odrzucam</button>' +
        '</div>' +
      '</div>';

    document.body.appendChild(banner);

    // Force reflow for transition
    void banner.offsetHeight;
    banner.classList.add('consent-banner--visible');

    banner.querySelector('.consent-banner__btn--accept').addEventListener('click', function () {
      localStorage.setItem(CONSENT_KEY, 'accepted');
      hideBanner();
      loadAnalytics();
    });

    banner.querySelector('.consent-banner__btn--reject').addEventListener('click', function () {
      localStorage.setItem(CONSENT_KEY, 'rejected');
      hideBanner();
    });
  }

  function hideBanner() {
    if (!banner) return;
    banner.classList.remove('consent-banner--visible');
    setTimeout(function () {
      if (banner && banner.parentNode) {
        banner.parentNode.removeChild(banner);
      }
    }, 300);
  }

  function loadAnalytics() {
    // Replace with your actual Google Analytics or other tracking code
    // Example for GA4:
    // var script = document.createElement('script');
    // script.src = 'https://www.googletagmanager.com/gtag/js?id=G-XXXXXXX';
    // script.async = true;
    // document.head.appendChild(script);
    // script.onload = function() {
    //   window.dataLayer = window.dataLayer || [];
    //   function gtag(){dataLayer.push(arguments);}
    //   gtag('js', new Date());
    //   gtag('config', 'G-XXXXXXX');
    // };
  }
})();
