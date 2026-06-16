// Parallax - hero background parallax effect + text reveal + slideshow
(function () {
  'use strict';

  var hero = document.querySelector('.hero');
  if (!hero) return;

  var reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  // --- Slideshow: cycle between hero slides ---
  var slides = hero.querySelectorAll('.hero__slide');
  var currentSlide = 0;
  var SLIDE_INTERVAL = 5000; // 5 seconds per slide

  if (slides.length > 1) {
    setInterval(function () {
      slides[currentSlide].classList.remove('hero__slide--active');
      currentSlide = (currentSlide + 1) % slides.length;
      slides[currentSlide].classList.add('hero__slide--active');
    }, SLIDE_INTERVAL);
  }

  // --- Text reveal on si:page-ready ---
  function revealText() {
    hero.classList.add('hero--revealed');
  }

  document.addEventListener('si:page-ready', revealText);

  // --- Parallax scrolling on the active slide ---
  if (reducedMotion || slides.length === 0) return;

  var parallaxRate = 0.4;
  var ticking = false;
  var lastScrollY = 0;
  var heroHeight = hero.offsetHeight;

  function updateParallax() {
    if (lastScrollY <= heroHeight) {
      var offset = lastScrollY * parallaxRate;
      // Apply parallax to all slides (only visible one matters)
      for (var i = 0; i < slides.length; i++) {
        slides[i].style.transform = 'translate3d(0, ' + offset + 'px, 0)';
      }
    }
    ticking = false;
  }

  function onScroll() {
    lastScrollY = window.pageYOffset || document.documentElement.scrollTop;
    if (!ticking) {
      ticking = true;
      requestAnimationFrame(updateParallax);
    }
  }

  window.addEventListener('scroll', onScroll, { passive: true });
  window.addEventListener('resize', function () {
    heroHeight = hero.offsetHeight;
  });

  onScroll();
})();
