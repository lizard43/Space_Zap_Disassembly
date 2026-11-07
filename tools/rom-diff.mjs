#!/usr/bin/env node
// Compare a newly assembled Space Zap ROM image against the original four ROMs.
import { readFileSync } from 'node:fs';

const [imagePath, ...originalPaths] = process.argv.slice(2);
if (!imagePath || originalPaths.length !== 4) {
  process.stderr.write('Usage: node tools/rom-diff.mjs <image.bin> <0662.01> <0663.xx> <0664.xx> <0665.xx>\n');
  process.exit(2);
}

const image = readFileSync(imagePath);
const original = Buffer.concat(originalPaths.map(p => readFileSync(p)));
const hex = (value, digits = 4) => value.toString(16).toUpperCase().padStart(digits, '0');
const first = Math.min(image.length, original.length);
let mismatchCount = 0;
const examples = [];
for (let address = 0; address < first; ++address) {
  if (image[address] === original[address]) continue;
  mismatchCount += 1;
  if (examples.length < 12) {
    examples.push({ address, actual: image[address], expected: original[address] });
  }
}

console.error('ROM comparison (hexadecimal)');
console.error('  Assembled : ' + image.length + ' bytes (0x' + hex(image.length) + ')');
console.error('  Original  : ' + original.length + ' bytes (0x' + hex(original.length) + ')');
console.error('  Difference: ' + (image.length - original.length) + ' bytes');
if (examples.length) {
  console.error('');
  console.error('  Address  Assembled  Original');
  for (const { address, actual, expected } of examples) {
    console.error('  $' + hex(address) + '      $' + hex(actual, 2) + '       $' + hex(expected, 2));
  }
  console.error('  Different bytes at aligned addresses: ' + mismatchCount);
  const address = examples[0].address;
  const low = Math.max(0, address - 8);
  const high = Math.min(first, address + 12);
  console.error('');
  console.error('  First mismatch context, $' + hex(low) + '-$' + hex(high - 1) + ':');
  console.error('  Assembled: ' + [...image.subarray(low, high)].map(x => hex(x, 2)).join(' '));
  console.error('  Original : ' + [...original.subarray(low, high)].map(x => hex(x, 2)).join(' '));
} else {
  console.error('  All overlapping bytes match.');
}
if (image.length !== original.length) {
  console.error('  Missing/extra bytes prevent a full aligned-image match.');
}
