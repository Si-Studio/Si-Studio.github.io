// Navigation — mobile menu toggle, scroll state, focus trap
// Requirement 2: Site-Wide Navigation
(function () {
  'use strict';

  // -------------------------------------------------------------------------
  // Reduced-motion check
  // -------------------------------------------------------------------------
  var prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');

  // -------------------------------------------------------------------------
  // Elements
  // -------------------------------------------------------------------------
  var header = document.querySelector('.site-header');
  var toggle = document.querySelector('.site-nav__toggle');
  var menu = document.getElementById('mobile-menu');
  var closeBtn = menu ? menu.querySelector('.mobile-menu__close') : null;

  // -------------------------------------------------------------------------
  // Scroll listener: toggle is-scrolled class at threshold
  // -------------------------------------------------------------------------
  function initScrollListener() {
    if (!header) return;

    var threshold = parseInt(header.getAttribute('data-scroll-threshold'), 10) || 80;
    var isScrolled = false;

    function onScroll() {
      var scrollY = window.pageYOffset || document.documentElement.scrollTop;
      if (scrollY > threshold && !isScrolled) {
        header.classList.add('is-scrolled');
        isScrolled = true;
      } else if (scrollY <= threshold && isScrolled) {
        header.classList.remove('is-scrolled');
        isScrolled = false;
      }
    }

    // Check initial state
    onScroll();
    window.addEventListener('scroll', onScroll, { passive: true });
  }

  // -------------------------------------------------------------------------
  // Mobile menu open/close
  // -------------------------------------------------------------------------
  function openMenu() {
    if (!menu || !toggle) return;

    menu.removeAttribute('hidden');
    // Force reflow so CSS transition triggers
    void menu.offsetHeight;
    menu.classList.add('is-open');
    toggle.setAttribute('aria-expanded', 'true');
    document.body.style.overflow = 'hidden';

    // Move focus into the menu
    var firstFocusable = getFirstFocusable(menu);
    if (firstFocusable) {
      firstFocusable.focus();
    }

    // Attach listeners
    document.addEventListener('keydown', onMenuKeydown);
  }

  function closeMenu() {
    if (!menu || !toggle) return;

    menu.classList.remove('is-open');
    toggle.setAttribute('aria-expanded', 'false');
    document.body.style.overflow = '';

    // Remove listeners
    document.removeEventListener('keydown', onMenuKeydown);

    // Wait for transition before hiding (unless reduced motion)
    if (prefersReducedMotion.matches) {
      menu.setAttribute('hidden', '');
    } else {
      // Match the 300ms CSS opacity transition
      setTimeout(function () {
        if (!menu.classList.contains('is-open')) {
          menu.setAttribute('hidden', '');
        }
      }, 300);
    }

    // Return focus to the hamburger toggle
    toggle.focus();
  }

  // -------------------------------------------------------------------------
  // Focus trap within mobile menu
  // -------------------------------------------------------------------------
  function getFocusableElements(container) {
    var selectors = [
      'a[href]',
      'button:not([disabled])',
      'input:not([disabled])',
      'textarea:not([disabled])',
      'select:not([disabled])',
      '[tabindex]:not([tabindex="-1"])'
    ];
    return Array.prototype.slice.call(
      container.querySelectorAll(selectors.join(','))
    );
  }

  function getFirstFocusable(container) {
    var elements = getFocusableElements(container);
    return elements.length > 0 ? elements[0] : null;
  }

  function trapFocus(e) {
    if (!menu) return;

    var focusable = getFocusableElements(menu);
    if (focusable.length === 0) return;

    var first = focusable[0];
    var last = focusable[focusable.length - 1];

    if (e.shiftKey && document.activeElement === first) {
      e.preventDefault();
      last.focus();
    } else if (!e.shiftKey && document.activeElement === last) {
      e.preventDefault();
      first.focus();
    }
  }

  // -------------------------------------------------------------------------
  // Keyboard handler while menu is open
  // -------------------------------------------------------------------------
  function onMenuKeydown(e) {
    if (e.key === 'Escape' || e.key === 'Esc') {
      e.preventDefault();
      closeMenu();
      return;
    }

    if (e.key === 'Tab') {
      trapFocus(e);
    }
  }

  // -------------------------------------------------------------------------
  // Event bindings
  // -------------------------------------------------------------------------
  function initMenuToggle() {
    if (!toggle || !menu) return;

    toggle.addEventListener('click', function () {
      var isExpanded = toggle.getAttribute('aria-expanded') === 'true';
      if (isExpanded) {
        closeMenu();
      } else {
        openMenu();
      }
    });

    // Close button inside mobile menu
    if (closeBtn) {
      closeBtn.addEventListener('click', function () {
        closeMenu();
      });
    }

    // Close menu when a link inside it is clicked
    var menuLinks = menu.querySelectorAll('.mobile-menu__links a');
    for (var i = 0; i < menuLinks.length; i++) {
      menuLinks[i].addEventListener('click', function () {
        closeMenu();
      });
    }
  }

  // -------------------------------------------------------------------------
  // Initialize
  // -------------------------------------------------------------------------
  initScrollListener();
  initMenuToggle();
})();
