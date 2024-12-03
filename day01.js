#!/usr/bin/env bun

const getProblemText = async() => {
  if (globalThis.document) {
    return document.body.textContent;
  }
  const filename = process.argv[1].replace(/.*(day\d+)[.]js/, '$1.txt');
  const file = Bun.file(filename);
  return file.text();
};

const range = (high, low) => Array.from({ length: high - low}).map((_, i) => i + low);
const range0 = (high) => range(high, 0);

const lineWithLeftRight = (await getProblemText())
  .trim()
  .split('\n')
  .map((line) => {
    return line.split(/\s+/g).map(Number);
  });

const columnLeft = lineWithLeftRight.map(([left, _]) => left).toSorted((a, b) => a - b);
const columnRight = lineWithLeftRight.map(([_, right]) => right).toSorted((a, b) => a - b);


let a = 0;
for (const i of range0(columnLeft.length)) {
  a += Math.abs(columnLeft[i] - columnRight[i]);
}

// eslint-disable-next-line no-console
console.log('answer1', a);

const histogram = {};
for (const right of columnRight) {
  histogram[right] = (histogram[right] ?? 0) + 1;
}

let b = 0;
for (const left of columnLeft) {
  b += (histogram[left] ?? 0) * left;
}

// eslint-disable-next-line no-console
console.log('answer2', b);
