#!/usr/bin/env bun

const getProblemText = async() => {
  if (globalThis.document) {
    return document.body.textContent;
  }
  const filename = process.argv[1].replace(/.*(day\d+)[.]js/, '$1.txt');
  const file = Bun.file(filename);
  return file.text();
};

const sortByAsc = (a, b) => a - b;
const sortByDesc = (a, b) =>  b - a;
const abs = (a) => Math.abs(a);

const isSorted = (a) => String(a) === String(a.toSorted(sortByAsc)) || String(a) === String(a.toSorted(sortByDesc));

/** inclusive both side, lower <= n <= upper */
const inRange = (lower, upper) => (val) => lower <= val && val <= upper;
const in1to3 = inRange(1, 3);

const isStrictlyMonotone = (a) => a.every((_, i) => {
  if(i === 0) { return true; }
  return in1to3(abs(a[i - 1] - a[i]));
});

const answer1 = (await getProblemText())
  .trim()
  .split('\n')
  .map((line) => line.split(/\s+/g).map(Number))
  .filter((ns) => isSorted(ns) && isStrictlyMonotone(ns))
  .length;


// eslint-disable-next-line no-console
console.log('answer1', answer1);

const range = (high, low) => Array.from({ length: high - low}).map((_, i) => i + low);
const range0 = (high) => range(high, 0);

const isTolerable = (a) => {
  if(isSorted(a) && isStrictlyMonotone(a)) {return true;}

  for (const i of range0(a.length)) {
    const b = a.toSpliced(i, 1);
    if(isSorted(b) && isStrictlyMonotone(b)){return true;}
  }
  return false;
};

const answer2 = (await getProblemText())
  .trim()
  .split('\n')
  .map((line) => line.split(/\s+/g).map(Number))
  .filter(isTolerable)
  .length;

// eslint-disable-next-line no-console
console.log('answer2', answer2);
