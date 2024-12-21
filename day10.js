#!/usr/bin/env bun

const getProblemText = async() => {
  if (globalThis.document) {
    return document.body.textContent;
  }
  const filename = process.argv[1].replace(/.*(day\d+)[.]js/, '$1.txt');
  const file = Bun.file(filename);
  return file.text();
};

const sum = (...args) => args.flat(Infinity).reduce((a, b) => a + b, 0);

const inputMap = (await getProblemText())
  .trim()
  .split('\n')
  .map((line) => line.split('').map(Number));

const flattenMap = inputMap.flatMap((row, r) => row.map((h, c) => `${r},${c},${h}`));

const findNeighbors = (point, flattenMap) => {
  const [r, c, h] = point.split(',').map(Number);
  const nps = [
    `${r - 1},${c},${h + 1}`,
    `${r + 1},${c},${h + 1}`,
    `${r},${c - 1},${h + 1}`,
    `${r},${c + 1},${h + 1}`,
  ];
  const result = nps.filter((np) => flattenMap.includes(np));
  return result;
};

const startpoints = flattenMap.filter((startPoint) => /0$/.test(startPoint));
const scores = startpoints.map((startPoint) => {
  const queue = [startPoint];
  const uniqTailSet = new Set();
  while (queue.length) {
    const point = queue.shift();
    const neighbors = findNeighbors(point, flattenMap);
    queue.push(...neighbors);
    for (const neighbor of neighbors) {
      if (/9$/.test(neighbor)) {
        uniqTailSet.add(neighbor);
      }
    }
  }
  return uniqTailSet.size;
});

const answer1 = sum(scores);

// eslint-disable-next-line no-console
console.log('answer1', answer1);

const answer2 = '';

// eslint-disable-next-line no-console
console.log('answer2', answer2);
