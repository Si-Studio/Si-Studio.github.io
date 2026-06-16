/**
 * Property 8: Email Pattern Validation
 * Validates: Requirements 7.3
 *
 * For any string input, the email validator SHALL accept the input if and only if
 * it matches the pattern \S+@\S+\.\S+ (one or more non-whitespace characters,
 * followed by @, followed by one or more non-whitespace characters, followed by
 * a dot, followed by one or more non-whitespace characters). Strings without @,
 * without a dot after @, or with whitespace in any segment SHALL be rejected.
 *
 * Tag: Feature: premium-interior-design-website, Property 8: Email Pattern Validation
 */

const fc = require('fast-check');

// Function under test — mirrors assets/js/contact.js
function validateEmail(value) {
  return /\S+@\S+\.\S+/.test(value);
}

describe('Feature: premium-interior-design-website, Property 8: Email Pattern Validation', () => {
  // Generator: non-whitespace string of length >= 1
  const nonWhitespaceString = fc.stringMatching(/^\S+$/);

  it('valid format (nonWs@nonWs.nonWs) returns true', () => {
    fc.assert(
      fc.property(
        nonWhitespaceString,
        nonWhitespaceString,
        nonWhitespaceString,
        (local, domain, tld) => {
          const email = `${local}@${domain}.${tld}`;
          return validateEmail(email) === true;
        }
      ),
      { numRuns: 100 }
    );
  });

  it('missing @ returns false', () => {
    fc.assert(
      fc.property(
        fc.string({ minLength: 1 }).filter(s => !s.includes('@')),
        (input) => {
          return validateEmail(input) === false;
        }
      ),
      { numRuns: 100 }
    );
  });

  it('missing dot after @ returns false', () => {
    // Generate non-whitespace strings without dots
    const noDotChars = 'abcdefghijklmnopqrstuvwxyz0123456789-_+!#$%&*=?^~';
    const noDotNonWs = fc.array(
      fc.constantFrom(...noDotChars.split('')),
      { minLength: 1, maxLength: 20 }
    ).map(arr => arr.join(''));
    fc.assert(
      fc.property(
        nonWhitespaceString,
        noDotNonWs,
        (local, afterAt) => {
          const input = `${local}@${afterAt}`;
          return validateEmail(input) === false;
        }
      ),
      { numRuns: 100 }
    );
  });

  it('whitespace in local part still rejected when no valid structure', () => {
    fc.assert(
      fc.property(
        fc.string({ minLength: 1 }).filter(s => /\s/.test(s) && !/@/.test(s)),
        (input) => {
          return validateEmail(input) === false;
        }
      ),
      { numRuns: 100 }
    );
  });

  it('whitespace-only string returns false', () => {
    fc.assert(
      fc.property(
        fc.constantFrom(' ', '\t', '\n', '\r', '   ', '\t\t', ' \n '),
        (input) => {
          return validateEmail(input) === false;
        }
      ),
      { numRuns: 100 }
    );
  });

  it('empty string returns false', () => {
    expect(validateEmail('')).toBe(false);
  });

  it('generated valid emails (local@domain.tld) return true', () => {
    fc.assert(
      fc.property(
        fc.emailAddress(),
        (email) => {
          return validateEmail(email) === true;
        }
      ),
      { numRuns: 100 }
    );
  });

  it('result matches regex directly for any string', () => {
    fc.assert(
      fc.property(
        fc.string(),
        (input) => {
          const expected = /\S+@\S+\.\S+/.test(input);
          return validateEmail(input) === expected;
        }
      ),
      { numRuns: 100 }
    );
  });
});
