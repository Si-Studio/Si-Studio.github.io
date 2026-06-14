// Lightbox — full-screen image viewer
// Requirement 3.7, 8.1, 8.7
(function() {
  'use strict';

  var lightbox = document.getElementById('lightbox');
  if (!lightbox) return;

  var closeBtn = lightbox.querySelector('.lightbox__close');
  var prevBtn = lightbox.querySelector('.lightbox__prev');
  var nextBtn = lightbox.querySelector('.lightbox__next');
  var backdrop = lightbox.querySelector('.lightbox__backdrop');
  var imageEl = lightbox.querySelector('.lightbox__image');

  var images = [];
  var currentIndex = 0;
  var triggerElement = null;
  var isOpen = false;

  // Swipe tracking
  var pointerStartX = 0;
  var pointerEndX = 0;
  var SWIPE_THRESHOLD = 50;

  // Focus trap elements (close, prev, next)
  var focusableElements = [closeBtn, prevBtn, nextBtn];

  // -------------------------------------------------------------------------
  // Initialization — collect all lightbox-enabled images
  // -------------------------------------------------------------------------
  function init() {
    var triggers = document.querySelectorAll('[data-lightbox]');
    if (!triggers.length) return;

    for (var i = 0; i < triggers.length; i++) {
      images.push({
        src: triggers[i].getAttribute('data-lightbox') || triggers[i].src,
        alt: triggers[i].alt || ''
      });
      triggers[i].setAttribute('data-lightbox-index', i);
      triggers[i].addEventListener('click', onTriggerClick);
    }
  }

  // -------------------------------------------------------------------------
  // Open lightbox
  // -------------------------------------------------------------------------
  function open(index, trigger) {
    if (isOpen) return;
    isOpen = true;
    currentIndex = index;
    triggerElement = trigger;

    showImage(currentIndex, false);
    lightbox.removeAttribute('hidden');
    document.body.style.overflow = 'hidden';

    // Fade in (opacity transition handled by CSS class)
    // Force reflow before adding visible class for transition
    void lightbox.offsetHeight;
    lightbox.classList.add('lightbox--visible');

    // Bind events while open
    document.addEventListener('keydown', onKeyDown);
    lightbox.addEventListener('pointerdown', onPointerDown);
    lightbox.addEventListener('pointerup', onPointerUp);

    // Focus the close button
    closeBtn.focus();
  }

  // -------------------------------------------------------------------------
  // Close lightbox
  // -------------------------------------------------------------------------
  function close() {
    if (!isOpen) return;
    isOpen = false;

    lightbox.classList.remove('lightbox--visible');

    // Unbind events
    document.removeEventListener('keydown', onKeyDown);
    lightbox.removeEventListener('pointerdown', onPointerDown);
    lightbox.removeEventListener('pointerup', onPointerUp);

    // After fade-out transition, hide completely
    setTimeout(function() {
      if (!isOpen) {
        lightbox.setAttribute('hidden', '');
        document.body.style.overflow = '';
        imageEl.src = '';
        imageEl.alt = '';
      }
    }, 300);

    // Return focus to triggering element
    if (triggerElement) {
      triggerElement.focus();
    }
  }

  // -------------------------------------------------------------------------
  // Show image at index
  // -------------------------------------------------------------------------
  function showImage(index, animate) {
    if (index < 0 || index >= images.length) return;
    currentIndex = index;

    if (animate) {
      // Crossfade: fade out current, swap src, fade in
      imageEl.classList.add('lightbox__image--fading');
      setTimeout(function() {
        imageEl.src = images[currentIndex].src;
        imageEl.alt = images[currentIndex].alt;
        imageEl.classList.remove('lightbox__image--fading');
      }, 200);
    } else {
      imageEl.src = images[currentIndex].src;
      imageEl.alt = images[currentIndex].alt;
    }
  }

  // -------------------------------------------------------------------------
  // Navigation
  // -------------------------------------------------------------------------
  function showPrev() {
    var newIndex = (currentIndex - 1 + images.length) % images.length;
    showImage(newIndex, true);
  }

  function showNext() {
    var newIndex = (currentIndex + 1) % images.length;
    showImage(newIndex, true);
  }

  // -------------------------------------------------------------------------
  // Event handlers
  // -------------------------------------------------------------------------
  function onTriggerClick(e) {
    e.preventDefault();
    var index = parseInt(this.getAttribute('data-lightbox-index'), 10);
    open(index, this);
  }

  function onKeyDown(e) {
    if (!isOpen) return;

    switch (e.key) {
      case 'Escape':
        close();
        break;
      case 'ArrowLeft':
        showPrev();
        break;
      case 'ArrowRight':
        showNext();
        break;
      case 'Tab':
        trapFocus(e);
        break;
    }
  }

  // -------------------------------------------------------------------------
  // Focus trap
  // -------------------------------------------------------------------------
  function trapFocus(e) {
    var firstEl = focusableElements[0];
    var lastEl = focusableElements[focusableElements.length - 1];

    if (e.shiftKey) {
      // Shift+Tab — if on first element, wrap to last
      if (document.activeElement === firstEl) {
        e.preventDefault();
        lastEl.focus();
      }
    } else {
      // Tab — if on last element, wrap to first
      if (document.activeElement === lastEl) {
        e.preventDefault();
        firstEl.focus();
      }
    }
  }

  // -------------------------------------------------------------------------
  // Touch/pointer swipe detection
  // -------------------------------------------------------------------------
  function onPointerDown(e) {
    pointerStartX = e.clientX;
  }

  function onPointerUp(e) {
    pointerEndX = e.clientX;
    var diff = pointerEndX - pointerStartX;

    if (Math.abs(diff) >= SWIPE_THRESHOLD) {
      if (diff < 0) {
        showNext(); // swipe left → next
      } else {
        showPrev(); // swipe right → prev
      }
    }
  }

  // -------------------------------------------------------------------------
  // Button click handlers (only active while open via delegation check)
  // -------------------------------------------------------------------------
  closeBtn.addEventListener('click', function() {
    if (isOpen) close();
  });

  prevBtn.addEventListener('click', function(e) {
    e.stopPropagation();
    if (isOpen) showPrev();
  });

  nextBtn.addEventListener('click', function(e) {
    e.stopPropagation();
    if (isOpen) showNext();
  });

  // Close on backdrop click (not on image or controls)
  backdrop.addEventListener('click', function() {
    if (isOpen) close();
  });

  // -------------------------------------------------------------------------
  // Start
  // -------------------------------------------------------------------------
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
