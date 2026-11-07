#!/usr/bin/env node
// Check TERSE word naming in both directions: source -> dictionary -> token vectors.
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const read = (p) => readFileSync(resolve(root, p), 'utf8');
const source = read('Space_Zap_Disassembly.asm');
const dictionary = read('docs/TERSE-WORD-DICTIONARY.md');
const vectors = read('docs/TERSE-TOKEN-VECTORS.md');

// Actual native ROM vector assignments, not inferred from descriptive labels.
const words = [
  ['01', '2DUP'], ['03', 'ZERO_BRANCH'], ['04', 'SWAP'],
  ['05', 'DROP'], ['06', 'EXIT'], ['08', 'B!'], ['09', '1'],
  ['0B', '0'], ['0C', '@'], ['0D', 'DUP'], ['0E', 'LIT8'],
  ['0F', '+'], ['10', '!'], ['13', 'ROT'], ['14', '1+'],
  ['15', '1-'], ['16', 'BMOVE'], ['1B', 'LIT'], ['1C', 'ZERO'],
  ['1F', 'OUTP'], ['21', 'INP'], ['24', 'I'], ['25', 'B@'],
  ['3A', 'ARITH_SHIFT_RIGHT'], ['3D', 'INDEXED_DISPATCH'],
  ['3F', '-'], ['43', '1-B!'], ['44', '='], ['45', 'PICK'],
  ['46', 'BRANCH_ABSOLUTE'], ['4C', 'AND'], ['54', 'OR'],
  ['82', 'MINUS'], ['93', 'COMPARE_BRANCH_NE'],
  ['94', 'ADD_INLINE16'], ['C2', 'U>=']
];
assert.equal(words.length, 36);

const quickSection = dictionary.split('## Quick reference')[1]?.split('## Recovered words')[0];
assert.ok(quickSection, 'missing quick reference');
const quickRows = [...quickSection.matchAll(/^\| \[`([^`]+)`\]\(#[^)]+\) \|/gm)].map(m => m[1]);
assert.equal(quickRows.length, words.length, 'quick reference count differs from token inventory');

let sourceOccurrences = 0;
for (const [token, name] of words) {
  assert.ok(quickRows.includes(name), `word ${name} ($${token}) missing in quick reference`);
  // Punctuation is followed by a colon, so use the simpler exact row parser.
  const row = vectors.split('\n').find(line => line.startsWith('| `' + '$' + token + '` |'));
  assert.ok(row, `no vector row for $${token}`);
  const description = row.split('|')[3].trim();
  assert.ok(description.startsWith(name + ':'), `vector $${token}: expected ${name}, found ${description}`);
  const sourceVector = source.split('\n').find(line =>
    new RegExp(';\\s*token \\ Other
  // DB comments can describe inline operands or source/debug addresses.
  for (const line of source.split('\n')) {
    const m = line.match(/^\s*DB\s+\$([0-9A-F]{2})\s*;\s*(.+?)\s*$/i);
    if (!m || m[1].toUpperCase() !== token) continue;
    const annotation = m[2].trim();
    if (annotation === name || annotation === 'TERSE_' + name) sourceOccurrences++;
  }
}
const nativeMapping = [
  ['TERSE_LIT16','LIT'], ['TERSE_ZERO','0'], ['TERSE_ONE','1'],
  ['TERSE_FETCH','@'], ['TERSE_BYTE_FETCH','B@'], ['TERSE_STORE','!'],
  ['TERSE_BYTE_STORE','B!'], ['TERSE_ZERO_WORD_AT_ADDRESS','ZERO'],
  ['TERSE_ADD','+'], ['TERSE_SUBTRACT','-'], ['TERSE_DECREMENT','1-'],
  ['TERSE_INCREMENT','1+'], ['TERSE_BITWISE_AND','AND'],
  ['TERSE_BITWISE_OR','OR'], ['TERSE_LOOP_INDEX','I'],
  ['TERSE_PORT_OUT','OUTP'], ['TERSE_PORT_IN','INP'],
  ['TERSE_DECREMENT_BYTE_AT_ADDRESS','1-B!'], ['TERSE_EQUAL','='],
  ['TERSE_MEMORY_COPY','BMOVE'], ['TERSE_STACK_ROTATE','ROT'],
  ['TERSE_STACK_PICK','PICK'], ['TERSE_NEGATE','MINUS'],
  ['TERSE_UNSIGNED_GE','U>=']
];
for (const [symbol, name] of nativeMapping) {
  assert.ok(source.includes(`; DNA TERSE word: ${name} (assembler symbol: ${symbol})\n${symbol}:`),
    `missing source label correspondence for ${name} (${symbol})`);
}
console.log(`PASS: ${words.length} dictionary words agree with vector names and source token comments (${sourceOccurrences} occurrences).`);
console.log(`PASS: ${nativeMapping.length} native labels carry matching TERSE vocabulary annotations.`);
assert.ok(sourceOccurrences > 0, 'no named tokens found in source');
console.log('ROM SHA-1 validation remains mandatory via ./build.sh.');
 + token + ' — ').test(line));
  assert.ok(sourceVector, 'source vector missing token  Other
  // DB comments can describe inline operands or source/debug addresses.
  for (const line of source.split('\n')) {
    const m = line.match(/^\s*DB\s+\$([0-9A-F]{2})\s*;\s*(.+?)\s*$/i);
    if (!m || m[1].toUpperCase() !== token) continue;
    const annotation = m[2].trim();
    if (annotation === name || annotation === 'TERSE_' + name) sourceOccurrences++;
  }
}
const nativeMapping = [
  ['TERSE_LIT16','LIT'], ['TERSE_ZERO','0'], ['TERSE_ONE','1'],
  ['TERSE_FETCH','@'], ['TERSE_BYTE_FETCH','B@'], ['TERSE_STORE','!'],
  ['TERSE_BYTE_STORE','B!'], ['TERSE_ZERO_WORD_AT_ADDRESS','ZERO'],
  ['TERSE_ADD','+'], ['TERSE_SUBTRACT','-'], ['TERSE_DECREMENT','1-'],
  ['TERSE_INCREMENT','1+'], ['TERSE_BITWISE_AND','AND'],
  ['TERSE_BITWISE_OR','OR'], ['TERSE_LOOP_INDEX','I'],
  ['TERSE_PORT_OUT','OUTP'], ['TERSE_PORT_IN','INP'],
  ['TERSE_DECREMENT_BYTE_AT_ADDRESS','1-B!'], ['TERSE_EQUAL','='],
  ['TERSE_MEMORY_COPY','BMOVE'], ['TERSE_STACK_ROTATE','ROT'],
  ['TERSE_STACK_PICK','PICK'], ['TERSE_NEGATE','MINUS'],
  ['TERSE_UNSIGNED_GE','U>=']
];
for (const [symbol, name] of nativeMapping) {
  assert.ok(source.includes(`; DNA TERSE word: ${name} (assembler symbol: ${symbol})\n${symbol}:`),
    `missing source label correspondence for ${name} (${symbol})`);
}
console.log(`PASS: ${words.length} dictionary words agree with vector names and source token comments (${sourceOccurrences} occurrences).`);
console.log(`PASS: ${nativeMapping.length} native labels carry matching TERSE vocabulary annotations.`);
assert.ok(sourceOccurrences > 0, 'no named tokens found in source');
console.log('ROM SHA-1 validation remains mandatory via ./build.sh.');
 + token);
  assert.equal(sourceVector.split(' — ').pop().trim(), name,
    'source vector  Other
  // DB comments can describe inline operands or source/debug addresses.
  for (const line of source.split('\n')) {
    const m = line.match(/^\s*DB\s+\$([0-9A-F]{2})\s*;\s*(.+?)\s*$/i);
    if (!m || m[1].toUpperCase() !== token) continue;
    const annotation = m[2].trim();
    if (annotation === name || annotation === 'TERSE_' + name) sourceOccurrences++;
  }
}
const nativeMapping = [
  ['TERSE_LIT16','LIT'], ['TERSE_ZERO','0'], ['TERSE_ONE','1'],
  ['TERSE_FETCH','@'], ['TERSE_BYTE_FETCH','B@'], ['TERSE_STORE','!'],
  ['TERSE_BYTE_STORE','B!'], ['TERSE_ZERO_WORD_AT_ADDRESS','ZERO'],
  ['TERSE_ADD','+'], ['TERSE_SUBTRACT','-'], ['TERSE_DECREMENT','1-'],
  ['TERSE_INCREMENT','1+'], ['TERSE_BITWISE_AND','AND'],
  ['TERSE_BITWISE_OR','OR'], ['TERSE_LOOP_INDEX','I'],
  ['TERSE_PORT_OUT','OUTP'], ['TERSE_PORT_IN','INP'],
  ['TERSE_DECREMENT_BYTE_AT_ADDRESS','1-B!'], ['TERSE_EQUAL','='],
  ['TERSE_MEMORY_COPY','BMOVE'], ['TERSE_STACK_ROTATE','ROT'],
  ['TERSE_STACK_PICK','PICK'], ['TERSE_NEGATE','MINUS'],
  ['TERSE_UNSIGNED_GE','U>=']
];
for (const [symbol, name] of nativeMapping) {
  assert.ok(source.includes(`; DNA TERSE word: ${name} (assembler symbol: ${symbol})\n${symbol}:`),
    `missing source label correspondence for ${name} (${symbol})`);
}
console.log(`PASS: ${words.length} dictionary words agree with vector names and source token comments (${sourceOccurrences} occurrences).`);
console.log(`PASS: ${nativeMapping.length} native labels carry matching TERSE vocabulary annotations.`);
assert.ok(sourceOccurrences > 0, 'no named tokens found in source');
console.log('ROM SHA-1 validation remains mandatory via ./build.sh.');
 + token + ' differs from dictionary');
  // Only complete, named token comments are vocabulary annotations. Other
  // DB comments can describe inline operands or source/debug addresses.
  for (const line of source.split('\n')) {
    const m = line.match(/^\s*DB\s+\$([0-9A-F]{2})\s*;\s*(.+?)\s*$/i);
    if (!m || m[1].toUpperCase() !== token) continue;
    const annotation = m[2].trim();
    if (annotation === name || annotation === 'TERSE_' + name) sourceOccurrences++;
  }
}
const nativeMapping = [
  ['TERSE_LIT16','LIT'], ['TERSE_ZERO','0'], ['TERSE_ONE','1'],
  ['TERSE_FETCH','@'], ['TERSE_BYTE_FETCH','B@'], ['TERSE_STORE','!'],
  ['TERSE_BYTE_STORE','B!'], ['TERSE_ZERO_WORD_AT_ADDRESS','ZERO'],
  ['TERSE_ADD','+'], ['TERSE_SUBTRACT','-'], ['TERSE_DECREMENT','1-'],
  ['TERSE_INCREMENT','1+'], ['TERSE_BITWISE_AND','AND'],
  ['TERSE_BITWISE_OR','OR'], ['TERSE_LOOP_INDEX','I'],
  ['TERSE_PORT_OUT','OUTP'], ['TERSE_PORT_IN','INP'],
  ['TERSE_DECREMENT_BYTE_AT_ADDRESS','1-B!'], ['TERSE_EQUAL','='],
  ['TERSE_MEMORY_COPY','BMOVE'], ['TERSE_STACK_ROTATE','ROT'],
  ['TERSE_STACK_PICK','PICK'], ['TERSE_NEGATE','MINUS'],
  ['TERSE_UNSIGNED_GE','U>=']
];
for (const [symbol, name] of nativeMapping) {
  assert.ok(source.includes(`; DNA TERSE word: ${name} (assembler symbol: ${symbol})\n${symbol}:`),
    `missing source label correspondence for ${name} (${symbol})`);
}
console.log(`PASS: ${words.length} dictionary words agree with vector names and source token comments (${sourceOccurrences} occurrences).`);
console.log(`PASS: ${nativeMapping.length} native labels carry matching TERSE vocabulary annotations.`);
assert.ok(sourceOccurrences > 0, 'no named tokens found in source');
console.log('ROM SHA-1 validation remains mandatory via ./build.sh.');
