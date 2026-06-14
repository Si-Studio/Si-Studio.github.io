/**
 * Property 7: Required Field Validation
 * Feature: premium-interior-design-website, Property 7: Required Field Validation
 *
 * Validates: Requirements 7.2
 *
 * For any string input, the required-field validator SHALL accept the input
 * if and only if it contains at least one character that is not a whitespace
 * character (space, tab, newline, carriage return). Empty strings and strings
 * composed entirely of whitespace SHALL be rejected.
 */

const fc = require('fast-check');

// Pure validation function extracted from assets/js/contact.js
function validateRequired(value) {
  return /\S/.test(value);
}

describe('Property 7: Required Field Validation', () => {
  // **Validates: Requirements 7.2**

  test('any string with at least one non-whitespace character returns true', () => {
    fc.assert(
      fc.property(
        fc.tuple(fc.string(), fc.string({ minLength: 1 }).filter(s => /\S/.test(s)), fc.string()).map(
          ([prefix, nonWs, suffix]) => prefix + nonWs + suffix
        ),
        (input) => {
          expect(validateRequired(input)).toBe(true);
        }
      ),
      { numRuns: 100 }
    );
  });

  test('empty string returns false', () => {
    expect(validateRequired('')).toBe(false);
  });

  test('string composed entirely of whitespace returns false', () => {
    fc.assert(
      fc.property(
        fc.array(fc.constantFrom(' ', '\t', '\n', '\r'), { minLength: 1, maxLength: 50 }).map(arr => arr.join('')),
        (input) => {
          expect(validateRequired(input)).toBe(false);
        }
      ),
      { numRuns: 100 }
    );
  });

  test('string with mixed whitespace and non-whitespace returns true', () => {
    fc.assert(
      fc.property(
        fc.tuple(
          fc.array(fc.constantFrom(' ', '\t', '\n', '\r'), { minLength: 0, maxLength: 10 }).map(arr => arr.join('')),
          fc.string({ minLength: 1 }).filter(s => /\S/.test(s)),
          fc.array(fc.constantFrom(' ', '\t', '\n', '\r'), { minLength: 0, maxLength: 10 }).map(arr => arr.join(''))
        ).map(([ws1, nonWs, ws2]) => ws1 + nonWs + ws2),
        (input) => {
          expect(validateRequired(input)).toBe(true);
        }
      ),
      { numRuns: 100 }
    );
  });

  test('validateRequired returns boolean for any arbitrary string', () => {
    fc.assert(
      fc.property(
        fc.string(),
        (input) => {
          const result = validateRequired(input);
          expect(typeof result).toBe('boolean');
          // The result must be true iff input contains at least one non-whitespace char
          expect(result).toBe(/\S/.test(input));
        }
      ),
      { numRuns: 100 }
    );
  });
});
