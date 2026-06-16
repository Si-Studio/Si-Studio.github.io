// Contact form — validation and submission
// Requirement 7: Contact Page
(function() {
  'use strict';

  var form = document.getElementById('contact-form');
  if (!form) return;

  var fields = {
    name: {
      el: document.getElementById('contact-name'),
      errorEl: document.getElementById('contact-name-error'),
      required: true,
      validate: validateRequired,
      message: 'To pole jest wymagane'
    },
    email: {
      el: document.getElementById('contact-email'),
      errorEl: document.getElementById('contact-email-error'),
      required: true,
      validate: validateEmail,
      message: 'Podaj prawidłowy adres email'
    },
    phone: {
      el: document.getElementById('contact-phone'),
      errorEl: document.getElementById('contact-phone-error'),
      required: false,
      validate: null,
      message: ''
    },
    message: {
      el: document.getElementById('contact-message'),
      errorEl: document.getElementById('contact-message-error'),
      required: true,
      validate: validateRequired,
      message: 'To pole jest wymagane'
    }
  };

  var statusEl = document.getElementById('contact-form-status');

  /**
   * Validate that a value contains at least 1 non-whitespace character.
   * @param {string} value
   * @returns {boolean}
   */
  function validateRequired(value) {
    return /\S/.test(value);
  }

  /**
   * Validate email matches pattern: non-whitespace @ non-whitespace . non-whitespace
   * @param {string} value
   * @returns {boolean}
   */
  function validateEmail(value) {
    return /\S+@\S+\.\S+/.test(value);
  }

  /**
   * Show inline error for a field.
   * @param {object} field - field config object
   * @param {string} message - error message to display
   */
  function showError(field, message) {
    field.el.classList.add('contact-form__input--error');
    field.errorEl.textContent = message;
  }

  /**
   * Clear inline error for a field.
   * @param {object} field - field config object
   */
  function clearError(field) {
    field.el.classList.remove('contact-form__input--error');
    field.errorEl.textContent = '';
  }

  /**
   * Validate all fields. Returns true if all valid.
   * @returns {boolean}
   */
  function validateAll() {
    var valid = true;

    // Name
    if (!validateRequired(fields.name.el.value)) {
      showError(fields.name, fields.name.message);
      valid = false;
    } else {
      clearError(fields.name);
    }

    // Email — must be non-empty AND match pattern
    if (!validateRequired(fields.email.el.value)) {
      showError(fields.email, 'To pole jest wymagane');
      valid = false;
    } else if (!validateEmail(fields.email.el.value)) {
      showError(fields.email, fields.email.message);
      valid = false;
    } else {
      clearError(fields.email);
    }

    // Phone — optional, no validation needed
    clearError(fields.phone);

    // Message
    if (!validateRequired(fields.message.el.value)) {
      showError(fields.message, fields.message.message);
      valid = false;
    } else {
      clearError(fields.message);
    }

    return valid;
  }

  /**
   * Show status message (success or error).
   * @param {string} message
   * @param {string} type - 'success' or 'error'
   */
  function showStatus(message, type) {
    statusEl.textContent = message;
    statusEl.className = 'contact-form__status contact-form__status--' + type;
  }

  /**
   * Clear the status message.
   */
  function clearStatus() {
    statusEl.textContent = '';
    statusEl.className = 'contact-form__status';
  }

  /**
   * Clear all form fields.
   */
  function clearFields() {
    fields.name.el.value = '';
    fields.email.el.value = '';
    fields.phone.el.value = '';
    fields.message.el.value = '';
  }

  /**
   * Handle form submission.
   * @param {Event} e
   */
  function handleSubmit(e) {
    e.preventDefault();
    clearStatus();

    if (!validateAll()) {
      return;
    }

    // Check if form action is a Formspree or similar endpoint
    var action = form.getAttribute('action');
    var isMailto = action && action.indexOf('mailto:') === 0;

    if (isMailto) {
      // For mailto fallback, construct mailto link then show success
      var subject = encodeURIComponent('Zapytanie ze strony Si Studio');
      var body = encodeURIComponent(
        'Imię: ' + fields.name.el.value + '\n' +
        'Email: ' + fields.email.el.value + '\n' +
        'Telefon: ' + fields.phone.el.value + '\n\n' +
        fields.message.el.value
      );
      window.location.href = action + '?subject=' + subject + '&body=' + body;

      showStatus('Dziękujemy! Wiadomość została wysłana.', 'success');
      clearFields();
      return;
    }

    // For Formspree or other endpoints, use fetch
    var formData = new FormData(form);

    fetch(action, {
      method: 'POST',
      body: formData,
      headers: {
        'Accept': 'application/json'
      }
    })
    .then(function(response) {
      if (response.ok) {
        showStatus('Dziękujemy! Wiadomość została wysłana.', 'success');
        clearFields();
      } else {
        showStatus('Nie udało się wysłać wiadomości. Spróbuj ponownie później.', 'error');
      }
    })
    .catch(function() {
      showStatus('Nie udało się wysłać wiadomości. Spróbuj ponownie później.', 'error');
    });
  }

  // Bind submit handler
  form.addEventListener('submit', handleSubmit);

  // Clear field errors on input (provide immediate feedback)
  Object.keys(fields).forEach(function(key) {
    var field = fields[key];
    if (field.el) {
      field.el.addEventListener('input', function() {
        clearError(field);
        clearStatus();
      });
    }
  });
})();
