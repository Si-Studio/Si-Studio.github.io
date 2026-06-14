// Image Fallback — graceful degradation for failed image loads
// Requirements: 10.4, 10.5
// When an <img> fails to load, hide it so the container's background-color
// placeholder remains visible and alt text is still accessible via the
// element's accessibility tree.
(function () {
  'use strict';

  function handleImageError(img) {
    // Make image invisible but keep its space (width/height prevent CLS)
    img.style.opacity = '0';
    img.classList.add('img--error');
  }

  // Handle images that have already errored before this script runs
  var images = document.querySelectorAll('img');
  for (var i = 0; i < images.length; i++) {
    if (images[i].complete && images[i].naturalWidth === 0 && images[i].src) {
      handleImageError(images[i]);
    }
  }

  // Listen for future errors (covers lazy-loaded images)
  document.addEventListener('error', function (e) {
    if (e.target && e.target.tagName === 'IMG') {
      handleImageError(e.target);
    }
  }, true);
})();
