#!/usr/bin/env bun

const getProblemText = async() => {
  if (globalThis.document) {
    return document.body.textContent;
  }
  const filename = process.argv[1].replace(/.*(day\d+)[.]js/, '$1.txt');
  const file = Bun.file(filename);
  return file.text();
};

const inputLine = (await getProblemText()).trim();

const diskSeqState = [];

let id = 0;
let isSpace = false;
for (const char of inputLine) {
  if (isSpace) {
  diskSeqState.push(['x', Number(char)]);

  } else {
    diskSeqState.push([id, Number(char)]);
    id += 1;
  }
  isSpace = !isSpace;
}

let sum = 0n;
let cIdx = 0;
let rIdx = diskSeqState.length - 1;
let offset = 0;
while (cIdx < rIdx) {
  const [cId, cCount] = diskSeqState[cIdx];
  const [rId, rCount] = diskSeqState[rIdx];
  if (Number.isInteger(cId)) {
    sum += BigInt(cId * offset);
  } else {
    sum += BigInt(rId * offset);
    diskSeqState[rIdx] = [rId, rCount - 1];
  }
  diskSeqState[cIdx] = [cId, cCount - 1];

  while (diskSeqState.at(cIdx)?.at(-1) === 0) {
    cIdx += 1;
  }
  while (diskSeqState.at(rIdx)?.at(-1) === 0) {
    rIdx -= 2;
  }

  offset += 1;
}

const answer1 = sum;

// eslint-disable-next-line no-console
console.log('answer1', answer1);

const answer2 = '';


// eslint-disable-next-line no-console
console.log('answer2', answer2);
