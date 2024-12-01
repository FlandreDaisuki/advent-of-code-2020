#!/usr/bin/env node

const getProblemText = async () => {
  if (globalThis.document) {
    return document.body.textContent;
  }
  const process = await import('node:process');
  const fs = await import('node:fs/promises');
  const filename = process.argv[1].replace(/.*(day\d+)[.]js/, '$1.txt');
  return fs.readFile(filename, 'utf8');
};

/** @param {string} text */
const splitLines = (text, separator = '\n') => text.split(separator)
  .map((line) => line.trim())
  .filter(Boolean);

/** @param {number[]} arr */
const sum = (arr) => Array.from(arr).reduce((a, b) => a + b, 0);

const schematic = await getProblemText();

const lines = splitLines(schematic);

const digitPositions = lines.flatMap((line, r) => {
  return [...line.matchAll(/\d+/g)].map((matched) => ({ digits: matched[0], c: matched.index, r }));
});

const getNeighbors = ({ digits, r, c }) => {
  const dl = digits.length;
  const neighbors = [];
  for (let ri = r - 1; ri <= r + 1; ri += 1) {
    if (ri < 0 || ri > lines.length) { continue; } // boundary
    for (let ci = c - 1; ci <= c + dl; ci += 1) {
      if (ci < 0 || ci > lines[0].length) { continue; } // boundary
      if (ri === r && ci >= c && ci < c + dl) { continue; } // word
      neighbors.push({ r: ri, c: ci });
    }
  }
  return neighbors;
};

const isSymbol = (c) => /[^\d\.]/.test(c ?? '');

const partNumbers = digitPositions.filter((dp) => getNeighbors(dp).some((n) => isSymbol(lines[n.r]?.[n.c])));

const answer1 = sum(partNumbers.map((pn) => Number(pn.digits)));

console.log('answer1', answer1);

const gearPositions = lines.flatMap((line, r) => {
  return [...line.matchAll(/[*]/g)].map((matched) => ({ c: matched.index, r }));
});

const foundGearNeighborPairNumbers = gearPositions.map((gp) => {
  const gearPositionNeighborDigits = getNeighbors({ digits: '*', ...gp })
    .map((gpn) => ({ digit: lines[gpn.r]?.[gpn.c], ...gpn }))
    .filter((dp) => dp.digit && Number.isInteger(Number(dp.digit)))
    .map((dp) => partNumbers.find((pn) => dp.r === pn.r && dp.c >= pn.c && dp.c < pn.c + pn.digits.length))
    .filter(Boolean)
    .map((dp) => Number(dp.digits));

  const pairNumbers = Array.from(new Set(gearPositionNeighborDigits));
  return pairNumbers.length > 1 ? pairNumbers : null;
}).filter(Boolean);

const answer2 = sum(foundGearNeighborPairNumbers.map((p) => p[0] * p[1]));

console.log('answer2', answer2);
